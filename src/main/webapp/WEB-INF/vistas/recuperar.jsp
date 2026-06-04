<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Recuperar Contraseña - Hermes</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <style>
            body {
                background: #f1f5f9;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
            }
            .card-login {
                max-width: 400px;
                width: 100%;
                border: none;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
        </style>
    </head>
    <body>
        <div class="card card-login p-4">
            <div class="text-center mb-4">
                <h4 class="fw-bold" style="color: #1a3a5c;">🛡️ Hermes</h4>
                <p class="text-muted">Recuperación de cuenta</p>
            </div>

            <% if (request.getAttribute("error") != null) {%>
            <div class="alert alert-danger"><%= request.getAttribute("error")%></div>
            <% } %>

            <% if (request.getAttribute("mensaje") != null) {%>
            <div class="alert alert-success"><%= request.getAttribute("mensaje")%></div>
            <% } else { %>
            <form action="RecuperacionServlet" method="post">
                <input type="hidden" name="accion" value="solicitar">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Correo Electrónico</label>
                    <input type="email" name="correo" class="form-control" placeholder="tu@correo.com" required>
                    <div class="form-text">Te enviaremos un enlace seguro para restablecer tu clave.</div>
                </div>
                <button type="submit" class="btn btn-primary w-100 mb-3">Enviar enlace de recuperación</button>
            </form>
            <% }%>
            <div class="text-center">
                <a href="${pageContext.request.contextPath}/LoginServlet" class="text-decoration-none">Volver al inicio de sesión</a>
            </div>
        </div>
    </body>
</html>