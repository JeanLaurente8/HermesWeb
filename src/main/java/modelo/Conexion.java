package modelo;

import jakarta.persistence.*;

public class Conexion {

    private static Conexion instancia;
    private final EntityManagerFactory emf;

    private Conexion() {
        emf = Persistence.createEntityManagerFactory("HermesPU");
    }

    public static Conexion getInstance() {
        if (instancia == null) {
            instancia = new Conexion();
        }
        return instancia;
    }

    public EntityManager createEntityManager() {
        return emf.createEntityManager();
    }
}
