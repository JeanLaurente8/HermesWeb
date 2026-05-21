package controlador;
 
import modelo.*;
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
            dao.close(); empDAO.close(); areaDAO.close();
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        SolicitudDAO dao = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();
 
        try {
            Solicitud s;
            if (accion.equals("actualizar")) {
                s = dao.buscar(Integer.parseInt(request.getParameter("idSolicitud")));
            } else {
                s = new Solicitud();
            }
            s.setDescripcion(request.getParameter("descripcion"));
            s.setEstadoSolicitud(request.getParameter("estadoSolicitud"));
            String idEmp = request.getParameter("idEmpleado");
            if (idEmp != null && !idEmp.isEmpty())
                s.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
            String idArea = request.getParameter("idArea");
            if (idArea != null && !idArea.isEmpty())
                s.setArea(areaDAO.buscar(Integer.parseInt(idArea)));
 
            if (accion.equals("actualizar")) dao.actualizar(s);
            else dao.guardar(s);
            response.sendRedirect("SolicitudServlet?accion=listar");
        } finally {
            dao.close(); empDAO.close(); areaDAO.close();
        }
    }
 
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}