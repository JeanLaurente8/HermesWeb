package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
 
public class AreaTrabajoServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        String accion = request.getParameter("accion");
        AreaTrabajoDAO dao = new AreaTrabajoDAO();
 
        try {
            if (accion == null || accion.equals("listar")) {
                List<Areatrabajo> lista = dao.listar();
                request.setAttribute("areas", lista);
                request.getRequestDispatcher("/WEB-INF/vistas/area.jsp").forward(request, response);
 
            } else if (accion.equals("editar")) {
                Areatrabajo area = dao.buscar(Integer.parseInt(request.getParameter("id")));
                request.setAttribute("areaEditar", area);
                request.setAttribute("areas", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/area.jsp").forward(request, response);
 
            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("AreaTrabajoServlet?accion=listar");
            }
        } finally {
            dao.close();
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        AreaTrabajoDAO dao = new AreaTrabajoDAO();
 
        try {
            if (accion.equals("guardar")) {
                Areatrabajo area = new Areatrabajo(request.getParameter("nombreArea"));
                dao.guardar(area);
 
            } else if (accion.equals("actualizar")) {
                Areatrabajo area = dao.buscar(Integer.parseInt(request.getParameter("idArea")));
                area.setNombreArea(request.getParameter("nombreArea"));
                area.setEstado(request.getParameter("estado") != null);
                dao.actualizar(area);
            }
            response.sendRedirect("AreaTrabajoServlet?accion=listar");
        } finally {
            dao.close();
        }
    }
 
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}