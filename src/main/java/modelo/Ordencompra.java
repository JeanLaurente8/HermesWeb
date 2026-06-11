package modelo;

import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "orden_compra")
public class Ordencompra {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_orden")
    private int idOrden;

    @Column(name = "fecha_generacion")
    private LocalDateTime fechaGeneracion;

    @ManyToOne
    @JoinColumn(name = "id_analista")
    private Empleado analista;

    @ManyToOne
    @JoinColumn(name = "id_gerente")
    private Empleado gerente;

    @ManyToOne
    @JoinColumn(name = "id_proveedor")
    private Proveedor proveedor;

    @Column(name = "estado_oc")
    private String estadoOc = "En Revisión";

    @Column(name = "descripcion")
    private String descripcion;

    // Flag para saber si fue generada automáticamente
    @Column(name = "es_automatica")
    private boolean esAutomatica = false;

    @PrePersist
    public void prePersist() {
        if (fechaGeneracion == null) fechaGeneracion = LocalDateTime.now();
        if (estadoOc == null) estadoOc = "En Revisión";
    }

    public Ordencompra() {}

    public int getIdOrden()                         { return idOrden; }
    public void setIdOrden(int v)                   { this.idOrden = v; }
    public LocalDateTime getFechaGeneracion()       { return fechaGeneracion; }
    public void setFechaGeneracion(LocalDateTime v) { this.fechaGeneracion = v; }
    public Empleado getAnalista()                   { return analista; }
    public void setAnalista(Empleado v)             { this.analista = v; }
    public Empleado getGerente()                    { return gerente; }
    public void setGerente(Empleado v)              { this.gerente = v; }
    public Proveedor getProveedor()                 { return proveedor; }
    public void setProveedor(Proveedor v)           { this.proveedor = v; }
    public String getEstadoOc()                     { return estadoOc; }
    public void setEstadoOc(String v)               { this.estadoOc = v; }
    public String getDescripcion()                  { return descripcion; }
    public void setDescripcion(String v)            { this.descripcion = v; }
    public boolean isEsAutomatica()                 { return esAutomatica; }
    public void setEsAutomatica(boolean v)          { this.esAutomatica = v; }
}