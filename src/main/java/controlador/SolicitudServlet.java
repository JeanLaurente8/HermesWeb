package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class SolicitudServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        String accion = request.getParameter("accion");
        SolicitudDAO dao = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("solicitudes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("areas", areaDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                request.setAttribute("solicitudEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("solicitudes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("areas", areaDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("SolicitudServlet?accion=listar");
            }
        } finally {
            dao.close();
            empDAO.close();
            areaDAO.close();
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
        SolicitudDAO dao = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();

        try {
            String idEmp = request.getParameter("idEmpleado");
            String idArea = request.getParameter("idArea");
            String descripcion = request.getParameter("descripcion");

            // Validación estricta del backend
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {
                if (idEmp == null || idEmp.trim().isEmpty() || idArea == null || idArea.trim().isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, areaDAO, accion, "Error: Debe seleccionar tanto el empleado solicitante como el área de procedencia.");
                    return;
                }

                if (descripcion == null || descripcion.trim().isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, areaDAO, accion, "Error: La descripción de la solicitud no puede estar vacía.");
                    return;
                }
            }

            Solicitud s;
            if ("actualizar".equals(accion)) {
                s = dao.buscar(Integer.parseInt(request.getParameter("idSolicitud")));
                // Si es una actualización, permitimos que el estado cambie según lo enviado en el select
                s.setEstadoSolicitud(request.getParameter("estadoSolicitud"));
            } else {
                s = new Solicitud();
                s.setEstadoSolicitud("Pendiente");
            }

            s.setDescripcion(descripcion.trim());
            s.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
            s.setArea(areaDAO.buscar(Integer.parseInt(idArea)));

            if ("actualizar".equals(accion)) {
                dao.actualizar(s);
            } else {
                dao.guardar(s);
            }

            response.sendRedirect("SolicitudServlet?accion=listar");

        } finally {
            dao.close();
            empDAO.close();
            areaDAO.close();
        }
    }

    // Método auxiliar para manejo de errores
    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, SolicitudDAO dao, EmpleadoDAO empDAO, AreaTrabajoDAO areaDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("solicitudes", dao.listar());
        request.setAttribute("empleados", empDAO.listar());
        request.setAttribute("areas", areaDAO.listarActivos());

        if (accion.equals("actualizar")) {
            Solicitud s = dao.buscar(Integer.parseInt(request.getParameter("idSolicitud")));
            request.setAttribute("solicitudEditar", s);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);
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