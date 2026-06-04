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

        if (!verificarSesion(request, response)) {
            return;
        }

        String accion = request.getParameter("accion");
        ArticuloDAO dao = new ArticuloDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                request.setAttribute("articulos", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                request.setAttribute("articuloEditar", dao.buscar(Integer.parseInt(request.getParameter("id"))));
                request.setAttribute("articulos", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("ArticuloServlet?accion=listar");
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
        String nombre = request.getParameter("nombre");
        ArticuloDAO dao = new ArticuloDAO();

        try {
            // Validaciones Estrictas Backend
            if (accion != null && (accion.equals("guardar") || accion.equals("actualizar"))) {

                // Validar formato (admite números, letras, espacios y guiones)
                if (!esNombreArticuloValido(nombre)) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: El nombre del artículo tiene un formato inválido. Solo se admiten letras, números, espacios y guiones.");
                    return;
                }

                // Validar duplicados en la lista actual
                boolean esDuplicado = false;
                List<Articulo> listaExistentes = dao.listar();

                for (Articulo art : listaExistentes) {
                    if (art.getNombre().trim().equalsIgnoreCase(nombre.trim())) {
                        if (accion.equals("guardar")) {
                            esDuplicado = true;
                            break;
                        } else if (accion.equals("actualizar")) {
                            int idActual = Integer.parseInt(request.getParameter("idArticulo"));
                            if (art.getIdArticulo() != idActual) {
                                esDuplicado = true;
                                break;
                            }
                        }
                    }
                }

                if (esDuplicado) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: Ya existe un artículo registrado con el nombre '" + nombre + "'.");
                    return;
                }
            }

            Articulo a;
            String[] estadoVals = request.getParameterValues("estado");
            boolean estado = true;
            if (estadoVals != null && estadoVals.length > 0) {
                estado = Boolean.parseBoolean(estadoVals[estadoVals.length - 1]);
            }

            int stock = 0;
            int stockLimite = 0;
            try {
                stock = Integer.parseInt(request.getParameter("stock"));
            } catch (NumberFormatException ex) {
                stock = 0;
            }
            try {
                stockLimite = Integer.parseInt(request.getParameter("stockLimite"));
            } catch (NumberFormatException ex) {
                stockLimite = 0;
            }

            if ("actualizar".equals(accion)) {
                a = dao.buscar(Integer.parseInt(request.getParameter("idArticulo")));
                if (a == null) {
                    response.sendRedirect("ArticuloServlet?accion=listar");
                    return;
                }
                a.setNombre(nombre.trim());
                a.setDescripcion(request.getParameter("descripcion"));
                a.setStock(stock);
                a.setStockLimite(stockLimite);
                a.setEstado(estado);
                a.setRequiereCompra(request.getParameter("requiereCompra") != null);
                dao.actualizar(a);
            } else if ("guardar".equals(accion)) {
                a = new Articulo();
                a.setNombre(nombre.trim());
                a.setDescripcion(request.getParameter("descripcion"));
                a.setStock(stock);
                a.setStockLimite(stockLimite);
                a.setEstado(estado);
                a.setRequiereCompra(request.getParameter("requiereCompra") != null);
                dao.guardar(a);
            }

            response.sendRedirect("ArticuloServlet?accion=listar");

        } finally {
            dao.close();
        }
    }

    // Método auxiliar para manejo de errores
    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, ArticuloDAO dao, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("articulos", dao.listar());

        if (accion.equals("actualizar")) {
            Articulo articulo = dao.buscar(Integer.parseInt(request.getParameter("idArticulo")));
            request.setAttribute("articuloEditar", articulo);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/articulo.jsp").forward(request, response);
    }

    // Validación Regex (permite letras, números, espacios y guiones)
    private boolean esNombreArticuloValido(String nombre) {
        if (nombre == null || nombre.trim().isEmpty()) {
            return false;
        }
        if (nombre.length() < 3 || nombre.length() > 100) {
            return false;
        }
        String regex = "^[a-zA-ZÁ-ÿ0-9\\s\\-]+$";
        return nombre.matches(regex);
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
