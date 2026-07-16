package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

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
        ArticuloDAO artDAO = new ArticuloDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                String errorEliminar = (String) request.getSession().getAttribute("errorEliminarOC");
                if (errorEliminar != null) {
                    request.getSession().removeAttribute("errorEliminarOC");
                    request.setAttribute("error", errorEliminar);
                }
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.setAttribute("articulos", artDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                request.setAttribute("ordenEditar", dao.buscarConDetalle(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.setAttribute("articulos", artDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);

            } else if (accion.equals("imprimir")) {
                Ordencompra oc = dao.buscarConDetalle(Integer.parseInt(request.getParameter("id")));
                if (oc == null) {
                    response.sendRedirect("OrdenCompraServlet?accion=listar");
                    return;
                }
                request.setAttribute("oc", oc);
                request.getRequestDispatcher("/WEB-INF/vistas/oc_imprimir.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                String errorEliminar = dao.eliminar(Integer.parseInt(request.getParameter("id")));
                if (errorEliminar != null) {
                    request.getSession().setAttribute("errorEliminarOC", errorEliminar);
                }
                response.sendRedirect("OrdenCompraServlet?accion=listar");
            }
        } finally {
            dao.close();
            empDAO.close();
            provDAO.close();
            artDAO.close();
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
        ArticuloDAO artDAO = new ArticuloDAO();

        try {
            String estadoOc = request.getParameter("estadoOc");
            String idGerente = request.getParameter("idGerente");
            String idProveedor = request.getParameter("idProveedor");

            // Validaciones de Negocio Estrictas
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {

                if (idProveedor == null || idProveedor.trim().isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, artDAO, accion, "Error: Es obligatorio seleccionar un Proveedor para la Orden de Compra.");
                    return;
                }

                if ("Autorizada".equals(estadoOc) && (idGerente == null || idGerente.trim().isEmpty())) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, artDAO, accion, "Error de validación: Para que una Orden de Compra pase a estado 'Autorizada', debe tener un Gerente de Compras asignado.");
                    return;
                }

                List<DetalleOc> detalles = construirDetalles(request, artDAO);
                if (detalles.isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, artDAO, accion, "Error: Debes agregar al menos un artículo con su cantidad a la Orden de Compra.");
                    return;
                }

                Ordencompra o;
                if ("actualizar".equals(accion)) {
                    o = dao.buscarConDetalle(Integer.parseInt(request.getParameter("idOrden")));
                } else {
                    o = new Ordencompra();
                }

                o.setDescripcion(request.getParameter("descripcion"));
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

                o.getDetalles().clear();
                for (DetalleOc d : detalles) {
                    o.addDetalle(d);
                }

                if ("actualizar".equals(accion)) {
                    dao.actualizar(o);
                } else {
                    dao.guardar(o);
                }
            }

            response.sendRedirect("OrdenCompraServlet?accion=listar");

        } finally {
            dao.close();
            empDAO.close();
            provDAO.close();
            artDAO.close();
        }
    }

    private List<DetalleOc> construirDetalles(HttpServletRequest request, ArticuloDAO artDAO) {
        List<DetalleOc> detalles = new ArrayList<>();
        String[] idsArticulo = request.getParameterValues("idArticulo[]");
        String[] cantidades = request.getParameterValues("cantidad[]");

        if (idsArticulo == null || cantidades == null) {
            return detalles;
        }

        for (int i = 0; i < idsArticulo.length; i++) {
            String idArt = idsArticulo[i];
            if (idArt == null || idArt.trim().isEmpty()) {
                continue;
            }

            int cantidad;
            try {
                cantidad = Integer.parseInt(cantidades[i]);
            } catch (NumberFormatException e) {
                continue;
            }
            if (cantidad <= 0) {
                continue;
            }

            Articulo articulo = artDAO.buscar(Integer.parseInt(idArt));
            if (articulo == null) {
                continue;
            }

            DetalleOc d = new DetalleOc();
            d.setArticulo(articulo);
            d.setCantidad(cantidad);
            detalles.add(d);
        }
        return detalles;
    }

    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, OrdenCompraDAO dao, EmpleadoDAO empDAO, ProveedorDAO provDAO, ArticuloDAO artDAO, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("ordenes", dao.listar());
        request.setAttribute("empleados", empDAO.listar());
        request.setAttribute("proveedores", provDAO.listarActivos());
        request.setAttribute("articulos", artDAO.listar());

        if (accion.equals("actualizar")) {
            Ordencompra o = dao.buscarConDetalle(Integer.parseInt(request.getParameter("idOrden")));
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
