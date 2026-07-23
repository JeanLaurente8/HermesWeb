<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*, util.AuthUtils" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hermes – Artículos e Inventario</title>
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
            .stock-bar{
                height:6px;
                border-radius:3px;
                background:#e2e8f0;
                margin-top:4px
            }
            .stock-bar-fill{
                height:100%;
                border-radius:3px;
                transition:.3s
            }
            .search-box {
                max-width: 300px;
            }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Articulo> articulos = (List<Articulo>) request.getAttribute("articulos");
            List<Proveedor> proveedores = (List<Proveedor>) request.getAttribute("proveedores");
            Articulo articuloEditar = (Articulo) request.getAttribute("articuloEditar");
            String errorBackend = (String) request.getAttribute("error");

            Boolean tieneOCPendiente = (Boolean) request.getAttribute("tieneOCPendiente");
            if (tieneOCPendiente == null) {
                tieneOCPendiente = false;
            }

            boolean tieneAccesoCompleto = AuthUtils.tieneAccesoCompleto(sesion, "Articulos");
            boolean esGerenteCompras = sesion != null && "Gerente Compras".equalsIgnoreCase(sesion.getCargo());
            boolean esEmpleado = sesion != null && "Empleado".equalsIgnoreCase(sesion.getCargo());

            int totalAlertas = 0;
            if (articulos != null) {
                for (Articulo a : articulos) {
                    if ("ALERTA".equals(a.getEstadoStock())) {
                        totalAlertas++;
                    }
                }
            }

            String ocGenerada = (String) session.getAttribute("ocGenerada");
            if (ocGenerada != null) {
                session.removeAttribute("ocGenerada");
            }

            String ocAdvertencia = (String) session.getAttribute("ocAdvertencia");
            if (ocAdvertencia != null)
                session.removeAttribute("ocAdvertencia");
        %>

        <div class="container-fluid p-0"><div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-boxes me-2 text-primary"></i>Artículos e Inventario</h6>
                            <small class="text-muted">Control de stock y alertas tempranas</small></div>
                        <div class="d-flex align-items-center gap-2">
                            <% if (totalAlertas > 0) {%><span class="badge bg-warning text-dark"><i class="fas fa-exclamation-triangle me-1"></i><%= totalAlertas%> en alerta</span><% }%>
                            <small class="text-muted"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%></small>
                        </div>
                    </div>
                    <div class="p-4">

                        <% if (ocGenerada != null) {%>
                        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                            <i class="fas fa-check-circle me-2 fs-5"></i>
                            <div>
                                <strong>✔ Orden de Compra generada automáticamente</strong><br>
                                <small><%= ocGenerada%></small>
                                <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="ms-3 btn btn-sm btn-success"><i class="fas fa-shopping-cart me-1"></i>Ver OC</a>
                            </div>
                            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                        </div>
                        <% } %>

                        <% if (ocAdvertencia != null) {%>
                        <div class="alert alert-info alert-dismissible fade show d-flex align-items-center mb-3" role="alert">
                            <i class="fas fa-info-circle me-2 fs-5"></i>
                            <div>
                                <strong>ℹ Aviso de Orden de Compra</strong><br>
                                <small><%= ocAdvertencia%></small>
                                <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="ms-3 btn btn-sm btn-outline-info"><i class="fas fa-list me-1"></i>Ir a Órdenes</a>
                            </div>
                            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                        </div>
                        <% } %>

                        <% if (errorBackend != null) {%>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i> <%= errorBackend%>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                        <% } %>

                        <% if (totalAlertas > 0) {%>
                        <div class="alert alert-warning d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                            <div><strong>⚠ Alerta de Stock Crítico:</strong> <strong><%= totalAlertas%></strong> artículo(s) requieren reposición.</div>
                        </div>
                        <% }%>

                        <% if (tieneAccesoCompleto) {%>
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3">
                                <h5 class="mb-0"><i class="fas fa-<%= articuloEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i><%= articuloEditar != null ? "Editar Artículo" : "Nuevo Artículo"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/ArticuloServlet" method="post" id="formArticulo" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= articuloEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (articuloEditar != null) {%><input type="hidden" name="idArticulo" value="<%= articuloEditar.getIdArticulo()%>"/><% }%>

                                    <input type="hidden" name="generarOC" id="flagGenerarOC" value="false">
                                    <input type="hidden" name="idProveedorOC" id="valProveedorOC" value="">

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Nombre del Artículo</label>
                                        <input type="text" name="nombre" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getNombre() : ""%>" placeholder="Ej: Chaleco antibalas" required minlength="3" maxlength="100">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Stock Actual</label>
                                        <input type="number" name="stock" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getStock() : "0"%>" min="0" required <%= esGerenteCompras ? "readonly title=\"Edición manual restringida por perfil\"" : ""%>>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Stock Límite</label>
                                        <input type="number" name="stockLimite" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getStockLimite() : "5"%>" min="0" required>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Precio Unit.</label>
                                        <div class="input-group">
                                            <span class="input-group-text">S/</span>
                                            <input type="number" step="0.01" name="precio" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getPrecio() : "0.00"%>" min="0" required>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Proveedor Asociado</label>
                                        <select name="idProveedor" class="form-select" required>
                                            <option value="">— Seleccionar —</option>
                                            <% if (proveedores != null) {
                                                    for (Proveedor p : proveedores) {
                                                        boolean sel = articuloEditar != null && articuloEditar.getProveedor() != null && articuloEditar.getProveedor().getIdProveedor() == p.getIdProveedor();
                                            %>
                                            <option value="<%= p.getIdProveedor()%>" <%= sel ? "selected" : ""%>><%= p.getRazonSocial()%></option>
                                            <% }
                                                }%>
                                        </select>
                                    </div>
                                    <div class="col-md-10">
                                        <label class="form-label fw-semibold">Descripción</label>
                                        <input type="text" name="descripcion" class="form-control" value="<%= articuloEditar != null && articuloEditar.getDescripcion() != null ? articuloEditar.getDescripcion() : ""%>" placeholder="Descripción opcional" maxlength="255">
                                    </div>

                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100 mb-1"><i class="fas fa-save me-1"></i><%= articuloEditar != null ? "Actualizar" : "Guardar"%></button>
                                    </div>

                                    <% if (articuloEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>

                        <div class="modal fade" id="modalCrearOCAutomatica" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title"><i class="fas fa-robot text-primary me-2"></i>Stock bajo detectado</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body text-start">
                                        <p>El stock que estás guardando es menor o igual al límite. Se generará una <strong>Orden de Compra Automática</strong>.</p>
                                        <p class="fw-semibold mb-2 mt-3">¿Requiere cambio de proveedor para esta OC?</p>

                                        <div class="form-check mb-2">
                                            <input class="form-check-input" type="radio" name="cambioProv" id="provNo" value="no" checked>
                                            <label class="form-check-label" for="provNo">No, usar el proveedor asignado al artículo</label>
                                        </div>
                                        <div class="form-check mb-3">
                                            <input class="form-check-input" type="radio" name="cambioProv" id="provSi" value="si">
                                            <label class="form-check-label" for="provSi">Sí, elegir un proveedor diferente para la OC</label>
                                        </div>

                                        <div id="divNuevoProveedor" style="display: none;" class="p-3 bg-light rounded border">
                                            <label class="form-label fw-semibold">Seleccione el nuevo proveedor:</label>
                                            <select id="selectNuevoProveedor" class="form-select">
                                                <option value="">— Seleccionar Proveedor —</option>
                                                <% if (proveedores != null) {
                                                        for (Proveedor p : proveedores) {%>
                                                <option value="<%= p.getIdProveedor()%>"><%= p.getRazonSocial()%></option>
                                                <% }
                                                    } %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                        <button type="button" class="btn btn-primary" id="btnConfirmarOC"><i class="fas fa-check me-1"></i>Confirmar y Guardar</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% }%>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Inventario de Artículos</h5>
                                <div class="input-group search-box">
                                    <span class="input-group-text bg-light border-end-0"><i class="fas fa-search text-muted"></i></span>
                                    <input type="text" id="buscadorArticulos" class="form-control border-start-0 ps-0" placeholder="Buscar por nombre...">
                                </div>
                                <span class="badge bg-primary"><%= articulos != null ? articulos.size() : 0%> artículos</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0" id="tablaArticulos">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="px-4">#</th>
                                                <th>Artículo</th>
                                                <th class="text-center">Stock Actual</th>
                                                <th class="text-center">Límite</th>
                                                <% if (!esEmpleado) { %><th class="text-center">Precio Unit.</th><% } %>
                                                <th>Proveedor</th>
                                                <th class="text-center">Estado</th>
                                                <% if (tieneAccesoCompleto) { %><th class="text-center">Acciones</th><% } %>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (articulos != null && !articulos.isEmpty()) {
                                                    for (Articulo a : articulos) {
                                                        boolean alerta = "ALERTA".equals(a.getEstadoStock());
                                                        int pct = a.getStockLimite() > 0 ? Math.min(100, a.getStock() * 100 / (a.getStockLimite() * 2)) : 100;
                                                        String barColor = alerta ? "#dc2626" : "#16a34a";
                                            %>
                                            <tr class="<%= alerta ? "table-warning" : ""%> fila-articulo">
                                                <td class="px-4 fw-semibold text-primary">#<%= a.getIdArticulo()%></td>
                                                <td class="nombre-articulo">
                                                    <div class="fw-semibold"><%= a.getNombre()%></div>
                                                    <small class="text-muted"><%= a.getDescripcion() != null ? a.getDescripcion() : ""%></small>
                                                    <div class="stock-bar"><div class="stock-bar-fill" style="width:<%= pct%>%;background:<%= barColor%>"></div></div>
                                                </td>
                                                <td class="text-center fw-bold fs-5 <%= alerta ? "text-danger" : "text-success"%>"><%= a.getStock()%></td>
                                                <td class="text-center text-muted"><%= a.getStockLimite()%></td>
                                                <% if (!esEmpleado) {%><td class="text-center fw-semibold">S/ <%= String.format("%.2f", a.getPrecio())%></td><% }%>
                                                <td><small><%= a.getProveedor() != null ? a.getProveedor().getRazonSocial() : "Sin asignar"%></small></td>                                                <td class="text-center">
                                                    <span class="badge <%= alerta ? "bg-danger" : "bg-success"%>">
                                                        <%= alerta ? "ALERTA" : "OK"%>
                                                    </span>
                                                </td>
                                                <% if (tieneAccesoCompleto) {%>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=editar&id=<%= a.getIdArticulo()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=eliminar&id=<%= a.getIdArticulo()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('¿Eliminar artículo?')"><i class="fas fa-trash"></i></a>
                                                </td>
                                                <% } %>
                                            </tr>
                                            <% }
                                            } else {%>
                                            <%
                                                int totalColumnas = 6;
                                                if (!esEmpleado) {
                                                    totalColumnas++;
                                                }
                                                if (tieneAccesoCompleto)
                                                    totalColumnas++;
                                            %>
                                            <tr><td colspan="<%= totalColumnas%>" class="text-center py-5 text-muted">
                                                    <i class="fas fa-boxes fa-3x mb-3 d-block"></i>No hay artículos registrados
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
                                                           document.addEventListener("DOMContentLoaded", function () {
                                                               const inputBuscador = document.getElementById("buscadorArticulos");
                                                               if (inputBuscador) {
                                                                   inputBuscador.addEventListener("keyup", function () {
                                                                       const filtro = this.value.toLowerCase();
                                                                       const filas = document.querySelectorAll("#tablaArticulos tbody tr.fila-articulo");
                                                                       filas.forEach(fila => {
                                                                           const nombreArticulo = fila.querySelector(".nombre-articulo .fw-semibold").textContent.toLowerCase();
                                                                           fila.style.display = nombreArticulo.includes(filtro) ? "" : "none";
                                                                       });
                                                                   });
                                                               }

                                                               const formArt = document.getElementById('formArticulo');
                                                               const radioSi = document.getElementById('provSi');
                                                               const radioNo = document.getElementById('provNo');
                                                               const divNuevoProv = document.getElementById('divNuevoProveedor');
                                                               const btnConfirmarOC = document.getElementById('btnConfirmarOC');

                                                               const tieneOCPendiente = <%= tieneOCPendiente%>;
                                                               let modalOC;

                                                               if (document.getElementById('modalCrearOCAutomatica')) {
                                                                   modalOC = new bootstrap.Modal(document.getElementById('modalCrearOCAutomatica'));
                                                               }

                                                               if (radioSi && radioNo) {
                                                                   radioSi.addEventListener('change', () => divNuevoProv.style.display = 'block');
                                                                   radioNo.addEventListener('change', () => divNuevoProv.style.display = 'none');
                                                               }

                                                               if (formArt) {
                                                                   formArt.addEventListener('submit', function (e) {
                                                                       if (!formArt.checkValidity()) {
                                                                           e.preventDefault();
                                                                           formArt.classList.add('was-validated');
                                                                           return;
                                                                       }

                                                                       const stock = parseInt(formArt.querySelector('input[name="stock"]').value);
                                                                       const limite = parseInt(formArt.querySelector('input[name="stockLimite"]').value);

                                                                       if (stock <= limite && formArt.dataset.ocConfirmada !== 'true' && !tieneOCPendiente) {
                                                                           e.preventDefault();
                                                                           modalOC.show();
                                                                       }
                                                                   });
                                                               }

                                                               if (btnConfirmarOC) {
                                                                   btnConfirmarOC.addEventListener('click', function () {
                                                                       document.getElementById('flagGenerarOC').value = "true";
                                                                       const selectProvArticulo = formArt.querySelector('select[name="idProveedor"]');
                                                                       document.getElementById('valProveedorOC').value = radioSi.checked ? document.getElementById('selectNuevoProveedor').value : selectProvArticulo.value;
                                                                       formArt.dataset.ocConfirmada = 'true';
                                                                       formArt.submit();
                                                                   });
                                                               }
                                                           });
        </script>
    </body>
</html>