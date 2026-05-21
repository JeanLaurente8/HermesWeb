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
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}