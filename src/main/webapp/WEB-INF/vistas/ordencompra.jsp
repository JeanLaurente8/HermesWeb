<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html><html lang="es"><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Hermes – Órdenes de Compra</title>
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
            .badge-auto {
                background: #dbeafe;
                color: #1d4ed8;
                font-size: 10px;
                padding: 2px 6px;
                border-radius: 99px;
                font-weight: 600;
                vertical-align: middle;
            }
        </style>
    </head><body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Ordencompra> ordenes = (List<Ordencompra>) request.getAttribute("ordenes");
            List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
            List<Proveedor> proveedores = (List<Proveedor>) request.getAttribute("proveedores");
            List<Articulo> articulosDisponibles = (List<Articulo>) request.getAttribute("articulos");
            Ordencompra ordenEditar = (Ordencompra) request.getAttribute("ordenEditar");
            List<DetalleOc> detallesEditar = ordenEditar != null ? ordenEditar.getDetalles() : null;
            String errorBackend = (String) request.getAttribute("error");
            String[] estadosOC = {"En Revisión", "Autorizada", "Enviada", "Rechazada"};

            boolean esAdmin = sesion != null && ("Gerente Compras".equals(sesion.getCargo())
                    || "Administrador".equals(sesion.getCargo())
                    || "admin".equalsIgnoreCase(sesion.getUsername()));
        %>

        <div class="container-fluid p-0"><div class="row g-0">

                <jsp:include page="/WEB-INF/vistas/sidebar.jsp" />

                <div class="col-md-9 col-lg-10 main-content">
                    <div class="topbar d-flex justify-content-between align-items-center">
                        <div><h6 class="mb-0 fw-bold"><i class="fas fa-shopping-cart me-2 text-primary"></i>Órdenes de Compra</h6>
                            <small class="text-muted">Generación y aprobación de órdenes</small></div>
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
                                <h5 class="mb-0">
                                    <i class="fas fa-<%= ordenEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i>
                                    <%= ordenEditar != null ? "Editar Orden de Compra" : "Nueva Orden de Compra"%>
                                </h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/OrdenCompraServlet" method="post" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="<%= ordenEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (ordenEditar != null) {%>
                                    <input type="hidden" name="idOrden" value="<%= ordenEditar.getIdOrden()%>"/>
                                    <% }%>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">
                                            Artículo en Alerta
                                            <span class="badge-auto ms-1">Generación automática</span>
                                        </label>
                                        <input type="text" name="descripcion" class="form-control"
                                               value="<%= ordenEditar != null && ordenEditar.getDescripcion() != null ? ordenEditar.getDescripcion() : ""%>"
                                               placeholder="Artículo que disparó la alerta" maxlength="255">
                                        <div class="form-text text-muted">Se completa automáticamente al detectar stock bajo.</div>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Proveedor</label>
                                        <select name="idProveedor" class="form-select" required>
                                            <option value="">— Seleccionar —</option>
                                            <% if (proveedores != null) {
                                                    for (Proveedor p : proveedores) {
                                                        boolean sel = ordenEditar != null && ordenEditar.getProveedor() != null
                                                                && ordenEditar.getProveedor().getIdProveedor() == p.getIdProveedor();%>
                                            <option value="<%= p.getIdProveedor()%>" <%= sel ? "selected" : ""%>><%= p.getRazonSocial()%></option>
                                            <% }
                                                } %>
                                        </select>
                                        <div class="invalid-feedback">Por favor, asigne un proveedor a la orden.</div>
                                    </div>

                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Estado OC</label>
                                        <% if (ordenEditar == null) { %>
                                        <input type="text" class="form-control" value="En Revisión" disabled>
                                        <input type="hidden" name="estadoOc" value="En Revisión">
                                        <% } else { %>
                                        <select name="estadoOc" class="form-select" required>
                                            <% for (String est : estadosOC) {
                                                    boolean sel = est.equals(ordenEditar.getEstadoOc());%>
                                            <option value="<%= est%>" <%= sel ? "selected" : ""%>><%= est%></option>
                                            <% }%>
                                        </select>
                                        <% } %>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Analista de Compras</label>
                                        <select class="form-select" disabled>
                                            <%
                                                int analistaFijo = 0;
                                                if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = ordenEditar != null && ordenEditar.getAnalista() != null
                                                                ? ordenEditar.getAnalista().getIdEmpleado() == e.getIdEmpleado()
                                                                : (e.getCargo() != null && e.getCargo().toLowerCase().contains("analista") || analistaFijo == 0);

                                                        if (sel)
                                                            analistaFijo = e.getIdEmpleado();
                                            %>
                                            <option value="<%= e.getIdEmpleado()%>" <%= sel ? "selected" : ""%>><%= e.getNombreCompleto()%></option>
                                            <% }
                                                }%>
                                        </select>
                                        <input type="hidden" name="idAnalista" value="<%= analistaFijo%>">
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Gerente de Compras</label>
                                        <select class="form-select" disabled>
                                            <%
                                                int gerenteFijo = 0;
                                                if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = ordenEditar != null && ordenEditar.getGerente() != null
                                                                ? ordenEditar.getGerente().getIdEmpleado() == e.getIdEmpleado()
                                                                : (e.getCargo() != null && e.getCargo().contains("Gerente") || gerenteFijo == 0);
                                                        if (sel)
                                                            gerenteFijo = e.getIdEmpleado();
                                            %>
                                            <option value="<%= e.getIdEmpleado()%>" <%= sel ? "selected" : ""%>><%= e.getNombreCompleto()%></option>
                                            <% }
                                                }%>
                                        </select>
                                        <input type="hidden" name="idGerente" value="<%= gerenteFijo%>">
                                    </div>

                                    <div class="col-md-12">
                                        <hr class="my-2">
                                        <label class="form-label fw-semibold">Artículos a Pedir</label>
                                        <table class="table table-sm align-middle mb-2" id="tablaDetalle">
                                            <thead>
                                                <tr>
                                                    <th>Artículo</th>
                                                    <th style="width:140px">Cantidad</th>
                                                    <th style="width:48px"></th>
                                                </tr>
                                            </thead>
                                            <tbody id="cuerpoDetalle">
                                                <% if (detallesEditar != null && !detallesEditar.isEmpty()) {
                                                        for (DetalleOc d : detallesEditar) { %>
                                                <tr>
                                                    <td>
                                                        <select name="idArticulo[]" class="form-select form-select-sm" required>
                                                            <option value="">— Seleccionar —</option>
                                                            <% if (articulosDisponibles != null) {
                                                                    for (Articulo art : articulosDisponibles) {
                                                                        boolean selArt = d.getArticulo() != null && d.getArticulo().getIdArticulo() == art.getIdArticulo();%>
                                                            <option value="<%= art.getIdArticulo()%>" <%= selArt ? "selected" : ""%>><%= art.getNombre()%></option>
                                                            <% }
                                                                }%>
                                                        </select>
                                                    </td>
                                                    <td><input type="number" name="cantidad[]" class="form-control form-control-sm" min="1" value="<%= d.getCantidad()%>" required></td>
                                                    <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="eliminarFilaDetalle(this)"><i class="fas fa-times"></i></button></td>
                                                </tr>
                                                <% }
                                                } else { %>
                                                <tr>
                                                    <td>
                                                        <select name="idArticulo[]" class="form-select form-select-sm" required>
                                                            <option value="">— Seleccionar —</option>
                                                            <% if (articulosDisponibles != null) {
                                                                    for (Articulo art : articulosDisponibles) {%>
                                                            <option value="<%= art.getIdArticulo()%>"><%= art.getNombre()%></option>
                                                            <% }
                                                                } %>
                                                        </select>
                                                    </td>
                                                    <td><input type="number" name="cantidad[]" class="form-control form-control-sm" min="1" value="1" required></td>
                                                    <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="eliminarFilaDetalle(this)"><i class="fas fa-times"></i></button></td>
                                                </tr>
                                                <% }%>
                                            </tbody>
                                        </table>
                                        <button type="button" class="btn btn-sm btn-outline-primary" onclick="agregarFilaDetalle()">
                                            <i class="fas fa-plus me-1"></i>Agregar artículo
                                        </button>
                                    </div>

                                    <div class="col-md-2 d-flex align-items-end mt-4">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i><%= ordenEditar != null ? "Actualizar" : "Crear OC"%>
                                        </button>
                                    </div>
                                    <% if (ordenEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end mt-4">
                                        <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>

                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Listado de Órdenes de Compra</h5>
                                <span class="badge bg-primary"><%= ordenes != null ? ordenes.size() : 0%> registros</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="px-4">#</th>
                                                <th>Fecha</th>
                                                <th>Artículo en Alerta</th>
                                                <th>Detalle (Artículo x Cant.)</th>
                                                <th>Proveedor</th>
                                                <th>Analista</th>
                                                <th>Gerente</th>
                                                <th class="text-center">Estado</th>
                                                <th class="text-center">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (ordenes != null && !ordenes.isEmpty()) {
                                                    for (Ordencompra o : ordenes) {
                                                        String badgeClass;
                                                        switch (o.getEstadoOc() != null ? o.getEstadoOc() : "") {
                                                            case "Autorizada":
                                                                badgeClass = "bg-success";
                                                                break;
                                                            case "Rechazada":
                                                                badgeClass = "bg-danger";
                                                                break;
                                                            case "Enviada":
                                                                badgeClass = "bg-info";
                                                                break;
                                                            case "En Revisión":
                                                                badgeClass = "bg-primary text-white";
                                                                break;
                                                            default:
                                                                badgeClass = "bg-secondary";
                                                        }
                                                        boolean esAutomatica = o.getDescripcion() != null && !o.getDescripcion().isEmpty();
                                            %>
                                            <tr>
                                                <td class="px-4 fw-semibold text-primary">OC-<%= o.getIdOrden()%></td>
                                                <td><small class="text-muted"><%= o.getFechaGeneracion() != null ? o.getFechaGeneracion().toString().replace("T", " ").substring(0, 16) : "—"%></small></td>
                                                <td>
                                                    <% if (esAutomatica) {%>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <i class="fas fa-robot text-primary" title="Generada automáticamente"></i>
                                                        <div>
                                                            <div class="fw-semibold"><%= o.getDescripcion()%></div>
                                                            <small class="badge-auto">Auto</small>
                                                        </div>
                                                    </div>
                                                    <% } else { %>
                                                    <span class="text-muted small">Manual</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <% List<DetalleOc> detallesOrden = o.getDetalles();
                                                        if (detallesOrden != null && !detallesOrden.isEmpty()) {
                                                            for (DetalleOc d : detallesOrden) {%>
                                                    <span class="badge bg-light text-dark border d-block mb-1 text-start">
                                                        <%= d.getArticulo() != null ? d.getArticulo().getNombre() : "Artículo eliminado"%>
                                                        <strong class="text-primary">x<%= d.getCantidad()%></strong>
                                                    </span>
                                                    <% }
                                                    } else { %>
                                                    <span class="text-muted small">Sin detalle</span>
                                                    <% }%>
                                                </td>
                                                <td><div class="fw-semibold"><%= o.getProveedor() != null ? o.getProveedor().getRazonSocial() : "—"%></div></td>
                                                <td><small><%= o.getAnalista() != null ? o.getAnalista().getNombreCompleto() : "—"%></small></td>
                                                <td><small><%= o.getGerente() != null ? o.getGerente().getNombreCompleto() : "—"%></small></td>
                                                <td class="text-center">
                                                    <span class="badge <%= badgeClass%>"><%= o.getEstadoOc()%></span>
                                                </td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=imprimir&id=<%= o.getIdOrden()%>"
                                                       target="_blank"
                                                       class="btn btn-sm btn-outline-secondary me-1"><i class="fas fa-print"></i></a>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=editar&id=<%= o.getIdOrden()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=eliminar&id=<%= o.getIdOrden()%>"
                                                       class="btn btn-sm btn-outline-danger"
                                                       onclick="return confirm('¿Eliminar OC-<%= o.getIdOrden()%>?')"><i class="fas fa-trash"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                                            } else { %>
                                            <tr><td colspan="9" class="text-center py-5 text-muted">
                                                    <i class="fas fa-shopping-cart fa-3x mb-3 d-block"></i>No hay órdenes de compra registradas
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
                                                           const articulosDisponibles = [
            <% if (articulosDisponibles != null) {
                    for (Articulo art : articulosDisponibles) {
                        String nombreSeguro = art.getNombre() != null ? art.getNombre() : "";
                        nombreSeguro = nombreSeguro.replace("\\", "\\\\").replace("\"", "\\\"");
            %>
                                                               {id: <%= art.getIdArticulo()%>, nombre: "<%= nombreSeguro%>"},
            <% }
                }%>
                                                           ];

                                                           function generarOpcionesArticulo() {
                                                               let html = '<option value="">— Seleccionar —</option>';
                                                               articulosDisponibles.forEach(function (art) {
                                                                   html += '<option value="' + art.id + '">' + art.nombre + '</option>';
                                                               });
                                                               return html;
                                                           }

                                                           function agregarFilaDetalle() {
                                                               const tbody = document.getElementById('cuerpoDetalle');
                                                               const fila = document.createElement('tr');

                                                               const tdArticulo = document.createElement('td');
                                                               const select = document.createElement('select');
                                                               select.name = 'idArticulo[]';
                                                               select.className = 'form-select form-select-sm';
                                                               select.required = true;
                                                               select.innerHTML = generarOpcionesArticulo();
                                                               tdArticulo.appendChild(select);

                                                               const tdCantidad = document.createElement('td');
                                                               const inputCantidad = document.createElement('input');
                                                               inputCantidad.type = 'number';
                                                               inputCantidad.name = 'cantidad[]';
                                                               inputCantidad.className = 'form-control form-control-sm';
                                                               inputCantidad.min = '1';
                                                               inputCantidad.value = '1';
                                                               inputCantidad.required = true;
                                                               tdCantidad.appendChild(inputCantidad);

                                                               const tdBoton = document.createElement('td');
                                                               const btn = document.createElement('button');
                                                               btn.type = 'button';
                                                               btn.className = 'btn btn-sm btn-outline-danger';
                                                               btn.innerHTML = '<i class="fas fa-times"></i>';
                                                               btn.onclick = function () {
                                                                   eliminarFilaDetalle(this);
                                                               };
                                                               tdBoton.appendChild(btn);

                                                               fila.appendChild(tdArticulo);
                                                               fila.appendChild(tdCantidad);
                                                               fila.appendChild(tdBoton);
                                                               tbody.appendChild(fila);
                                                           }
                                                           function eliminarFilaDetalle(btn) {
                                                               const tbody = document.getElementById('cuerpoDetalle');
                                                               if (tbody.rows.length > 1) {
                                                                   btn.closest('tr').remove();
                                                               } else {
                                                                   alert('La orden debe tener al menos un artículo.');
                                                               }
                                                           }
        </script>
        <script>
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