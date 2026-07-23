package modelo;

import jakarta.persistence.*;

@Entity
@Table(name = "area_trabajo")
public class Areatrabajo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_area")
    private int idArea;

    @Column(name = "nombre_area")
    private String nombreArea;

    @Column(name = "estado")
    private boolean estado = true;

    public Areatrabajo() {}

    public Areatrabajo(String nombreArea) {
        this.nombreArea = nombreArea;
        this.estado = true;
    }

    public int getIdArea()                  { return idArea; }
    public void setIdArea(int idArea)       { this.idArea = idArea; }
    public String getNombreArea()           { return nombreArea; }
    public void setNombreArea(String n)     { this.nombreArea = n; }
    public boolean isEstado()               { return estado; }
    public void setEstado(boolean estado)   { this.estado = estado; }
}