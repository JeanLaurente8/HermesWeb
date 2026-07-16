<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes – Devoluciones</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            .sidebar{
                background:linear-gradient(180deg,#1a3a5c 0%,#0f2340 100%);
                min-height:100vh;
                color:white
            }
            .sidebar .nav-link{
                color:rgba(255,255,255,.75);
                padding:10px 20px;
                border-radius:8px;
                margin:2px 8px;
                transition:.2s;
                font-size:14px
            }
            .sidebar .nav-link:hover,.sidebar .nav-link.active{
                background:rgba(255,255,255,.12);
                color:white
            }
            .sidebar .nav-section{
                font-size:10px;
                text-transform:uppercase;
                letter-spacing:1px;
                color:rgba(255,255,255,.4);
                padding:12px 20px 4px
            }
            .main-content{
                background:#f1f5f9;
                min-height:100vh
            }
            .topbar{
                background:white;
                padding:12px 24px;
                border-bottom:1px solid #e2e8f0
            }
            .card-modern{
                border:none;
                border-radius:12px;
                box-shadow:0 2px 8px rgba(0,0,0,.07)
            }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
            List<Devolucion> devoluciones = (List<Devolucion>) request.getAttribute("devoluciones");
            String errorBackend = (String) request.getAttribute("error");
        %>
        <div class="container-fluid p-0"><div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-undo me-2 text-primary"></i>Devoluciones</h6>
                            <small class="text-muted">Registro de devolución de artículos entregados</small></div>
                        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                    </div>
                    <div class="p-4">

                        <% if (errorBackend != null) {%>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i> <%= errorBackend%>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <% }%>

                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3"><h5 class="mb-0"><i class="fas fa-plus-circle me-2 text-primary"></i>Nueva Devolución</h5></div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/DevolucionServlet" method="post" id="formDevolucion" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="motivo" id="inputMotivoOculto" value="">

                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Solicitud</label>
                                        <%
                                            java.util.Map<Integer, Integer> pendientes = (java.util.Map<Integer, Integer>) request.getAttribute("pendientes");
                                        %>
                                        <select name="idSolicitud" id="selectSolicitud" class="form-select" required>
                                            <option value="">— Seleccionar —</option>
                                            <% if (solicitudes != null) {
                                                    for (Solicitud s : solicitudes) {
                                                        int pend = pendientes != null && pendientes.get(s.getIdSolicitud()) != null ? pendientes.get(s.getIdSolicitud()) : s.getCantidad();
                                            %>
                                            <option value="<%= s.getIdSolicitud()%>"
                                                    data-pendiente="<%= pend%>"
                                                    data-articulo="<%= s.getArticulo() != null ? s.getArticulo().getNombre() : "—"%>">
                                                SOL-<%= s.getIdSolicitud()%> — <%= s.getArticulo() != null ? s.getArticulo().getNombre() : "—"%> (Pendiente: <%= pend%> de <%= s.getCantidad()%>)
                                            </option>
                                            <% }
                                                }%>
                                        </select>                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Pendiente por devolver</label>
                                        <input type="text" id="displayCantidadOriginal" class="form-control" disabled placeholder="—">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Cantidad a devolver</label>
                                        <input type="number" name="cantidadDevuelta" id="inputCantidadDevuelta" class="form-control" min="1" required disabled>
                                    </div>

                                    <div class="col-md-2 d-flex align-items-end mt-2">
                                        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-save me-1"></i>Registrar</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="modal fade" id="modalMotivo" tabindex="-1" data-bs-backdrop="static">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fas fa-comment-dots text-primary me-2"></i>Devolución parcial</h5>
                                    </div>
                                    <div class="modal-body text-start">
                                        <p>La cantidad a devolver es <strong>menor</strong> a la cantidad original de la solicitud. Indica el motivo:</p>
                                        <textarea id="inputMotivo" class="form-control" rows="3" placeholder="Ej: artículo dañado, sobrante, etc." required></textarea>
                                        <div class="text-danger small mt-1" id="errorMotivo" style="display:none;">El motivo es obligatorio.</div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="btnCancelarMotivo">Cancelar</button>
                                        <button type="button" class="btn btn-primary" id="btnConfirmarMotivo">Confirmar y Registrar</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Historial de Devoluciones</h5>
                                <span class="badge bg-primary"><%= devoluciones != null ? devoluciones.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr><th class="px-4">#</th><th>Fecha</th><th>Solicitud</th><th>Artículo</th><th class="text-center">Cant. Devuelta</th><th>Motivo</th><th>Gestionado por</th></tr>
                                        </thead>
                                        <tbody>
                                            <% if (devoluciones != null && !devoluciones.isEmpty()) {
                                                    for (Devolucion d : devoluciones) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">DEV-<%= d.getIdDevolucion()%></td>
                                                <td><small class="text-muted"><%= d.getFechaDevolucion() != null ? d.getFechaDevolucion().toString().replace("T", " ").substring(0, 16) : "—"%></small></td>
                                                <td>SOL-<%= d.getSolicitud().getIdSolicitud()%></td>
                                                <td><%= d.getSolicitud().getArticulo() != null ? d.getSolicitud().getArticulo().getNombre() : "—"%></td>
                                                <td class="text-center fw-bold"><%= d.getCantidadDevuelta()%></td>
                                                <td><small><%= d.getMotivo() != null ? d.getMotivo() : "—"%></small></td>
                                                <td><small><%= d.getEmpleado() != null ? d.getEmpleado().getNombreCompleto() : "—"%></small></td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted">No hay devoluciones registradas</td></tr>
                                            <% }%>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div></div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            const selectSolicitud = document.getElementById('selectSolicitud');
            const displayCantidadOriginal = document.getElementById('displayCantidadOriginal');
            const inputCantidadDevuelta = document.getElementById('inputCantidadDevuelta');
            const formDevolucion = document.getElementById('formDevolucion');
            const inputMotivoOculto = document.getElementById('inputMotivoOculto');

            let cantidadOriginalActual = 0;

            selectSolicitud.addEventListener('change', function () {
                const opt = this.options[this.selectedIndex];
                const pendiente = opt.getAttribute('data-pendiente');
                if (pendiente) {
                    cantidadOriginalActual = parseInt(pendiente, 10);
                    displayCantidadOriginal.value = cantidadOriginalActual;
                    inputCantidadDevuelta.disabled = false;
                    inputCantidadDevuelta.max = cantidadOriginalActual;
                    inputCantidadDevuelta.value = cantidadOriginalActual;
                } else {
                    cantidadOriginalActual = 0;
                    displayCantidadOriginal.value = '';
                    inputCantidadDevuelta.disabled = true;
                    inputCantidadDevuelta.value = '';
                }
            });
            const modalMotivoEl = document.getElementById('modalMotivo');
            const modalMotivo = new bootstrap.Modal(modalMotivoEl);
            const inputMotivo = document.getElementById('inputMotivo');
            const errorMotivo = document.getElementById('errorMotivo');
            const btnConfirmarMotivo = document.getElementById('btnConfirmarMotivo');

            formDevolucion.addEventListener('submit', function (e) {
                if (!formDevolucion.checkValidity()) {
                    e.preventDefault();
                    formDevolucion.classList.add('was-validated');
                    return;
                }

                const cantidadDevuelta = parseInt(inputCantidadDevuelta.value, 10);

                // Devolución parcial: pedimos motivo obligatorio antes de enviar
                if (cantidadDevuelta < cantidadOriginalActual && formDevolucion.dataset.motivoConfirmado !== 'true') {
                    e.preventDefault();
                    inputMotivo.value = '';
                    errorMotivo.style.display = 'none';
                    modalMotivo.show();
                }
            });

            btnConfirmarMotivo.addEventListener('click', function () {
                const motivo = inputMotivo.value.trim();
                if (!motivo) {
                    errorMotivo.style.display = 'block';
                    return;
                }
                inputMotivoOculto.value = motivo;
                formDevolucion.dataset.motivoConfirmado = 'true';
                modalMotivo.hide();
                formDevolucion.submit();
            });
        </script>
    </body>
</html>