package controlador;

import modelo.*;
import util.AuthUtils;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DevolucionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!verificarSesion(request, response)) {
            return;
        }

        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");
        if (!AuthUtils.tieneAccesoCompleto(sesion, "Devolucion")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        DevolucionDAO devDAO = new DevolucionDAO();
        SolicitudDAO solDAO = new SolicitudDAO();

        try {
            String accion = request.getParameter("accion");

            if ("aprobar".equals(accion)) {
                int idDevolucion = Integer.parseInt(request.getParameter("id"));
                devDAO.aprobar(idDevolucion);
                response.sendRedirect(request.getContextPath() + "/DevolucionServlet");
                return;
            }

            List<Solicitud> todas = solDAO.listar();

            todas.removeIf(s -> !"Entregada".equals(s.getEstadoSolicitud()));

            Map<Integer, Integer> pendientes = new HashMap<>();
            List<Solicitud> candidatas = new ArrayList<>();
            for (Solicitud s : todas) {
                int yaDevuelto = devDAO.sumaDevueltaPorSolicitud(s.getIdSolicitud());
                int pendiente = s.getCantidad() - yaDevuelto;
                if (pendiente > 0) {
                    pendientes.put(s.getIdSolicitud(), pendiente);
                    candidatas.add(s);
                }
            }

            request.setAttribute("solicitudes", candidatas);
            request.setAttribute("pendientes", pendientes);
            request.setAttribute("devoluciones", devDAO.listar());
            request.getRequestDispatcher("/WEB-INF/vistas/devolucion.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error procesando la solicitud.");
            request.getRequestDispatcher("/WEB-INF/vistas/devolucion.jsp").forward(request, response);
        } finally {
            solDAO.close();
            devDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!verificarSesion(request, response)) {
            return;
        }
        request.setCharacterEncoding("UTF-8");

        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");
        if (!AuthUtils.tieneAccesoCompleto(sesion, "Devolucion")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        SolicitudDAO solDAO = new SolicitudDAO();
        DevolucionDAO devDAO = new DevolucionDAO();

        try {
            int idSolicitud = Integer.parseInt(request.getParameter("idSolicitud"));
            int cantidadDevuelta = Integer.parseInt(request.getParameter("cantidadDevuelta"));
            String motivo = request.getParameter("motivo");

            Solicitud s = solDAO.buscar(idSolicitud);
            if (s == null) {
                request.setAttribute("error", "La solicitud seleccionada no existe.");
                doGet(request, response);
                return;
            }

            int yaDevuelto = devDAO.sumaDevueltaPorSolicitud(idSolicitud);
            int disponibleParaDevolver = s.getCantidad() - yaDevuelto;

            if (cantidadDevuelta <= 0 || cantidadDevuelta > disponibleParaDevolver) {
                request.setAttribute("error", "La cantidad a devolver debe ser mayor a 0 y no superar lo pendiente por devolver (" + disponibleParaDevolver + ").");
                doGet(request, response);
                return;
            }

            if (cantidadDevuelta < disponibleParaDevolver && (motivo == null || motivo.trim().isEmpty())) {
                request.setAttribute("error", "Debes indicar el motivo cuando la devolución es parcial (menor a la cantidad pendiente por devolver).");
                doGet(request, response);
                return;
            }

            Devolucion d = new Devolucion();
            d.setSolicitud(s);
            d.setEmpleado(sesion);
            d.setCantidadDevuelta(cantidadDevuelta);
            d.setMotivo(motivo != null ? motivo.trim() : null);

            boolean ok = devDAO.guardar(d);
            if (!ok) {
                request.setAttribute("error", "No se pudo registrar la devolución.");
                doGet(request, response);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/DevolucionServlet");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Datos inválidos.");
            doGet(request, response);
        } finally {
            solDAO.close();
            devDAO.close();
        }
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) {
            res.sendRedirect(req.getContextPath() + "/LoginServlet");
            return false;
        }
        return true;
    }
}