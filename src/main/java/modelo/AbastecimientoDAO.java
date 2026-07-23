package modelo;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import java.util.List;

public class AbastecimientoDAO {

    private EntityManager getEntityManager() {
        return Conexion.getInstance().createEntityManager();
    }

    public List<Abastecimiento> listar() {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                "SELECT DISTINCT a FROM Abastecimiento a " +
                "LEFT JOIN FETCH a.orden o " +
                "LEFT JOIN FETCH o.detalles d " +
                "LEFT JOIN FETCH d.articulo " +
                "ORDER BY a.idAbastecimiento DESC", Abastecimiento.class).getResultList();
        } finally {
            em.close();
        }
    }

    public boolean guardar(Abastecimiento a, int idOrden) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();

            Ordencompra oc = em.createQuery(
                "SELECT DISTINCT o FROM Ordencompra o " +
                "LEFT JOIN FETCH o.detalles d " +
                "LEFT JOIN FETCH d.articulo " +
                "WHERE o.idOrden = :id", Ordencompra.class)
                .setParameter("id", idOrden)
                .getSingleResult();

            if (oc.getDetalles() == null || oc.getDetalles().isEmpty()) {
                throw new IllegalStateException("La OC-" + idOrden + " no tiene artículos en su detalle.");
            }

            a.setOrden(oc);
            em.persist(a);

            for (DetalleOc d : oc.getDetalles()) {
                Articulo articulo = d.getArticulo();
                articulo.setStock(articulo.getStock() + d.getCantidad());
            }

            oc.setEstadoOc("Conforme");

            em.getTransaction().commit();
            return true;
        } catch (NoResultException e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}