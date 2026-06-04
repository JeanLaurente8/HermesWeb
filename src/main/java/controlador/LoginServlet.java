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

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            enviarError(request, response, "Debe completar todos los campos para ingresar.");
            return;
        }

        username = username.trim();

        EmpleadoDAO dao = new EmpleadoDAO();
        try {
            Empleado empleado = dao.login(username, password);

            if (empleado != null) {

                if (!empleado.isEstado()) {
                    enviarError(request, response, "Tu cuenta está inactiva. Por favor, verifica tu correo electrónico para activarla.");
                    return;
                }

                // Acceso exitoso
                HttpSession session = request.getSession();
                session.setAttribute("empleado", empleado);
                response.sendRedirect("MenuServlet");

            } else {
                // Falla en credenciales
                enviarError(request, response, "Usuario o contraseña incorrectos.");
            }
        } finally {
            dao.close();
        }
    }

    // Método auxiliar para evitar repetir código
    private void enviarError(HttpServletRequest request, HttpServletResponse response, String mensaje) throws ServletException, IOException {
        request.setAttribute("error", mensaje);
        request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
    }
}