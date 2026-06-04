<%@ page pageEncoding="UTF-8" %>
<%@ page import="modelo.Empleado, util.AuthUtils" %>
<%
    Empleado usuarioActual = (Empleado) session.getAttribute("empleado");
%>

<div class="col-md-3 col-lg-2 sidebar">
    <div class="p-3 border-bottom border-secondary border-opacity-25">
        <div class="d-flex align-items-center gap-2">
            <span style="font-size:22px">🛡️</span>
            <div>
                <div class="fw-bold" style="font-size:14px">Hermes</div>
                <div style="font-size:11px;opacity:.6">Inventario</div>
            </div>
        </div>
    </div>
    <nav class="pt-2">
        <ul class="nav flex-column">
            <li><a href="${pageContext.request.contextPath}/MenuServlet" class="nav-link"><i class="fas fa-home me-2"></i>Inicio</a></li>

            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Articulos") || AuthUtils.puedeVerModulo(usuarioActual, "Areas")) { %>
            <div class="nav-section">Inventario</div>
            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Articulos")) { %>
            <li><a href="${pageContext.request.contextPath}/ArticuloServlet?accion=listar" class="nav-link"><i class="fas fa-boxes me-2"></i>Artículos</a></li>
                <% } %>
            <li><a href="${pageContext.request.contextPath}/AreaTrabajoServlet?accion=listar" class="nav-link"><i class="fas fa-building me-2"></i>Áreas</a></li>
                <% } %>

            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Solicitudes") || AuthUtils.puedeVerModulo(usuarioActual, "OrdenesCompra") || AuthUtils.puedeVerModulo(usuarioActual, "Conformidad")) { %>
            <div class="nav-section">Compras</div>
            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Solicitudes")) { %>
            <li><a href="${pageContext.request.contextPath}/SolicitudServlet?accion=listar" class="nav-link"><i class="fas fa-clipboard-list me-2"></i>Solicitudes</a></li>
                <% } %>
                <% if (AuthUtils.puedeVerModulo(usuarioActual, "OrdenesCompra")) { %>
            <li><a href="${pageContext.request.contextPath}/OrdenCompraServlet?accion=listar" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Órdenes OC</a></li>
                <% } %>
                <% if (AuthUtils.puedeVerModulo(usuarioActual, "Conformidad")) { %>
            <li><a href="${pageContext.request.contextPath}/ConformidadServlet?accion=listar" class="nav-link"><i class="fas fa-check-circle me-2"></i>Conformidad</a></li>
                <% } %>
                <% } %>

            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Empleados") || AuthUtils.puedeVerModulo(usuarioActual, "Proveedores")) { %>
            <div class="nav-section">Administración</div>
            <% if (AuthUtils.puedeVerModulo(usuarioActual, "Empleados")) { %>
            <li><a href="${pageContext.request.contextPath}/EmpleadoServlet?accion=listar" class="nav-link"><i class="fas fa-users me-2"></i>Empleados</a></li>
                <% } %>
                <% if (AuthUtils.puedeVerModulo(usuarioActual, "Proveedores")) { %>
            <li><a href="${pageContext.request.contextPath}/ProveedorServlet?accion=listar" class="nav-link"><i class="fas fa-truck me-2"></i>Proveedores</a></li>
                <% } %>
                <% }%>

            <div class="nav-section mt-2"></div>
            <li><a href="${pageContext.request.contextPath}/LogoutServlet" class="nav-link text-danger"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
        </ul>
    </nav>
</div>