package modelo;

import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name = "conformidad")
public class Conformidad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_conformidad")
    private int idConformidad;

    @ManyToOne
    @JoinColumn(name = "id_solicitud")
    private Solicitud solicitud;

    @ManyToOne
    @JoinColumn(name = "id_empleado")
    private Empleado empleado;
    
    @Column(name = "fecha_conformidad")
    private LocalDateTime fechaConformidad;

    @Column(name = "firma_conformidad")
    private boolean firmaConformidad;

    @Column(name = "comentarios", columnDefinition = "TEXT")
    private String comentarios;

    @PrePersist
    public void prePersist() {
        if (fechaConformidad == null) fechaConformidad = LocalDateTime.now();
    }

    public Conformidad() {}

    public int getIdConformidad()                   { return idConformidad; }
    public void setIdConformidad(int v)             { this.idConformidad = v; }
    public Solicitud getSolicitud()                 { return solicitud; }
    public void setSolicitud(Solicitud v)           { this.solicitud = v; }
    public Empleado getEmpleado()                   { return empleado; }
    public void setEmpleado(Empleado v)             { this.empleado = v; }
    public LocalDateTime getFechaConformidad()      { return fechaConformidad; }
    public void setFechaConformidad(LocalDateTime v){ this.fechaConformidad = v; }
    public boolean isFirmaConformidad()             { return firmaConformidad; }
    public void setFirmaConformidad(boolean v)      { this.firmaConformidad = v; }
    public String getComentarios()                  { return comentarios; }
    public void setComentarios(String v)            { this.comentarios = v; }
}