package modelo;

import jakarta.persistence.*;

@Entity
@Table(name = "proveedor")
public class Proveedor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_proveedor")
    private int idProveedor;

    @Column(name = "ruc")
    private String ruc;

    @Column(name = "razon_social")
    private String razonSocial;

    @Column(name = "contacto")
    private String contacto;

    @Column(name = "correo_proveedor")
    private String correoProveedor;

    @Column(name = "estado")
    private boolean estado = true;

    public Proveedor() {}

    public int getIdProveedor()                 { return idProveedor; }
    public void setIdProveedor(int v)           { this.idProveedor = v; }
    public String getRuc()                      { return ruc; }
    public void setRuc(String v)                { this.ruc = v; }
    public String getRazonSocial()              { return razonSocial; }
    public void setRazonSocial(String v)        { this.razonSocial = v; }
    public String getContacto()                 { return contacto; }
    public void setContacto(String v)           { this.contacto = v; }
    public String getCorreoProveedor()          { return correoProveedor; }
    public void setCorreoProveedor(String v)    { this.correoProveedor = v; }
    public boolean isEstado()                   { return estado; }
    public void setEstado(boolean v)            { this.estado = v; }
}