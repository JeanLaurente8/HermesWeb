package controlador;

import modelo.Empleado;
import modelo.EmpleadoDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet(name = "RecuperacionServlet", urlPatterns = {"/RecuperacionServlet"})
public class RecuperacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");

        if ("restablecer".equals(accion)) {
            String token = request.getParameter("token");
            EmpleadoDAO dao = new EmpleadoDAO();

            try {
                Empleado e = dao.buscarPorToken(token);

                if (e != null) {
                    request.setAttribute("idEmpleado", e.getIdEmpleado());
                    request.setAttribute("token", token);
                    request.getRequestDispatcher("/WEB-INF/vistas/restablecer.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "El enlace de recuperación es inválido o ha expirado.");
                    request.getRequestDispatcher("/WEB-INF/vistas/recuperar.jsp").forward(request, response);
                }
            } finally {
                dao.close();
            }
        } else {
            request.getRequestDispatcher("/WEB-INF/vistas/recuperar.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");
        EmpleadoDAO dao = new EmpleadoDAO();

        try {
            if ("solicitar".equals(accion)) {
                String correo = request.getParameter("correo");
                String token = UUID.randomUUID().toString();

                boolean exito = dao.guardarTokenRecuperacion(correo, token);

                if (exito) {
                    Empleado e = dao.buscarPorCorreo(correo);
                    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();

                    EmailHelper.enviarCorreoRecuperacionAsync(correo, e.getNombre(), token, baseUrl);

                    request.setAttribute("mensaje", "Se ha enviado un enlace de recuperación a tu correo electrónico.");
                } else {
                    request.setAttribute("error", "No se encontró una cuenta activa con ese correo electrónico.");
                }
                request.getRequestDispatcher("/WEB-INF/vistas/recuperar.jsp").forward(request, response);

            } else if ("cambiar".equals(accion)) {
                int idEmpleado = Integer.parseInt(request.getParameter("idEmpleado"));
                String nuevaPassword = request.getParameter("password");
                String token = request.getParameter("token");

                // Validar que el token sea válido
                Empleado eToken = dao.buscarPorToken(token);
                if (eToken != null) {

                    // Validar que la nueva contraseña no sea igual a la actual
                    Empleado eActual = dao.buscar(idEmpleado);
                    if (eActual.getPassword().equals(nuevaPassword)) {
                        request.setAttribute("error", "La nueva contraseña no puede ser igual a la anterior.");
                        request.setAttribute("idEmpleado", idEmpleado);
                        request.setAttribute("token", token);
                        request.getRequestDispatcher("/WEB-INF/vistas/restablecer.jsp").forward(request, response);
                        return;
                    }

                    // Actualizar contraseña
                    if (dao.actualizarPassword(idEmpleado, nuevaPassword)) {
                        request.setAttribute("exito", "Tu contraseña ha sido actualizada correctamente. Ya puedes iniciar sesión.");
                        request.getRequestDispatcher("/WEB-INF/vistas/login.jsp").forward(request, response);
                    } else {
                        request.setAttribute("error", "Hubo un problema al actualizar la contraseña.");
                        request.getRequestDispatcher("/WEB-INF/vistas/restablecer.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "El token ya fue utilizado o expiró.");
                    request.getRequestDispatcher("/WEB-INF/vistas/recuperar.jsp").forward(request, response);
                }
            }
        } finally {
            dao.close();
        }
    }
}