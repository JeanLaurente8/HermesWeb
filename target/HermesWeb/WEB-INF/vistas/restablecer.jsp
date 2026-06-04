<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Nueva Contraseña - Hermes</title>
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
                <h4 class="fw-bold" style="color: #1a3a5c;">Crea una nueva contraseña</h4>
            </div>

            <% if (request.getAttribute("error") != null) {%>
            <div class="alert alert-danger"><%= request.getAttribute("error")%></div>
            <% }%>

            <form action="RecuperacionServlet" method="post">
                <input type="hidden" name="accion" value="cambiar">
                <input type="hidden" name="idEmpleado" value="<%= request.getAttribute("idEmpleado")%>">
                <input type="hidden" name="token" value="<%= request.getAttribute("token")%>">

                <div class="mb-3">
                    <label class="form-label fw-semibold">Nueva Contraseña</label>
                    <input type="password" name="password" class="form-control" required minlength="6">
                </div>
                <button type="submit" class="btn btn-success w-100">Actualizar Contraseña</button>
            </form>
        </div>
    </body>
</html>