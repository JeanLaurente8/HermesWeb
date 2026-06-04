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
        </style>
    </head><body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Conformidad> conformidades = (List<Conformidad>) request.getAttribute("conformidades");
            List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            Conformidad conformidadEditar = (Conformidad) request.getAttribute("conformidadEditar");
            String errorBackend = (String) request.getAttribute("error");
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
                                        <label class="form-label fw-semibold">Solicitud</label>
                                        <select name="idSolicitud" class="form-select" required>
                                            <option value="">Seleccionar solicitud</option>
                                            <% if (solicitudes != null) {
                                                    for (Solicitud s : solicitudes) {
                                                        boolean sel = conformidadEditar != null && conformidadEditar.getSolicitud() != null
                                                                && conformidadEditar.getSolicitud().getIdSolicitud() == s.getIdSolicitud();%>
                                            <option value="<%= s.getIdSolicitud()%>" <%= sel ? "selected" : ""%>>
                                                #<%= s.getIdSolicitud()%> <%= s.getEmpleado() != null ? s.getEmpleado().getNombreCompleto() : "?"%>
                                                (<%= s.getEstadoSolicitud()%>)
                                            </option>
                                            <% }
                                                } %>
                                        </select>
                                        <div class="invalid-feedback">Por favor, seleccione una solicitud.</div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Empleado que Recibe</label>
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
                                        <div class="invalid-feedback">Por favor, seleccione el empleado receptor.</div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Comentarios</label>
                                        <input type="text" name="comentarios" class="form-control"
                                               value="<%= conformidadEditar != null && conformidadEditar.getComentarios() != null ? conformidadEditar.getComentarios() : ""%>"
                                               placeholder="Observaciones sobre la recepción"
                                               pattern="^[a-zA-ZÁ-ÿ0-9\s\-]*$" maxlength="255">
                                        <div class="invalid-feedback">Formato inválido. Solo se admiten letras, números, espacios y guiones.</div>
                                    </div>
                                    <div class="col-md-3 d-flex align-items-center gap-3">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="firmaConformidad" id="firma" role="switch"
                                                   <%= conformidadEditar != null && conformidadEditar.isFirmaConformidad() ? "checked" : ""%>>
                                            <label class="form-check-label fw-semibold" for="firma">Firma de Conformidad</label>
                                        </div>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i><%= conformidadEditar != null ? "Actualizar" : "Registrar"%>
                                        </button>
                                    </div>
                                    <% if (conformidadEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
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
                                            <tr><th class="px-4">#</th><th>Solicitud</th><th>Empleado Receptor</th><th>Fecha</th><th class="text-center">Firma</th><th>Comentarios</th><th class="text-center">Acciones</th></tr>
                                        </thead>
                                        <tbody>
                                            <% if (conformidades != null && !conformidades.isEmpty()) {
                                                    for (Conformidad c : conformidades) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= c.getIdConformidad()%></td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        #<%= c.getSolicitud() != null ? c.getSolicitud().getIdSolicitud() : "—"%>
                                                    </span>
                                                </td>
                                                <td><div class="fw-semibold"><%= c.getEmpleado() != null ? c.getEmpleado().getNombreCompleto() : "—"%></div></td>
                                                <td><small class="text-muted"><%= c.getFechaConformidad() != null ? c.getFechaConformidad().toString().replace("T", " ").substring(0, 16) : "—"%></small></td>
                                                <td class="text-center">
                                                    <% if (c.isFirmaConformidad()) { %>
                                                    <span class="badge bg-success"><i class="fas fa-check me-1"></i>Firmado</span>
                                                    <% } else { %>
                                                    <span class="badge bg-warning text-dark"><i class="fas fa-clock me-1"></i>Pendiente</span>
                                                    <% }%>
                                                </td>
                                                <td><small><%= c.getComentarios() != null ? c.getComentarios() : ""%></small></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=editar&id=<%= c.getIdConformidad()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=eliminar&id=<%= c.getIdConformidad()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('¿Eliminar conformidad #<%= c.getIdConformidad()%>?')"><i class="fas fa-trash"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted">
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
                                                           })()
        </script>
    </body></html>