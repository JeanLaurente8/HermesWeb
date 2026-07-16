-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3307
-- Tiempo de generación: 16-07-2026 a las 09:10:06
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gestion_oc_alerta`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `abastecimiento`
--

CREATE TABLE `abastecimiento` (
  `id_abastecimiento` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_empleado` int(11) NOT NULL,
  `fecha_recepcion` datetime DEFAULT current_timestamp(),
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `abastecimiento`
--

INSERT INTO `abastecimiento` (`id_abastecimiento`, `id_orden`, `id_empleado`, `fecha_recepcion`, `observaciones`) VALUES
(1, 3, 1, '2026-07-07 16:49:18', ''),
(2, 18, 1, '2026-07-08 23:06:47', ''),
(3, 20, 1, '2026-07-08 23:21:28', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_trabajo`
--

CREATE TABLE `area_trabajo` (
  `id_area` int(11) NOT NULL,
  `nombre_area` varchar(100) NOT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `area_trabajo`
--

INSERT INTO `area_trabajo` (`id_area`, `nombre_area`, `estado`) VALUES
(1, 'Almacén', 1),
(2, 'Compras', 1),
(3, 'Operaciones (Procesamiento)', 1),
(4, 'Transporte de Valores', 1),
(5, 'Seguridad Electrónica', 1),
(6, 'Mantenimiento', 1),
(7, 'Recursos Humanos', 1),
(8, 'Administración y Finanzas', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `articulo`
--

CREATE TABLE `articulo` (
  `id_articulo` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `stock` int(11) DEFAULT 0,
  `stock_limite` int(11) DEFAULT 5,
  `imagen` longblob DEFAULT NULL,
  `requiere_compra` tinyint(1) DEFAULT 0,
  `estado` tinyint(1) DEFAULT 1,
  `stock_maximo` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) NOT NULL DEFAULT 0,
  `precio` decimal(10,2) DEFAULT 0.00,
  `id_proveedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `articulo`
--

INSERT INTO `articulo` (`id_articulo`, `nombre`, `descripcion`, `stock`, `stock_limite`, `imagen`, `requiere_compra`, `estado`, `stock_maximo`, `stock_minimo`, `precio`, `id_proveedor`) VALUES
(1, 'Precinto de Seguridad Polipropileno', 'Precintos para valijas de transporte', 500, 200, NULL, 0, 1, 0, 0, 20.00, 1),
(2, 'Bolsa para Transporte de Efectivo', 'Bolsas de alta resistencia 30x40cm', 111, 100, NULL, 0, 1, 0, 0, 10.00, 1),
(3, 'Chaleco Antibalas Nivel III', 'EPP para personal operativo', 10, 5, NULL, 0, 1, 0, 0, 120.00, 1),
(4, 'Papel Térmico para Voucher', 'Rollos para terminales de procesamiento', 50, 60, NULL, 1, 1, 0, 0, 40.00, 1),
(5, 'Cinta de Embalaje Transparente', 'Cinta industrial 2x100yd', 12, 10, NULL, 0, 1, 0, 0, 10.00, 4),
(6, 'Tinta para Sellos de Seguridad', 'Tinta indeleble color rojo', 5, 8, NULL, 1, 1, 0, 0, 14.00, 1),
(7, 'Destornillador', 'Artículo requerido para el almacén', 10, 2, NULL, 0, 1, 0, 0, 10.00, 4),
(8, 'Prueba', 'Prueba', 3, 3, NULL, 1, 1, 0, 0, 2.00, 4),
(9, 'Papel Toalla', 'Papel Toalla Paracas Extra Suave', 10, 5, NULL, 0, 1, 0, 0, 2.00, 4);

--
-- Disparadores `articulo`
--
DELIMITER $$
CREATE TRIGGER `tr_evaluar_stock_hermes` BEFORE UPDATE ON `articulo` FOR EACH ROW BEGIN
    -- Si el stock actual es menor o igual al límite, se activa la alerta
    IF NEW.stock <= NEW.stock_limite THEN
        SET NEW.requiere_compra = TRUE;
    ELSE
        SET NEW.requiere_compra = FALSE;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `conformidad`
--

CREATE TABLE `conformidad` (
  `id_conformidad` int(11) NOT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `fecha_conformidad` timestamp NOT NULL DEFAULT current_timestamp(),
  `firma_conformidad` tinyint(1) DEFAULT 0,
  `comentarios` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `conformidad`
--

INSERT INTO `conformidad` (`id_conformidad`, `id_solicitud`, `id_empleado`, `fecha_conformidad`, `firma_conformidad`, `comentarios`) VALUES
(1, 1, 1, '2026-06-04 20:30:46', 1, 'Material recibido completo y sellado.'),
(2, 2, 2, '2026-06-10 04:34:57', 1, ''),
(3, 5, 7, '2026-06-23 05:08:07', 1, ''),
(4, 8, 6, '2026-06-24 02:02:31', 1, ''),
(5, 7, 7, '2026-06-24 02:13:54', 1, ''),
(6, 9, 5, '2026-06-24 04:15:04', 1, 'Prueba'),
(7, 10, 5, '2026-06-24 04:25:00', 1, ''),
(8, 11, 5, '2026-06-24 04:25:50', 1, ''),
(9, 12, 5, '2026-06-24 04:26:37', 1, ''),
(10, 14, 5, '2026-06-25 05:18:30', 1, ''),
(11, 15, 2, '2026-07-02 11:29:33', 1, ''),
(12, 16, 6, '2026-07-02 14:08:43', 1, ''),
(13, 18, 7, '2026-07-02 17:36:17', 1, ''),
(14, 19, 6, '2026-07-02 19:37:54', 1, ''),
(15, 22, 6, '2026-07-02 19:40:21', 1, 'Conforme'),
(16, 17, 6, '2026-07-16 06:37:52', 0, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_oc`
--

CREATE TABLE `detalle_oc` (
  `id_detalle_oc` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `id_articulo` int(11) DEFAULT NULL,
  `id_orden` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_oc`
--

INSERT INTO `detalle_oc` (`id_detalle_oc`, `cantidad`, `id_articulo`, `id_orden`) VALUES
(2, 10, 2, 18),
(3, 3, 3, 19),
(8, 14, 5, 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_solicitud`
--

CREATE TABLE `detalle_solicitud` (
  `id_detalle` int(11) NOT NULL,
  `id_solicitud` int(11) DEFAULT NULL,
  `id_articulo` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalle_solicitud`
--

INSERT INTO `detalle_solicitud` (`id_detalle`, `id_solicitud`, `id_articulo`, `cantidad`) VALUES
(1, 1, 1, 100),
(2, 1, 2, 50),
(3, 4, 2, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `devolucion`
--

CREATE TABLE `devolucion` (
  `id_devolucion` int(11) NOT NULL,
  `id_solicitud` int(11) NOT NULL,
  `id_empleado` int(11) NOT NULL,
  `cantidad_devuelta` int(11) NOT NULL,
  `motivo` text DEFAULT NULL,
  `fecha_devolucion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `devolucion`
--

INSERT INTO `devolucion` (`id_devolucion`, `id_solicitud`, `id_empleado`, `cantidad_devuelta`, `motivo`, `fecha_devolucion`) VALUES
(1, 17, 1, 1, 'Artículo dañado', '2026-07-15 17:37:58'),
(2, 17, 1, 1, '', '2026-07-15 19:00:52'),
(3, 21, 1, 1, '', '2026-07-15 21:36:58'),
(4, 13, 1, 200, '', '2026-07-15 21:37:09'),
(5, 6, 1, 7, '', '2026-07-15 23:52:35'),
(6, 23, 1, 5, 'Prueba', '2026-07-15 23:54:15'),
(7, 23, 1, 4, 'Prueba', '2026-07-15 23:54:29');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `id_empleado` int(11) NOT NULL,
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido_paterno` varchar(100) NOT NULL,
  `apellido_materno` varchar(100) NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `correo` varchar(150) DEFAULT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `id_area` int(11) DEFAULT NULL,
  `cargo` varchar(50) NOT NULL,
  `estado` tinyint(1) DEFAULT 1,
  `token_recuperacion` varchar(100) DEFAULT NULL,
  `expiracion_token` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`id_empleado`, `dni`, `nombre`, `apellido_paterno`, `apellido_materno`, `fecha_nacimiento`, `direccion`, `correo`, `username`, `password`, `id_area`, `cargo`, `estado`, `token_recuperacion`, `expiracion_token`) VALUES
(1, '70000001', 'Carlos', 'Nolan', 'Mariategui', '1995-04-12', 'Av. Defensores del Morro 456, Chorrillos', 'carlos.admin@hermes.com.pe', 'admin', 'admin123', 3, 'Administrador', 1, NULL, NULL),
(2, '40000002', 'Ricardo', 'Holder', 'Lopez', '1988-08-23', 'Calle Los Ficus 123, Santiago de Surco', 'ricardo.almacen@hermes.com.pe', 'almacen01', 'almacen123', 1, 'Asistente Almacén', 1, NULL, NULL),
(3, '10000003', 'Patricia', 'Noni', 'Tapia', '1992-11-05', 'Av. Javier Prado Este 2540, San Borja', 'patricia.compras@hermes.com.pe', 'analista01', 'analista123', 2, 'Analista Compras', 1, NULL, NULL),
(4, '08000004', 'Jorge', 'Torres', 'Maldonado', '1981-02-14', 'Av. Paseo de la República 3650, San Isidro', 'jorge.gerente@hermes.com.pe', 'gerente01', 'gerente123', 2, 'Gerente Compras', 1, NULL, NULL),
(5, '78008009', 'JEAN FRANCO ANTONIO', 'LAURENTE', 'CARRASCO', NULL, NULL, 'geanfranco_lc_15@hotmail.com', 'coordinador01', 'Coordinador12345', 1, 'Coordinador Almacén', 1, NULL, NULL),
(6, '70469587', 'LUIS HERNAN', 'NOHARA', 'VARGAS', NULL, NULL, '70469587@mail.isil.pe', 'empleado01', 'empleado456', 6, 'Empleado', 1, NULL, NULL),
(7, '73636621', 'DANIEL ENRIQUE', 'CARHUAS', 'CANCHUMANYA', NULL, NULL, 'francooalc@gmail.com', 'empleado02', 'empleado456', 6, 'Empleado', 1, NULL, NULL),
(8, '44923234', 'CARLOS ANDRES', 'TIPACTI', 'MONTES', NULL, NULL, '78008009@mail.isil.pe', 'analista04', 'analista123456', 2, 'Analista Compras', 0, NULL, NULL),
(9, '78008008', 'MIRELLA CYNTHIA', 'LAURENTE', 'CARRASCO', NULL, NULL, '44923234@mail.isil.pe', 'gerente02', 'prueba1234', NULL, 'Analista Compras', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_compra`
--

CREATE TABLE `orden_compra` (
  `id_orden` int(11) NOT NULL,
  `fecha_generacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_analista` int(11) DEFAULT NULL,
  `id_gerente` int(11) DEFAULT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `estado_oc` varchar(30) DEFAULT 'En Revisión',
  `descripcion` varchar(255) DEFAULT NULL,
  `es_automatica` bit(1) DEFAULT NULL,
  `id_articulo` int(11) DEFAULT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `orden_compra`
--

INSERT INTO `orden_compra` (`id_orden`, `fecha_generacion`, `id_analista`, `id_gerente`, `id_proveedor`, `estado_oc`, `descripcion`, `es_automatica`, `id_articulo`, `cantidad`) VALUES
(3, '2026-06-04 20:30:45', 3, 4, 3, 'Conforme', NULL, NULL, 0, 1),
(18, '2026-07-09 04:06:01', 3, 4, 1, 'Conforme', 'Bolsa para Transporte de Efectivo', b'1', NULL, 1),
(19, '2026-07-09 04:13:46', 3, 4, 4, 'En Revisión', 'Chaleco Antibalas Nivel III', b'1', NULL, 1),
(20, '2026-07-09 04:19:30', 3, 4, 1, 'Rechazada', 'Cinta de Embalaje Transparente', b'1', NULL, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL,
  `ruc` varchar(11) NOT NULL,
  `razon_social` varchar(200) NOT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `correo_proveedor` varchar(150) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`id_proveedor`, `ruc`, `razon_social`, `contacto`, `correo_proveedor`, `estado`) VALUES
(1, '20100100101', 'Seguridad Industrial S.A.C.', 'Ing. Alberto Rossi', 'ventas@seguridadind.com.pe', 1),
(2, '20554433221', 'Suministros Globales Perú', 'Sra. Maria Torres', 'pedidos@suministros.pe', 1),
(3, '20887766554', 'Tech Logistics S.A.', 'Sr. Kevin Huamán', 'corporativo@techlogistics.com', 1),
(4, '10780080090', 'LAURENTE CARRASCO JEAN FRANCO ANTONIO', 'Ing Jean Laurente', 'inversioneslogsac@mail.log.com', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitud`
--

CREATE TABLE `solicitud` (
  `id_solicitud` int(11) NOT NULL,
  `id_empleado` int(11) DEFAULT NULL,
  `id_area` int(11) DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT current_timestamp(),
  `estado_solicitud` varchar(30) DEFAULT 'Pendiente',
  `descripcion` text DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `id_articulo` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitud`
--

INSERT INTO `solicitud` (`id_solicitud`, `id_empleado`, `id_area`, `fecha_solicitud`, `estado_solicitud`, `descripcion`, `cantidad`, `id_articulo`) VALUES
(1, 1, 3, '2026-06-04 20:30:45', 'Pendiente', 'Solicitud mensual de precintos y bolsas para el área de procesamiento', NULL, NULL),
(2, 7, 8, '2026-06-10 03:43:40', 'Pendiente', '', NULL, NULL),
(4, 7, 8, '2026-06-10 03:57:57', 'Pendiente', 'A la espera de la aprobación de la solicitud', NULL, NULL),
(5, 7, 8, '2026-06-23 05:07:52', 'Pendiente', 'Req de prueba', NULL, NULL),
(6, 7, 6, '2026-06-23 13:06:36', 'Aprobada', 'REQ Prueba', 7, 3),
(7, 2, 1, '2026-06-23 13:39:30', 'Rechazada', 'REQ Prueba | Motivo rechazo: No hay stock', 1, 3),
(8, 5, 1, '2026-06-23 13:39:50', 'Entregada', 'REQ Prueba', 39, 2),
(9, 2, 1, '2026-06-24 04:14:45', 'Entregada', 'REQ Prueba', 15, 6),
(10, 1, 3, '2026-06-24 04:24:48', 'Entregada', 'REQ Prueba', 1, 1),
(11, 3, 2, '2026-06-24 04:25:36', 'Entregada', 'REQ Prueba', 1, 1),
(12, 8, 2, '2026-06-24 04:26:25', 'Entregada', 'REQ Prueba', 51, 2),
(13, 3, 2, '2026-06-24 20:33:12', 'Aprobada', 'REQ Prueba', 200, 1),
(14, 7, 6, '2026-06-25 05:11:46', 'Entregada', 'REQ Prueba', 30, 1),
(15, 2, 1, '2026-06-25 05:42:28', 'Entregada', 'REQ Prueba', 30, 2),
(16, 6, 6, '2026-07-02 14:08:08', 'Entregada', 'Requerimiento mensual de Julio', 2, 2),
(17, 6, 6, '2026-07-02 14:28:16', 'Aprobada', 'Req Prueba', 2, 2),
(18, 6, 6, '2026-07-02 14:28:17', 'Entregada', 'Req Prueba | Motivo rechazo: Falta de stock', 2, 3),
(19, 6, 6, '2026-07-02 18:35:52', 'Entregada', 'Requerido mensual', 1, 3),
(20, 6, 6, '2026-07-02 18:35:52', 'Aprobada', 'Requerido mensual', 1, 2),
(21, 6, 6, '2026-07-02 18:35:52', 'Aprobada', 'Requerido mensual', 1, 5),
(22, 6, 6, '2026-07-02 19:38:45', 'Entregada', 'REQ Prueba', 3, 2),
(23, 1, 3, '2026-07-16 04:53:43', 'Aprobada', 'Prueba', 10, 7);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `abastecimiento`
--
ALTER TABLE `abastecimiento`
  ADD PRIMARY KEY (`id_abastecimiento`),
  ADD KEY `fk_abastecimiento_orden` (`id_orden`),
  ADD KEY `fk_abastecimiento_empleado` (`id_empleado`);

--
-- Indices de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `articulo`
--
ALTER TABLE `articulo`
  ADD PRIMARY KEY (`id_articulo`),
  ADD KEY `idx_buscar_articulo` (`nombre`),
  ADD KEY `fk_art_prov` (`id_proveedor`);

--
-- Indices de la tabla `conformidad`
--
ALTER TABLE `conformidad`
  ADD PRIMARY KEY (`id_conformidad`),
  ADD KEY `id_solicitud` (`id_solicitud`),
  ADD KEY `id_empleado` (`id_empleado`);

--
-- Indices de la tabla `detalle_oc`
--
ALTER TABLE `detalle_oc`
  ADD PRIMARY KEY (`id_detalle_oc`),
  ADD KEY `FKbtm5v0iat66yx0gnajeqsix59` (`id_articulo`),
  ADD KEY `FKovdrij07hsu8rvqjdqtjlmglx` (`id_orden`);

--
-- Indices de la tabla `detalle_solicitud`
--
ALTER TABLE `detalle_solicitud`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_solicitud` (`id_solicitud`),
  ADD KEY `id_articulo` (`id_articulo`);

--
-- Indices de la tabla `devolucion`
--
ALTER TABLE `devolucion`
  ADD PRIMARY KEY (`id_devolucion`),
  ADD KEY `id_solicitud` (`id_solicitud`),
  ADD KEY `id_empleado` (`id_empleado`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `dni` (`dni`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `correo` (`correo`),
  ADD KEY `id_area` (`id_area`);

--
-- Indices de la tabla `orden_compra`
--
ALTER TABLE `orden_compra`
  ADD PRIMARY KEY (`id_orden`),
  ADD KEY `id_analista` (`id_analista`),
  ADD KEY `id_gerente` (`id_gerente`),
  ADD KEY `id_proveedor` (`id_proveedor`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `ruc` (`ruc`);

--
-- Indices de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD PRIMARY KEY (`id_solicitud`),
  ADD KEY `id_empleado` (`id_empleado`),
  ADD KEY `id_area` (`id_area`),
  ADD KEY `FKr0demkus14xfe7aor9f5n2a8r` (`id_articulo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `abastecimiento`
--
ALTER TABLE `abastecimiento`
  MODIFY `id_abastecimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `articulo`
--
ALTER TABLE `articulo`
  MODIFY `id_articulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `conformidad`
--
ALTER TABLE `conformidad`
  MODIFY `id_conformidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `detalle_oc`
--
ALTER TABLE `detalle_oc`
  MODIFY `id_detalle_oc` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `detalle_solicitud`
--
ALTER TABLE `detalle_solicitud`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `devolucion`
--
ALTER TABLE `devolucion`
  MODIFY `id_devolucion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `orden_compra`
--
ALTER TABLE `orden_compra`
  MODIFY `id_orden` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  MODIFY `id_solicitud` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `abastecimiento`
--
ALTER TABLE `abastecimiento`
  ADD CONSTRAINT `fk_abastecimiento_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  ADD CONSTRAINT `fk_abastecimiento_orden` FOREIGN KEY (`id_orden`) REFERENCES `orden_compra` (`id_orden`);

--
-- Filtros para la tabla `articulo`
--
ALTER TABLE `articulo`
  ADD CONSTRAINT `fk_art_prov` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`);

--
-- Filtros para la tabla `conformidad`
--
ALTER TABLE `conformidad`
  ADD CONSTRAINT `conformidad_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  ADD CONSTRAINT `conformidad_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`);

--
-- Filtros para la tabla `detalle_oc`
--
ALTER TABLE `detalle_oc`
  ADD CONSTRAINT `FKbtm5v0iat66yx0gnajeqsix59` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`),
  ADD CONSTRAINT `FKovdrij07hsu8rvqjdqtjlmglx` FOREIGN KEY (`id_orden`) REFERENCES `orden_compra` (`id_orden`);

--
-- Filtros para la tabla `detalle_solicitud`
--
ALTER TABLE `detalle_solicitud`
  ADD CONSTRAINT `detalle_solicitud_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  ADD CONSTRAINT `detalle_solicitud_ibfk_2` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`);

--
-- Filtros para la tabla `devolucion`
--
ALTER TABLE `devolucion`
  ADD CONSTRAINT `devolucion_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  ADD CONSTRAINT `devolucion_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`);

--
-- Filtros para la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD CONSTRAINT `empleado_ibfk_1` FOREIGN KEY (`id_area`) REFERENCES `area_trabajo` (`id_area`);

--
-- Filtros para la tabla `orden_compra`
--
ALTER TABLE `orden_compra`
  ADD CONSTRAINT `orden_compra_ibfk_1` FOREIGN KEY (`id_analista`) REFERENCES `empleado` (`id_empleado`),
  ADD CONSTRAINT `orden_compra_ibfk_2` FOREIGN KEY (`id_gerente`) REFERENCES `empleado` (`id_empleado`),
  ADD CONSTRAINT `orden_compra_ibfk_3` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`);

--
-- Filtros para la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD CONSTRAINT `FKr0demkus14xfe7aor9f5n2a8r` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`),
  ADD CONSTRAINT `solicitud_ibfk_1` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  ADD CONSTRAINT `solicitud_ibfk_2` FOREIGN KEY (`id_area`) REFERENCES `area_trabajo` (`id_area`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
