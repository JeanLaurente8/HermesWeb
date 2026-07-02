package modelo;

import javax.persistence.*;
import java.util.List;

public class SolicitudDAO {
    private EntityManager em;

    public SolicitudDAO() {
        em = Conexion.getInstance().createEntityManager();
    }

    public List<Solicitud> listar() {
        return em.createQuery("SELECT s FROM Solicitud s ORDER BY s.fechaSolicitud DESC", Solicitud.class).getResultList();
    }

    // Solo las solicitudes del empleado en sesión
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
            // Si se rechaza, guardar el motivo en descripcion
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