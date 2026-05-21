<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html><html lang="es"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes – Empleados</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>.sidebar{
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
        }</style>
    </head><body>
        <%  Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            List<Areatrabajo> areas = (List<Areatrabajo>) request.getAttribute("areas");
            Empleado empleadoEditar = (Empleado) request.getAttribute("empleadoEditar");%>
        <div class="container-fluid p-0"><div class="row g-0">
                <div class="col-md-3 col-lg-2 sidebar">
                    <div class="p-3 border-bottom border-secondary border-opacity-25"><div class="d-flex align-items-center gap-2"><span style="font-size:22px">🛡️</span><div><div class="fw-bold" style="font-size:14px">Hermes</div><div style="font-size:11px;opacity:.6">Inventario</div></div></div></div>
                    <nav class="pt-2"><ul class="nav flex-column">
                            <li><a href="${pageContext.request.contextPath}/MenuServlet" class="nav-link"><i class="fas fa-home me-2"></i>Inicio</a></li>
                            <div class="nav-section">Inventario</div>
                            <li><a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="nav-link"><i class="fas fa-boxes me-2"></i>Artículos</a></li>
                            <li><a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="nav-link"><i class="fas fa-building me-2"></i>Áreas</a></li>
                            <div class="nav-section">Compras</div>
                            <li><a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="nav-link"><i class="fas fa-clipboard-list me-2"></i>Solicitudes</a></li>
                            <li><a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Órdenes OC</a></li>
                            <li><a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="nav-link"><i class="fas fa-check-circle me-2"></i>Conformidad</a></li>
                            <div class="nav-section">Administración</div>
                            <li><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="nav-link active"><i class="fas fa-users me-2"></i>Empleados</a></li>
                            <li><a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="nav-link"><i class="fas fa-truck me-2"></i>Proveedores</a></li>
                            <div class="nav-section mt-2"></div>
                            <li><a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-danger"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul></nav>
                </div>
                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-primary"></i>Gestión de Empleados</h6><small class="text-muted">Personal registrado en el sistema</small></div>
                        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                    </div>
                    <div class="p-4">
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3"><h5 class="mb-0"><i class="fas fa-<%= empleadoEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i><%= empleadoEditar != null ? "Editar Empleado" : "Nuevo Empleado"%></h5></div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/EmpleadoServlet" method="post" class="row g-3">
                                    <input type="hidden" name="accion" value="<%= empleadoEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (empleadoEditar != null) {%><input type="hidden" name="idEmpleado" value="<%= empleadoEditar.getIdEmpleado()%>"/><%}%>
                                    <div class="col-md-2"><label class="form-label fw-semibold">DNI</label><input type="text" name="dni" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getDni() : ""%>" maxlength="8" required placeholder="12345678"></div>
                                    <div class="col-md-3"><label class="form-label fw-semibold">Nombre</label><input type="text" name="nombre" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getNombre() : ""%>" required></div>
                                    <div class="col-md-3"><label class="form-label fw-semibold">Apellido Paterno</label><input type="text" name="apellidoPaterno" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getApellidoPaterno() : ""%>" required></div>
                                    <div class="col-md-3"><label class="form-label fw-semibold">Apellido Materno</label><input type="text" name="apellidoMaterno" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getApellidoMaterno() : ""%>" required></div>
                                    <div class="col-md-3"><label class="form-label fw-semibold">Correo</label><input type="email" name="correo" class="form-control" value="<%= empleadoEditar != null && empleadoEditar.getCorreo() != null ? empleadoEditar.getCorreo() : ""%>"></div>
                                    <div class="col-md-2"><label class="form-label fw-semibold">Username</label><input type="text" name="username" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getUsername() : ""%>" required></div>
                                    <div class="col-md-2"><label class="form-label fw-semibold">Password</label><input type="password" name="password" class="form-control" value="<%= empleadoEditar != null ? empleadoEditar.getPassword() : ""%>" required></div>
                                    <div class="col-md-2"><label class="form-label fw-semibold">Cargo</label>
                                        <select name="cargo" class="form-select" required>
                                            <% String[] cargos = {"Empleado", "Asistente Almacén", "Analista Compras", "Gerente Compras"};
                                for (String c : cargos) {
                                    String sel = empleadoEditar != null && c.equals(empleadoEditar.getCargo()) ? "selected" : "";%>
                                            <option value="<%= c%>" <%= sel%>><%= c%></option>
                                            <%}%>
                                        </select>
                                    </div>
                                    <div class="col-md-2"><label class="form-label fw-semibold">Área</label>
                                        <select name="idArea" class="form-select">
                                            <option value="">— Sin área —</option>
                                            <% if (areas != null) {
                                    for (Areatrabajo ar : areas) {
                                        String sel = empleadoEditar != null && empleadoEditar.getArea() != null && empleadoEditar.getArea().getIdArea() == ar.getIdArea() ? "selected" : "";%>
                                            <option value="<%= ar.getIdArea()%>" <%= sel%>><%= ar.getNombreArea()%></option>
                                            <%}
                                }%>
                                        </select>
                                    </div>
                                    <% if (empleadoEditar != null) {%>
                                    <div class="col-md-1 d-flex align-items-end pb-1"><div class="form-check"><input class="form-check-input" type="checkbox" name="estado" id="estEmp" <%= empleadoEditar.isEstado() ? "checked" : ""%>><label class="form-check-label small" for="estEmp">Activo</label></div></div>
                                            <%}%>
                                    <div class="col-md-2 d-flex align-items-end"><button type="submit" class="btn btn-primary w-100"><i class="fas fa-save me-1"></i><%= empleadoEditar != null ? "Actualizar" : "Guardar"%></button></div>
                                    <%if (empleadoEditar != null) {%><div class="col-md-2 d-flex align-items-end"><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a></div><%}%>
                                </form>
                            </div>
                        </div>
                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Empleados</h5>
                                <span class="badge bg-primary"><%= empleados != null ? empleados.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0"><div class="table-responsive"><table class="table table-hover mb-0">
                                        <thead class="bg-light"><tr><th class="px-4">#</th><th>Nombre Completo</th><th>DNI</th><th>Username</th><th>Cargo</th><th>Área</th><th class="text-center">Estado</th><th class="text-center">Acciones</th></tr></thead>
                                        <tbody>
                                            <%if (empleados != null && !empleados.isEmpty()) {
                        for (Empleado e : empleados) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= e.getIdEmpleado()%></td>
                                                <td><div class="fw-semibold"><%= e.getNombreCompleto()%></div><small class="text-muted"><%= e.getCorreo() != null ? e.getCorreo() : ""%></small></td>
                                                <td><%= e.getDni()%></td>
                                                <td><code><%= e.getUsername()%></code></td>
                                                <td><span class="badge bg-primary bg-opacity-10 text-primary"><%= e.getCargo()%></span></td>
                                                <td><%= e.getArea() != null ? e.getArea().getNombreArea() : "—"%></td>
                                                <td class="text-center"><span class="badge <%= e.isEstado() ? "bg-success" : "bg-secondary"%>"><%= e.isEstado() ? "Activo" : "Inactivo"%></span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=editar&id=<%= e.getIdEmpleado()%>" class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=eliminar&id=<%= e.getIdEmpleado()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Desactivar empleado?')"><i class="fas fa-toggle-off"></i></a>
                                                </td>
                                            </tr>
                                            <%}
                } else {%><tr><td colspan="8" class="text-center py-5 text-muted"><i class="fas fa-users fa-3x mb-3 d-block"></i>No hay empleados registrados</td></tr><%}%>
                                        </tbody>
                                    </table></div></div>
                        </div>
                    </div>
                </div>
            </div></div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body></html>