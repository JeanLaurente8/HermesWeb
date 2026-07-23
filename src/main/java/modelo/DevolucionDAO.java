package modelo;

import jakarta.persistence.*;
import java.util.List;

public class DevolucionDAO {

    private final EntityManager em;

    public DevolucionDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Devolucion> listar() {
        return em.createQuery(
                "SELECT d FROM Devolucion d "
                + "LEFT JOIN FETCH d.solicitud s "
                + "LEFT JOIN FETCH s.articulo "
                + "ORDER BY d.fechaDevolucion DESC", Devolucion.class).getResultList();
    }

    public int sumaDevueltaPorSolicitud(int idSolicitud) {
        Long suma = em.createQuery(
                "SELECT COALESCE(SUM(d.cantidadDevuelta), 0) FROM Devolucion d "
                + "WHERE d.solicitud.idSolicitud = :id", Long.class)
                .setParameter("id", idSolicitud)
                .getSingleResult();
        return suma.intValue();
    }

    public boolean guardar(Devolucion d) {
        em.getTransaction().begin();
        try {
            Solicitud s = em.find(Solicitud.class, d.getSolicitud().getIdSolicitud());
            if (s == null || s.getArticulo() == null) {
                em.getTransaction().rollback();
                return false;
            }

            d.setSolicitud(s);
            d.setEstadoDevolucion("En revisión");
            em.persist(d);

            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean aprobar(int idDevolucion) {
        em.getTransaction().begin();
        try {
            Devolucion d = em.find(Devolucion.class, idDevolucion);
            
            if (d != null && "En revisión".equals(d.getEstadoDevolucion())) {
                d.setEstadoDevolucion("Aprobado");
                
                Articulo art = em.find(Articulo.class, d.getSolicitud().getArticulo().getIdArticulo());
                if (art != null) {
                    art.setStock(art.getStock() + d.getCantidadDevuelta());
                    art.setRequiereCompra(art.getStock() <= art.getStockLimite());
                    em.merge(art);
                }
                em.merge(d);
            }

            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        }
    }

    public void close() {
        if (em != null && em.isOpen()) {
            em.close();
        }
    }
}
