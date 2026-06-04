package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AreaTrabajoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) {
            return;
        }

        String accion = request.getParameter("accion");
        AreaTrabajoDAO dao = new AreaTrabajoDAO();

        try {
            if (accion == null || accion.equals("listar")) {
                List<Areatrabajo> lista = dao.listar();
                request.setAttribute("areas", lista);
                request.getRequestDispatcher("/WEB-INF/vistas/area.jsp").forward(request, response);

            } else if (accion.equals("editar")) {
                Areatrabajo area = dao.buscar(Integer.parseInt(request.getParameter("id")));
                request.setAttribute("areaEditar", area);
                request.setAttribute("areas", dao.listar());
                request.getRequestDispatcher("/WEB-INF/vistas/area.jsp").forward(request, response);

            } else if (accion.equals("eliminar")) {
                dao.eliminar(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("AreaTrabajoServlet?accion=listar");
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
        String nombreArea = request.getParameter("nombreArea");
        AreaTrabajoDAO dao = new AreaTrabajoDAO();

        try {
            if (accion.equals("guardar") || accion.equals("actualizar")) {

                // Validar el formato (sin números)
                if (!esNombreAreaValido(nombreArea)) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: El nombre del área solo admite letras, espacios y guiones.");
                    return;
                }

                // Validar duplicados en la lista actual
                boolean esDuplicado = false;
                List<Areatrabajo> listaExistentes = dao.listar();

                for (Areatrabajo a : listaExistentes) {
                    // Ignora mayúsculas/minúsculas y espacios en blanco extra al comparar
                    if (a.getNombreArea().trim().equalsIgnoreCase(nombreArea.trim())) {
                        if (accion.equals("guardar")) {
                            esDuplicado = true;
                            break;
                        } else if (accion.equals("actualizar")) {
                            int idActual = Integer.parseInt(request.getParameter("idArea"));
                            // Si el nombre coincide pero el ID es diferente, entonces pertenece a otra área (es duplicado)
                            if (a.getIdArea() != idActual) {
                                esDuplicado = true;
                                break;
                            }
                        }
                    }
                }

                if (esDuplicado) {
                    enviarErrorYRetornar(request, response, dao, accion, "Error: Ya existe un área de trabajo registrada con el nombre '" + nombreArea + "'.");
                    return;
                }
            }

            if (accion.equals("guardar")) {
                Areatrabajo area = new Areatrabajo(nombreArea.trim());
                dao.guardar(area);

            } else if (accion.equals("actualizar")) {
                Areatrabajo area = dao.buscar(Integer.parseInt(request.getParameter("idArea")));
                area.setNombreArea(nombreArea.trim());
                area.setEstado(request.getParameter("estado") != null);
                dao.actualizar(area);
            }
            response.sendRedirect("AreaTrabajoServlet?accion=listar");

        } finally {
            dao.close();
        }
    }

    // Método auxiliar para no repetir el código de retorno de errores
    private void enviarErrorYRetornar(HttpServletRequest request, HttpServletResponse response, AreaTrabajoDAO dao, String accion, String mensajeError) throws ServletException, IOException {
        request.setAttribute("error", mensajeError);
        request.setAttribute("areas", dao.listar());

        if (accion.equals("actualizar")) {
            Areatrabajo area = dao.buscar(Integer.parseInt(request.getParameter("idArea")));
            request.setAttribute("areaEditar", area);
        }

        request.getRequestDispatcher("/WEB-INF/vistas/area.jsp").forward(request, response);
    }

    // Validación Regex (no permite números ni guiones bajos)
    private boolean esNombreAreaValido(String nombre) {
        if (nombre == null || nombre.trim().isEmpty()) {
            return false;
        }
        if (nombre.length() < 3 || nombre.length() > 50) {
            return false;
        }
        // Expresión regular: Letras (incluye acentos y ñ), espacios y guiones.
        String regex = "^[a-zA-ZÁ-ÿ\\s\\-]+$";
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