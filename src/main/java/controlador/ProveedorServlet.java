package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
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

        if (!verificarSesion(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        ProveedorDAO dao = new ProveedorDAO();

        try {
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {
                String ruc = request.getParameter("ruc");
                String correo = request.getParameter("correoProveedor");

                // Validación de formato de RUC
                if (ruc == null || !ruc.matches("^(10|20)[0-9]{9}$")) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: El RUC debe contener exactamente 11 dígitos y empezar con 10 o 20.");
                    return;
                }

                // Validación de formato de correo
                if (correo != null && !correo.trim().isEmpty() && !validarFormatoCorreo(correo)) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: El formato del correo electrónico ingresado no es válido.");
                    return;
                }

                // Validación de duplicados
                boolean duplicadoRUC = false;
                List<Proveedor> existentes = dao.listar();

                for (Proveedor p : existentes) {
                    if (accion.equals("actualizar") && p.getIdProveedor() == Integer.parseInt(request.getParameter("idProveedor"))) {
                        continue;
                    }
                    if (p.getRuc().equals(ruc)) {
                        duplicadoRUC = true;
                        break;
                    }
                }

                if (duplicadoRUC) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: Ya existe un proveedor registrado con el RUC " + ruc + ".");
                    return;
                }
            }

            Proveedor p;
            if (accion.equals("actualizar")) {
                p = dao.buscar(Integer.parseInt(request.getParameter("idProveedor")));
            } else {
                p = new Proveedor();
            }

            p.setRuc(request.getParameter("ruc"));
            p.setRazonSocial(request.getParameter("razonSocial").trim());
            p.setContacto(request.getParameter("contacto") != null ? request.getParameter("contacto").trim() : "");
            p.setCorreoProveedor(request.getParameter("correoProveedor") != null ? request.getParameter("correoProveedor").trim() : "");
            p.setEstado(request.getParameter("estado") != null);

            if (accion.equals("actualizar")) {
                dao.actualizar(p);
            } else {
                p.setEstado(true);
                dao.guardar(p);
            }
            response.sendRedirect("ProveedorServlet?accion=listar");

        } finally {
            dao.close();
        }
    }

    // --- MÉTODOS AUXILIARES ---
    private boolean validarFormatoCorreo(String correo) {
        String regex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
        return Pattern.matches(regex, correo);
    }

    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, ProveedorDAO dao, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("proveedores", dao.listar());

        if (accion.equals("actualizar")) {
            Proveedor p = dao.buscar(Integer.parseInt(request.getParameter("idProveedor")));
            request.setAttribute("proveedorEditar", p);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/proveedor.jsp").forward(request, response);
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