package modelo;

import jakarta.persistence.*;
import java.util.List;

public class SolicitudDAO {
    private final EntityManager em;

    public SolicitudDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Solicitud> listar() {
        return em.createQuery("SELECT s FROM Solicitud s ORDER BY s.fechaSolicitud DESC", Solicitud.class).getResultList();
    }

    public List<Solicitud> listarParaConformidad() {
        return em.createQuery(
            "SELECT s FROM Solicitud s WHERE s.estadoSolicitud NOT IN ('Entregada', 'Rechazada') ORDER BY s.fechaSolicitud DESC", 
            Solicitud.class).getResultList();
    }

    public List<Solicitud> listarParaConformidadPorEmpleado(int idEmpleado) {
        return em.createQuery(
            "SELECT s FROM Solicitud s WHERE s.empleado.idEmpleado = :id AND s.estadoSolicitud NOT IN ('Entregada', 'Rechazada') ORDER BY s.fechaSolicitud DESC", 
            Solicitud.class)
            .setParameter("id", idEmpleado)
            .getResultList();
    }
    
    public List<Solicitud> listarPorEmpleado(int idEmpleado) {
        return em.createQuery(
            "SELECT s FROM Solicitud s WHERE s.empleado.idEmpleado = :id ORDER BY s.fechaSolicitud DESC",
            Solicitud.class)
            .setParameter("id", idEmpleado)
            .getResultList();
    }

    public Solicitud buscar(int id) {
        return em.find(Solicitud.class, id);
    }

    public void guardar(Solicitud s) {
        em.getTransaction().begin();
        em.persist(s);
        em.getTransaction().commit();
    }

    public void actualizar(Solicitud s) {
        em.getTransaction().begin();
        em.merge(s);
        em.getTransaction().commit();
    }

    public void cambiarEstado(int idSolicitud, String nuevoEstado, String motivo) {
        em.getTransaction().begin();
        Solicitud s = em.find(Solicitud.class, idSolicitud);
        if (s != null) {
            s.setEstadoSolicitud(nuevoEstado);
            if ("Rechazada".equals(nuevoEstado) && motivo != null && !motivo.trim().isEmpty()) {
                s.setDescripcion(s.getDescripcion() + " | Motivo rechazo: " + motivo.trim());
            }
            em.merge(s);
        }
        em.getTransaction().commit();
    }

    public void eliminar(int id) {
        em.getTransaction().begin();
        Solicitud s = em.find(Solicitud.class, id);
        if (s != null) em.remove(s);
        em.getTransaction().commit();
    }

    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}