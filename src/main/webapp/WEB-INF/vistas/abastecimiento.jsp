<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, util.AuthUtils, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hermes – Abastecimiento</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            .sidebar{ background:linear-gradient(180deg,#1a3a5c 0%,#0f2340 100%); min-height:100vh; color:white }
            .sidebar .nav-link{ color:rgba(255,255,255,.75); padding:10px 20px; border-radius:8px; margin:2px 8px; transition:.2s; font-size:14px }
            .sidebar .nav-link:hover,.sidebar .nav-link.active{ background:rgba(255,255,255,.12); color:white }
            .sidebar .nav-section{ font-size:10px; text-transform:uppercase; letter-spacing:1px; color:rgba(255,255,255,.4); padding:12px 20px 4px }
            .main-content{ background:#f1f5f9; min-height:100vh }
            .topbar{ background:white; padding:12px 24px; border-bottom:1px solid #e2e8f0 }
            .card-modern{ border:none; border-radius:12px; box-shadow:0 2px 8px rgba(0,0,0,.07) }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Abastecimiento> abastecimientos = (List<Abastecimiento>) request.getAttribute("abastecimientos");
            List<Ordencompra> ordenes = (List<Ordencompra>) request.getAttribute("ordenesPendientes");
            String errorBackend = (String) request.getAttribute("error");
        %>
        <div class="container-fluid p-0">
            <div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-boxes me-2 text-primary"></i>Recepción de Abastecimiento</h6>
                            <small class="text-muted">Ingreso de mercadería al almacén central</small></div>
                        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                    </div>

                    <div class="p-4">
                        <% if (errorBackend != null) {%>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i> <%= errorBackend%>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <% }%>

                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3">
                                <h5 class="mb-0"><i class="fas fa-plus-circle me-2 text-primary"></i>Registrar Nuevo Ingreso</h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/AbastecimientoServlet" method="post" class="row g-3 align-items-end needs-validation" novalidate>
                                    
                                    <div class="col-md-5">
                                        <label class="form-label fw-semibold">Orden de Compra a Recibir</label>
                                        <select name="idOrden" class="form-select" required>
                                            <option value="">-- Seleccionar OC Aprobada --</option>
                                            <% if (ordenes != null) {
                                                for (Ordencompra o : ordenes) { %>
                                                <option value="<%= o.getIdOrden()%>">OC-<%= o.getIdOrden()%> - <%= o.getProveedor() != null ? o.getProveedor().getRazonSocial() : ""%></option>
                                            <% }} %>
                                        </select>
                                        <div class="invalid-feedback">Debe seleccionar una orden de compra válida.</div>
                                    </div>

                                    <div class="col-md-5">
                                        <label class="form-label fw-semibold">Observaciones (Opcional)</label>
                                        <input type="text" name="observaciones" class="form-control" placeholder="Ej: Mercadería en buen estado" maxlength="255">
                                    </div>

                                    <div class="col-md-2">
                                        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-save me-2"></i>Registrar</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Historial de Ingresos</h5>
                                <span class="badge bg-primary"><%= abastecimientos != null ? abastecimientos.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="px-4"># Ingreso</th>
                                                <th>OC Origen</th>
                                                <th>Artículo(s) / Cantidad</th>
                                                <th>Recepcionado Por</th>
                                                <th>Fecha y Hora</th>
                                                <th>Observaciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (abastecimientos != null && !abastecimientos.isEmpty()) {
                                                    for (Abastecimiento a : abastecimientos) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">IN-<%= a.getIdAbastecimiento()%></td>
                                                <td><span class="badge bg-light text-dark border">OC-<%= a.getOrden().getIdOrden()%></span></td>
                                                <td>
                                                    <% List<DetalleOc> detallesRecibidos = a.getOrden().getDetalles();
                                                        if (detallesRecibidos != null && !detallesRecibidos.isEmpty()) {
                                                            for (DetalleOc d : detallesRecibidos) { %>
                                                    <span class="badge bg-success-subtle text-success-emphasis border d-block mb-1 text-start">
                                                        <%= d.getArticulo() != null ? d.getArticulo().getNombre() : "Artículo eliminado"%>
                                                        <strong>+<%= d.getCantidad()%></strong>
                                                    </span>
                                                    <% }
                                                        } else { %>
                                                    <span class="text-muted small">Sin detalle</span>
                                                    <% } %>
                                                </td>
                                                <td><small class="fw-semibold"><%= a.getEmpleado().getNombreCompleto()%></small></td>
                                                <td><small class="text-muted"><%= a.getFechaRecepcion() != null ? a.getFechaRecepcion().toString().substring(0, 16) : "—"%></small></td>
                                                <td><small class="text-muted"><%= a.getObservaciones() != null && !a.getObservaciones().isEmpty() ? a.getObservaciones() : "Sin observaciones"%></small></td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="6" class="text-center py-5 text-muted"><i class="fas fa-box-open fa-3x mb-3 d-block"></i>No hay abastecimientos registrados</td></tr>
                                            <% }%>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Validación Frontend con Bootstrap
            (() => {
                'use strict'
                const forms = document.querySelectorAll('.needs-validation')
                Array.from(forms).forEach(form => {
                    form.addEventListener('submit', event => {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        form.classList.add('was-validated')
                    }, false)
                })
            })()
        </script>
    </body>
</html>