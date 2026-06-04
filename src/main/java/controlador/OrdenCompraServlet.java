package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class OrdenCompraServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

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
            dao.close();
            empDAO.close();
            provDAO.close();
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
        OrdenCompraDAO dao = new OrdenCompraDAO();
        EmpleadoDAO empDAO = new EmpleadoDAO();
        ProveedorDAO provDAO = new ProveedorDAO();

        try {
            String estadoOc = request.getParameter("estadoOc");
            String idGerente = request.getParameter("idGerente");
            String idProveedor = request.getParameter("idProveedor");

            // Validaciones de Negocio Estrictas
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {

                if (idProveedor == null || idProveedor.trim().isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, accion, "Error: Es obligatorio seleccionar un Proveedor para la Orden de Compra.");
                    return;
                }

                if ("Autorizada".equals(estadoOc) && (idGerente == null || idGerente.trim().isEmpty())) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, accion, "Error de validación: Para que una Orden de Compra pase a estado 'Autorizada', debe tener un Gerente de Compras asignado.");
                    return;
                }
            }

            Ordencompra o;
            if ("actualizar".equals(accion)) {
                o = dao.buscar(Integer.parseInt(request.getParameter("idOrden")));
            } else {
                o = new Ordencompra();
            }

            o.setEstadoOc(estadoOc);

            String idAnalista = request.getParameter("idAnalista");
            if (idAnalista != null && !idAnalista.isEmpty()) {
                o.setAnalista(empDAO.buscar(Integer.parseInt(idAnalista)));
            } else {
                o.setAnalista(null);
            }

            if (idGerente != null && !idGerente.isEmpty()) {
                o.setGerente(empDAO.buscar(Integer.parseInt(idGerente)));
            } else {
                o.setGerente(null);
            }

            if (idProveedor != null && !idProveedor.isEmpty()) {
                o.setProveedor(provDAO.buscar(Integer.parseInt(idProveedor)));
            }

            if ("actualizar".equals(accion)) {
                dao.actualizar(o);
            } else {
                dao.guardar(o);
            }

            response.sendRedirect("OrdenCompraServlet?accion=listar");

        } finally {
            dao.close();
            empDAO.close();
            provDAO.close();
        }
    }

    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, OrdenCompraDAO dao, EmpleadoDAO empDAO, ProveedorDAO provDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("ordenes", dao.listar());
        request.setAttribute("empleados", empDAO.listar());
        request.setAttribute("proveedores", provDAO.listarActivos());

        if (accion.equals("actualizar")) {
            Ordencompra o = dao.buscar(Integer.parseInt(request.getParameter("idOrden")));
            request.setAttribute("ordenEditar", o);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);
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