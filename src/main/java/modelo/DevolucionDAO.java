package modelo;
import javax.persistence.*;
import java.util.List;

public class DevolucionDAO {
    private EntityManager em;

    public DevolucionDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Devolucion> listar() {
        return em.createQuery(
            "SELECT d FROM Devolucion d " +
            "LEFT JOIN FETCH d.solicitud s " +
            "LEFT JOIN FETCH s.articulo " +
            "ORDER BY d.fechaDevolucion DESC", Devolucion.class).getResultList();
    }

    // Suma de lo ya devuelto para una solicitud, para no permitir devolver
    // más de lo pendiente si se hacen varias devoluciones parciales.
    public int sumaDevueltaPorSolicitud(int idSolicitud) {
        Long suma = em.createQuery(
            "SELECT COALESCE(SUM(d.cantidadDevuelta), 0) FROM Devolucion d " +
            "WHERE d.solicitud.idSolicitud = :id", Long.class)
            .setParameter("id", idSolicitud)
            .getSingleResult();
        return suma.intValue();
    }

    // Guarda la devolución y aumenta el stock del artículo correspondiente,
    // todo dentro de la misma transacción.
    public boolean guardar(Devolucion d) {
        em.getTransaction().begin();
        try {
            Solicitud s = em.find(Solicitud.class, d.getSolicitud().getIdSolicitud());
            if (s == null || s.getArticulo() == null) {
                em.getTransaction().rollback();
                return false;
            }

            Articulo art = em.find(Articulo.class, s.getArticulo().getIdArticulo());
            if (art == null) {
                em.getTransaction().rollback();
                return false;
            }

            art.setStock(art.getStock() + d.getCantidadDevuelta());
            art.setRequiereCompra(art.getStock() <= art.getStockLimite());
            em.merge(art);

            d.setSolicitud(s);
            em.persist(d);

            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        }
    }

    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}