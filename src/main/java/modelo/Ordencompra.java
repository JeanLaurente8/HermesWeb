package modelo;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.*;

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

    @Column(name = "es_automatica")
    private Boolean esAutomatica = false;

    @OneToMany(mappedBy = "orden", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<DetalleOc> detalles = new ArrayList<>();

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
    public Boolean getEsAutomatica()                { return esAutomatica; }
    public void setEsAutomatica(Boolean v)          { this.esAutomatica = v; }
    public boolean isEsAutomatica()                 { return esAutomatica != null ? esAutomatica : false; }

    public List<DetalleOc> getDetalles()            { return detalles; }
    public void setDetalles(List<DetalleOc> v)      { this.detalles = v; }

    public void addDetalle(DetalleOc d) {
        d.setOrden(this);
        this.detalles.add(d);
    }
}