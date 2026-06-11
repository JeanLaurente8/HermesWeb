package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class ArticuloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;

        String accion = request.getParameter("accion");
        ArticuloDAO dao = new ArticuloDAO();
        ProveedorDAO provDAO = new ProveedorDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("articulos", dao.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                request.setAttribute("articuloEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("articulos", dao.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("ArticuloServlet?accion=listar");
            }
        } finally {
            dao.close();
            provDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;

        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        String nombre = request.getParameter("nombre");
        ArticuloDAO dao = new ArticuloDAO();
        ProveedorDAO provDAO = new ProveedorDAO();

        try {
            // ── VALIDACIONES ─────────────────────────────────────────
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {

                if (!esNombreArticuloValido(nombre)) {
                    request.setAttribute("error", "Error: El nombre del artículo tiene un formato inválido. Solo se admiten letras, números, espacios y guiones.");
                    request.setAttribute("articulos", dao.listar());
                    request.setAttribute("proveedores", provDAO.listarActivos());
                    if (accion.equals("actualizar"))
                        request.setAttribute("articuloEditar", dao.buscar(Integer.parseInt(request.getParameter("idArticulo"))));
                    request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);
                    return;
                }

                boolean esDuplicado = false;
                for (Articulo art : dao.listar()) {
                    if (art.getNombre().trim().equalsIgnoreCase(nombre.trim())) {
                        if (accion.equals("guardar")) { esDuplicado = true; break; }
                        else if (accion.equals("actualizar")) {
                            int idActual = Integer.parseInt(request.getParameter("idArticulo"));
                            if (art.getIdArticulo() != idActual) { esDuplicado = true; break; }
                        }
                    }
                }
                if (esDuplicado) {
                    request.setAttribute("error", "Error: Ya existe un artículo con el nombre '" + nombre + "'.");
                    request.setAttribute("articulos", dao.listar());
                    request.setAttribute("proveedores", provDAO.listarActivos());
                    if (accion.equals("actualizar"))
                        request.setAttribute("articuloEditar", dao.buscar(Integer.parseInt(request.getParameter("idArticulo"))));
                    request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);
                    return;
                }
            }

            // ── PARSEAR VALORES ───────────────────────────────────────
            String[] estadoVals = request.getParameterValues("estado");
            boolean estado = true;
            if (estadoVals != null && estadoVals.length > 0)
                estado = Boolean.parseBoolean(estadoVals[estadoVals.length - 1]);

            int stock = 0, stockLimite = 0;
            double precio = 0.0;
            try { stock = Integer.parseInt(request.getParameter("stock")); } catch (NumberFormatException ex) {}
            try { stockLimite = Integer.parseInt(request.getParameter("stockLimite")); } catch (NumberFormatException ex) {}
            try { precio = Double.parseDouble(request.getParameter("precio")); } catch (NumberFormatException ex) {}

            String idProvStr = request.getParameter("idProveedor");
            Proveedor proveedorSeleccionado = null;
            if (idProvStr != null && !idProvStr.isEmpty()) {
                proveedorSeleccionado = provDAO.buscar(Integer.parseInt(idProvStr));
            }

            // ── GUARDAR O ACTUALIZAR ──────────────────────────────────
            Articulo a;
            if ("actualizar".equals(accion)) {
                a = dao.buscar(Integer.parseInt(request.getParameter("idArticulo")));
                if (a == null) { response.sendRedirect("ArticuloServlet?accion=listar"); return; }
            } else {
                a = new Articulo();
            }

            a.setNombre(nombre.trim());
            a.setDescripcion(request.getParameter("descripcion"));
            a.setStock(stock);
            a.setStockLimite(stockLimite);
            a.setPrecio(precio);
            a.setProveedor(proveedorSeleccionado);
            a.setEstado(estado);
            a.setRequiereCompra(stock <= stockLimite);

            if ("actualizar".equals(accion)) dao.actualizar(a);
            else dao.guardar(a);

            // ── GENERACIÓN AUTOMÁTICA DE OC ───────────────────────────
            if (stock <= stockLimite) {
                OrdenCompraDAO ocDAO = new OrdenCompraDAO();
                try {
                    if (!ocDAO.existeOCAutomaticaParaArticulo(nombre.trim())) {

                        Empleado analista = ocDAO.obtenerAnalista();
                        Empleado gerente  = ocDAO.obtenerGerente();

                        Ordencompra oc = new Ordencompra();
                        oc.setEstadoOc("En Revisión");
                        oc.setDescripcion(nombre.trim());
                        oc.setEsAutomatica(true);
                        oc.setAnalista(analista);
                        oc.setGerente(gerente);

                        // Asignar el proveedor del artículo a la OC automáticamente
                        if (proveedorSeleccionado != null) {
                            oc.setProveedor(proveedorSeleccionado);
                        }

                        ocDAO.guardar(oc);

                        // Guardar datos en sesión para el modal de confirmación de proveedor
                        request.getSession().setAttribute("ocGenerada",
                            "Se generó automáticamente una OC en estado 'En Revisión' " +
                            "para el artículo \"" + nombre.trim() + "\".");

                        request.getSession().setAttribute("ocIdGenerada", oc.getIdOrden());

                        // Guardar info del proveedor para el modal
                        if (proveedorSeleccionado != null) {
                            request.getSession().setAttribute("proveedorOC",
                                proveedorSeleccionado.getRazonSocial());
                            request.getSession().setAttribute("idOCGenerada", oc.getIdOrden());
                        }
                    }
                } finally {
                    ocDAO.close();
                }
            }

            response.sendRedirect("ArticuloServlet?accion=listar");

        } finally {
            dao.close();
            provDAO.close();
        }
    }

    private boolean esNombreArticuloValido(String nombre) {
        if (nombre == null || nombre.trim().isEmpty()) return false;
        if (nombre.length() < 3 || nombre.length() > 100) return false;
        return nombre.matches("^[a-zA-ZÁ-ÿ0-9\\s\\-]+$");
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) { res.sendRedirect("LoginServlet"); return false; }
        return true;
    }
}