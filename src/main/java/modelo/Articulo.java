package modelo;

import javax.persistence.*;

@Entity
@Table(name = "articulo")
public class Articulo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_articulo")
    private int idArticulo;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "stock")
    private int stock;

    @Column(name = "stock_limite")
    private int stockLimite;

    @Column(name = "requiere_compra")
    private boolean requiereCompra;

    @Column(name = "estado")
    private boolean estado = true;

    public Articulo() {}

    public int getIdArticulo()                  { return idArticulo; }
    public void setIdArticulo(int v)            { this.idArticulo = v; }
    public String getNombre()                   { return nombre; }
    public void setNombre(String v)             { this.nombre = v; }
    public String getDescripcion()              { return descripcion; }
    public void setDescripcion(String v)        { this.descripcion = v; }
    public int getStock()                       { return stock; }
    public void setStock(int v)                 { this.stock = v; }
    public int getStockLimite()                 { return stockLimite; }
    public void setStockLimite(int v)           { this.stockLimite = v; }
    public boolean isRequiereCompra()           { return requiereCompra; }
    public void setRequiereCompra(boolean v)    { this.requiereCompra = v; }
    public boolean isEstado()                   { return estado; }
    public void setEstado(boolean v)            { this.estado = v; }

    public String getEstadoStock() {
        return stock <= stockLimite ? "ALERTA" : "OK";
    }
}