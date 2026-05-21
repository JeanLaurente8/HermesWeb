package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class ArticuloServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        if (!verificarSesion(request, response)) return;
 
        String accion = request.getParameter("accion");
        ArticuloDAO dao = new ArticuloDAO();
 
        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("articulos", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);
 
            } else if (accion.equals("editar")) {
                request.setAttribute("articuloEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("articulos", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);
 
            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("ArticuloServlet?accion=listar");
            }
        } finally {
            dao.close();
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
        ArticuloDAO dao = new ArticuloDAO();

        try {
            Articulo a;
            String[] estadoVals = request.getParameterValues("estado");
            boolean estado = true;
            if (estadoVals != null && estadoVals.length > 0) {
                estado = Boolean.parseBoolean(estadoVals[estadoVals.length - 1]);
            }

            int stock = 0;
            int stockLimite = 0;
            try {
                stock = Integer.parseInt(request.getParameter("stock"));
            } catch (NumberFormatException ex) {
                stock = 0;
            }
            try {
                stockLimite = Integer.parseInt(request.getParameter("stockLimite"));
            } catch (NumberFormatException ex) {
                stockLimite = 0;
            }

            if ("actualizar".equals(accion)) {
                a = dao.buscar(Integer.parseInt(request.getParameter("idArticulo")));
                if (a == null) {
                    response.sendRedirect("ArticuloServlet?accion=listar");
                    return;
                }
                a.setNombre(request.getParameter("nombre"));
                a.setDescripcion(request.getParameter("descripcion"));
                a.setStock(stock);
                a.setStockLimite(stockLimite);
                a.setEstado(estado);
                a.setRequiereCompra(request.getParameter("requiereCompra") != null);
                dao.actualizar(a);
            } else {
                a = new Articulo();
                a.setNombre(request.getParameter("nombre"));
                a.setDescripcion(request.getParameter("descripcion"));
                a.setStock(stock);
                a.setStockLimite(stockLimite);
                a.setEstado(estado); // usar el valor enviado por el formulario
                a.setRequiereCompra(request.getParameter("requiereCompra") != null);
                dao.guardar(a);
            }

            response.sendRedirect("ArticuloServlet?accion=listar");

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