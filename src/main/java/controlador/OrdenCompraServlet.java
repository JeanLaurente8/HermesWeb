package controlador;

import modelo.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
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
                String mensajeError = (String) request.getSession().getAttribute("mensajeErrorOC");
                if (mensajeError != null) {
                    request.getSession().removeAttribute("mensajeErrorOC");
                    request.setAttribute("error", mensajeError);
                }
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.setAttribute("articulos", artDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                Ordencompra ordenAEditar = dao.buscarConDetalle(Integer.parseInt(request.getParameter("id")));

                if (ordenAEditar == null) {
                    response.sendRedirect("OrdenCompraServlet?accion=listar");
                    return;
                }

                if (!"En Revisión".equals(ordenAEditar.getEstadoOc())) {
                    request.getSession().setAttribute("mensajeErrorOC",
                            "La OC-" + ordenAEditar.getIdOrden() + " no se puede editar: solo las órdenes en estado "
                            + "'En Revisión' son editables (estado actual: '" + ordenAEditar.getEstadoOc() + "').");
                    response.sendRedirect("OrdenCompraServlet?accion=listar");
                    return;
                }

                request.setAttribute("ordenEditar", ordenAEditar);
                request.setAttribute("ordenes", dao.listar());
                request.setAttribute("empleados", empDAO.listar());
                request.setAttribute("proveedores", provDAO.listarActivos());
                request.setAttribute("articulos", artDAO.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/ordencompra.jsp").forward(request, response);

            } else if (accion.equals("imprimir")) {
                Ordencompra ocImprimir = dao.buscarConDetalle(Integer.parseInt(request.getParameter("id")));
                if (ocImprimir == null) {
                    response.sendRedirect("OrdenCompraServlet?accion=listar");
                    return;
                }
                request.setAttribute("oc", ocImprimir);
                request.getRequestDispatcher("/WEB-INF/vistas/oc_imprimir.jsp").forward(request, response);

            } else if (accion.equals("aprobar") || accion.equals("rechazar")) {
                String nuevoEstado = accion.equals("aprobar") ? "Aprobada" : "Rechazada";
                String errorCambio = dao.cambiarEstado(Integer.parseInt(request.getParameter("id")), nuevoEstado);
                if (errorCambio != null) {
                    request.getSession().setAttribute("mensajeErrorOC", errorCambio);
                }
                response.sendRedirect("OrdenCompraServlet?accion=listar");

            } else if (accion.equals("eliminar")) {
                String errorEliminar = dao.eliminar(Integer.parseInt(request.getParameter("id")));
                if (errorEliminar != null) {
                    request.getSession().setAttribute("mensajeErrorOC", errorEliminar);
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
            String idProveedor = request.getParameter("idProveedor");

            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {

                List<DetalleOc> detalles = construirDetalles(request, artDAO, provDAO);
                if (detalles.isEmpty()) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, artDAO, accion, "Error: Debes agregar al menos un artículo con su cantidad a la Orden de Compra.");
                    return;
                }

                boolean faltaProveedorEnLinea = detalles.stream().anyMatch(d -> d.getProveedor() == null);
                if (faltaProveedorEnLinea) {
                    enviarErrorYRetornar(request, response, dao, empDAO, provDAO, artDAO, accion, "Error: Debes asignar un proveedor a cada artículo del detalle de la Orden de Compra.");
                    return;
                }

                Ordencompra o;
                if ("actualizar".equals(accion)) {
                    o = dao.buscarConDetalle(Integer.parseInt(request.getParameter("idOrden")));
                    if (o == null) {
                        response.sendRedirect("OrdenCompraServlet?accion=listar");
                        return;
                    }
                    if (!"En Revisión".equals(o.getEstadoOc())) {
                        request.getSession().setAttribute("mensajeErrorOC",
                                "La OC-" + o.getIdOrden() + " no se puede editar: solo las órdenes en estado "
                                + "'En Revisión' son editables (estado actual: '" + o.getEstadoOc() + "').");
                        response.sendRedirect("OrdenCompraServlet?accion=listar");
                        return;
                    }
                } else {
                    o = new Ordencompra();
                    o.setEstadoOc("En Revisión");
                }

                o.setDescripcion(request.getParameter("descripcion"));

                String idAnalista = request.getParameter("idAnalista");
                if (idAnalista != null && !idAnalista.isEmpty()) {
                    o.setAnalista(empDAO.buscar(Integer.parseInt(idAnalista)));
                } else {
                    o.setAnalista(null);
                }

                String idGerente = request.getParameter("idGerente");
                if (idGerente != null && !idGerente.isEmpty()) {
                    o.setGerente(empDAO.buscar(Integer.parseInt(idGerente)));
                } else {
                    o.setGerente(null);
                }

                if (idProveedor != null && !idProveedor.isEmpty()) {
                    o.setProveedor(provDAO.buscar(Integer.parseInt(idProveedor)));
                } else {
                    o.setProveedor(null);
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

    private List<DetalleOc> construirDetalles(HttpServletRequest request, ArticuloDAO artDAO, ProveedorDAO provDAO) {
        List<DetalleOc> detalles = new ArrayList<>();
        String[] idsArticulo = request.getParameterValues("idArticulo[]");
        String[] cantidades = request.getParameterValues("cantidad[]");
        String[] idsProveedorLinea = request.getParameterValues("idProveedorLinea[]");

        if (idsArticulo == null || cantidades == null) {
            return detalles;
        }

        for (int i = 0; i < idsArticulo.length; i++) {
            String idArt = idsArticulo[i];
            if (idArt == null || idArt.trim().isEmpty()) continue;

            int cantidad;
            try {
                cantidad = Integer.parseInt(cantidades[i]);
            } catch (NumberFormatException e) {
                continue;
            }
            if (cantidad <= 0) continue;

            Articulo articulo = artDAO.buscar(Integer.parseInt(idArt));
            if (articulo == null) continue;

            DetalleOc d = new DetalleOc();
            d.setArticulo(articulo);
            d.setCantidad(cantidad);

            if (idsProveedorLinea != null && i < idsProveedorLinea.length
                    && idsProveedorLinea[i] != null && !idsProveedorLinea[i].trim().isEmpty()) {
                Proveedor provLinea = provDAO.buscar(Integer.parseInt(idsProveedorLinea[i]));
                d.setProveedor(provLinea);
            }

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