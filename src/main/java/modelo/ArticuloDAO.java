package modelo;
 
import jakarta.persistence.*;
import java.util.List;
 
public class ArticuloDAO {
    private final EntityManager em;
 
    public ArticuloDAO() {
        em = Conexion.getInstance().createEntityManager();
    }
 
    public List<Articulo> listar() {
        return em.createQuery("SELECT a FROM Articulo a WHERE a.estado = true ORDER BY a.nombre", Articulo.class).getResultList();
    }
 
    public List<Articulo> listarConAlerta() {
        return em.createQuery("SELECT a FROM Articulo a WHERE a.estado = true AND a.requiereCompra = true ORDER BY a.stock", Articulo.class).getResultList();
    }
 
    public Articulo buscar(int id) {
        return em.find(Articulo.class, id);
    }
 
    public void guardar(Articulo a) {
        em.getTransaction().begin();
        em.persist(a);
        em.getTransaction().commit();
    }
 
    public void actualizar(Articulo a) {
        em.getTransaction().begin();
        em.merge(a);
        em.getTransaction().commit();
    }
 
    public void eliminar(int id) {
        em.getTransaction().begin();
        Articulo a = em.find(Articulo.class, id);
        if (a != null) { a.setEstado(false); em.merge(a); }
        em.getTransaction().commit();
    }
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}