package modelo;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "empleado")
public class Empleado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_empleado")
    private int idEmpleado;

    @Column(name = "dni")
    private String dni;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "apellido_paterno")
    private String apellidoPaterno;

    @Column(name = "apellido_materno")
    private String apellidoMaterno;

    @Column(name = "correo")
    private String correo;

    @Column(name = "username")
    private String username;

    @Column(name = "password")
    private String password;

    @Column(name = "cargo")
    private String cargo;

    @Column(name = "estado")
    private boolean estado = true;

    @ManyToOne
    @JoinColumn(name = "id_area")
    private Areatrabajo area;

    @Column(name = "token_recuperacion")
    private String tokenRecuperacion;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "expiracion_token")
    private Date expiracionToken;

    public Empleado() {
    }

    public int getIdEmpleado() {
        return idEmpleado;
    }

    public void setIdEmpleado(int v) {
        this.idEmpleado = v;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String v) {
        this.dni = v;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String v) {
        this.nombre = v;
    }

    public String getApellidoPaterno() {
        return apellidoPaterno;
    }

    public void setApellidoPaterno(String v) {
        this.apellidoPaterno = v;
    }

    public String getApellidoMaterno() {
        return apellidoMaterno;
    }

    public void setApellidoMaterno(String v) {
        this.apellidoMaterno = v;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String v) {
        this.correo = v;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String v) {
        this.username = v;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String v) {
        this.password = v;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String v) {
        this.cargo = v;
    }

    public boolean isEstado() {
        return estado;
    }

    public void setEstado(boolean v) {
        this.estado = v;
    }

    public Areatrabajo getArea() {
        return area;
    }

    public void setArea(Areatrabajo v) {
        this.area = v;
    }

    // --- GETTERS Y SETTERS ---
    public String getTokenRecuperacion() {
        return tokenRecuperacion;
    }

    public void setTokenRecuperacion(String tokenRecuperacion) {
        this.tokenRecuperacion = tokenRecuperacion;
    }

    public Date getExpiracionToken() {
        return expiracionToken;
    }

    public void setExpiracionToken(Date expiracionToken) {
        this.expiracionToken = expiracionToken;
    }

    public String getNombreCompleto() {
        return nombre + " " + apellidoPaterno + " " + apellidoMaterno;
    }
}