<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes – Empleados</title>
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
            input[readonly] {
                background-color: #e9ecef !important;
                color: #6c757d;
                cursor: not-allowed;
            }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            List<Areatrabajo> areas = (List<Areatrabajo>) request.getAttribute("areas");
            Empleado empleadoEditar = (Empleado) request.getAttribute("empleadoEditar");
        %>
        
        <div class="container-fluid p-0">
            <div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-primary"></i>Gestión de Empleados</h6>
                            <small class="text-muted">Personal registrado en el sistema</small>
                        </div>
                        <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                    </div>
                    
                    <div class="p-4">
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3">
                                <h5 class="mb-0"><i class="fas fa-<%= empleadoEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i><%= empleadoEditar != null ? "Editar Empleado" : "Nuevo Empleado"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/EmpleadoServlet" method="post" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= empleadoEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (empleadoEditar != null) { %>
                                        <input type="hidden" name="idEmpleado" value="<%= empleadoEditar.getIdEmpleado()%>"/>
                                    <% } %>

                                    <!-- DNI con botón de consulta -->
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">DNI</label>
                                        <div class="input-group">
                                            <input type="text" name="dni" id="dniInput" class="form-control" 
                                                   value="<%= empleadoEditar != null ? empleadoEditar.getDni() : ""%>" 
                                                   maxlength="8" required pattern="^[0-9]{8}$" placeholder="12345678">
                                            <button class="btn btn-outline-primary" type="button" id="btnBuscarDni" title="Consultar DNI">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                        <div class="invalid-feedback">El DNI debe tener exactamente 8 números.</div>
                                    </div>

                                    <!-- Nombres y Apellidos bloqueados (readonly) -->
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Nombres</label>
                                        <input type="text" name="nombre" id="nombreInput" class="form-control" 
                                               value="<%= empleadoEditar != null ? empleadoEditar.getNombre() : ""%>" 
                                               required readonly tabindex="-1">
                                        <div class="invalid-feedback">El nombre es obligatorio.</div>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Apellido Paterno</label>
                                        <input type="text" name="apellidoPaterno" id="apePatInput" class="form-control" 
                                               value="<%= empleadoEditar != null ? empleadoEditar.getApellidoPaterno() : ""%>" 
                                               required readonly tabindex="-1">
                                        <div class="invalid-feedback">El apellido paterno es obligatorio.</div>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Apellido Materno</label>
                                        <input type="text" name="apellidoMaterno" id="apeMatInput" class="form-control" 
                                               value="<%= empleadoEditar != null ? empleadoEditar.getApellidoMaterno() : ""%>" 
                                               required readonly tabindex="-1">
                                        <div class="invalid-feedback">El apellido materno es obligatorio.</div>
                                    </div>

                                    <!-- Correo -->
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Correo</label>
                                        <input type="email" name="correo" class="form-control" 
                                               value="<%= empleadoEditar != null && empleadoEditar.getCorreo() != null ? empleadoEditar.getCorreo() : ""%>"
                                               required placeholder="correo@hermes.com.pe">
                                        <div class="invalid-feedback">Ingrese un correo válido.</div>
                                    </div>

                                    <!-- Username -->
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Username</label>
                                        <input type="text" name="username" class="form-control" 
                                               value="<%= empleadoEditar != null ? empleadoEditar.getUsername() : ""%>" 
                                               required pattern="^[a-zA-Z0-9_\-]+$" minlength="4" placeholder="usuario">
                                        <div class="invalid-feedback">Mínimo 4 caracteres.</div>
                                    </div>

                                    <!-- Password -->
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Password</label>
                                        <input type="password" name="password" class="form-control" 
                                               value="<%= empleadoEditar != null ? empleadoEditar.getPassword() : ""%>" 
                                               required minlength="6" placeholder="******">
                                        <div class="invalid-feedback">Mínimo 6 caracteres.</div>
                                    </div>

                                    <!-- Cargo -->
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Cargo</label>
                                        <select name="cargo" class="form-select" required>
                                            <option value="">Seleccione...</option>
                                            <option value="Empleado" <%= empleadoEditar != null && "Empleado".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Empleado</option>
                                            <option value="Asistente Almacén" <%= empleadoEditar != null && "Asistente Almacén".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Asistente Almacén</option>
                                            <option value="Coordinador Almacén" <%= empleadoEditar != null && "Coordinador Almacén".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Coordinador Almacén</option>
                                            <option value="Analista Compras" <%= empleadoEditar != null && "Analista Compras".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Analista Compras</option>
                                            <option value="Gerente Compras" <%= empleadoEditar != null && "Gerente Compras".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Gerente Compras</option>
                                            <option value="Administrador" <%= empleadoEditar != null && "Administrador".equals(empleadoEditar.getCargo()) ? "selected" : ""%>>Administrador</option>
                                        </select>
                                        <div class="invalid-feedback">Seleccione un cargo.</div>
                                    </div>

                                    <!-- Área -->
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Área</label>
                                        <select name="idArea" class="form-select" required>
                                            <option value="" disabled <%= empleadoEditar == null || empleadoEditar.getArea() == null ? "selected" : ""%>>Seleccione...</option>
                                            <% if (areas != null) {
                                                for (Areatrabajo ar : areas) {
                                                    String sel = empleadoEditar != null && empleadoEditar.getArea() != null && empleadoEditar.getArea().getIdArea() == ar.getIdArea() ? "selected" : "";
                                            %>
                                            <option value="<%= ar.getIdArea()%>" <%= sel%>><%= ar.getNombreArea()%></option>
                                            <%  }
                                               } %>
                                        </select>
                                        <div class="invalid-feedback">Seleccione un área.</div>
                                    </div>

                                    <!-- Estado (Solo si edita) -->
                                    <% if (empleadoEditar != null) {%>
                                    <div class="col-md-2 d-flex align-items-center pt-4">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="estado" id="estEmp" <%= empleadoEditar.isEstado() ? "checked" : ""%>>
                                            <label class="form-check-label small" for="estEmp">Activo</label>
                                        </div>
                                    </div>
                                    <%}%>

                                    <!-- Botones -->
                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i><%= empleadoEditar != null ? "Actualizar" : "Guardar"%>
                                        </button>
                                    </div>
                                    <% if (empleadoEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% } %>
                                </form>
                            </div>
                        </div>

                        <!-- Listado de Empleados -->
                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Empleados</h5>
                                <span class="badge bg-primary"><%= empleados != null ? empleados.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="px-4">#</th>
                                                <th>Nombre Completo</th>
                                                <th>DNI</th>
                                                <th>Username</th>
                                                <th>Cargo</th>
                                                <th>Área</th>
                                                <th class="text-center">Estado</th>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (empleados != null && !empleados.isEmpty()) {
                                                for (Empleado e : empleados) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= e.getIdEmpleado()%></td>
                                                <td>
                                                    <div class="fw-semibold"><%= e.getNombreCompleto()%></div>
                                                    <small class="text-muted"><%= e.getCorreo() != null ? e.getCorreo() : ""%></small>
                                                </td>
                                                <td><%= e.getDni()%></td>
                                                <td><code><%= e.getUsername()%></code></td>
                                                <td><span class="badge bg-primary bg-opacity-10 text-primary"><%= e.getCargo()%></span></td>
                                                <td><%= e.getArea() != null ? e.getArea().getNombreArea() : "—"%></td>
                                                <td class="text-center">
                                                    <span class="badge <%= e.isEstado() ? "bg-success" : "bg-secondary"%>">
                                                        <%= e.isEstado() ? "Activo" : "Inactivo"%>
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=editar&id=<%= e.getIdEmpleado()%>" class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=eliminar&id=<%= e.getIdEmpleado()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Desactivar empleado?')"><i class="fas fa-toggle-off"></i></a>
                                                </td>
                                            </tr>
                                            <%  }
                                               } else { %>
                                            <tr>
                                                <td colspan="8" class="text-center py-5 text-muted">
                                                    <i class="fas fa-users fa-3x mb-3 d-block"></i>No hay empleados registrados
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <%
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
        %>

        <% if (error != null) {%>
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: '<%= error%>'
            });
        </script>
        <% } %>

        <% if (success != null) {%>
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Éxito',
                text: '<%= success%>'
            }).then(() => {
                window.location.href = "EmpleadoServlet?accion=listar";
            });
        </script>
        <% }%>

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

            // Lógica AJAX para Consulta de DNI a la API
            document.addEventListener('DOMContentLoaded', function () {
                const btnBuscarDni = document.getElementById('btnBuscarDni');
                if (btnBuscarDni) {
                    btnBuscarDni.addEventListener('click', function () {
                        const dniValue = document.getElementById('dniInput').value;
                        if (dniValue.length === 8 && /^[0-9]+$/.test(dniValue)) {
                            const icon = this.querySelector('i');
                            icon.className = 'fas fa-spinner fa-spin';

                            fetch('${pageContext.request.contextPath}/EmpleadoServlet?accion=consultarDni&dni=' + dniValue, {
                                method: 'POST'
                            })
                            .then(response => {
                                if (!response.ok) throw new Error('DNI no encontrado');
                                return response.json();
                            })
                            .then(data => {
                                let nombres = data.nombres || (data.data && data.data.nombres);
                                let apePat = data.apellido_paterno || data.apellidoPaterno || (data.data && data.data.apellido_paterno);
                                let apeMat = data.apellido_materno || data.apellidoMaterno || (data.data && data.data.apellido_materno);

                                if (nombres) document.getElementById('nombreInput').value = nombres;
                                if (apePat) document.getElementById('apePatInput').value = apePat;
                                if (apeMat) document.getElementById('apeMatInput').value = apeMat;
                            })
                            .catch(error => {
                                Swal.fire({icon: 'warning', title: 'Aviso', text: 'No se pudo encontrar información para este DNI.'});
                            })
                            .finally(() => {
                                icon.className = 'fas fa-search';
                            });
                        } else {
                            Swal.fire({icon: 'warning', title: 'Formato incorrecto', text: 'Por favor, ingrese un DNI válido de 8 dígitos.'});
                        }
                    });
                }
            });
        </script>
    </body>
</html>