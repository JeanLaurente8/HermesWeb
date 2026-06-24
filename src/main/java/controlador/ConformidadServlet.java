package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class ConformidadServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        String accion = request.getParameter("accion");
        ConformidadDAO dao = new ConformidadDAO();
        SolicitudDAO solDAO = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("conformidades", dao.listar());
                request.setAttribute("solicitudes", solDAO.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                request.setAttribute("conformidadEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("conformidades", dao.listar());
                request.setAttribute("solicitudes", solDAO.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("ConformidadServlet?accion=listar");
            }
        } finally {
            dao.close();
            solDAO.close();
            empDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ConformidadDAO dao = new ConformidadDAO();
        SolicitudDAO solDAO = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        ArticuloDAO artDAO = new ArticuloDAO();

        try {
            // Validaciones Estrictas Backend
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {
                String comentarios = request.getParameter("comentarios");
                String idSolStr = request.getParameter("idSolicitud");

                if (comentarios != null && !comentarios.trim().isEmpty()) {
                    if (!comentarios.matches("^[a-zA-ZÁ-ÿ0-9\\s\\-]*$")) {
                        enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, "Error: Los comentarios tienen formato inválido.");
                        return;
                    }
                }

                if (idSolStr != null && !idSolStr.isEmpty()) {
                    int idSol = Integer.parseInt(idSolStr);
                    boolean esDuplicado = false;
                    List<Conformidad> listaExistentes = dao.listar();

                    for (Conformidad c : listaExistentes) {
                        if (c.getSolicitud() != null && c.getSolicitud().getIdSolicitud() == idSol) {
                            if (accion.equals("guardar")) {
                                esDuplicado = true;
                                break;
                            } else if (accion.equals("actualizar")) {
                                int idActual = Integer.parseInt(request.getParameter("idConformidad"));
                                if (c.getIdConformidad() != idActual) {
                                    esDuplicado = true;
                                    break;
                                }
                            }
                        }
                    }

                    if (esDuplicado) {
                        enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, "Error: Ya existe una conformidad registrada para la Solicitud #" + idSol + ".");
                        return;
                    }
                }
            }

            // LÓGICA DE CONTROL DE STOCK
            Conformidad c;
            boolean descontarStock = false;
            boolean devolverStock = false;
            boolean esConformeNuevo = "on".equals(request.getParameter("firmaConformidad"));

            if ("actualizar".equals(accion)) {
                c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
                boolean eraConforme = c.isFirmaConformidad();

                // Si antes no estaba firmado y ahora sí -> Descontar
                if (!eraConforme && esConformeNuevo) {
                    descontarStock = true;
                }
                // Si antes estaba firmado y ahora se le quita la firma (rechazado) -> Devolver
                if (eraConforme && !esConformeNuevo) {
                    devolverStock = true;
                }

            } else {
                c = new Conformidad();
                // Si es nuevo y nace firmado -> Descontar
                if (esConformeNuevo) {
                    descontarStock = true;
                }
            }

            c.setFirmaConformidad(esConformeNuevo);
            c.setComentarios(request.getParameter("comentarios") != null ? request.getParameter("comentarios").trim() : "");

            String idSol = request.getParameter("idSolicitud");
            if (idSol != null && !idSol.isEmpty()) {
                c.setSolicitud(solDAO.buscar(Integer.parseInt(idSol)));
            }

            String idEmp = request.getParameter("idEmpleado");
            if (idEmp != null && !idEmp.isEmpty()) {
                c.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
            }

            // VALIDACIÓN: CONTROL DE STOCK INSUFICIENTE
            if (descontarStock && c.getSolicitud() != null && c.getSolicitud().getArticulo() != null) {
                // Buscamos el artículo para verificar su stock real actual
                Articulo articuloVerificar = artDAO.buscar(c.getSolicitud().getArticulo().getIdArticulo());
                int stockDisponible = articuloVerificar.getStock();
                int cantidadRequerida = c.getSolicitud().getCantidad();

                // Si no hay suficiente stock en almacén, rebotamos la operación
                if (stockDisponible < cantidadRequerida) {
                    String mensajeError = "Error: No se puede procesar la conformidad. El stock actual de '"
                            + articuloVerificar.getNombre() + "' es de " + stockDisponible
                            + " unidades, pero la solicitud requiere " + cantidadRequerida + ".";

                    enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, mensajeError);
                    return; // Detiene la ejecución por completo para que no guarde nada
                }
            }
            
            // Si pasa la validación, recién procedemos a guardar en la base de datos
            if ("actualizar".equals(accion)) {
                dao.actualizar(c);
            } else {
                dao.guardar(c);
            }
            // EJECUTAMOS EL MOVIMIENTO DE STOCK Y CAMBIO DE ESTADO
            if (c.getSolicitud() != null) {
                if (descontarStock || devolverStock) {
                    if (c.getSolicitud().getArticulo() != null) {
                        int idArticuloVinc = c.getSolicitud().getArticulo().getIdArticulo();
                        Articulo articuloDB = artDAO.buscar(idArticuloVinc);
                        int cantidadMovimiento = c.getSolicitud().getCantidad();
                        int stockActual = articuloDB.getStock();

                        if (descontarStock) {
                            articuloDB.setStock(stockActual - cantidadMovimiento);
                        } else if (devolverStock) {
                            articuloDB.setStock(stockActual + cantidadMovimiento);
                        }
                        artDAO.actualizar(articuloDB);
                    }

                    Solicitud sol = c.getSolicitud();
                    if (descontarStock) {
                        sol.setEstadoSolicitud("Entregada");
                    } else if (devolverStock) {
                        sol.setEstadoSolicitud("Pendiente");
                    }
                    solDAO.actualizar(sol);
                }
            }

            response.sendRedirect("ConformidadServlet?accion=listar");
            
           
        } finally {
            dao.close();
            solDAO.close();
            empDAO.close();
            artDAO.close();
        }
    }
    
    // Método auxiliar para manejo de errores
    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, ConformidadDAO dao, SolicitudDAO solDAO, EmpleadoDAO empDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("conformidades", dao.listar());
        request.setAttribute("solicitudes", solDAO.listar());
        request.setAttribute("empleados", empDAO.listar());

        if (accion.equals("actualizar")) {
            Conformidad c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
            request.setAttribute("conformidadEditar", c);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) {
            res.sendRedirect("LoginServlet");
            return false;
        }
        return true;
    }
}