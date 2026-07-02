<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*, util.AuthUtils" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Hermes – Solicitudes</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .sidebar{background:linear-gradient(180deg,#1a3a5c 0%,#0f2340 100%);min-height:100vh;color:white}
        .sidebar .nav-link{color:rgba(255,255,255,.75);padding:10px 20px;border-radius:8px;margin:2px 8px;transition:.2s;font-size:14px}
        .sidebar .nav-link:hover,.sidebar .nav-link.active{background:rgba(255,255,255,.12);color:white}
        .sidebar .nav-section{font-size:10px;text-transform:uppercase;letter-spacing:1px;color:rgba(255,255,255,.4);padding:12px 20px 4px}
        .main-content{background:#f1f5f9;min-height:100vh}
        .topbar{background:white;padding:12px 24px;border-bottom:1px solid #e2e8f0}
        .card-modern{border:none;border-radius:12px;box-shadow:0 2px 8px rgba(0,0,0,.07)}
        .detalle-row{background:#f8fafc;border:1px solid #e2e8f0;border-radius:8px;padding:10px 14px;margin-bottom:8px}
        .btn-add-line{border:2px dashed #2563eb;color:#2563eb;background:transparent;border-radius:8px;padding:8px;width:100%;transition:.2s}
        .btn-add-line:hover{background:#dbeafe}
        .input-disabled{background:#e9ecef !important;pointer-events:none;color:#6c757d}
    </style>
</head>
<body>
<%
    Empleado sesion = (Empleado) session.getAttribute("empleado");
    List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
    List<Articulo> articulos    = (List<Articulo>)  request.getAttribute("articulos");
    String errorBackend         = (String) request.getAttribute("error");

    boolean puedeCrear   = AuthUtils.tieneAccesoCompleto(sesion, "Solicitudes");
    boolean puedeGestionar = AuthUtils.puedeGestionarSolicitudes(sesion);
%>

<div class="container-fluid p-0"><div class="row g-0">

<jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

<div class="col-md-9 col-lg-10 main-content">
    <div class="topbar d-flex justify-content-between align-items-center">
        <div>
            <h6 class="mb-0 fw-bold"><i class="fas fa-clipboard-list me-2 text-primary"></i>Gestión de Solicitudes</h6>
            <small class="text-muted">Registro y seguimiento de pedidos de insumos</small>
        </div>
        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : "" %></small>
    </div>

    <div class="p-4">

        <%-- ── ERROR ── --%>
        <% if (errorBackend != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i><%= errorBackend %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <%-- ══════════════════════════════════════════════════════
             FORMULARIO NUEVA SOLICITUD — solo para quienes pueden crear
        ══════════════════════════════════════════════════════ --%>
        <% if (puedeCrear) { %>
        <div class="card card-modern mb-4">
            <div class="card-header bg-white py-3">
                <h5 class="mb-0"><i class="fas fa-plus-circle me-2 text-primary"></i>Nueva Solicitud</h5>
            </div>
            <div class="card-body">
                <form id="formSolicitud" action="${pageContext.request.contextPath}/SolicitudServlet" method="post" class="needs-validation" novalidate>
                    <input type="hidden" name="accion" value="guardar"/>

                    <%-- Empleado y Área: bloqueados, se toman de la sesión --%>
                    <div class="row g-3 mb-3">
                        <div class="col-md-5">
                            <label class="form-label fw-semibold">Empleado Solicitante</label>
                            <input type="text" class="form-control input-disabled"
                                   value="<%= sesion != null ? sesion.getNombreCompleto() : "" %>" readonly>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Área de Procedencia</label>
                            <input type="text" class="form-control input-disabled"
                                   value="<%= sesion != null && sesion.getArea() != null ? sesion.getArea().getNombreArea() : "Sin área asignada" %>" readonly>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Estado</label>
                            <input type="text" class="form-control input-disabled" value="Pendiente" readonly>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-12">
                            <label class="form-label fw-semibold">Descripción / Motivo General</label>
                            <textarea name="descripcion" class="form-control" rows="2" required
                                      placeholder="Describa el motivo general de la solicitud..."></textarea>
                            <div class="invalid-feedback">La descripción es obligatoria.</div>
                        </div>
                    </div>

                    <%-- MAESTRO-DETALLE: líneas de artículos --%>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">
                            <i class="fas fa-list me-1 text-primary"></i>Artículos Solicitados
                            <span class="badge bg-primary ms-2" id="contadorLineas">1</span>
                        </label>

                        <div id="contenedorLineas">
                            <%-- Línea 1 (inicial) --%>
                            <div class="detalle-row d-flex align-items-center gap-3" id="linea-1">
                                <div class="flex-grow-1">
                                    <select name="idArticulo[]" class="form-select" required>
                                        <option value="">— Seleccionar artículo —</option>
                                        <% if (articulos != null) {
                                               for (Articulo art : articulos) { %>
                                        <option value="<%= art.getIdArticulo() %>"><%= art.getNombre() %></option>
                                        <% }} %>
                                    </select>
                                    <div class="invalid-feedback">Seleccione un artículo.</div>
                                </div>
                                <div style="width:130px">
                                    <input type="number" name="cantidad[]" class="form-control" min="1" value="1" required placeholder="Cantidad">
                                    <div class="invalid-feedback">Mín. 1.</div>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="eliminarLinea(this)" disabled>
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>

                        <button type="button" class="btn-add-line mt-2" onclick="agregarLinea()">
                            <i class="fas fa-plus me-2"></i>Agregar otro artículo
                        </button>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane me-1"></i>Registrar Solicitud
                        </button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <%-- ══════════════════════════════════════════
             TABLA DE SOLICITUDES
        ══════════════════════════════════════════ --%>
        <div class="card card-modern">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>
                    <%= puedeGestionar ? "Todas las Solicitudes" : "Mis Solicitudes" %>
                </h5>
                <span class="badge bg-primary"><%= solicitudes != null ? solicitudes.size() : 0 %> registros</span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="bg-light">
                            <tr>
                                <th class="px-4">#</th>
                                <th>Solicitante / Área</th>
                                <th>Artículo</th>
                                <th class="text-center">Cant.</th>
                                <th>Fecha</th>
                                <th class="text-center">Estado</th>
                                <th class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (solicitudes != null && !solicitudes.isEmpty()) {
                               for (Solicitud s : solicitudes) {
                                   String badgeClass;
                                   switch (s.getEstadoSolicitud() != null ? s.getEstadoSolicitud() : "") {
                                       case "Aprobada":  badgeClass = "bg-success"; break;
                                       case "Rechazada": badgeClass = "bg-danger";  break;
                                       case "Enviada":   badgeClass = "bg-info";    break;
                                       case "Entregada": badgeClass = "bg-primary"; break;
                                       default:          badgeClass = "bg-warning text-dark";
                                   }
                                   boolean pendiente = "Pendiente".equals(s.getEstadoSolicitud());
                        %>
                        <tr>
                            <td class="px-4 fw-semibold text-primary">#<%= s.getIdSolicitud() %></td>
                            <td>
                                <div class="fw-semibold"><%= s.getEmpleado() != null ? s.getEmpleado().getNombreCompleto() : "—" %></div>
                                <small class="text-muted"><%= s.getArea() != null ? s.getArea().getNombreArea() : "—" %></small>
                            </td>
                            <td>
                                <div class="fw-semibold"><%= s.getArticulo() != null ? s.getArticulo().getNombre() : "—" %></div>
                            </td>
                            <td class="text-center fw-bold"><%= s.getCantidad() %></td>
                            <td><small class="text-muted"><%= s.getFechaSolicitud() != null ? s.getFechaSolicitud().toString().replace("T"," ").substring(0,16) : "—" %></small></td>
                            <td class="text-center"><span class="badge <%= badgeClass %>"><%= s.getEstadoSolicitud() %></span></td>
                            <td class="text-center">
                                <%-- Botón detalles — siempre visible --%>
                                <button class="btn btn-sm btn-outline-secondary me-1"
                                        onclick="verDetalles(<%= s.getIdSolicitud() %>,
                                                             '<%= s.getEmpleado() != null ? s.getEmpleado().getNombreCompleto().replace("'","") : "" %>',
                                                             '<%= s.getArea() != null ? s.getArea().getNombreArea().replace("'","") : "" %>',
                                                             '<%= s.getArticulo() != null ? s.getArticulo().getNombre().replace("'","") : "" %>',
                                                             '<%= s.getCantidad() %>',
                                                             '<%= s.getEstadoSolicitud() %>',
                                                             '<%= s.getFechaSolicitud() != null ? s.getFechaSolicitud().toString().replace("T"," ").substring(0,16) : "" %>',
                                                             '<%= s.getDescripcion() != null ? s.getDescripcion().replace("'","").replace("\"","") : "" %>')"
                                        title="Ver detalles">
                                    <i class="fas fa-eye"></i>
                                </button>

                                <%-- Aprobar y Rechazar — solo Gerente/Analista/Admin y solo si está Pendiente --%>
                                <% if (puedeGestionar && pendiente) { %>
                                <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=aprobar&id=<%= s.getIdSolicitud() %>"
                                   class="btn btn-sm btn-success me-1"
                                   onclick="return confirm('¿Aprobar solicitud #<%= s.getIdSolicitud() %>?')"
                                   title="Aprobar">
                                    <i class="fas fa-check"></i>
                                </a>
                                <button class="btn btn-sm btn-danger"
                                        onclick="abrirModalRechazo(<%= s.getIdSolicitud() %>)"
                                        title="Rechazar">
                                    <i class="fas fa-times"></i>
                                </button>
                                <% } %>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="7" class="text-center py-5 text-muted">
                            <i class="fas fa-clipboard-list fa-3x mb-3 d-block"></i>No hay solicitudes registradas
                        </td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</div></div>

<%-- ══════════════════════════════════════════════
     MODAL DETALLES
══════════════════════════════════════════════ --%>
<div class="modal fade" id="modalDetalles" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:12px;border:none;box-shadow:0 8px 32px rgba(0,0,0,.15)">
            <div class="modal-header" style="background:linear-gradient(135deg,#1a3a5c,#2563eb);color:white;border-radius:12px 12px 0 0">
                <h5 class="modal-title"><i class="fas fa-clipboard-list me-2"></i>Detalle de Solicitud <span id="detId"></span></h5>
                <button type="button" class="btn-close" style="filter:brightness(0) invert(1)" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <table class="table table-borderless mb-0">
                    <tbody>
                        <tr><th class="text-muted" style="width:40%">Solicitante</th><td id="detEmpleado" class="fw-semibold"></td></tr>
                        <tr><th class="text-muted">Área</th><td id="detArea"></td></tr>
                        <tr><th class="text-muted">Artículo</th><td id="detArticulo" class="fw-semibold"></td></tr>
                        <tr><th class="text-muted">Cantidad</th><td id="detCantidad"></td></tr>
                        <tr><th class="text-muted">Fecha</th><td id="detFecha"></td></tr>
                        <tr><th class="text-muted">Estado</th><td id="detEstado"></td></tr>
                        <tr><th class="text-muted">Descripción</th><td id="detDescripcion" class="text-muted fst-italic"></td></tr>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<%-- ══════════════════════════════════════════════
     MODAL RECHAZO CON MOTIVO
══════════════════════════════════════════════ --%>
<div class="modal fade" id="modalRechazo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:12px;border:none;box-shadow:0 8px 32px rgba(0,0,0,.15)">
            <div class="modal-header bg-danger text-white" style="border-radius:12px 12px 0 0">
                <h5 class="modal-title"><i class="fas fa-times-circle me-2"></i>Rechazar Solicitud</h5>
                <button type="button" class="btn-close" style="filter:brightness(0) invert(1)" data-bs-dismiss="modal"></button>
            </div>
            <form id="formRechazo" action="${pageContext.request.contextPath}/SolicitudServlet" method="post">
                <input type="hidden" name="accion" value="rechazar"/>
                <input type="hidden" name="idSolicitud" id="idSolicitudRechazo"/>
                <div class="modal-body p-4">
                    <div class="alert alert-warning d-flex gap-2 align-items-center">
                        <i class="fas fa-exclamation-triangle"></i>
                        <div>Esta acción cambiará el estado de la solicitud a <strong>Rechazada</strong>.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Motivo del Rechazo <span class="text-danger">*</span></label>
                        <textarea id="motivoRechazo" name="motivoRechazo" class="form-control" rows="3"
                                  placeholder="Ingrese el motivo del rechazo..."></textarea>
                        <div class="text-danger small mt-1 d-none" id="errorMotivo">
                            <i class="fas fa-exclamation-circle me-1"></i>El motivo es obligatorio para rechazar la solicitud.
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-danger" onclick="confirmarRechazo()">
                        <i class="fas fa-times me-1"></i>Confirmar Rechazo
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // MAESTRO-DETALLE
    let contadorLineas = 1;

    const articulosData = [
        <%
            if (articulos != null) {
                boolean primero = true;
                for (Articulo art : articulos) {
                    if (!primero) out.print(",");
                    String nombreEscapado = art.getNombre() == null ? "" :
                        art.getNombre()
                           .replace("\\", "\\\\")
                           .replace("\"", "\\\"")
                           .replace("\r", "")
                           .replace("\n", " ");
                    out.print("{\"id\":" + art.getIdArticulo() + ",\"nombre\":\"" + nombreEscapado + "\"}");
                    primero = false;
                }
            }
        %>
    ];

    function crearSelectArticulo() {
        const select = document.createElement('select');
        select.name = 'idArticulo[]';
        select.className = 'form-select';
        select.required = true;

        const optVacia = document.createElement('option');
        optVacia.value = '';
        optVacia.textContent = '— Seleccionar artículo —';
        select.appendChild(optVacia);

        articulosData.forEach(art => {
            const opt = document.createElement('option');
            opt.value = art.id;
            opt.textContent = art.nombre;
            select.appendChild(opt);
        });

        return select;
    }

    function agregarLinea() {
        contadorLineas++;
        document.getElementById('contadorLineas').textContent = contadorLineas;

        const div = document.createElement('div');
        div.className = 'detalle-row d-flex align-items-center gap-3';
        div.id = 'linea-' + contadorLineas;

        const colSelect = document.createElement('div');
        colSelect.className = 'flex-grow-1';
        colSelect.appendChild(crearSelectArticulo());

        const colCantidad = document.createElement('div');
        colCantidad.style.width = '130px';
        colCantidad.innerHTML = `<input type="number" name="cantidad[]" class="form-control" min="1" value="1" required placeholder="Cantidad">`;

        const btnEliminar = document.createElement('button');
        btnEliminar.type = 'button';
        btnEliminar.className = 'btn btn-sm btn-outline-danger';
        btnEliminar.onclick = function () { eliminarLinea(this); };
        btnEliminar.innerHTML = '<i class="fas fa-times"></i>';

        div.appendChild(colSelect);
        div.appendChild(colCantidad);
        div.appendChild(btnEliminar);
        document.getElementById('contenedorLineas').appendChild(div);

        const primeraBtn = document.querySelector('#linea-1 button');
        if (primeraBtn) primeraBtn.disabled = false;
    }

    function eliminarLinea(btn) {
        const linea = btn.closest('.detalle-row');
        const contenedor = document.getElementById('contenedorLineas');
        if (contenedor.children.length <= 1) return;
        linea.remove();
        contadorLineas--;
        document.getElementById('contadorLineas').textContent = contadorLineas;

        if (contenedor.children.length === 1) {
            const btn1 = contenedor.querySelector('button');
            if (btn1) btn1.disabled = true;
        }
    }

    // MODAL DETALLES
    function verDetalles(id, empleado, area, articulo, cantidad, estado, fecha, descripcion) {
        document.getElementById('detId').textContent = '#' + id;
        document.getElementById('detEmpleado').textContent   = empleado   || '—';
        document.getElementById('detArea').textContent       = area       || '—';
        document.getElementById('detArticulo').textContent   = articulo   || '—';
        document.getElementById('detCantidad').textContent   = cantidad   || '—';
        document.getElementById('detFecha').textContent      = fecha      || '—';
        document.getElementById('detDescripcion').textContent= descripcion|| '—';

        const estadoEl = document.getElementById('detEstado');
        const estadoTexto = (estado || '').trim();
        const clases = {
            'Aprobada':  'badge bg-success',
            'Rechazada': 'badge bg-danger',
            'Enviada':   'badge bg-info',
            'Entregada': 'badge bg-primary',
            'Pendiente': 'badge bg-warning text-dark'
        };
        estadoEl.innerHTML = '<span class="' + (clases[estadoTexto] || 'badge bg-secondary') + '">' + (estadoTexto || 'Sin estado') + '</span>';

        new bootstrap.Modal(document.getElementById('modalDetalles')).show();
    }

    // MODAL RECHAZO
    function abrirModalRechazo(idSolicitud) {
        document.getElementById('idSolicitudRechazo').value = idSolicitud;
        document.getElementById('motivoRechazo').value = '';
        document.getElementById('errorMotivo').classList.add('d-none');
        new bootstrap.Modal(document.getElementById('modalRechazo')).show();
    }

    function confirmarRechazo() {
        const motivo = document.getElementById('motivoRechazo').value.trim();
        if (!motivo) {
            document.getElementById('errorMotivo').classList.remove('d-none');
            return;
        }
        document.getElementById('errorMotivo').classList.add('d-none');
        document.getElementById('formRechazo').submit();
    }

    // VALIDACIÓN BOOTSTRAP
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
