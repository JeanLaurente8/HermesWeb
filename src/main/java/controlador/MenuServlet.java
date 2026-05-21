package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
 
public class MenuServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("empleado") == null) {
            response.sendRedirect("LoginServlet");
            return;
        }
 
        ArticuloDAO dao = new ArticuloDAO();
        try {
            List<Articulo> alertas = dao.listarConAlerta();
            request.setAttribute("alertas", alertas);
            request.getRequestDispatcher("/WEB-INF/vistas/menu.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }
}