package controlador;
 
import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
 
public class LoginServlet extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("empleado") != null) {
            response.sendRedirect("MenuServlet");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
 
        EmpleadoDAO dao = new EmpleadoDAO();
        try {
            Empleado empleado = dao.login(username, password);
            if (empleado != null) {
                HttpSession session = request.getSession();
                session.setAttribute("empleado", empleado);
                response.sendRedirect("MenuServlet");
            } else {
                request.setAttribute("error", "Usuario o contraseña incorrectos.");
                request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
            }
        } finally {
            dao.close();
        }
    }
}