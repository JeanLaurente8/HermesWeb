<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Hermes – Iniciar Sesión</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            :root {
                --primary: #1a3a5c;
                --accent: #2563eb;
            }
            body {
                background: linear-gradient(135deg, var(--primary) 0%, #2563eb 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .login-card {
                border: none;
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                width: 100%;
                max-width: 420px;
            }
            .login-header {
                background: linear-gradient(135deg, var(--primary), var(--accent));
                border-radius: 16px 16px 0 0;
                padding: 32px;
                text-align: center;
                color: white;
            }
            .login-header .shield-icon {
                font-size: 48px;
                margin-bottom: 12px;
            }
            .login-body {
                padding: 32px;
            }
            .form-control:focus {
                border-color: var(--accent);
                box-shadow: 0 0 0 3px rgba(37,99,235,.15);
            }
            .btn-login {
                background: linear-gradient(135deg, var(--primary), var(--accent));
                border: none;
                font-weight: 600;
                padding: 12px;
                border-radius: 8px;
            }
            .btn-login:hover {
                opacity: .9;
            }
            .alert-danger {
                border-radius: 8px;
                font-size: 14px;
            }
            .hint-box {
                background: #f0f9ff;
                border: 1px solid #bae6fd;
                border-radius: 8px;
                padding: 12px;
                font-size: 13px;
                color: #0369a1;
            }
        </style>
    </head>
    <body>
        <div class="login-card card">
            <div class="login-header">
                <div class="shield-icon">🛡️</div>
                <h4 class="fw-bold mb-1">Hermes Transportes</h4>
                <p class="mb-0 opacity-75 small">Sistema de Gestión de Inventario y OC</p>
            </div>
            <div class="login-body">
                <h5 class="fw-semibold mb-4 text-center text-dark">Iniciar Sesión</h5>

                <% String error = (String) request.getAttribute("error");
            if (error != null) {%>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i><%= error%>
                </div>
                <% }%>

                <form action="${pageContext.request.contextPath}/LoginServlet" method="post" id="loginForm" class="needs-validation" novalidate>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Usuario</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-user text-muted"></i></span>
                            <input type="text" name="username" id="username" class="form-control" placeholder="Ej: almacen01" required pattern="^[a-zA-Z0-9_\-]+$" autofocus>
                            <div class="invalid-feedback">Ingrese un usuario válido.</div>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Contraseña</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock text-muted"></i></span>
                            <input type="password" name="password" id="password" class="form-control" placeholder="••••••••" required>
                            <div class="invalid-feedback">La contraseña es obligatoria.</div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-login btn-primary w-100 text-white">
                        <i class="fas fa-sign-in-alt me-2"></i>Ingresar al Sistema
                    </button>
                    <a href="RecuperacionServlet" class="small text-decoration-none">¿Olvidaste tu contraseña?</a>
                </form>

                <div class="hint-box mt-4">
                    <i class="fas fa-info-circle me-1"></i>
                    <strong>Usuarios de prueba:</strong><br>
                    almacen01 / analista01 / gerente01<br>
                    <span class="text-muted">(contraseña = nombre + 123)</span>
                </div>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (() => {
                'use strict'
                const form = document.getElementById('loginForm')
                const userField = document.getElementById('username')
                
                form.addEventListener('submit', event => {
                    userField.value = userField.value.trim();
                    
                    if (!form.checkValidity()) {
                        event.preventDefault()
                        event.stopPropagation()
                    }
                    form.classList.add('was-validated')
                }, false)
            })()
        </script>
    </body>
</html>