package modelo;

import jakarta.persistence.*;

@Entity
@Table(name = "detalle_oc")
public class DetalleOc {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_detalle_oc")
    private int idDetalleOc;

    @Column(name = "cantidad")
    private int cantidad;

    @ManyToOne
    @JoinColumn(name = "id_articulo")
    private Articulo articulo;

    @ManyToOne
    @JoinColumn(name = "id_proveedor")
    private Proveedor proveedor;

    @ManyToOne
    @JoinColumn(name = "id_orden")
    private Ordencompra orden;

    public DetalleOc() {}

    public int getIdDetalleOc()            { return idDetalleOc; }
    public void setIdDetalleOc(int v)      { this.idDetalleOc = v; }
    public int getCantidad()               { return cantidad; }
    public void setCantidad(int v)         { this.cantidad = v; }
    public Articulo getArticulo()          { return articulo; }
    public void setArticulo(Articulo v)    { this.articulo = v; }
    public Proveedor getProveedor()        { return proveedor; }
    public void setProveedor(Proveedor v)  { this.proveedor = v; }
    public Ordencompra getOrden()          { return orden; }
    public void setOrden(Ordencompra v)    { this.orden = v; }
}