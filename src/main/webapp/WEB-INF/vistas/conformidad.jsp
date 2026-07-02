<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html><html lang="es"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes Conformidad</title>
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
            /* Estilo extra para el checkbox de estado */
            .estado-checkbox input:checked + label {
                color: #198754;
                font-weight: bold;
            } /* Verde Conforme */
            .estado-checkbox input:not(:checked) + label {
                color: #dc3545;
                font-weight: bold;
            } /* Rojo Rechazado */
        </style>
    </head><body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Conformidad> conformidades = (List<Conformidad>) request.getAttribute("conformidades");
            List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            Conformidad conformidadEditar = (Conformidad) request.getAttribute("conformidadEditar");
            String errorBackend = (String) request.getAttribute("error");
            boolean esEmpleadoSesion = sesion != null && "Empleado".equalsIgnoreCase(sesion.getCargo());
        %>
        <%
            boolean esAdmin = sesion != null && ("Gerente Compras".equals(sesion.getCargo())
                    || "Administrador".equals(sesion.getCargo())
                    || "admin".equalsIgnoreCase(sesion.getUsername()));
        %>
        <div class="container-fluid p-0"><div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-check-circle me-2 text-primary"></i>Conformidad de Pedidos</h6>
                            <small class="text-muted">Registro de recepción y firma de conformidad</small></div>
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
                                <h5 class="mb-0"><i class="fas fa-<%= conformidadEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i>
                                    <%= conformidadEditar != null ? "Editar Conformidad" : "Registrar Conformidad"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/ConformidadServlet" method="post" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= conformidadEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (conformidadEditar != null) {%>
                                    <input type="hidden" name="idConformidad" value="<%= conformidadEditar.getIdConformidad()%>"/>
                                    <% } %>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Solicitud Base</label>
                                        <select name="idSolicitud" id="selectSolicitud" class="form-select" required>
                                            <option value="" data-articulo="" data-cantidad="">Seleccionar solicitud</option>
                                            <% if (solicitudes != null) {
                                                    for (Solicitud s : solicitudes) {
                                                        boolean sel = conformidadEditar != null && conformidadEditar.getSolicitud() != null
                                                                && conformidadEditar.getSolicitud().getIdSolicitud() == s.getIdSolicitud();

                                                        // Guardamos el artículo y cantidad en data-attributes
                                                        String nombreArticulo = (s.getArticulo() != null) ? s.getArticulo().getNombre() : "Sin Artículo";
                                                        String cantidadStr = (s.getCantidad() != null) ? String.valueOf(s.getCantidad()) : "0";
                                            %>
                                            <option value="<%= s.getIdSolicitud()%>" data-articulo="<%= nombreArticulo%>" data-cantidad="<%= cantidadStr%>" <%= sel ? "selected" : ""%>>
                                                #<%= s.getIdSolicitud()%> - <%= s.getEmpleado() != null ? s.getEmpleado().getNombreCompleto() : "?"%>
                                            </option>
                                            <% }
                                                }%>
                                        </select>
                                        <div class="invalid-feedback">Por favor, seleccione una solicitud.</div>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-muted">Artículo a Confirmar</label>
                                        <input type="text" id="displayArticulo" class="form-control bg-light" readonly tabindex="-1"
                                               value="<%= conformidadEditar != null && conformidadEditar.getSolicitud() != null && conformidadEditar.getSolicitud().getArticulo() != null ? conformidadEditar.getSolicitud().getArticulo().getNombre() : ""%>">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold text-muted">Cantidad</label>
                                        <input type="text" id="displayCantidad" class="form-control bg-light text-center" readonly tabindex="-1"
                                               value="<%= conformidadEditar != null && conformidadEditar.getSolicitud() != null && conformidadEditar.getSolicitud().getCantidad() != null ? conformidadEditar.getSolicitud().getCantidad() : ""%>">
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Empleado</label>
                                        <% if (esEmpleadoSesion) { %>
                                        <input type="hidden" name="idEmpleado" value="<%= sesion.getIdEmpleado()%>">
                                        <input type="text" class="form-control bg-light" readonly tabindex="-1"
                                               value="<%= sesion.getNombreCompleto()%>">
                                        <% } else { %>
                                        <select name="idEmpleado" class="form-select" required>
                                            <option value="">Seleccionar empleado</option>
                                            <% if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = conformidadEditar != null && conformidadEditar.getEmpleado() != null
                                                                && conformidadEditar.getEmpleado().getIdEmpleado() == e.getIdEmpleado();%>
                                            <option value="<%= e.getIdEmpleado()%>" <%= sel ? "selected" : ""%>><%= e.getNombreCompleto()%></option>
                                            <% }
                                                }%>
                                        </select>
                                        <% } %>
                                        <div class="invalid-feedback">Por favor, seleccione el empleado.</div>
                                    </div>

                                    <div class="col-md-8 d-flex align-items-center">
                                        <div class="form-check form-switch estado-checkbox fs-5 ms-2 mt-4">
                                            <input class="form-check-input shadow-none" type="checkbox" name="firmaConformidad" id="firma" role="switch"
                                                   <%= (conformidadEditar == null || conformidadEditar.isFirmaConformidad()) ? "checked" : ""%>>
                                            <label class="form-check-label ms-2" id="labelFirma" for="firma" style="cursor:pointer;">
                                                <%= (conformidadEditar == null || conformidadEditar.isFirmaConformidad()) ? "Conforme" : "Rechazado"%>
                                            </label>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label fw-semibold">Comentarios / Observaciones</label>
                                        <textarea name="comentarios" class="form-control" rows="3"
                                                  placeholder="Escriba aquí las observaciones sobre la recepción o el motivo de rechazo..."
                                                  pattern="^[a-zA-ZÁ-ÿ0-9\s\-]*$" maxlength="255"><%= conformidadEditar != null && conformidadEditar.getComentarios() != null ? conformidadEditar.getComentarios() : ""%></textarea>
                                        <div class="invalid-feedback">Formato inválido. Solo se admiten letras, números, espacios y guiones.</div>
                                    </div>

                                    <div class="col-12 text-end mt-3">
                                        <% if (conformidadEditar != null) { %>
                                        <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="btn btn-secondary me-2">Cancelar</a>
                                        <% }%>
                                        <button type="submit" class="btn btn-primary px-4">
                                            <i class="fas fa-save me-1"></i><%= conformidadEditar != null ? "Actualizar" : "Registrar Conformidad"%>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Registro de Conformidades</h5>
                                <span class="badge bg-primary"><%= conformidades != null ? conformidades.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="px-4">#</th>
                                                <th>Solicitud</th>
                                                <th>Empleado</th>
                                                <th>Artículo Entregado</th>
                                                <th>Fecha</th>
                                                <th class="text-center">Estado</th>
                                                <th>Comentarios</th>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (conformidades != null && !conformidades.isEmpty()) {
                                                    for (Conformidad c : conformidades) {
                                                        // Extraer datos visuales de la solicitud vinculada
                                                        String nombreArticulo = (c.getSolicitud() != null && c.getSolicitud().getArticulo() != null) ? c.getSolicitud().getArticulo().getNombre() : "—";
                                                        String cantidad = (c.getSolicitud() != null && c.getSolicitud().getCantidad() != null) ? String.valueOf(c.getSolicitud().getCantidad()) : "—";
                                            %>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= c.getIdConformidad()%></td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        #<%= c.getSolicitud() != null ? c.getSolicitud().getIdSolicitud() : "—"%>
                                                    </span>
                                                </td>
                                                <td><div class="fw-semibold"><%= c.getEmpleado() != null ? c.getEmpleado().getNombreCompleto() : "—"%></div></td>

                                                <td>
                                                    <span class="fw-bold text-primary"><%= cantidad%>x</span> <%= nombreArticulo%>
                                                </td>

                                                <td><small class="text-muted"><%= c.getFechaConformidad() != null ? c.getFechaConformidad().toString().replace("T", " ").substring(0, 16) : "—"%></small></td>
                                                <td class="text-center">
                                                    <% if (c.isFirmaConformidad()) { %>
                                                    <span class="badge bg-success"><i class="fas fa-check me-1"></i>Conforme</span>
                                                    <% } else { %>
                                                    <span class="badge bg-danger"><i class="fas fa-times me-1"></i>Rechazado</span>
                                                    <% }%>
                                                </td>
                                                <td><small class="text-truncate d-inline-block" style="max-width: 150px;" title="<%= c.getComentarios() != null ? c.getComentarios() : ""%>"><%= c.getComentarios() != null ? c.getComentarios() : ""%></small></td>
                                                <td class="text-center">
                                                    <% if (!esEmpleadoSesion) { %>
                                                    <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=editar&id=<%= c.getIdConformidad()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=eliminar&id=<%= c.getIdConformidad()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('¿Eliminar conformidad #<%= c.getIdConformidad()%>?')"><i class="fas fa-trash"></i></a>
                                                    <% } %> </td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="8" class="text-center py-5 text-muted">
                                                    <i class="fas fa-check-circle fa-3x mb-3 d-block"></i>No hay conformidades registradas
                                                </td></tr>
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
                                                           })();

                                                           document.addEventListener("DOMContentLoaded", function () {
                                                               const selectSolicitud = document.getElementById('selectSolicitud');
                                                               const displayArticulo = document.getElementById('displayArticulo');
                                                               const displayCantidad = document.getElementById('displayCantidad');

                                                               if (selectSolicitud) {
                                                                   selectSolicitud.addEventListener('change', function () {
                                                                       const selectedOption = this.options[this.selectedIndex];
                                                                       const articulo = selectedOption.getAttribute('data-articulo');
                                                                       const cantidad = selectedOption.getAttribute('data-cantidad');

                                                                       displayArticulo.value = articulo ? articulo : "";
                                                                       displayCantidad.value = cantidad ? cantidad : "";
                                                                   });
                                                               }

                                                               const checkboxFirma = document.getElementById('firma');
                                                               const labelFirma = document.getElementById('labelFirma');

                                                               if (checkboxFirma && labelFirma) {
                                                                   checkboxFirma.addEventListener('change', function () {
                                                                       if (this.checked) {
                                                                           labelFirma.textContent = 'Conforme';
                                                                       } else {
                                                                           labelFirma.textContent = 'Rechazado';
                                                                       }
                                                                   });
                                                               }
                                                           });
        </script>
    </body></html>