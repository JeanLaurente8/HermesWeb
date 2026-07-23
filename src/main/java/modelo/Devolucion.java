package modelo;
import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name = "devolucion")
public class Devolucion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_devolucion")
    private int idDevolucion;

    @ManyToOne
    @JoinColumn(name = "id_solicitud")
    private Solicitud solicitud;

    @ManyToOne
    @JoinColumn(name = "id_empleado")
    private Empleado empleado; // quien gestiona/registra la devolución

    @Column(name = "estado_devolucion")
    private String estadoDevolucion = "En revisión";
    
    @Column(name = "cantidad_devuelta")
    private int cantidadDevuelta;

    @Column(name = "motivo", columnDefinition = "TEXT")
    private String motivo;

    @Column(name = "fecha_devolucion")
    private LocalDateTime fechaDevolucion;

    @PrePersist
    public void prePersist() {
        if (fechaDevolucion == null) fechaDevolucion = LocalDateTime.now();
    }

    public Devolucion() {}

    public int getIdDevolucion()                { return idDevolucion; }
    public void setIdDevolucion(int v)           { this.idDevolucion = v; }
    public Solicitud getSolicitud()              { return solicitud; }
    public void setSolicitud(Solicitud v)        { this.solicitud = v; }
    public Empleado getEmpleado()                { return empleado; }
    public void setEmpleado(Empleado v)          { this.empleado = v; }
    public int getCantidadDevuelta()             { return cantidadDevuelta; }
    public void setCantidadDevuelta(int v)       { this.cantidadDevuelta = v; }
    public String getMotivo()                    { return motivo; }
    public void setMotivo(String v)              { this.motivo = v; }
    public LocalDateTime getFechaDevolucion()    { return fechaDevolucion; }
    public void setFechaDevolucion(LocalDateTime v) { this.fechaDevolucion = v; }
    public String getEstadoDevolucion() { return estadoDevolucion; }
    public void setEstadoDevolucion(String estadoDevolucion) { this.estadoDevolucion = estadoDevolucion; }
}