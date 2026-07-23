package modelo;
 
import jakarta.persistence.*;
import java.util.List;
 
public class AreaTrabajoDAO {
    private final EntityManager em;
 
    public AreaTrabajoDAO() {
        em = Conexion.getInstance().createEntityManager();
    }
 
    public List<Areatrabajo> listar() {
        return em.createQuery("SELECT a FROM Areatrabajo a ORDER BY a.nombreArea", Areatrabajo.class).getResultList();
    }
 
    public List<Areatrabajo> listarActivos() {
        return em.createQuery("SELECT a FROM Areatrabajo a WHERE a.estado = true ORDER BY a.nombreArea", Areatrabajo.class).getResultList();
    }
 
    public Areatrabajo buscar(int id) {
        return em.find(Areatrabajo.class, id);
    }
 
    public void guardar(Areatrabajo area) {
        em.getTransaction().begin();
        em.persist(area);
        em.getTransaction().commit();
    }
 
    public void actualizar(Areatrabajo area) {
        em.getTransaction().begin();
        em.merge(area);
        em.getTransaction().commit();
    }
 
    public void eliminar(int id) {
        em.getTransaction().begin();
        Areatrabajo a = em.find(Areatrabajo.class, id);
        if (a != null) { a.setEstado(false); em.merge(a); }
        em.getTransaction().commit();
    }
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}