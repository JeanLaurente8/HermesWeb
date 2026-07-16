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
                // Asistente Almacén solo puede VER artículos (sin CRUD)
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén");

            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "Solicitudes":
                // Empleados, Coordinador y Asistente Almacén pueden ver solicitudes
                // Gerente y Analista también las ven para aprobar/rechazar
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén")
                        || cargo.equalsIgnoreCase("Asistente Almacén")
                        || cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "Conformidad":
                // Asistente Almacén solo VE el listado (sin CRUD)
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Asistente Almacén");

            case "Empleados":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "Areas":
                return cargo.equalsIgnoreCase("Gerente Compras");

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
                // Asistente Almacén NO tiene acceso completo, solo visualiza
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

            case "Proveedores":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "OrdenesCompra":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras");

            case "Solicitudes":
                // Empleado y Coordinador pueden crear solicitudes
                // Asistente Almacén NO puede crear solicitudes
                return cargo.equalsIgnoreCase("Empleado")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

            case "Conformidad":
                // Asistente Almacén SOLO visualiza, no puede crear/editar conformidades
                return cargo.equalsIgnoreCase("Empleado");

            case "Empleados":
                return false;

            case "Areas":
                return cargo.equalsIgnoreCase("Gerente Compras");

            case "Abastecimiento":
                return cargo.equalsIgnoreCase("Gerente Compras")
                        || cargo.equalsIgnoreCase("Analista Compras")
                        || cargo.equalsIgnoreCase("Coordinador Almacén");

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

    // Puede aprobar o rechazar solicitudes
    public static boolean puedeGestionarSolicitudes(Empleado e) {
        if (e == null) {
            return false;
        }
        String cargo = e.getCargo() != null ? e.getCargo() : "";
        String username = e.getUsername() != null ? e.getUsername() : "";
        return username.equalsIgnoreCase("admin")
                || cargo.equalsIgnoreCase("Gerente Compras")
                || cargo.equalsIgnoreCase("Asistente Almacén")
                || cargo.equalsIgnoreCase("Analista Compras");
    }
}
