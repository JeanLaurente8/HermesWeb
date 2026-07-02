package controlador;

import modelo.*;
import util.AuthUtils;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class SolicitudServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;

        String accion = request.getParameter("accion");
        SolicitudDAO dao = new SolicitudDAO();
        ArticuloDAO artDAO = new ArticuloDAO();
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");

        try {
            if (accion == null || accion.equals("listar")) {
                if (esEmpleado(sesion)) {
                    request.setAttribute("solicitudes", dao.listarPorEmpleado(sesion.getIdEmpleado()));
                } else {
                    request.setAttribute("solicitudes", dao.listar());
                }
                request.setAttribute("articulos", artDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);

            } else if (accion.equals("aprobar")) {
                if (!AuthUtils.puedeGestionarSolicitudes(sesion)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                int id = Integer.parseInt(request.getParameter("id"));
                dao.cambiarEstado(id, "Aprobada", null);
                response.sendRedirect("SolicitudServlet?accion=listar");

            } else if (accion.equals("rechazar")) {
                response.sendRedirect("SolicitudServlet?accion=listar");
            }
        } finally {
            dao.close();
            artDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        SolicitudDAO dao = new SolicitudDAO();
        ArticuloDAO artDAO = new ArticuloDAO();
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");

        try {
            // RECHAZAR CON MOTIVO
            if ("rechazar".equals(accion)) {
                if (!AuthUtils.puedeGestionarSolicitudes(sesion)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                String motivo = request.getParameter("motivoRechazo");
                if (motivo == null || motivo.trim().isEmpty()) {
                    request.setAttribute("error", "Debe ingresar el motivo del rechazo.");
                    cargarListado(request, dao, artDAO, sesion);
                    request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);
                    return;
                }
                int id = Integer.parseInt(request.getParameter("idSolicitud"));
                dao.cambiarEstado(id, "Rechazada", motivo.trim());
                response.sendRedirect("SolicitudServlet?accion=listar");
                return;
            }

            // GUARDAR NUEVA SOLICITUD (MAESTRO-DETALLE)
            if ("guardar".equals(accion)) {
                String descripcion = request.getParameter("descripcion");

                // Validaciones
                if (descripcion == null || descripcion.trim().isEmpty()) {
                    request.setAttribute("error", "La descripción es obligatoria.");
                    cargarListado(request, dao, artDAO, sesion);
                    request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);
                    return;
                }

                // Leer arrays de artículos y cantidades (maestro-detalle)
                String[] idArticulos  = request.getParameterValues("idArticulo[]");
                String[] cantidades   = request.getParameterValues("cantidad[]");

                if (idArticulos == null || idArticulos.length == 0) {
                    request.setAttribute("error", "Debe agregar al menos un artículo a la solicitud.");
                    cargarListado(request, dao, artDAO, sesion);
                    request.getRequestDispatcher("/WEB-INF/vistas/solicitud.jsp").forward(request, response);
                    return;
                }

                // El empleado y área se toman de la sesión (bloqueados en la vista)
                Empleado empSesion = (Empleado) request.getSession().getAttribute("empleado");

                // Crear una solicitud por cada línea del detalle
                for (int i = 0; i < idArticulos.length; i++) {
                    String idArt = idArticulos[i];
                    String cant  = (cantidades != null && i < cantidades.length) ? cantidades[i] : "1";

                    if (idArt == null || idArt.trim().isEmpty()) continue;

                    int cantidad = 1;
                    try { cantidad = Integer.parseInt(cant); } catch (NumberFormatException ex) {}
                    if (cantidad < 1) cantidad = 1;

                    Solicitud s = new Solicitud();
                    s.setDescripcion(descripcion.trim());
                    s.setEstadoSolicitud("Pendiente");
                    s.setEmpleado(empSesion);
                    s.setArea(empSesion.getArea());
                    s.setArticulo(artDAO.buscar(Integer.parseInt(idArt)));
                    s.setCantidad(cantidad);
                    dao.guardar(s);
                }

                response.sendRedirect("SolicitudServlet?accion=listar");
            }

        } finally {
            dao.close();
            artDAO.close();
        }
    }

    // Carga el listado según el rol del empleado
    private void cargarListado(HttpServletRequest request, SolicitudDAO dao,
                                ArticuloDAO artDAO, Empleado sesion) {
        if (esEmpleado(sesion)) {
            request.setAttribute("solicitudes", dao.listarPorEmpleado(sesion.getIdEmpleado()));
        } else {
            request.setAttribute("solicitudes", dao.listar());
        }
        request.setAttribute("articulos", artDAO.listar());
    }

    private boolean esEmpleado(Empleado sesion) {
        if (sesion == null) return false;
        String cargo = sesion.getCargo() != null ? sesion.getCargo() : "";
        return cargo.equalsIgnoreCase("Empleado");
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}
