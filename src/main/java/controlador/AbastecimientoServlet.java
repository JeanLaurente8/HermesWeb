package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import javax.persistence.EntityManager;

public class AbastecimientoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;

        AbastecimientoDAO dao = new AbastecimientoDAO();

        EntityManager em = Conexion.getInstance().createEntityManager();
        try {
            List<Ordencompra> ordenesPendientes = em.createQuery(
                "SELECT o FROM Ordencompra o WHERE o.estadoOc IN ('Autorizada', 'Enviada')", Ordencompra.class)
                .getResultList();

            request.setAttribute("abastecimientos", dao.listar());
            request.setAttribute("ordenesPendientes", ordenesPendientes);
            request.getRequestDispatcher("/WEB-INF/vistas/abastecimiento.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarSesion(request, response)) return;
        request.setCharacterEncoding("UTF-8");

        Empleado sesion = (Empleado) request.getSession().getAttribute("empleado");
        AbastecimientoDAO dao = new AbastecimientoDAO();

        try {
            String idOrdenStr = request.getParameter("idOrden");
            String observaciones = request.getParameter("observaciones");

            if (idOrdenStr != null && !idOrdenStr.isEmpty()) {
                int idOrden = Integer.parseInt(idOrdenStr);

                EntityManager em = Conexion.getInstance().createEntityManager();
                Empleado empleadoGestionado;
                try {
                    empleadoGestionado = em.find(Empleado.class, sesion.getIdEmpleado());
                } finally {
                    em.close();
                }

                Abastecimiento a = new Abastecimiento();
                a.setEmpleado(empleadoGestionado);
                a.setObservaciones(observaciones);

                // El DAO carga la orden con su detalle_oc y aumenta el stock
                // de cada artículo automáticamente dentro de la transacción.
                boolean ok = dao.guardar(a, idOrden);

                if (!ok) {
                    request.setAttribute("error", "No se pudo procesar el ingreso: revisa que la OC tenga artículos en su detalle.");
                    doGet(request, response);
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/AbastecimientoServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Ocurrió un error al procesar el ingreso.");
            doGet(request, response);
        }
    }

    private boolean verificarSesion(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("empleado") == null) {
            res.sendRedirect(req.getContextPath() + "/LoginServlet");
            return false;
        }
        return true;
    }
}