package util;

import modelo.Empleado;

public class AuthUtils {

    // Controla si el usuario puede ver el módulo en el menú lateral o pantalla principal
    public static boolean puedeVerModulo(Empleado e, String modulo) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";

        // Si el username es 'admin', ve TODO.
        if (username.equalsIgnoreCase("admin")) {
            return true;
        }

        switch (modulo) {
            case "Articulos":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");
            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");
            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");
            case "Solicitudes":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén");
            case "Conformidad":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Asistente Almacén");
            case "Empleados":
                return cargo.equalsIgnoreCase("Asistente Almacén");
            case "Areas":
                // Define qué usuario puede ver las áreas
                return cargo.equalsIgnoreCase("Gerente Compras");
            default:
                return false;
        }
    }

    // Controla si el usuario puede CREAR, EDITAR o ELIMINAR (Acceso Completo)
    public static boolean tieneAccesoCompleto(Empleado e, String modulo) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";

        // Admin tiene control total
        if (username.equalsIgnoreCase("admin")) {
            return true;
        }

        switch (modulo) {
            case "Articulos":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");
            // Analista Compras no entra aquí (solo visualiza)
            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras");
            // Analista Compras no entra aquí (solo visualiza)
            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");
            case "Solicitudes":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");
            case "Conformidad":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Asistente Almacén");
            case "Empleados":
                return false; // Asistente Almacén solo visualiza.
            case "Areas":
                return cargo.equalsIgnoreCase("Gerente Compras");
            default:
                return false;
        }
    }
}