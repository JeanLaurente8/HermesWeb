<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hermes – Áreas de Trabajo</title>
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
            .table-modern{
                background:white;
                border-radius:10px;
                overflow:hidden;
                box-shadow:0 2px 4px rgba(0,0,0,.05)
            }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Areatrabajo> areas = (List<Areatrabajo>) request.getAttribute("areas");
            Areatrabajo areaEditar = (Areatrabajo) request.getAttribute("areaEditar");
            String errorBackend = (String) request.getAttribute("error");
        %>
        <%
            boolean esAdmin = sesion != null && ("Gerente Compras".equals(sesion.getCargo())
                    || "Administrador".equals(sesion.getCargo())
                    || "admin".equalsIgnoreCase(sesion.getUsername()));
        %>
        <div class="container-fluid p-0">
            <div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-building me-2 text-primary"></i>Áreas de Trabajo</h6>
                            <small class="text-muted">Gestión de sedes y áreas de la empresa</small></div>
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
                                <h5 class="mb-0"><i class="fas fa-<%= areaEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i><%= areaEditar != null ? "Editar Área" : "Nueva Área de Trabajo"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/AreaTrabajoServlet" method="post" class="row g-3 align-items-end needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= areaEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (areaEditar != null) {%><input type="hidden" name="idArea" value="<%= areaEditar.getIdArea()%>"/><% }%>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Nombre del Área</label>
                                        <input type="text" name="nombreArea" class="form-control" 
                                               value="<%= areaEditar != null ? areaEditar.getNombreArea() : ""%>" 
                                               placeholder="Ej: Almacén Central" 
                                               required minlength="3" maxlength="50" pattern="^[a-zA-ZÁ-ÿ\s\-]+$">
                                        <div class="invalid-feedback">
                                            El nombre debe tener entre 3 y 50 caracteres. Solo se permiten letras, espacios y guiones.
                                        </div>
                                    </div>
                                    <% if (areaEditar != null) {%>
                                    <div class="col-md-2 d-flex align-items-end pb-1">
                                        <div class="form-check"><input class="form-check-input" type="checkbox" name="estado" id="estado" <%= areaEditar.isEstado() ? "checked" : ""%>>
                                            <label class="form-check-label" for="estado">Activa</label></div>
                                    </div>
                                    <% }%>
                                    <div class="col-md-4">
                                        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-save me-2"></i><%= areaEditar != null ? "Actualizar" : "Guardar"%></button>
                                    </div>
                                    <% if (areaEditar != null) { %>
                                    <div class="col-md-2">
                                        <a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>
                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Áreas</h5>
                                <span class="badge bg-primary"><%= areas != null ? areas.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light"><tr><th class="px-4">#</th><th>Nombre</th><th class="text-center">Estado</th><th class="text-center">Acciones</th></tr></thead>
                                        <tbody>
                                            <% if (areas != null && !areas.isEmpty()) {
                                                    for (Areatrabajo a : areas) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= a.getIdArea()%></td>
                                                <td class="fw-semibold"><%= a.getNombreArea()%></td>
                                                <td class="text-center"><span class="badge <%= a.isEstado() ? "bg-success" : "bg-secondary"%>"><%= a.isEstado() ? "Activa" : "Inactiva"%></span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=editar&id=<%= a.getIdArea()%>" class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=eliminar&id=<%= a.getIdArea()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Desactivar esta área?')"><i class="fas fa-toggle-off"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="4" class="text-center py-5 text-muted"><i class="fas fa-building fa-3x mb-3 d-block"></i>No hay áreas registradas</td></tr>
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