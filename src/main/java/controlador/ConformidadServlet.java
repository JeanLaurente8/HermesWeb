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
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");

        try {
            if (accion == null || accion.equals("listar")) {
                cargarListado(request, dao, solDAO, empDAO, sesion);
                request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                // Bloqueo para Empleado y Asistente Almacén
                if (esEmpleado(sesion) || esAsistenteAlmacen(sesion)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                request.setAttribute("conformidadEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                cargarListado(request, dao, solDAO, empDAO, sesion);
                request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                // Bloqueo para Empleado y Asistente Almacén
                if (esEmpleado(sesion) || esAsistenteAlmacen(sesion)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
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
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");

        try {
            // Bloqueo total de POST para Asistente Almacén
            if (esAsistenteAlmacen(sesion)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            if ("actualizar".equals(accion) && esEmpleado(sesion)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

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

            Conformidad c;
            boolean descontarStock = false;
            boolean devolverStock = false;
            boolean esConformeNuevo = "on".equals(request.getParameter("firmaConformidad"));

            if ("actualizar".equals(accion)) {
                c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
                boolean eraConforme = c.isFirmaConformidad();

                if (!eraConforme && esConformeNuevo) descontarStock = true;
                if (eraConforme && !esConformeNuevo) devolverStock = true;

            } else {
                c = new Conformidad();
                if (esConformeNuevo) descontarStock = true;
            }

            c.setFirmaConformidad(esConformeNuevo);
            c.setComentarios(request.getParameter("comentarios") != null ? request.getParameter("comentarios").trim() : "");

            String idSol = request.getParameter("idSolicitud");
            if (idSol != null && !idSol.isEmpty()) {
                Solicitud solicitud = solDAO.buscar(Integer.parseInt(idSol));
                if (esEmpleado(sesion) && !esSolicitudDelEmpleado(solicitud, sesion)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                c.setSolicitud(solicitud);
            }

            if (esEmpleado(sesion)) {
                c.setEmpleado(sesion);
            } else {
                String idEmp = request.getParameter("idEmpleado");
                if (idEmp != null && !idEmp.isEmpty()) {
                    c.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
                }
            }

            if (descontarStock && c.getSolicitud() != null && c.getSolicitud().getArticulo() != null) {
                Articulo articuloVerificar = artDAO.buscar(c.getSolicitud().getArticulo().getIdArticulo());
                int stockDisponible = articuloVerificar.getStock();
                int cantidadRequerida = c.getSolicitud().getCantidad();

                if (stockDisponible < cantidadRequerida) {
                    String mensajeError = "Error: No se puede procesar la conformidad. El stock actual de '"
                            + articuloVerificar.getNombre() + "' es de " + stockDisponible
                            + " unidades, pero la solicitud requiere " + cantidadRequerida + ".";

                    enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, mensajeError);
                    return;
                }
            }
            
            if ("actualizar".equals(accion)) {
                dao.actualizar(c);
            } else {
                dao.guardar(c);
            }

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
    
    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, ConformidadDAO dao, SolicitudDAO solDAO, EmpleadoDAO empDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");
        cargarListado(request, dao, solDAO, empDAO, sesion);

        if (accion.equals("actualizar")) {
            Conformidad c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
            request.setAttribute("conformidadEditar", c);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/conformidad.jsp").forward(request, response);
    }

    private void cargarListado(HttpServletRequest request, ConformidadDAO dao, SolicitudDAO solDAO, EmpleadoDAO empDAO, Empleado sesion) {
        if (esEmpleado(sesion)) {
            request.setAttribute("conformidades", dao.listarPorEmpleado(sesion.getIdEmpleado()));
            request.setAttribute("solicitudes", solDAO.listarPorEmpleado(sesion.getIdEmpleado()));
        } else {
            request.setAttribute("conformidades", dao.listar());
            request.setAttribute("solicitudes", solDAO.listar());
        }
        request.setAttribute("empleados", empDAO.listar());
    }

    private boolean esEmpleado(Empleado sesion) {
        if (sesion == null) return false;
        String cargo = sesion.getCargo() != null ? sesion.getCargo() : "";
        return cargo.equalsIgnoreCase("Empleado");
    }

    private boolean esAsistenteAlmacen(Empleado sesion) {
        if (sesion == null) return false;
        String cargo = sesion.getCargo() != null ? sesion.getCargo() : "";
        return cargo.equalsIgnoreCase("Asistente Almacén") || cargo.equalsIgnoreCase("Asistente Almacen");
    }

    private boolean esSolicitudDelEmpleado(Solicitud solicitud, Empleado empleado) {
        return solicitud != null
            && solicitud.getEmpleado() != null
            && empleado != null
            && solicitud.getEmpleado().getIdEmpleado() == empleado.getIdEmpleado();
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