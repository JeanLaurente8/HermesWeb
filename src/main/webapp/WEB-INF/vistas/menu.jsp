<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hermes – Menú Principal</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --primary: #1a3a5c;
                --accent: #2563eb;
            }
            .sidebar {
                background: linear-gradient(180deg, var(--primary) 0%, #0f2340 100%);
                min-height: 100vh;
                color: white;
            }
            .sidebar .brand {
                padding: 24px 20px 16px;
                border-bottom: 1px solid rgba(255,255,255,.1);
            }
            .sidebar .nav-link {
                color: rgba(255,255,255,.75);
                padding: 10px 20px;
                border-radius: 8px;
                margin: 2px 8px;
                transition: .2s;
                font-size: 14px;
            }
            .sidebar .nav-link:hover, .sidebar .nav-link.active {
                background: rgba(255,255,255,.12);
                color: white;
            }
            .sidebar .nav-section {
                font-size: 10px;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: rgba(255,255,255,.4);
                padding: 12px 20px 4px;
            }
            .main-content {
                background: #f1f5f9;
                min-height: 100vh;
            }
            .topbar {
                background: white;
                padding: 12px 24px;
                border-bottom: 1px solid #e2e8f0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .card-modern {
                border: none;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,.07);
                transition: .2s;
                text-decoration: none;
                color: inherit;
                display: block;
            }
            .card-modern:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 24px rgba(0,0,0,.12);
            }
            .card-icon-wrap {
                width: 56px;
                height: 56px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 24px;
            }
            .alert-strip {
                background: #fef3c7;
                border: 1px solid #fcd34d;
                border-radius: 10px;
                padding: 12px 16px;
            }
            .stat-card {
                border: none;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,.07);
            }
        </style>
    </head>
    <body>
        <%
            Empleado sesion = (Empleado) session.getAttribute("empleado");
            List<Articulo> alertas = (List<Articulo>) request.getAttribute("alertas");
            int totalAlertas = alertas != null ? alertas.size() : 0;
        %>
        <div class="container-fluid p-0">
            <div class="row g-0">
                <!-- SIDEBAR -->
                <div class="col-md-3 col-lg-2 sidebar">
                    <div class="brand">
                        <div class="d-flex align-items-center gap-2">
                            <span style="font-size:24px">🛡️</span>
                            <div>
                                <div class="fw-bold" style="font-size:15px">Hermes</div>
                                <div style="font-size:11px;opacity:.6">Sistema de Inventario</div>
                            </div>
                        </div>
                    </div>
                    <nav class="pt-2">
                        <ul class="nav flex-column">
                            <li><a href="${pageContext.request.contextPath}/MenuServlet" class="nav-link active"><i class="fas fa-home me-2"></i>Inicio</a></li>
                            <div class="nav-section">Inventario</div>
                            <li><a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="nav-link"><i class="fas fa-boxes me-2"></i>Artículos</a></li>
                            <li><a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="nav-link"><i class="fas fa-building me-2"></i>Áreas</a></li>
                            <div class="nav-section">Compras</div>
                            <li><a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="nav-link"><i class="fas fa-clipboard-list me-2"></i>Solicitudes</a></li>
                            <li><a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Órdenes OC</a></li>
                            <li><a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="nav-link"><i class="fas fa-check-circle me-2"></i>Conformidad</a></li>
                            <div class="nav-section">Administración</div>
                            <li><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="nav-link"><i class="fas fa-users me-2"></i>Empleados</a></li>
                            <li><a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="nav-link"><i class="fas fa-truck me-2"></i>Proveedores</a></li>
                            <div class="nav-section mt-3"></div>
                            <li><a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-danger"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul>
                    </nav>
                </div>

                <!-- MAIN -->
                <div class="col-md-9 col-lg-10 main-content">
                    <!-- TOPBAR -->
                    <div class="topbar">
                        <div>
                            <h6 class="mb-0 fw-bold text-dark">Panel Principal</h6>
                            <small class="text-muted">Sistema de Alertas Tempranas y Órdenes de Compra</small>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <% if (totalAlertas > 0) {%>
                            <span class="badge bg-warning text-dark"><i class="fas fa-bell me-1"></i><%= totalAlertas%> alertas</span>
                            <% }%>
                            <span class="text-muted small"><i class="fas fa-user me-1"></i><%= sesion != null ? sesion.getNombreCompleto() : ""%> &nbsp;·&nbsp; <%= sesion != null ? sesion.getCargo() : ""%></span>
                        </div>
                    </div>

                    <div class="p-4">
                        <!-- Bienvenida -->
                        <div class="mb-4">
                            <h4 class="fw-bold text-dark mb-1">Bienvenido, <%= sesion != null ? sesion.getNombre() : ""%> 👋</h4>
                            <p class="text-muted">Accede a todas las funcionalidades del sistema desde aquí.</p>
                        </div>

                        <!-- Alerta de stock -->
                        <% if (totalAlertas > 0) {%>
                        <div class="alert-strip mb-4">
                            <div class="d-flex align-items-center gap-3">
                                <span style="font-size:28px">⚠️</span>
                                <div>
                                    <strong>Alerta de Stock Crítico</strong> —
                                    <strong><%= totalAlertas%></strong> artículo(s) han alcanzado el nivel mínimo.
                                    <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="ms-2 fw-bold text-warning">Ver inventario →</a>
                                </div>
                            </div>
                        </div>
                        <% } %>

                        <!-- Cards de módulos -->
                        <div class="row g-3">
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-primary bg-opacity-10 mb-3"><i class="fas fa-boxes text-primary"></i></div>
                                    <h6 class="fw-bold mb-1">Artículos</h6>
                                    <small class="text-muted">Inventario y stock</small>
                                    <% if (totalAlertas > 0) {%>
                                    <span class="badge bg-warning text-dark mt-2" style="width:fit-content"><%= totalAlertas%> en alerta</span>
                                    <% }%>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-success bg-opacity-10 mb-3"><i class="fas fa-clipboard-list text-success"></i></div>
                                    <h6 class="fw-bold mb-1">Solicitudes</h6>
                                    <small class="text-muted">Pedidos de insumos</small>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-warning bg-opacity-10 mb-3"><i class="fas fa-shopping-cart text-warning"></i></div>
                                    <h6 class="fw-bold mb-1">Órdenes de Compra</h6>
                                    <small class="text-muted">Generación y aprobación</small>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-info bg-opacity-10 mb-3"><i class="fas fa-check-circle text-info"></i></div>
                                    <h6 class="fw-bold mb-1">Conformidad</h6>
                                    <small class="text-muted">Recepción de pedidos</small>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-secondary bg-opacity-10 mb-3"><i class="fas fa-truck text-secondary"></i></div>
                                    <h6 class="fw-bold mb-1">Proveedores</h6>
                                    <small class="text-muted">Directorio de proveedores</small>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-danger bg-opacity-10 mb-3"><i class="fas fa-users text-danger"></i></div>
                                    <h6 class="fw-bold mb-1">Empleados</h6>
                                    <small class="text-muted">Personal del sistema</small>
                                </a>
                            </div>
                            <div class="col-md-4 col-lg-3">
                                <a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="card-modern card p-3">
                                    <div class="card-icon-wrap bg-dark bg-opacity-10 mb-3"><i class="fas fa-building text-dark"></i></div>
                                    <h6 class="fw-bold mb-1">Áreas de Trabajo</h6>
                                    <small class="text-muted">Sedes y áreas</small>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>