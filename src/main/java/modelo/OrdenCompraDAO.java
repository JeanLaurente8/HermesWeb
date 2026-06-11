package modelo;

import javax.persistence.*;
import java.util.List;

public class OrdenCompraDAO {
    private EntityManager em;

    public OrdenCompraDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Ordencompra> listar() {
        return em.createQuery("SELECT o FROM Ordencompra o ORDER BY o.fechaGeneracion DESC", Ordencompra.class).getResultList();
    }

    public Ordencompra buscar(int id) {
        return em.find(Ordencompra.class, id);
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

    public void eliminar(int id) {
        em.getTransaction().begin();
        Ordencompra o = em.find(Ordencompra.class, id);
        if (o != null) em.remove(o);
        em.getTransaction().commit();
    }

    // Verificar si ya existe OC automática en "En Revisión" para ese artículo
    public boolean existeOCAutomaticaParaArticulo(String nombreArticulo) {
        Long count = em.createQuery(
            "SELECT COUNT(o) FROM Ordencompra o WHERE o.estadoOc = 'En Revisión' " +
            "AND o.esAutomatica = true AND o.descripcion = :nombre",
            Long.class)
            .setParameter("nombre", nombreArticulo)
            .getSingleResult();
        return count > 0;
    }

    // Obtener el único analista de la BD
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

    // Obtener el único gerente de la BD
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