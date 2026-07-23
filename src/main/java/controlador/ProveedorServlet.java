package controlador;

import modelo.*;
import util.AuthUtils;
import servicios.PeruApiService;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

public class ProveedorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");

        if (!AuthUtils.puedeVerModulo(sesion, "Proveedores")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String accion = request.getParameter("accion");
        ProveedorDAO dao = new ProveedorDAO();

        try {

            if (accion == null || accion.equals("listar")) {

                request.setAttribute("proveedores", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp")
                        .forward(request, response);

            } else if (accion.equals("editar")) {

                if (!AuthUtils.tieneAccesoCompleto(sesion, "Proveedores")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                int id = Integer.parseInt(request.getParameter("id"));

                request.setAttribute("proveedorEditar", dao.buscar(id));
                request.setAttribute("proveedores", dao.listar());

                request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp")
                        .forward(request, response);

            } else if (accion.equals("eliminar")) {

                if (!AuthUtils.tieneAccesoCompleto(sesion, "Proveedores")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                int id = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(id);

                response.sendRedirect("ProveedorServlet?accion=listar");
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

        // ==============================
        // CONSULTA API RUC (AJAX)
        // ==============================
        if ("consultarRuc".equals(accion)) {

            String ruc = request.getParameter("ruc");

            PeruApiService api = new PeruApiService();
            String resultado = api.consultarRuc(ruc);

            if (resultado != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(resultado);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
            return;
        }

        // Guardar/actualizar solo para quien tenga acceso completo (Gerente Compras)
        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");
        if (!AuthUtils.tieneAccesoCompleto(sesion, "Proveedores")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        ProveedorDAO dao = new ProveedorDAO();

        try {

            if (accion != null
                    && (accion.equals("guardar") || accion.equals("actualizar"))) {

                String ruc = request.getParameter("ruc");
                String correo = request.getParameter("correoProveedor");

                // ==============================
                // VALIDACIÓN RUC
                // ==============================
                if (ruc == null || !ruc.matches("^(10|20)[0-9]{9}$")) {
                    enviarErrorYRetornar(request, response, dao, accion,
                            "Error: El RUC debe tener 11 dígitos y empezar con 10 o 20.");
                    return;
                }

                // ==============================
                // VALIDACIÓN CORREO
                // ==============================
                if (correo != null && !correo.trim().isEmpty()
                        && !validarFormatoCorreo(correo)) {

                    enviarErrorYRetornar(request, response, dao, accion,
                            "Error: El formato del correo no es válido.");
                    return;
                }

                // ==============================
                // VALIDACIÓN DUPLICADO RUC
                // ==============================
                List<Proveedor> existentes = dao.listar();
                boolean duplicado = false;

                int idActual = 0;
                if ("actualizar".equals(accion)) {
                    idActual = Integer.parseInt(request.getParameter("idProveedor"));
                }

                for (Proveedor p : existentes) {
                    if (p.getRuc().equals(ruc) && p.getIdProveedor() != idActual) {
                        duplicado = true;
                        break;
                    }
                }

                if (duplicado) {
                    enviarErrorYRetornar(request, response, dao, accion,
                            "Error: Ya existe un proveedor con ese RUC.");
                    return;
                }
            }

            // ==============================
            // CREAR / ACTUALIZAR OBJETO
            // ==============================
            Proveedor p;

            if ("actualizar".equals(accion)) {
                int id = Integer.parseInt(request.getParameter("idProveedor"));
                p = dao.buscar(id);
            } else {
                p = new Proveedor();
            }

            p.setRuc(request.getParameter("ruc"));

            if (!"actualizar".equals(accion)) {
                p.setRazonSocial(request.getParameter("razonSocial").trim());
            }

            p.setContacto(
                    request.getParameter("contacto") != null
                    ? request.getParameter("contacto").trim()
                    : null
            );

            p.setCorreoProveedor(
                    request.getParameter("correoProveedor") != null
                    ? request.getParameter("correoProveedor").trim()
                    : null
            );

            p.setEstado(true);

            // ==============================
            // GUARDAR / ACTUALIZAR
            // ==============================
            if ("actualizar".equals(accion)) {
                dao.actualizar(p);
            } else {
                dao.guardar(p);
            }

            response.sendRedirect("ProveedorServlet?accion=listar");

        } finally {
            dao.close();
        }
    }

    // ==============================
    // VALIDAR CORREO
    // ==============================
    private boolean validarFormatoCorreo(String correo) {
        String regex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
        return Pattern.matches(regex, correo);
    }

    // ==============================
    // MANEJO DE ERRORES
    // ==============================
    private void enviarErrorYRetornar(HttpServletRequest request,
            HttpServletResponse response,
            ProveedorDAO dao,
            String accion,
            String mensajeError)
            throws ServletException, IOException {

        request.setAttribute("error", mensajeError);
        request.setAttribute("proveedores", dao.listar());

        if ("actualizar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("idProveedor"));
            request.setAttribute("proveedorEditar", dao.buscar(id));
        }

        request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp")
                .forward(request, response);
    }

    // ==============================
    // VALIDAR SESIÓN
    // ==============================
    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("empleado") == null) {
            res.sendRedirect("LoginServlet");
            return false;
        }

        return true;
    }
}