<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.Empleado" %>
<%
    // Si ya hay sesión activa, redirigir al menú
    Empleado sesion = (Empleado) session.getAttribute("empleado");
    if (sesion != null) {
        response.sendRedirect(request.getContextPath() + "/MenuServlet");
        return;
    }
    // Si no hay sesión, redirigir al login
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
%>