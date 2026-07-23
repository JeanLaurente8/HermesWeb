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
            .resumen-oc {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 14px 18px;
            }
            .resumen-oc .fila {
                display: flex;
                justify-content: space-between;
                padding: 3px 0;
                font-size: 14px;
            }
            .resumen-oc .fila.total {
                border-top: 1px solid #cbd5e1;
                margin-top: 6px;
                padding-top: 8px;
                font-weight: 700;
                font-size: 16px;
                color: #1a3a5c;
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

                        <% if (ordenEditar != null) { %>
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="fas fa-edit me-2 text-primary"></i>
                                    Editar Orden de Compra OC-<%= ordenEditar.getIdOrden()%>
                                </h5>
                                <span class="badge bg-secondary"><%= ordenEditar.getEstadoOc()%></span>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/OrdenCompraServlet" method="post" class="row g-3 needs-validation" novalidate>
                                    <input type="hidden" name="accion" value="actualizar"/>
                                    <input type="hidden" name="idOrden" value="<%= ordenEditar.getIdOrden()%>"/>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">
                                            Artículo en Alerta
                                            <span class="badge-auto ms-1">Bloqueado</span>
                                        </label>
                                        <input type="text" class="form-control" disabled
                                               value="<%= ordenEditar.getDescripcion() != null && !ordenEditar.getDescripcion().isEmpty() ? ordenEditar.getDescripcion() : "Manual"%>">
                                        <input type="hidden" name="descripcion" value="<%= ordenEditar.getDescripcion() != null ? ordenEditar.getDescripcion() : ""%>">
                                        <div class="form-text text-muted">Este campo se genera automáticamente y no puede modificarse.</div>
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Proveedor de Referencia</label>
                                        <select name="idProveedor" class="form-select">
                                            <option value="">— Sin proveedor general —</option>
                                            <% if (proveedores != null) {
                                                    for (Proveedor p : proveedores) {
                                                        boolean sel = ordenEditar.getProveedor() != null
                                                                && ordenEditar.getProveedor().getIdProveedor() == p.getIdProveedor();%>
                                            <option value="<%= p.getIdProveedor()%>" <%= sel ? "selected" : ""%>><%= p.getRazonSocial()%></option>
                                            <% }
                                                } %>
                                        </select>
                                        <div class="form-text text-muted">Opcional: ahora cada artículo tiene su propio proveedor abajo.</div>
                                    </div>

                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Estado OC</label>
                                        <input type="text" class="form-control" value="<%= ordenEditar.getEstadoOc()%>" disabled>
                                        <div class="form-text text-muted">Usa los botones Aprobar/Rechazar del listado para cambiar el estado.</div>
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Analista de Compras</label>
                                        <select class="form-select" disabled>
                                            <%
                                                int analistaFijo = 0;
                                                if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = ordenEditar.getAnalista() != null
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

                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">Gerente de Compras</label>
                                        <select class="form-select" disabled>
                                            <%
                                                int gerenteFijo = 0;
                                                if (empleados != null) {
                                                    for (Empleado e : empleados) {
                                                        boolean sel = ordenEditar.getGerente() != null
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
                                                    <th style="width:220px">Proveedor</th>
                                                    <th style="width:48px"></th>
                                                </tr>
                                            </thead>
                                            <tbody id="cuerpoDetalle">
                                                <% if (detallesEditar != null && !detallesEditar.isEmpty()) {
                                                        int idx = 0;
                                                        for (DetalleOc d : detallesEditar) {
                                                            boolean esPrimerArticulo = (idx == 0); %>
                                                <tr>
                                                    <td>
                                                        <% if (esPrimerArticulo) { %>
                                                        <select class="form-select form-select-sm" disabled>
                                                            <option><%= d.getArticulo() != null ? d.getArticulo().getNombre() : "—"%></option>
                                                        </select>
                                                        <input type="hidden" name="idArticulo[]" value="<%= d.getArticulo() != null ? d.getArticulo().getIdArticulo() : ""%>">
                                                        <% } else { %>
                                                        <select name="idArticulo[]" class="form-select form-select-sm" required>
                                                            <option value="">— Seleccionar —</option>
                                                            <% if (articulosDisponibles != null) {
                                                                    for (Articulo art : articulosDisponibles) {
                                                                        boolean selArt = d.getArticulo() != null && d.getArticulo().getIdArticulo() == art.getIdArticulo();%>
                                                            <option value="<%= art.getIdArticulo()%>" <%= selArt ? "selected" : ""%>><%= art.getNombre()%></option>
                                                            <% }
                                                                }%>
                                                        </select>
                                                        <% } %>
                                                    </td>
                                                    <td><input type="number" name="cantidad[]" class="form-control form-control-sm" min="1" value="<%= d.getCantidad()%>" required></td>
                                                    <td>
                                                        <select name="idProveedorLinea[]" class="form-select form-select-sm" required>
                                                            <option value="">— Seleccionar —</option>
                                                            <% if (proveedores != null) {
                                                                    for (Proveedor p : proveedores) {
                                                                        boolean selProv = d.getProveedor() != null && d.getProveedor().getIdProveedor() == p.getIdProveedor();%>
                                                            <option value="<%= p.getIdProveedor()%>" <%= selProv ? "selected" : ""%>><%= p.getRazonSocial()%></option>
                                                            <% }
                                                                }%>
                                                        </select>
                                                    </td>
                                                    <td>
                                                        <% if (!esPrimerArticulo) { %>
                                                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="eliminarFilaDetalle(this)"><i class="fas fa-times"></i></button>
                                                        <% } else { %>
                                                        <span class="text-muted small" title="Artículo que disparó la alerta, no se puede quitar"><i class="fas fa-lock"></i></span>
                                                        <% } %>
                                                    </td>
                                                </tr>
                                                <% idx++;
                                                    }
                                                } %>
                                            </tbody>
                                        </table>
                                        <button type="button" class="btn btn-sm btn-outline-primary" onclick="agregarFilaDetalle()">
                                            <i class="fas fa-plus me-1"></i>Agregar artículo
                                        </button>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="resumen-oc">
                                            <div class="fila"><span>Subtotal</span><span id="subtotalOC">S/ 0.00</span></div>
                                            <div class="fila"><span>IGV (18%)</span><span id="igvOC">S/ 0.00</span></div>
                                            <div class="fila total"><span>Total</span><span id="totalOC">S/ 0.00</span></div>
                                        </div>
                                    </div>

                                    <div class="col-md-2 d-flex align-items-end mt-4">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="fas fa-save me-1"></i>Actualizar
                                        </button>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end mt-4">
                                        <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <% } %>

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
                                                <th>Detalle (Artículo x Cant. x Proveedor)</th>
                                                <th>Proveedor Ref.</th>
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
                                                            case "Aprobada":
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
                                                        boolean puedeAprobarRechazar = "En Revisión".equals(o.getEstadoOc());
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
                                                        <% if (d.getProveedor() != null) { %>
                                                        <span class="text-muted">· <%= d.getProveedor().getRazonSocial()%></span>
                                                        <% } %>
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
                                                    <% if (puedeAprobarRechazar) { %>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=aprobar&id=<%= o.getIdOrden()%>"
                                                       class="btn btn-sm btn-outline-success me-1"
                                                       onclick="return confirm('¿Aprobar OC-<%= o.getIdOrden()%>?')"><i class="fas fa-check"></i></a>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=rechazar&id=<%= o.getIdOrden()%>"
                                                       class="btn btn-sm btn-outline-danger me-1"
                                                       onclick="return confirm('¿Rechazar OC-<%= o.getIdOrden()%>?')"><i class="fas fa-ban"></i></a>
                                                    <% } %>
                                                    <% if (puedeAprobarRechazar) { %>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=editar&id=<%= o.getIdOrden()%>"
                                                       class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <% } else { %>
                                                    <span class="btn btn-sm btn-outline-secondary disabled me-1" title="Solo se puede editar mientras está 'En Revisión'">
                                                        <i class="fas fa-lock"></i>
                                                    </span>
                                                    <% } %>
                                                    <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=imprimir&id=<%= o.getIdOrden()%>"
                                                       target="_blank"
                                                       class="btn btn-sm btn-outline-secondary"><i class="fas fa-print"></i></a>
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
                        java.math.BigDecimal precioArt = art.getPrecio() != null ? art.getPrecio() : java.math.BigDecimal.ZERO;
            %>
                                                               {id: <%= art.getIdArticulo()%>, nombre: "<%= nombreSeguro%>", precio: <%= precioArt%>},
            <% }
                }%>
                                                           ];

                                                           const proveedoresDisponibles = [
            <% if (proveedores != null) {
                    for (Proveedor p : proveedores) {
                        String razonSegura = p.getRazonSocial() != null ? p.getRazonSocial() : "";
                        razonSegura = razonSegura.replace("\\", "\\\\").replace("\"", "\\\"");
            %>
                                                               {id: <%= p.getIdProveedor()%>, nombre: "<%= razonSegura%>"},
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

                                                           function generarOpcionesProveedor() {
                                                               let html = '<option value="">— Seleccionar —</option>';
                                                               proveedoresDisponibles.forEach(function (p) {
                                                                   html += '<option value="' + p.id + '">' + p.nombre + '</option>';
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

                                                               const tdProveedor = document.createElement('td');
                                                               const selectProv = document.createElement('select');
                                                               selectProv.name = 'idProveedorLinea[]';
                                                               selectProv.className = 'form-select form-select-sm';
                                                               selectProv.required = true;
                                                               selectProv.innerHTML = generarOpcionesProveedor();
                                                               tdProveedor.appendChild(selectProv);

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
                                                               fila.appendChild(tdProveedor);
                                                               fila.appendChild(tdBoton);
                                                               tbody.appendChild(fila);
                                                               actualizarResumen();
                                                           }
                                                           function eliminarFilaDetalle(btn) {
                                                               const tbody = document.getElementById('cuerpoDetalle');
                                                               if (tbody.rows.length > 1) {
                                                                   btn.closest('tr').remove();
                                                                   actualizarResumen();
                                                               } else {
                                                                   alert('La orden debe tener al menos un artículo.');
                                                               }
                                                           }

                                                           function actualizarResumen() {
                                                               const tbody = document.getElementById('cuerpoDetalle');
                                                               if (!tbody) {
                                                                   return;
                                                               }
                                                               let subtotal = 0;
                                                               Array.from(tbody.rows).forEach(function (fila) {
                                                                   const campoArt = fila.querySelector('[name="idArticulo[]"]');
                                                                   const inputCant = fila.querySelector('input[name="cantidad[]"]');
                                                                   if (!campoArt || !inputCant) {
                                                                       return;
                                                                   }
                                                                   const idArt = parseInt(campoArt.value, 10);
                                                                   const cantidad = parseFloat(inputCant.value) || 0;
                                                                   const articulo = articulosDisponibles.find(a => a.id === idArt);
                                                                   if (articulo) {
                                                                       subtotal += articulo.precio * cantidad;
                                                                   }
                                                               });
                                                               const igv = subtotal * 0.18;
                                                               const total = subtotal + igv;
                                                               const elSub = document.getElementById('subtotalOC');
                                                               const elIgv = document.getElementById('igvOC');
                                                               const elTotal = document.getElementById('totalOC');
                                                               if (elSub) elSub.textContent = 'S/ ' + subtotal.toFixed(2);
                                                               if (elIgv) elIgv.textContent = 'S/ ' + igv.toFixed(2);
                                                               if (elTotal) elTotal.textContent = 'S/ ' + total.toFixed(2);
                                                           }

                                                           const cuerpoDetalleEl = document.getElementById('cuerpoDetalle');
                                                           if (cuerpoDetalleEl) {
                                                               cuerpoDetalleEl.addEventListener('input', actualizarResumen);
                                                               cuerpoDetalleEl.addEventListener('change', actualizarResumen);
                                                               actualizarResumen();
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