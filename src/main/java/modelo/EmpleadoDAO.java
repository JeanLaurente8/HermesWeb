package modelo;
 
import javax.persistence.*;
import java.util.List;
 
public class EmpleadoDAO {
    private EntityManager em;
 
    public EmpleadoDAO() {
        em = Conexion.getInstance().createEntityManager();
    }
 
    public List<Empleado> listar() {
        return em.createQuery("SELECT e FROM Empleado e ORDER BY e.apellidoPaterno", Empleado.class).getResultList();
    }
 
    public Empleado buscar(int id) {
        return em.find(Empleado.class, id);
    }
 
    public Empleado login(String username, String password) {
        try {
            return em.createQuery(
                "SELECT e FROM Empleado e WHERE e.username = :u AND e.password = :p AND e.estado = true",
                Empleado.class)
                .setParameter("u", username)
                .setParameter("p", password)
                .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }
 
    public void guardar(Empleado e) {
        em.getTransaction().begin();
        em.persist(e);
        em.getTransaction().commit();
    }
 
    public void actualizar(Empleado e) {
        em.getTransaction().begin();
        em.merge(e);
        em.getTransaction().commit();
    }
 
    public void eliminar(int id) {
        em.getTransaction().begin();
        Empleado e = em.find(Empleado.class, id);
        if (e != null) { e.setEstado(false); em.merge(e); }
        em.getTransaction().commit();
    }
 
    public void close() {
        if (em != null && em.isOpen()) em.close();
    }
}