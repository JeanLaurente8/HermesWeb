package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class ConformidadServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
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
            dao.close(); solDAO.close(); empDAO.close();
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ConformidadDAO dao = new ConformidadDAO();
        SolicitudDAO solDAO = new SolicitudDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
 
        try {
            Conformidad c;
            if (accion.equals("actualizar")) {
                c = dao.buscar(Integer.parseInt(request.getParameter("idConformidad")));
            } else {
                c = new Conformidad();
            }
            c.setFirmaConformidad("on".equals(request.getParameter("firmaConformidad")));
            c.setComentarios(request.getParameter("comentarios"));
            String idSol = request.getParameter("idSolicitud");
            if (idSol != null && !idSol.isEmpty())
                c.setSolicitud(solDAO.buscar(Integer.parseInt(idSol)));
            String idEmp = request.getParameter("idEmpleado");
            if (idEmp != null && !idEmp.isEmpty())
                c.setEmpleado(empDAO.buscar(Integer.parseInt(idEmp)));
 
            if (accion.equals("actualizar")) dao.actualizar(c);
            else dao.guardar(c);
            response.sendRedirect("ConformidadServlet?accion=listar");
        } finally {
            dao.close(); solDAO.close(); empDAO.close();
        }
    }
 
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}