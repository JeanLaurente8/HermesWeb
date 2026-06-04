package controlador;

import modelo.*;
import controlador.EmailHelper;
import servicios.DniApiService;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;
import java.security.MessageDigest;

public class EmpleadoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion != null && accion.equals("activar")) {
            procesarActivacion(request, response);
            return;
        }

        if (!verificarSesion(request, response)) {
            return;
        }

        EmpleadoDAO dao = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();

        try {
            HttpSession session = request.getSession();

            String error = (String) session.getAttribute("error");
            if (error != null) {
                request.setAttribute("error", error);
                session.removeAttribute("error");
            }
            String success = (String) session.getAttribute("success");
            if (success != null) {
                request.setAttribute("success", success);
                session.removeAttribute("success");
            }

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
                session.setAttribute("success", "Empleado desactivado correctamente.");
                response.sendRedirect("EmpleadoServlet?accion=listar");
            }
        } finally {
            dao.close();
            areaDAO.close();
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

        // --- LÓGICA: Consultar API DNI (AJAX) ---
        if ("consultarDni".equals(accion)) {
            String dni = request.getParameter("dni");
            DniApiService api = new DniApiService();
            String resultado = api.consultarDni(dni);

            if (resultado != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(resultado);
            } else {
                // Si no se encuentra, envía error 404
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
            return;
        }

        EmpleadoDAO dao = new EmpleadoDAO();
        AreaTrabajoDAO areaDAO = new AreaTrabajoDAO();

        try {
            if (accion.equals("guardar") || accion.equals("actualizar")) {
                String dni = request.getParameter("dni");
                String correo = request.getParameter("correo");
                String username = request.getParameter("username");

                if (dni == null || !dni.matches("^[0-9]{8}$")) {
                    enviarErrorYRetornar(request, response, dao, areaDAO, accion, "Error: El DNI debe contener 8 números.");
                    return;
                }
                if (correo == null || !validarFormatoCorreo(correo)) {
                    enviarErrorYRetornar(request, response, dao, areaDAO, accion, "Error: Formato de correo inválido.");
                    return;
                }

                // Validación de duplicados
                boolean duplicadoDNI = false, duplicadoCorreo = false, duplicadoUser = false;
                List<Empleado> existentes = dao.listar();
                for (Empleado e : existentes) {
                    if (accion.equals("actualizar") && e.getIdEmpleado() == Integer.parseInt(request.getParameter("idEmpleado"))) {
                        continue;
                    }
                    if (e.getDni().equals(dni)) {
                        duplicadoDNI = true;
                    }
                    if (e.getCorreo().equalsIgnoreCase(correo)) {
                        duplicadoCorreo = true;
                    }
                    if (e.getUsername().equalsIgnoreCase(username)) {
                        duplicadoUser = true;
                    }
                }

                if (duplicadoDNI) {
                    enviarErrorYRetornar(request, response, dao, areaDAO, accion, "Error: DNI ya registrado.");
                    return;
                }
                if (duplicadoCorreo) {
                    enviarErrorYRetornar(request, response, dao, areaDAO, accion, "Error: Correo en uso.");
                    return;
                }
                if (duplicadoUser) {
                    enviarErrorYRetornar(request, response, dao, areaDAO, accion, "Error: Username no disponible.");
                    return;
                }
            }

            Empleado emp;
            if (accion.equals("actualizar")) {
                emp = dao.buscar(Integer.parseInt(request.getParameter("idEmpleado")));
                emp.setEstado(request.getParameter("estado") != null);
            } else {
                emp = new Empleado();
                emp.setEstado(false); // Forzar estado inactivo al crear (Se activa una vez el usuario confirme por correo)
            }

            emp.setDni(request.getParameter("dni"));
            emp.setNombre(request.getParameter("nombre").trim());
            emp.setApellidoPaterno(request.getParameter("apellidoPaterno").trim());
            emp.setApellidoMaterno(request.getParameter("apellidoMaterno").trim());
            emp.setCorreo(request.getParameter("correo").trim());
            emp.setUsername(request.getParameter("username").trim());
            emp.setPassword(request.getParameter("password"));
            emp.setCargo(request.getParameter("cargo"));

            String idArea = request.getParameter("idArea");
            if (idArea != null && !idArea.isEmpty()) {
                emp.setArea(areaDAO.buscar(Integer.parseInt(idArea)));
            } else {
                emp.setArea(null);
            }

            if (accion.equals("actualizar")) {
                dao.actualizar(emp);
                request.getSession().setAttribute("success", "Empleado actualizado correctamente.");
            } else {
                dao.guardar(emp); // Al guardar, la base de datos asigna un ID
                request.getSession().setAttribute("success", "Empleado registrado correctamente. Se envió correo de activación.");

                // Buscamos al usuario recién creado por su DNI para obtener el ID que le asignó la Base de Datos
                Empleado recienCreado = null;
                for (Empleado e : dao.listar()) {
                    if (e.getDni().equals(emp.getDni())) {
                        recienCreado = e;
                        break;
                    }
                }

                if (recienCreado != null) {
                    // Se genera el token de seguridad
                    String token = generarTokenMD5(recienCreado.getDni(), recienCreado.getCorreo());
                    // Se obtiene la URL base del sistema dinámicamente
                    String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();

                    // Correo enviado
                    EmailHelper.enviarCorreoActivacionAsync(recienCreado.getCorreo(), recienCreado.getNombre(), recienCreado.getIdEmpleado(), token, baseUrl);
                }
            }

            response.sendRedirect("EmpleadoServlet?accion=listar");

        } finally {
            dao.close();
            areaDAO.close();
        }
    }

    // --- LÓGICA DE ACTIVACIÓN ---
    private void procesarActivacion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String tokenRecibido = request.getParameter("token");

        if (idStr == null || tokenRecibido == null) {
            response.getWriter().write("<h3>Enlace de activacion invalido. Faltan parametros.</h3>");
            return;
        }

        EmpleadoDAO dao = new EmpleadoDAO();
        try {
            int id = Integer.parseInt(idStr);
            Empleado emp = dao.buscar(id);

            if (emp != null) {
                // Reconstruimos el token
                String tokenEsperado = generarTokenMD5(emp.getDni(), emp.getCorreo());

                if (tokenEsperado.equals(tokenRecibido)) {
                    if (!emp.isEstado()) {
                        emp.setEstado(true); // Usuario activo
                        dao.actualizar(emp);
                        response.getWriter().write("<div style='text-align:center; margin-top:50px; font-family:sans-serif;'>"
                                + "<h2 style='color:green;'>¡Cuenta Activada Exitosamente!</h2>"
                                + "<p>Tu correo ha sido verificado. Ya puedes cerrar esta ventana e iniciar sesion en Hermes.</p>"
                                + "</div>");
                    } else {
                        response.getWriter().write("<h3 style='text-align:center; font-family:sans-serif;'>Tu cuenta ya habia sido activada previamente.</h3>");
                    }
                } else {
                    response.getWriter().write("<h3 style='text-align:center; color:red; font-family:sans-serif;'>Error: El token de seguridad no coincide o esta alterado.</h3>");
                }
            } else {
                response.getWriter().write("<h3>Error: El empleado no existe.</h3>");
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("<h3>Error en el formato del enlace.</h3>");
        } finally {
            dao.close();
        }
    }

    // --- MÉTODOS DE VALIDACIÓN Y SEGURIDAD ---
    // Crea un código único indescifrable combinando el DNI, una frase secreta y el correo
    private String generarTokenMD5(String dni, String correo) {
        try {
            String fraseSecreta = "HERMES_SUPER_SECRET_KEY_2024";
            String rawData = dni + fraseSecreta + correo;
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(rawData.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "fallback_token_123";
        }
    }

    private boolean validarFormatoCorreo(String correo) {
        String regex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
        return Pattern.matches(regex, correo);
    }

    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, EmpleadoDAO dao, AreaTrabajoDAO areaDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("empleados", dao.listar());
        request.setAttribute("areas", areaDAO.listarActivos());
        if (accion.equals("actualizar")) {
            Empleado e = dao.buscar(Integer.parseInt(request.getParameter("idEmpleado")));
            request.setAttribute("empleadoEditar", e);
        }
        request.getRequestDispatcher("/WEB-INF/vistas/empleado.jsp").forward(request, response);
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) {
            res.sendRedirect("LoginServlet");
            return false;
        }
        return true;
    }
}