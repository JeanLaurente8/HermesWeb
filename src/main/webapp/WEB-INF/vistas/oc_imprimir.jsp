<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.*, java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>OC - Detalle de Impresión</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
        body { padding: 40px; }
        @media print {
            .no-print { display: none !important; }
            body { padding: 0; }
        }
        .encabezado { border-bottom: 3px solid #1a3a5c; padding-bottom: 12px; margin-bottom: 24px; }
    </style>
</head>
<body>
<%
    Ordencompra oc = (Ordencompra) request.getAttribute("oc");
%>
<div class="no-print mb-3 text-end">
    <button class="btn btn-primary" onclick="window.print()"><i class="fas fa-print"></i> Imprimir / Guardar PDF</button>
    <button class="btn btn-secondary" onclick="window.close()">Cerrar</button>
</div>

<div class="encabezado d-flex justify-content-between">
    <div>
        <h3 class="mb-0">Orden de Compra OC-<%= oc.getIdOrden() %></h3>
        <small class="text-muted">Sistema Hermes — Inventario y Compras</small>
    </div>
    <div class="text-end">
        <span class="badge bg-primary fs-6"><%= oc.getEstadoOc() %></span><br>
        <small><%= oc.getFechaGeneracion() != null ? oc.getFechaGeneracion().toString().replace("T", " ").substring(0, 16) : "—" %></small>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-6">
        <p><strong>Proveedor:</strong> <%= oc.getProveedor() != null ? oc.getProveedor().getRazonSocial() : "—" %></p>
        <p><strong>Artículo en Alerta:</strong> <%= oc.getDescripcion() != null && !oc.getDescripcion().isEmpty() ? oc.getDescripcion() : "Manual" %></p>
    </div>
    <div class="col-md-6">
        <p><strong>Analista de Compras:</strong> <%= oc.getAnalista() != null ? oc.getAnalista().getNombreCompleto() : "—" %></p>
        <p><strong>Gerente de Compras:</strong> <%= oc.getGerente() != null ? oc.getGerente().getNombreCompleto() : "—" %></p>
    </div>
</div>

<%
    java.math.BigDecimal totalOC = java.math.BigDecimal.ZERO;
%>
<table class="table table-bordered">
    <thead class="table-light">
        <tr>
            <th>Artículo</th>
            <th>Proveedor</th>
            <th class="text-center">Cantidad</th>
            <th class="text-end">Precio Unit.</th>
            <th class="text-end">Subtotal</th>
        </tr>
    </thead>
    <tbody>
        <% List<DetalleOc> detalles = oc.getDetalles();
           if (detalles != null && !detalles.isEmpty()) {
               for (DetalleOc d : detalles) {
                   Articulo art = d.getArticulo();
                   java.math.BigDecimal precioUnit = art != null && art.getPrecio() != null ? art.getPrecio() : java.math.BigDecimal.ZERO;
                   java.math.BigDecimal subtotal = precioUnit.multiply(java.math.BigDecimal.valueOf(d.getCantidad()));
                   totalOC = totalOC.add(subtotal);
        %>
        <tr>
            <td><%= art != null ? art.getNombre() : "Artículo eliminado" %></td>
            <td><%= d.getProveedor() != null ? d.getProveedor().getRazonSocial() : "—" %></td>
            <td class="text-center"><%= d.getCantidad() %></td>
            <td class="text-end">S/ <%= String.format("%.2f", precioUnit) %></td>
            <td class="text-end">S/ <%= String.format("%.2f", subtotal) %></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="5" class="text-center text-muted">Sin artículos registrados</td></tr>
        <% } %>
    </tbody>
    <% if (detalles != null && !detalles.isEmpty()) {
           java.math.BigDecimal igv = totalOC.multiply(new java.math.BigDecimal("0.18"));
           java.math.BigDecimal totalConIgv = totalOC.add(igv);
    %>
    <tfoot>
        <tr class="table-light">
            <th colspan="4" class="text-end">Subtotal</th>
            <th class="text-end">S/ <%= String.format("%.2f", totalOC) %></th>
        </tr>
        <tr class="table-light">
            <th colspan="4" class="text-end">IGV (18%)</th>
            <th class="text-end">S/ <%= String.format("%.2f", igv) %></th>
        </tr>
        <tr class="table-light">
            <th colspan="4" class="text-end">TOTAL</th>
            <th class="text-end">S/ <%= String.format("%.2f", totalConIgv) %></th>
        </tr>
    </tfoot>
    <% } %>
</table>

<script>
        window.onload = () => window.print();
</script>
</body>
</html>