package modelo;

import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "solicitud")
public class Solicitud {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_solicitud")
    private int idSolicitud;

    @ManyToOne
    @JoinColumn(name = "id_empleado")
    private Empleado empleado;

    @ManyToOne
    @JoinColumn(name = "id_area")
    private Areatrabajo area;

    @Column(name = "fecha_solicitud")
    private LocalDateTime fechaSolicitud;

    @Column(name = "estado_solicitud")
    private String estadoSolicitud = "Pendiente";

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @PrePersist
    public void prePersist() {
        if (fechaSolicitud == null) fechaSolicitud = LocalDateTime.now();
        if (estadoSolicitud == null) estadoSolicitud = "Pendiente";
    }

    @ManyToOne
    @JoinColumn(name = "id_articulo")
    private Articulo articulo;

    @Column(name = "cantidad")
    private Integer cantidad;
    
    public Solicitud() {}

    public int getIdSolicitud()                         { return idSolicitud; }
    public void setIdSolicitud(int v)                   { this.idSolicitud = v; }
    public Empleado getEmpleado()                       { return empleado; }
    public void setEmpleado(Empleado v)                 { this.empleado = v; }
    public Areatrabajo getArea()                        { return area; }
    public void setArea(Areatrabajo v)                  { this.area = v; }
    public LocalDateTime getFechaSolicitud()            { return fechaSolicitud; }
    public void setFechaSolicitud(LocalDateTime v)      { this.fechaSolicitud = v; }
    public String getEstadoSolicitud()                  { return estadoSolicitud; }
    public void setEstadoSolicitud(String v)            { this.estadoSolicitud = v; }
    public String getDescripcion()                      { return descripcion; }
    public void setDescripcion(String v)                { this.descripcion = v; }
    public Articulo getArticulo() {
        return articulo;
    }
    public void setArticulo(Articulo articulo) {
        this.articulo = articulo;
    }
    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }
}