<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="modelo.Empleado" %>
<%
    Empleado sesion = (Empleado) session.getAttribute("empleado");
    if (sesion != null) {
        response.sendRedirect(request.getContextPath() + "/MenuServlet");
        return;
    }
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
%>