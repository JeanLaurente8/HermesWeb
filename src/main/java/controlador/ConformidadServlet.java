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

        try {
            // Validaciones Estrictas Backend
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {
                String comentarios = request.getParameter("comentarios");
                String idSolStr = request.getParameter("idSolicitud");

                // Validar Regex de comentarios (si el usuario ingresó algo)
                if (comentarios != null && !comentarios.trim().isEmpty()) {
                    if (!comentarios.matches("^[a-zA-ZÁ-ÿ0-9\\s\\-]*$")) {
                        enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, "Error: Los comentarios tienen formato inválido. Solo se admiten letras, números, espacios y guiones.");
                        return;
                    }
                }

                // Validar que no haya otra conformidad para la misma solicitud (evita duplicados)
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
                        enviarErrorYRetornar(request, response, dao, solDAO, empDAO, accion, "Error: Ya existe una conformidad registrada para la Solicitud #" + idSol + ". Por favor, edite el registro existente en su lugar.");
                        return;
                    }
                }
            }

            Conformidad c;
            if ("actualizar".equals(accion)) {
                c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
            } else {
                c = new Conformidad();
            }

            c.setFirmaConformidad("on".equals(request.getParameter("firmaConformidad")));
            c.setComentarios(request.getParameter("comentarios") != null ? request.getParameter("comentarios").trim() : "");

            String idSol = request.getParameter("idSolicitud");
            if (idSol != null && !idSol.isEmpty()) {
                c.setSolicitud(solDAO.buscar(Integer.parseInt(idSol)));
            }

            String idEmp = request.getParameter("idEmpleado");
            if (idEmp != null && !idEmp.isEmpty()) {
                c.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
            }

            if ("actualizar".equals(accion)) {
                dao.actualizar(c);
            } else {
                dao.guardar(c);
            }

            response.sendRedirect("ConformidadServlet?accion=listar");

        } finally {
            dao.close();
            solDAO.close();
            empDAO.close();
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