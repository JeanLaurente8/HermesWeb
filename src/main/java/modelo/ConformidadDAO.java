package modelo;
 
import javax.persistence.*;
import java.util.List;
 
public class ConformidadDAO {
    private EntityManager em;
 
    public ConformidadDAO() {
        em = Conexion.getInstance().createEntityManager();
    }
 
    public List<Conformidad> listar() {
        return em.createQuery("SELECT c FROM Conformidad c ORDER BY c.fechaConformidad DESC", Conformidad.class).getResultList();
    }
 
    public Conformidad buscar(int id) {
        return em.find(Conformidad.class, id);
    }
 
    public void guardar(Conformidad c) {
        em.getTransaction().begin();
        em.persist(c);
        em.getTransaction().commit();
    }
 
    public void actualizar(Conformidad c) {
        em.getTransaction().begin();
        em.merge(c);
        em.getTransaction().commit();
    }
 
    public void eliminar(int id) {
        em.getTransaction().begin();
        Conformidad c = em.find(Conformidad.class, id);
        if (c != null) em.remove(c);
        em.getTransaction().commit();
    }
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}