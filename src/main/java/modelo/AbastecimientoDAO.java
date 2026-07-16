package modelo;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
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

            // Cargamos la orden con su detalle y artículos en la MISMA
            // transacción, para que los cambios de stock queden gestionados
            // por este EntityManager.
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

            // Persistimos el abastecimiento
            a.setOrden(oc);
            em.persist(a);

            // Aumentamos el stock de cada artículo según su cantidad en detalle_oc.
            // El trigger tr_evaluar_stock_hermes recalcula requiere_compra solo.
            for (DetalleOc d : oc.getDetalles()) {
                Articulo articulo = d.getArticulo();
                articulo.setStock(articulo.getStock() + d.getCantidad());
            }

            // Actualizamos el estado de la OC
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