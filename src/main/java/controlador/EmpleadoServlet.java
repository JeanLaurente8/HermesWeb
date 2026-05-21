package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class EmpleadoServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        String accion = request.getParameter("accion");
        EmpleadoDAO dao = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();
 
        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("empleados", dao.listar());
                request.setAttribute("areas", areaDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/empleado.jsp").forward(request, response);
 
            } else if (accion.equals("editar")) {
                request.setAttribute("empleadoEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("empleados", dao.listar());
                request.setAttribute("areas", areaDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/empleado.jsp").forward(request, response);
 
            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("EmpleadoServlet?accion=listar");
            }
        } finally {
            dao.close(); areaDAO.close();
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        EmpleadoDAO dao = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();
 
        try {
            Empleado emp;
            if (accion.equals("actualizar")) {
                emp = dao.buscar(Integer.parseInt(request.getParameter("idEmpleado")));
            } else {
                emp = new Empleado();
            }
            emp.setDni(request.getParameter("dni"));
            emp.setNombre(request.getParameter("nombre"));
            emp.setApellidoPaterno(request.getParameter("apellidoPaterno"));
            emp.setApellidoMaterno(request.getParameter("apellidoMaterno"));
            emp.setCorreo(request.getParameter("correo"));
            emp.setUsername(request.getParameter("username"));
            emp.setPassword(request.getParameter("password"));
            emp.setCargo(request.getParameter("cargo"));
            emp.setEstado(request.getParameter("estado") != null);
            String idArea = request.getParameter("idArea");
            if (idArea != null && !idArea.isEmpty())
                emp.setArea(areaDAO.buscar(Integer.parseInt(idArea)));
 
            if (accion.equals("actualizar")) dao.actualizar(emp);
            else dao.guardar(emp);
            response.sendRedirect("EmpleadoServlet?accion=listar");
        } finally {
            dao.close(); areaDAO.close();
        }
    }
 
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}