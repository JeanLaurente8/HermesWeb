package modelo;

import java.util.Date;
import javax.persistence.*;

@Entity
@Table(name = "abastecimiento")
public class Abastecimiento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_abastecimiento")
    private int idAbastecimiento;

    @ManyToOne
    @JoinColumn(name = "id_orden")
    private Ordencompra orden;

    @ManyToOne
    @JoinColumn(name = "id_empleado")
    private Empleado empleado;

    // insertable = false, updatable = false permite que la Base de Datos ponga el CURRENT_TIMESTAMP
    @Column(name = "fecha_recepcion", insertable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRecepcion;

    @Column(name = "observaciones")
    private String observaciones;

    public Abastecimiento() {
    }

    // Getters y Setters
    public int getIdAbastecimiento() { return idAbastecimiento; }
    public void setIdAbastecimiento(int idAbastecimiento) { this.idAbastecimiento = idAbastecimiento; }

    public Ordencompra getOrden() { return orden; }
    public void setOrden(Ordencompra orden) { this.orden = orden; }

    public Empleado getEmpleado() { return empleado; }
    public void setEmpleado(Empleado empleado) { this.empleado = empleado; }

    public Date getFechaRecepcion() { return fechaRecepcion; }
    public void setFechaRecepcion(Date fechaRecepcion) { this.fechaRecepcion = fechaRecepcion; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
}