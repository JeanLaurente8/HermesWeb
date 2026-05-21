<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html><html lang="es"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes Solicitudes</title>
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
            List<Solicitud> solicitudes = (List<Solicitud>) request.getAttribute("solicitudes");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            List<Areatrabajo> areas = (List<Areatrabajo>) request.getAttribute("areas");
            Solicitud solicitudEditar = (Solicitud) request.getAttribute("solicitudEditar");
            String[] estados = {"Pendiente", "Aprobada", "Rechazada", "Enviada", "Entregada"};
        %>
        <div class="container-fluid p-0"><div class="row g-0">

                <!-- SIDEBAR -->
                <div class="col-md-3 col-lg-2 sidebar">
                    <div class="p-3 border-bottom border-secondary border-opacity-25">
                        <div class="d-flex align-items-center gap-2"><span style="font-size:22px">🛡️</span>
                            <div><div class="fw-bold" style="font-size:14px">Hermes</div><div style="font-size:11px;opacity:.6">Inventario</div></div></div>
                    </div>
                    <nav class="pt-2"><ul class="nav flex-column">
                            <li><a href="${pageContext.request.contextPath}/MenuServlet" class="nav-link"><i class="fas fa-home me-2"></i>Inicio</a></li>
                            <div class="nav-section">Inventario</div>
                            <li><a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="nav-link"><i class="fas fa-boxes me-2"></i>Artículos</a></li>
                            <li><a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="nav-link"><i class="fas fa-building me-2"></i>Áreas</a></li>
                            <div class="nav-section">Compras</div>
                            <li><a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="nav-link active"><i class="fas fa-clipboard-list me-2"></i>Solicitudes</a></li>
                            <li><a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Órdenes OC</a></li>
                            <li><a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="nav-link"><i class="fas fa-check-circle me-2"></i>Conformidad</a></li>
                            <div class="nav-section">AdministraciÃ³n</div>
                            <li><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="nav-link"><i class="fas fa-users me-2"></i>Empleados</a></li>
                            <li><a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="nav-link"><i class="fas fa-truck me-2"></i>Proveedores</a></li>
                            <div class="nav-section mt-2"></div>
                            <li><a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-danger"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul></nav>
                </div>

                <!-- MAIN -->
                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-clipboard-list me-2 text-primary"></i>Gestión de Solicitudes</h6>
                            <small class="text-muted">Registro y seguimiento de pedidos de insumos</small></div>
                        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                    </div>
                    <div class="p-4">

                        <!-- FORMULARIO -->
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3">
                                <h5 class="mb-0"><i class="fas fa-<%= solicitudEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i>
                                    <%= solicitudEditar != null ? "Editar Solicitud" : "Nueva Solicitud"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/SolicitudServlet" method="post" class="row g-3">
                                    <input type="hidden" name="accion" value="<%= solicitudEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (solicitudEditar != null) {%>
                                    <input type="hidden" name="idSolicitud" value="<%= solicitudEditar.getIdSolicitud()%>"/>
                                    <% } %>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Empleado Solicitante</label>
                                        <select name="idEmpleado" class="form-select" required>
                                            <option value="">Seleccionar</option>
                                            <% if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = solicitudEditar != null && solicitudEditar.getEmpleado() != null
                                                && solicitudEditar.getEmpleado().getIdEmpleado() == e.getIdEmpleado();%>
                                            <option value="<%= e.getIdEmpleado()%>" <%= sel ? "selected" : ""%>><%= e.getNombreCompleto()%></option>
                                            <% }
                                } %>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Área de Procedencia</label>
                                        <select name="idArea" class="form-select" required>
                                            <option value="">Seleccionar</option>
                                            <% if (areas != null) {
                                                    for (Areatrabajo a : areas) {
                                                        boolean sel = solicitudEditar != null && solicitudEditar.getArea() != null
                                                && solicitudEditar.getArea().getIdArea() == a.getIdArea();%>
                                            <option value="<%= a.getIdArea()%>" <%= sel ? "selected" : ""%>><%= a.getNombreArea()%></option>
                                            <% }
                                } %>
                                        </select>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Estado</label>
                                        <select name="estadoSolicitud" class="form-select">
                                            <% for (String est : estados) {
                                    boolean sel = solicitudEditar != null && est.equals(solicitudEditar.getEstadoSolicitud());%>
                                            <option value="<%= est%>" <%= sel ? "selected" : ""%>><%= est%></option>
                                            <% }%>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Descripción / Motivo</label>
                                        <textarea name="descripcion" class="form-control" rows="2"
                                                  placeholder="Describa el motivo de la solicitud..."><%= solicitudEditar != null && solicitudEditar.getDescripcion() != null ? solicitudEditar.getDescripcion() : ""%></textarea>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i><%= solicitudEditar != null ? "Actualizar" : "Registrar"%>
                                        </button>
                                    </div>
                                    <% if (solicitudEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>

                        <!-- TABLA -->
                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Solicitudes</h5>
                                <span class="badge bg-primary"><%= solicitudes != null ? solicitudes.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr><th class="px-4">#</th><th>Solicitante</th><th>Área</th><th>Fecha</th><th class="text-center">Estado</th><th>Descripción</th><th class="text-center">Acciones</th></tr>
                                        </thead>
                                        <tbody>
                                            <% if (solicitudes != null && !solicitudes.isEmpty()) {
                                                    for (Solicitud s : solicitudes) {
                                                        String badgeClass;
                                                        switch (s.getEstadoSolicitud() != null ? s.getEstadoSolicitud() : "") {
                                                            case "Aprobada":
                                                                badgeClass = "bg-success";
                                                                break;
                                                            case "Rechazada":
                                                                badgeClass = "bg-danger";
                                                                break;
                                                            case "Enviada":
                                                                badgeClass = "bg-info";
                                                                break;
                                                            case "Entregada":
                                                                badgeClass = "bg-primary";
                                                                break;
                                                            default:
                                                                badgeClass = "bg-warning text-dark";
                                    }%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= s.getIdSolicitud()%></td>
                                                <td><div class="fw-semibold"><%= s.getEmpleado() != null ? s.getEmpleado().getNombreCompleto() : "â€”"%></div></td>
                                                <td><%= s.getArea() != null ? s.getArea().getNombreArea() : "â€”"%></td>
                                                <td><small class="text-muted"><%= s.getFechaSolicitud() != null ? s.getFechaSolicitud().toString().replace("T", " ").substring(0, 16) : "â€”"%></small></td>
                                                <td class="text-center"><span class="badge <%= badgeClass%>"><%= s.getEstadoSolicitud()%></span></td>
                                                <td><small><%= s.getDescripcion() != null ? s.getDescripcion() : ""%></small></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=editar&id=<%= s.getIdSolicitud()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=eliminar&id=<%= s.getIdSolicitud()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('Â¿Eliminar solicitud #<%= s.getIdSolicitud()%>?')"><i class="fas fa-trash"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                        } else { %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted">
                                                    <i class="fas fa-clipboard-list fa-3x mb-3 d-block"></i>No hay solicitudes registradas
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
    </body></html>