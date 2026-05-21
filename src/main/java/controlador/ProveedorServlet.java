package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class ProveedorServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        String accion = request.getParameter("accion");
        ProveedorDAO dao = new ProveedorDAO();
 
        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("proveedores", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp").forward(request, response);
 
            } else if (accion.equals("editar")) {
                request.setAttribute("proveedorEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("proveedores", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp").forward(request, response);
 
            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("ProveedorServlet?accion=listar");
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
        ProveedorDAO dao = new ProveedorDAO();
 
        try {
            Proveedor p;
            if (accion.equals("actualizar")) {
                p = dao.buscar(Integer.parseInt(request.getParameter("idProveedor")));
            } else {
                p = new Proveedor();
            }
            p.setRuc(request.getParameter("ruc"));
            p.setRazonSocial(request.getParameter("razonSocial"));
            p.setContacto(request.getParameter("contacto"));
            p.setCorreoProveedor(request.getParameter("correoProveedor"));
            p.setEstado(request.getParameter("estado") != null);
 
            if (accion.equals("actualizar")) dao.actualizar(p);
            else dao.guardar(p);
            response.sendRedirect("ProveedorServlet?accion=listar");
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