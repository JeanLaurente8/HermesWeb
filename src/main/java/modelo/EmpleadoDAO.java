package modelo;

import javax.persistence.*;
import java.util.Date;
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
        if (e != null) {
            e.setEstado(false);
            em.merge(e);
        }
        em.getTransaction().commit();
    }

    // Guarda el token y establece su expiración a 15 minutos desde el momento actual
    public boolean guardarTokenRecuperacion(String correo, String token) {
        try {
            em.getTransaction().begin();
            Empleado e = em.createQuery("SELECT e FROM Empleado e WHERE e.correo = :correo AND e.estado = true", Empleado.class)
                    .setParameter("correo", correo)
                    .getSingleResult();

            e.setTokenRecuperacion(token);
            // Sumar 15 minutos (15 * 60 * 1000 milisegundos) a la fecha actual
            e.setExpiracionToken(new Date(System.currentTimeMillis() + (15 * 60 * 1000)));

            em.merge(e);
            em.getTransaction().commit();
            return true;
        } catch (NoResultException ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false; // El correo no existe o el usuario está inactivo
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            ex.printStackTrace();
            return false;
        }
    }

    // Busca si existe un usuario con ese token y que la fecha de expiración sea mayor a la actual
    public Empleado buscarPorToken(String token) {
        try {
            return em.createQuery(
                    "SELECT e FROM Empleado e WHERE e.tokenRecuperacion = :token AND e.expiracionToken > CURRENT_TIMESTAMP AND e.estado = true",
                    Empleado.class)
                    .setParameter("token", token)
                    .getSingleResult();
        } catch (NoResultException ex) {
            return null; // Token inválido o ya expirado
        }
    }

    // Actualiza la clave y limpia el token para que no se vuelva a usar
    public boolean actualizarPassword(int idEmpleado, String nuevaPassword) {
        try {
            em.getTransaction().begin();
            Empleado e = em.find(Empleado.class, idEmpleado);
            if (e != null) {
                e.setPassword(nuevaPassword);
                e.setTokenRecuperacion(null);
                e.setExpiracionToken(null);
                em.merge(e);
                em.getTransaction().commit();
                return true;
            }
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return false;
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            ex.printStackTrace();
            return false;
        }
    }

    public Empleado buscarPorCorreo(String correo) {
        try {
            return em.createQuery("SELECT e FROM Empleado e WHERE e.correo = :c", Empleado.class)
                    .setParameter("c", correo)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    public void close() {
        if (em != null && em.isOpen()) {
            em.close();
        }
    }
}