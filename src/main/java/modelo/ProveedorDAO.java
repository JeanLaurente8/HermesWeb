package modelo;
 
import jakarta.persistence.*;
import java.util.List;
 
public class ProveedorDAO {
    private final EntityManager em;
 
    public ProveedorDAO() {
        em = Conexion.getInstance().createEntityManager();
    }
 
    public List<Proveedor> listar() {
        return em.createQuery("SELECT p FROM Proveedor p ORDER BY p.razonSocial", Proveedor.class).getResultList();
    }
 
    public List<Proveedor> listarActivos() {
        return em.createQuery("SELECT p FROM Proveedor p WHERE p.estado = true ORDER BY p.razonSocial", Proveedor.class).getResultList();
    }
 
    public Proveedor buscar(int id) {
        return em.find(Proveedor.class, id);
    }
 
    public void guardar(Proveedor p) {
        em.getTransaction().begin();
        em.persist(p);
        em.getTransaction().commit();
    }
 
    public void actualizar(Proveedor p) {
        em.getTransaction().begin();
        em.merge(p);
        em.getTransaction().commit();
    }
 
    public void eliminar(int id) {
        em.getTransaction().begin();
        Proveedor p = em.find(Proveedor.class, id);
        if (p != null) { p.setEstado(false); em.merge(p); }
        em.getTransaction().commit();
    }
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}