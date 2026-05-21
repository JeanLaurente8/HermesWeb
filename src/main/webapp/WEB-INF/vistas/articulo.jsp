<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
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
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Articulo> articulos = (List<Articulo>) request.getAttribute("articulos");
            Articulo articuloEditar = (Articulo) request.getAttribute("articuloEditar");
            int totalAlertas = 0;
            if (articulos != null) {
                for (Articulo a : articulos) {
                    if ("ALERTA".equals(a.getEstadoStock())) {
                        totalAlertas++;
                    }
                }
            }
        %>
        <div class="container-fluid p-0"><div class="row g-0">
                <!-- SIDEBAR -->
                <div class="col-md-3 col-lg-2 sidebar">
                    <div class="p-3 border-bottom border-secondary border-opacity-25">
                        <div class="d-flex align-items-center gap-2"><span style="font-size:22px">🛡️</span>
                            <div><div class="fw-bold" style="font-size:14px">Hermes</div><div style="font-size:11px;opacity:.6">Inventario</div></div>
                        </div>
                    </div>
                    <nav class="pt-2"><ul class="nav flex-column">
                            <li><a href="${pageContext.request.contextPath}/MenuServlet" class="nav-link"><i class="fas fa-home me-2"></i>Inicio</a></li>
                            <div class="nav-section">Inventario</div>
                            <li><a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="nav-link active"><i class="fas fa-boxes me-2"></i>Artículos</a></li>
                            <li><a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="nav-link"><i class="fas fa-building me-2"></i>Áreas</a></li>
                            <div class="nav-section">Compras</div>
                            <li><a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="nav-link"><i class="fas fa-clipboard-list me-2"></i>Solicitudes</a></li>
                            <li><a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Órdenes OC</a></li>
                            <li><a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="nav-link"><i class="fas fa-check-circle me-2"></i>Conformidad</a></li>
                            <div class="nav-section">Administración</div>
                            <li><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="nav-link"><i class="fas fa-users me-2"></i>Empleados</a></li>
                            <li><a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="nav-link"><i class="fas fa-truck me-2"></i>Proveedores</a></li>
                            <div class="nav-section mt-2"></div>
                            <li><a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-danger"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul></nav>
                </div>
                <!-- MAIN -->
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
                        <!-- Alerta banner -->
                        <% if (totalAlertas > 0) {%>
                        <div class="alert alert-warning d-flex align-items-center mb-4" role="alert">
                            <i class="fas fa-exclamation-triangle me-3 fs-5"></i>
                            <div><strong>⚠ Alerta de Stock Crítico:</strong> <strong><%= totalAlertas%></strong> artículo(s) requieren reposición. Se recomienda generar una Orden de Compra.</div>
                        </div>
                        <% }%>

                        <!-- FORMULARIO -->
                        <div class="card card-modern mb-4">
                            <div class="card-header bg-white py-3">
                                <h5 class="mb-0"><i class="fas fa-<%= articuloEditar != null ? "edit" : "plus-circle"%> me-2 text-primary"></i><%= articuloEditar != null ? "Editar Artículo" : "Nuevo Artículo"%></h5>
                            </div>
                            <div class="card-body">
                                <form action="${pageContext.request.contextPath}/ArticuloServlet" method="post" class="row g-3">
                                    <input type="hidden" name="accion" value="<%= articuloEditar != null ? "actualizar" : "guardar"%>"/>
                                    <% if (articuloEditar != null) {%><input type="hidden" name="idArticulo" value="<%= articuloEditar.getIdArticulo()%>"/><% }%>
                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Nombre del Artículo</label>
                                        <input type="text" name="nombre" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getNombre() : ""%>" placeholder="Ej: Chaleco antibalas" required>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Stock Actual</label>
                                        <input type="number" name="stock" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getStock() : "0"%>" min="0" required>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Stock Límite</label>
                                        <input type="number" name="stockLimite" class="form-control" value="<%= articuloEditar != null ? articuloEditar.getStockLimite() : "5"%>" min="0" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-semibold">Descripción</label>
                                        <input type="text" name="descripcion" class="form-control" value="<%= articuloEditar != null && articuloEditar.getDescripcion() != null ? articuloEditar.getDescripcion() : ""%>" placeholder="Descripción opcional">
                                    </div>
                                    <% if (articuloEditar != null) {%>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <div class="form-check mb-2">
                                            <input type="hidden" name="estado" value="false" />
                                            <input class="form-check-input" type="checkbox" name="estado" id="estadoArt"
                                                   value="true"
                                                   <%= (articuloEditar != null ? (articuloEditar.isEstado() ? "checked" : "") : "checked")%> >
                                            <label class="form-check-label" for="estadoArt">Activo</label>
                                        </div>
                                    </div>
                                    <% }%>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <button type="submit" class="btn btn-primary w-100"><i class="fas fa-save me-1"></i><%= articuloEditar != null ? "Actualizar" : "Guardar"%></button>
                                    </div>
                                    <% if (articuloEditar != null) { %>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="btn btn-secondary w-100">Cancelar</a>
                                    </div>
                                    <% }%>
                                </form>
                            </div>
                        </div>

                        <!-- TABLA -->
                        <div class="card card-modern">
                            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                                <h5 class="mb-0"><i class="fas fa-list me-2 text-primary"></i>Inventario de Artículos</h5>
                                <span class="badge bg-primary"><%= articulos != null ? articulos.size() : 0%> artículos</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="bg-light">
                                            <tr><th class="px-4">#</th><th>Artículo</th><th class="text-center">Stock Actual</th><th class="text-center">Límite</th><th class="text-center">Estado Stock</th><th class="text-center">Requiere OC</th><th class="text-center">Acciones</th></tr>
                                        </thead>
                                        <tbody>
                                            <% if (articulos != null && !articulos.isEmpty()) {
                                                    for (Articulo a : articulos) {
                                                        boolean alerta = "ALERTA".equals(a.getEstadoStock());
                                                        int pct = a.getStockLimite() > 0 ? Math.min(100, a.getStock() * 100 / (a.getStockLimite() * 2)) : 100;
                                                        String barColor = alerta ? "#dc2626" : "#16a34a";
                                            %>
                                            <tr class="<%= alerta ? "table-warning" : ""%>">
                                                <td class="px-4 fw-semibold text-primary">#<%= a.getIdArticulo()%></td>
                                                <td>
                                                    <div class="fw-semibold"><%= a.getNombre()%></div>
                                                    <small class="text-muted"><%= a.getDescripcion() != null ? a.getDescripcion() : ""%></small>
                                                    <div class="stock-bar"><div class="stock-bar-fill" style="width:<%= pct%>%;background:<%= barColor%>"></div></div>
                                                </td>
                                                <td class="text-center fw-bold fs-5 <%= alerta ? "text-danger" : "text-success"%>"><%= a.getStock()%></td>
                                                <td class="text-center text-muted"><%= a.getStockLimite()%></td>
                                                <td class="text-center">
                                                    <span class="badge <%= alerta ? "bg-danger" : "bg-success"%>">
                                                        <i class="fas fa-<%= alerta ? "exclamation-triangle" : "check"%> me-1"></i><%= alerta ? "ALERTA" : "OK"%>
                                                    </span>
                                                </td>
                                                <td class="text-center"><span class="badge <%= a.isRequiereCompra() ? "bg-warning text-dark" : "bg-light text-secondary border"%>"><%= a.isRequiereCompra() ? "Sí" : "No"%></span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=editar&id=<%= a.getIdArticulo()%>" class="btn btn-sm btn-outline-primary me-1"><i class="fas fa-edit"></i></a>
                                                    <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=eliminar&id=<%= a.getIdArticulo()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Eliminar artículo?')"><i class="fas fa-trash"></i></a>
                                                </td>
                                            </tr>
                                            <% }
                        } else { %>
                                            <tr><td colspan="7" class="text-center py-5 text-muted"><i class="fas fa-boxes fa-3x mb-3 d-block"></i>No hay artículos registrados</td></tr>
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