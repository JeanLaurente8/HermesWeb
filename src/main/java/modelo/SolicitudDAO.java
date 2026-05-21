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