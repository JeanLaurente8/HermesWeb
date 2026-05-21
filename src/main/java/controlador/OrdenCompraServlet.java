package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class OrdenCompraServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        String accion = request.getParameter("accion");
        OrdenCompraDAO dao = new OrdenCompraDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        ProveedorDAO provDAO = new ProveedorDAO();
 
        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);
 
            } else if (accion.equals("editar")) {
                request.setAttribute("ordenEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);
 
            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("OrdenCompraServlet?accion=listar");
            }
        } finally {
            dao.close(); empDAO.close(); provDAO.close();
        }
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        OrdenCompraDAO dao = new OrdenCompraDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        ProveedorDAO provDAO = new ProveedorDAO();
 
        try {
            Ordencompra o;
            if (accion.equals("actualizar")) {
                o = dao.buscar(Integer.parseInt(request.getParameter("idOrden")));
            } else {
                o = new Ordencompra();
            }
            o.setEstadoOc(request.getParameter("estadoOc"));
            String idAnalista = request.getParameter("idAnalista");
            if (idAnalista != null && !idAnalista.isEmpty())
                o.setAnalista(empDAO.buscar(Integer.parseInt(idAnalista)));
            String idGerente = request.getParameter("idGerente");
            if (idGerente != null && !idGerente.isEmpty())
                o.setGerente(empDAO.buscar(Integer.parseInt(idGerente)));
            String idProveedor = request.getParameter("idProveedor");
            if (idProveedor != null && !idProveedor.isEmpty())
                o.setProveedor(provDAO.buscar(Integer.parseInt(idProveedor)));
 
            if (accion.equals("actualizar")) dao.actualizar(o);
            else dao.guardar(o);
            response.sendRedirect("OrdenCompraServlet?accion=listar");
        } finally {
            dao.close(); empDAO.close(); provDAO.close();
        }
    }
 
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}