package util;

import modelo.Empleado;

public class AuthUtils {

    public static boolean puedeVerModulo(Empleado e, String modulo) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";

        if (username.equalsIgnoreCase("admin")) {
            return true;
        }

        switch (modulo) {
            case "Articulos":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Empleado");

            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "Solicitudes":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Gerente Compras");

            case "Conformidad":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

            case "Empleados":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "Areas":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "Abastecimiento":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén");

            case "Devolucion":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            default:
                return false;
        }
    }

    public static boolean tieneAccesoCompleto(Empleado e, String modulo) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";

        if (username.equalsIgnoreCase("admin")) {
            return true;
        }

        switch (modulo) {
            case "Articulos":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "Solicitudes":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

            case "Conformidad":
                return cargo.equalsIgnoreCase("Empleado");

            case "Empleados":
                return false;

            case "Areas":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "Abastecimiento":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén");

            case "Devolucion":
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            default:
                return false;
        }
    }

    public static boolean puedeGestionarSolicitudes(Empleado e) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";
        return username.equalsIgnoreCase("admin")
                || cargo.equalsIgnoreCase("Gerente Compras")
                || cargo.equalsIgnoreCase("Asistente Almacén");
    }
}