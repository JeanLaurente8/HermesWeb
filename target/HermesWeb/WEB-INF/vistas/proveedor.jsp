<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html><html lang="es"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes – Proveedores</title>
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
            List<Proveedor> proveedores = (List<Proveedor>) request.getAttribute("proveedores");
            Proveedor proveedorEditar = (Proveedor) request.getAttribute("proveedorEditar");
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
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-truck me-2 text-primary"></i>Gestión de Proveedores</h6>
                            <small class="text-muted">Directorio de proveedores de insumos</small></div>
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
                                <h5 class="mb-0"><i class="fas fa-<%= proveedorEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i>
                                    <%= proveedorEditar != null ? "Editar Proveedor" : "Nuevo Proveedor"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/ProveedorServlet" method="post" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= proveedorEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (proveedorEditar != null) {%>
                                    <input type="hidden" name="idProveedor" value="<%= proveedorEditar.getIdProveedor()%>"/>
                                    <% }%>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">RUC</label>
                                        
                                        <div class="input-group">
                                            <input type="text" name="ruc" class="form-control" id="rucInput"
                                               value="<%= proveedorEditar != null ? proveedorEditar.getRuc() : ""%>"
                                               maxlength="11" pattern="^(10|20)[0-9]{9}$" placeholder="10... o 20..." required>
                                        	<button class="btn btn-outline-primary" type="button" id="btnBuscarRuc" title="Consultar Ruc">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                        
                                        <div class="invalid-feedback">Debe contener 11 dígitos y empezar con 10 o 20.</div>
                                    </div>
                                    
                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Razón Social</label>
                                        <input type="text" name="razonSocial" class="form-control" id="razonSocialInput"
                                               value="<%= proveedorEditar != null ? proveedorEditar.getRazonSocial() : ""%>" required>
                                        <div class="invalid-feedback">La razón social es obligatoria.</div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Contacto</label>
                                        <input type="text" name="contacto" class="form-control"
                                               value="<%= proveedorEditar != null && proveedorEditar.getContacto() != null ? proveedorEditar.getContacto() : ""%>"
                                               placeholder="Nombre del representante">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Correo</label>
                                        <input type="email" name="correoProveedor" class="form-control"
                                               value="<%= proveedorEditar != null && proveedorEditar.getCorreoProveedor() != null ? proveedorEditar.getCorreoProveedor() : ""%>"
                                               placeholder="contacto@empresa.com">
                                        <div class="invalid-feedback">El formato del correo es inválido.</div>
                                    </div>
                                    <% if (proveedorEditar != null) {%>
                                    <div class="col-md-2 d-flex align-items-end pb-1">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="estado" id="estProv"
                                                   <%= proveedorEditar.isEstado() ? "checked" : ""%>>
                                            <label class="form-check-label" for="estProv">Activo</label>
                                        </div>
                                    </div>
                                    <% }%>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i><%= proveedorEditar != null ? "Actualizar" : "Guardar"%>
                                        </button>
                                    </div>
                                    <% if (proveedorEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Proveedores</h5>
                                <span class="badge bg-primary"><%= proveedores != null ? proveedores.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr><th class="px-4">#</th><th>Razón Social</th><th>RUC</th><th>Contacto</th><th>Correo</th><th class="text-center">Estado</th><th class="text-center">Acciones</th></tr>
                                        </thead>
                                        <tbody>
                                            <% if (proveedores != null && !proveedores.isEmpty()) {
                                                    for (Proveedor p : proveedores) {%>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">#<%= p.getIdProveedor()%></td>
                                                <td class="fw-semibold"><%= p.getRazonSocial()%></td>
                                                <td><code><%= p.getRuc()%></code></td>
                                                <td><%= p.getContacto() != null && !p.getContacto().isEmpty() ? p.getContacto() : "—"%></td>
                                                <td><small><%= p.getCorreoProveedor() != null && !p.getCorreoProveedor().isEmpty() ? p.getCorreoProveedor() : "—"%></small></td>
                                                <td class="text-center">
                                                    <span class="badge <%= p.isEstado() ? "bg-success" : "bg-secondary"%>">
                                                        <%= p.isEstado() ? "Activo" : "Inactivo"%>
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/ProveedorServlet?accion=editar&id=<%= p.getIdProveedor()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/ProveedorServlet?accion=eliminar&id=<%= p.getIdProveedor()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('¿Desactivar proveedor?')"><i class="fas fa-toggle-off"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted">
                                                    <i class="fas fa-truck fa-3x mb-3 d-block"></i>No hay proveedores registrados
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
            
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>    
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
		
		    // Lógica AJAX para Consulta de RUC a la API (peruapi.com)
            document.addEventListener('DOMContentLoaded', function () {
                const btnBuscarRuc = document.getElementById('btnBuscarRuc');
                
                if (btnBuscarRuc) {
                	btnBuscarRuc.addEventListener('click', function () {
                        const rucValue = document.getElementById('rucInput').value;
                        
                        if (rucValue.length === 11 && /^\d{11}$/.test(rucValue)) {
                            const icon = this.querySelector('i');
                            icon.className = 'fas fa-spinner fa-spin';
                            
                            fetch('${pageContext.request.contextPath}/ProveedorServlet?accion=consultarRuc&ruc=' + rucValue, {
                                method: 'POST'
                            })
                            .then(response => {
                                if (!response.ok) {
                                    throw new Error('RUC no encontrado');
                                }
                                return response.json();
                            })
                            .then(data => {
                                let razonSocial = data.razon_social || (data.data.razon_social)
                                
                                if (razonSocial) document.getElementById('razonSocialInput').value = razonSocial;
                            })
                            .catch(error => {
                                Swal.fire({icon: 'warning', title: 'Aviso', text: 'No se pudo encontrar información para este RUC.'});
                            })
                            .finally(() => {
                                icon.className = 'fas fa-search';
                            });
                        } else {
                            Swal.fire({icon: 'warning', title: 'Formato incorrecto', text: 'Por favor, ingrese un RUC válido de 11 dígitos.'});
                        }
                    });
                }
            });
        </script>
    </body></html>