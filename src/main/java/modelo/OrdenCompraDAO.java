package modelo;

import jakarta.persistence.*;
import java.util.List;

public class OrdenCompraDAO {
    private final EntityManager em;

    public OrdenCompraDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Ordencompra> listar() {
        return em.createQuery(
            "SELECT DISTINCT o FROM Ordencompra o " +
            "LEFT JOIN FETCH o.detalles d " +
            "LEFT JOIN FETCH d.articulo " +
            "ORDER BY o.fechaGeneracion DESC", Ordencompra.class).getResultList();
    }

    public Ordencompra buscar(int id) {
        return em.find(Ordencompra.class, id);
    }

    public Ordencompra buscarConDetalle(int id) {
        try {
            return em.createQuery(
                "SELECT DISTINCT o FROM Ordencompra o " +
                "LEFT JOIN FETCH o.detalles d " +
                "LEFT JOIN FETCH d.articulo " +
                "WHERE o.idOrden = :id", Ordencompra.class)
                .setParameter("id", id)
                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    public void guardar(Ordencompra o) {
        em.getTransaction().begin();
        em.persist(o);
        em.getTransaction().commit();
    }

    public void actualizar(Ordencompra o) {
        em.getTransaction().begin();
        em.merge(o);
        em.getTransaction().commit();
    }

    public String cambiarEstado(int id, String nuevoEstado) {
        em.getTransaction().begin();
        try {
            Ordencompra o = em.find(Ordencompra.class, id);
            if (o == null) {
                em.getTransaction().rollback();
                return "La OC-" + id + " no existe.";
            }
            if ("Aprobada".equals(nuevoEstado) && o.getGerente() == null) {
                em.getTransaction().rollback();
                return "No se puede aprobar la OC-" + id + ": no tiene un Gerente de Compras asignado.";
            }
            o.setEstadoOc(nuevoEstado);
            em.merge(o);
            em.getTransaction().commit();
            return null;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return "No se pudo actualizar el estado de la OC-" + id + ".";
        }
    }

    public String eliminar(int id) {
        em.getTransaction().begin();
        try {
            Long tieneAbastecimiento = em.createQuery(
                "SELECT COUNT(a) FROM Abastecimiento a WHERE a.orden.idOrden = :id", Long.class)
                .setParameter("id", id)
                .getSingleResult();

            if (tieneAbastecimiento > 0) {
                em.getTransaction().rollback();
                return "No se puede eliminar la OC-" + id + " porque ya tiene un ingreso de abastecimiento "
                     + "registrado. Elimina primero ese registro de Abastecimiento si realmente necesitas borrar la OC.";
            }

            Ordencompra o = em.find(Ordencompra.class, id);
            if (o != null) {
                em.remove(o);
            }
            em.getTransaction().commit();
            return null;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return "No se pudo eliminar la OC-" + id + ". Verifica que no tenga otros registros asociados.";
        }
    }

    public boolean existeOCAutomaticaParaArticulo(String nombreArticulo) {
        Long count = em.createQuery(
            "SELECT COUNT(o) FROM Ordencompra o WHERE o.estadoOc = 'En Revisión' " +
            "AND o.esAutomatica = true AND o.descripcion = :nombre",
            Long.class)
            .setParameter("nombre", nombreArticulo)
            .getSingleResult();
        return count > 0;
    }

    public Empleado obtenerAnalista() {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e WHERE e.cargo = 'Analista Compras' AND e.estado = true",
                Empleado.class)
                .setMaxResults(1)
                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    public Empleado obtenerGerente() {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e WHERE e.cargo = 'Gerente Compras' AND e.estado = true",
                Empleado.class)
                .setMaxResults(1)
                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}