CREATE DATABASE  IF NOT EXISTS `gestion_oc_alerta` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `gestion_oc_alerta`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: gestion_oc_alerta
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `abastecimiento`
--

DROP TABLE IF EXISTS `abastecimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abastecimiento` (
  `id_abastecimiento` int NOT NULL AUTO_INCREMENT,
  `id_orden` int NOT NULL,
  `id_empleado` int NOT NULL,
  `fecha_recepcion` datetime DEFAULT CURRENT_TIMESTAMP,
  `observaciones` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_abastecimiento`),
  KEY `fk_abastecimiento_orden` (`id_orden`),
  KEY `fk_abastecimiento_empleado` (`id_empleado`),
  CONSTRAINT `fk_abastecimiento_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `fk_abastecimiento_orden` FOREIGN KEY (`id_orden`) REFERENCES `orden_compra` (`id_orden`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abastecimiento`
--

LOCK TABLES `abastecimiento` WRITE;
/*!40000 ALTER TABLE `abastecimiento` DISABLE KEYS */;
INSERT INTO `abastecimiento` VALUES (1,3,1,'2026-07-07 16:49:18',''),(2,18,1,'2026-07-08 23:06:47',''),(3,20,1,'2026-07-08 23:21:28','');
/*!40000 ALTER TABLE `abastecimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `area_trabajo`
--

DROP TABLE IF EXISTS `area_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `area_trabajo` (
  `id_area` int NOT NULL AUTO_INCREMENT,
  `nombre_area` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id_area`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `area_trabajo`
--

LOCK TABLES `area_trabajo` WRITE;
/*!40000 ALTER TABLE `area_trabajo` DISABLE KEYS */;
INSERT INTO `area_trabajo` VALUES (1,'Almacén',1),(2,'Compras',1),(3,'Operaciones (Procesamiento)',1),(4,'Transporte de Valores',1),(5,'Seguridad Electrónica',1),(6,'Mantenimiento',1),(7,'Recursos Humanos',1),(8,'Administración y Finanzas',1);
/*!40000 ALTER TABLE `area_trabajo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `articulo`
--

DROP TABLE IF EXISTS `articulo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `articulo` (
  `id_articulo` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_general_ci,
  `stock` int DEFAULT '0',
  `stock_limite` int DEFAULT '5',
  `imagen` longblob,
  `requiere_compra` tinyint(1) DEFAULT '0',
  `estado` tinyint(1) DEFAULT '1',
  `stock_maximo` int NOT NULL DEFAULT '0',
  `stock_minimo` int NOT NULL DEFAULT '0',
  `precio` decimal(10,2) DEFAULT '0.00',
  `id_proveedor` int DEFAULT NULL,
  PRIMARY KEY (`id_articulo`),
  KEY `idx_buscar_articulo` (`nombre`),
  KEY `fk_art_prov` (`id_proveedor`),
  CONSTRAINT `fk_art_prov` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articulo`
--

LOCK TABLES `articulo` WRITE;
/*!40000 ALTER TABLE `articulo` DISABLE KEYS */;
INSERT INTO `articulo` VALUES (1,'Precinto de Seguridad Polipropileno','Precintos para valijas de transporte',500,200,NULL,0,1,0,0,20.00,1),(2,'Bolsa para Transporte de Efectivo','Bolsas de alta resistencia 30x40cm',113,101,NULL,0,1,0,0,10.00,1),(3,'Chaleco Antibalas Nivel III','EPP para personal operativo',10,5,NULL,0,1,0,0,120.00,1),(4,'Papel Térmico para Voucher','Rollos para terminales de procesamiento',50,60,NULL,1,1,0,0,40.00,1),(5,'Cinta de Embalaje Transparente','Cinta industrial 2x100yd',12,10,NULL,0,1,0,0,10.00,4),(6,'Tinta para Sellos de Seguridad','Tinta indeleble color rojo',5,8,NULL,1,1,0,0,14.00,1),(7,'Destornillador','Artículo requerido para el almacén',19,2,NULL,0,1,0,0,10.00,4),(8,'Prueba','Prueba',3,3,NULL,1,0,0,0,2.00,4),(9,'Papel Toalla','Papel Toalla Paracas Extra Suave',10,5,NULL,0,1,0,0,2.00,4),(10,'Faja para Billetes 100x','Paquete de fajas de papel engomado para fajos de alta denominación',5000,1000,NULL,0,1,0,0,15.50,7),(11,'Faja para Billetes 50x','Paquete de fajas de papel engomado',1500,1000,NULL,0,1,0,0,15.50,7),(12,'Bolsa de Monedas 500x','Bolsas de lona de alta resistencia para transporte de monedas',150,100,NULL,0,1,0,0,25.00,12),(13,'Precinto Plástico Numerado','Precinto de seguridad pull-tight con código de barras',500,300,NULL,0,1,0,0,0.80,12),(14,'Precinto Metálico Tipo Guaya','Precinto de alta seguridad para puertas de bóveda',500,150,NULL,0,1,0,0,4.50,12),(15,'Rollo Papel Térmico 80x80mm','Cajas de papel térmico para terminales y vouchers',100,50,NULL,0,1,0,0,45.00,8),(16,'Camisa Táctica Operativa','Camisa de uniforme resistente a fricción',120,40,NULL,0,1,0,0,85.00,9),(17,'Pantalón Cargo Operativo','Pantalón con refuerzos para tripulación',110,40,NULL,0,1,0,0,95.00,9),(18,'Botas de Seguridad Punta de Acero','Calzado dieléctrico antideslizante',35,30,NULL,0,1,0,0,140.00,9),(19,'Casco Balístico','Casco de protección para portavalores',15,10,NULL,0,1,0,0,350.00,6),(20,'Disco Duro para DVR 4TB','Almacenamiento optimizado para videovigilancia 24/7',8,5,NULL,0,1,0,0,520.00,22),(21,'Batería 12V 7Ah','Batería de respaldo para paneles de alarma',40,25,NULL,0,1,0,0,65.00,14),(22,'Llanta Blindada 22.5','Neumático especial para camiones de transporte de valores',12,10,NULL,0,1,0,0,1200.00,17),(23,'Aceite de Motor 15W40','Galonera de aceite sintético para flota pesada',45,20,NULL,0,1,0,0,110.00,17),(24,'Radio Portátil VHF','Equipo de radiocomunicación encriptada',10,5,NULL,0,1,0,0,850.00,16),(25,'Extintor PQS 6Kg','Extintor portátil multipropósito',60,20,NULL,0,1,0,0,95.00,19),(26,'Tinta Indeleble para Huellas','Almohadilla de alta fijación para controles biométricos físicos',30,20,NULL,0,1,0,0,28.00,7),(27,'Caja Fuerte Portátil','Caja de seguridad temporal para recojo en clientes',25,10,NULL,0,1,0,0,450.00,15),(28,'Sensor de Ruptura de Cristal','Sensor acústico para áreas acorazadas',30,15,NULL,0,1,0,0,180.00,14),(29,'Kit de Limpieza para Armas','Solvente, aceite y cepillos para mantenimiento de armamento',40,15,NULL,0,1,0,0,55.00,6);
/*!40000 ALTER TABLE `articulo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_evaluar_stock_hermes` BEFORE UPDATE ON `articulo` FOR EACH ROW BEGIN
    -- Si el stock actual es menor o igual al límite, se activa la alerta
    IF NEW.stock <= NEW.stock_limite THEN
        SET NEW.requiere_compra = TRUE;
    ELSE
        SET NEW.requiere_compra = FALSE;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `conformidad`
--

DROP TABLE IF EXISTS `conformidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conformidad` (
  `id_conformidad` int NOT NULL AUTO_INCREMENT,
  `id_solicitud` int DEFAULT NULL,
  `id_empleado` int DEFAULT NULL,
  `fecha_conformidad` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `firma_conformidad` tinyint(1) DEFAULT '0',
  `comentarios` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_conformidad`),
  KEY `id_solicitud` (`id_solicitud`),
  KEY `id_empleado` (`id_empleado`),
  CONSTRAINT `conformidad_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  CONSTRAINT `conformidad_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conformidad`
--

LOCK TABLES `conformidad` WRITE;
/*!40000 ALTER TABLE `conformidad` DISABLE KEYS */;
INSERT INTO `conformidad` VALUES (1,1,1,'2026-06-04 20:30:46',1,'Material recibido completo y sellado.'),(2,2,2,'2026-06-10 04:34:57',1,''),(3,5,7,'2026-06-23 05:08:07',1,''),(4,8,6,'2026-06-24 02:02:31',1,''),(5,7,7,'2026-06-24 02:13:54',1,''),(6,9,5,'2026-06-24 04:15:04',1,'Prueba'),(7,10,5,'2026-06-24 04:25:00',1,''),(8,11,5,'2026-06-24 04:25:50',1,''),(9,12,5,'2026-06-24 04:26:37',1,''),(10,14,5,'2026-06-25 05:18:30',1,''),(11,15,2,'2026-07-02 11:29:33',1,''),(12,16,6,'2026-07-02 14:08:43',1,''),(13,18,7,'2026-07-02 17:36:17',1,''),(14,19,6,'2026-07-02 19:37:54',1,''),(15,22,6,'2026-07-02 19:40:21',1,'Conforme'),(16,17,6,'2026-07-16 06:37:52',0,''),(17,20,6,'2026-07-22 16:11:02',0,'Prueba'),(18,NULL,6,'2026-07-22 23:09:06',0,'Prueba');
/*!40000 ALTER TABLE `conformidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_oc`
--

DROP TABLE IF EXISTS `detalle_oc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_oc` (
  `id_detalle_oc` int NOT NULL AUTO_INCREMENT,
  `cantidad` int DEFAULT NULL,
  `id_articulo` int DEFAULT NULL,
  `id_orden` int DEFAULT NULL,
  `id_proveedor` int DEFAULT NULL,
  PRIMARY KEY (`id_detalle_oc`),
  KEY `FKbtm5v0iat66yx0gnajeqsix59` (`id_articulo`),
  KEY `FKovdrij07hsu8rvqjdqtjlmglx` (`id_orden`),
  KEY `fk_detalle_oc_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_detalle_oc_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`),
  CONSTRAINT `FKbtm5v0iat66yx0gnajeqsix59` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`),
  CONSTRAINT `FKovdrij07hsu8rvqjdqtjlmglx` FOREIGN KEY (`id_orden`) REFERENCES `orden_compra` (`id_orden`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_oc`
--

LOCK TABLES `detalle_oc` WRITE;
/*!40000 ALTER TABLE `detalle_oc` DISABLE KEYS */;
INSERT INTO `detalle_oc` VALUES (2,10,2,18,NULL),(3,3,3,19,NULL),(8,14,5,20,NULL),(9,20,4,21,1);
/*!40000 ALTER TABLE `detalle_oc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_solicitud`
--

DROP TABLE IF EXISTS `detalle_solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_solicitud` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_solicitud` int DEFAULT NULL,
  `id_articulo` int DEFAULT NULL,
  `cantidad` int NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_solicitud` (`id_solicitud`),
  KEY `id_articulo` (`id_articulo`),
  CONSTRAINT `detalle_solicitud_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  CONSTRAINT `detalle_solicitud_ibfk_2` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_solicitud`
--

LOCK TABLES `detalle_solicitud` WRITE;
/*!40000 ALTER TABLE `detalle_solicitud` DISABLE KEYS */;
INSERT INTO `detalle_solicitud` VALUES (1,1,1,100),(2,1,2,50),(3,4,2,2);
/*!40000 ALTER TABLE `detalle_solicitud` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucion`
--

DROP TABLE IF EXISTS `devolucion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devolucion` (
  `id_devolucion` int NOT NULL AUTO_INCREMENT,
  `id_solicitud` int NOT NULL,
  `id_empleado` int NOT NULL,
  `cantidad_devuelta` int NOT NULL,
  `motivo` text COLLATE utf8mb4_general_ci,
  `fecha_devolucion` datetime DEFAULT NULL,
  `estado_devolucion` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_devolucion`),
  KEY `id_solicitud` (`id_solicitud`),
  KEY `id_empleado` (`id_empleado`),
  CONSTRAINT `devolucion_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`),
  CONSTRAINT `devolucion_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucion`
--

LOCK TABLES `devolucion` WRITE;
/*!40000 ALTER TABLE `devolucion` DISABLE KEYS */;
INSERT INTO `devolucion` VALUES (1,17,1,1,'Artículo dañado','2026-07-15 17:37:58','En revisión'),(2,17,1,1,'','2026-07-15 19:00:52','En revisión'),(3,21,1,1,'','2026-07-15 21:36:58','En revisión'),(4,13,1,200,'','2026-07-15 21:37:09','En revisión'),(5,6,1,7,'','2026-07-15 23:52:35','En revisión'),(6,23,1,5,'Prueba','2026-07-15 23:54:15','Aprobado'),(7,23,1,4,'Prueba','2026-07-15 23:54:29','Aprobado'),(8,22,6,3,'','2026-07-22 18:10:21','En revisión');
/*!40000 ALTER TABLE `devolucion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleado`
--

DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleado` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `dni` varchar(8) COLLATE utf8mb4_general_ci NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `apellido_paterno` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `apellido_materno` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `correo` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `id_area` int DEFAULT NULL,
  `cargo` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `token_recuperacion` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `expiracion_token` datetime DEFAULT NULL,
  PRIMARY KEY (`id_empleado`),
  UNIQUE KEY `dni` (`dni`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `correo` (`correo`),
  KEY `id_area` (`id_area`),
  CONSTRAINT `empleado_ibfk_1` FOREIGN KEY (`id_area`) REFERENCES `area_trabajo` (`id_area`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleado`
--

LOCK TABLES `empleado` WRITE;
/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` VALUES (1,'70000001','Carlos','Nolan','Mariategui','1995-04-12','Av. Defensores del Morro 456, Chorrillos','carlos.admin@hermes.com.pe','admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',3,'Administrador',1,NULL,NULL),(2,'40000002','Ricardo','Holder','Lopez','1988-08-23','Calle Los Ficus 123, Santiago de Surco','ricardo.almacen@hermes.com.pe','almacen01','7439033334ff7f5d2d164c47fe54b5819c0f7cd1225ecbc3bbac5bc80206b01f',1,'Asistente Almacén',1,NULL,NULL),(3,'10000003','Patricia','Noni','Tapia','1992-11-05','Av. Javier Prado Este 2540, San Borja','patricia.compras@hermes.com.pe','analista01','9cd268397030111adacb4268e51f0dbbb0dbc8c59eb34f8f7d55f72d4c888349',2,'Analista Compras',1,NULL,NULL),(4,'08000004','Jorge','Torres','Maldonado','1981-02-14','Av. Paseo de la República 3650, San Isidro','jorge.gerente@hermes.com.pe','gerente01','ecfba551324356e5bd27b548adf36b728783f60d9b573d142caac7baad62be49',2,'Gerente Compras',1,NULL,NULL),(5,'78008009','JEAN FRANCO ANTONIO','LAURENTE','CARRASCO',NULL,NULL,'geanfranco_lc_15@hotmail.com','coordinador01','4d11204dd0440b75d5f6a081dabbabf89c5987e1343bbfa1bc86099758eead01',1,'Coordinador Almacén',1,NULL,NULL),(6,'70469587','LUIS HERNAN','NOHARA','VARGAS',NULL,NULL,'70469587@mail.isil.pe','empleado01','e17fa44d1243206b4e1345a7e8d4c804809fd7533e8fb725a2a26c903bb8e4e0',6,'Empleado',1,NULL,NULL),(7,'73636621','DANIEL ENRIQUE','CARHUAS','CANCHUMANYA',NULL,NULL,'francooalc@gmail.com','empleado02','e17fa44d1243206b4e1345a7e8d4c804809fd7533e8fb725a2a26c903bb8e4e0',6,'Empleado',1,NULL,NULL),(8,'44923234','CARLOS ANDRES','TIPACTI','MONTES',NULL,NULL,'78008009@mail.isil.pe','analista04','5115208651ba3540e859dbf3e66cf4e7936ed6956f204ed5e70ac502dee09c74',2,'Analista Compras',0,NULL,NULL),(9,'78008008','MIRELLA CYNTHIA','LAURENTE','CARRASCO',NULL,NULL,'44923234@mail.isil.pe','gerente02','66db84d7882ef2321e453772d227c4e4e9a53c96131aac8e6549342dd97b3203',NULL,'Analista Compras',1,NULL,NULL),(10,'78008010','ROSARIO MARIBEL','LAURENTE','CARRASCO',NULL,NULL,'rosario.admin@hermes.com.pe','admin1','41e5653fc7aeb894026d6bb7b2db7f65902b454945fa8fd65a6327047b5277fb',8,'Empleado',0,NULL,NULL),(11,'73636622','RONALD','GALLEGOS','PARDO',NULL,NULL,'Ronald.admin@hermes.com.pe','admin5','admin123567',8,'Administrador',0,NULL,NULL);
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orden_compra`
--

DROP TABLE IF EXISTS `orden_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orden_compra` (
  `id_orden` int NOT NULL AUTO_INCREMENT,
  `fecha_generacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_analista` int DEFAULT NULL,
  `id_gerente` int DEFAULT NULL,
  `id_proveedor` int DEFAULT NULL,
  `estado_oc` varchar(30) COLLATE utf8mb4_general_ci DEFAULT 'En Revisión',
  `descripcion` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `es_automatica` bit(1) DEFAULT NULL,
  `id_articulo` int DEFAULT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_orden`),
  KEY `id_analista` (`id_analista`),
  KEY `id_gerente` (`id_gerente`),
  KEY `id_proveedor` (`id_proveedor`),
  CONSTRAINT `orden_compra_ibfk_1` FOREIGN KEY (`id_analista`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `orden_compra_ibfk_2` FOREIGN KEY (`id_gerente`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `orden_compra_ibfk_3` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orden_compra`
--

LOCK TABLES `orden_compra` WRITE;
/*!40000 ALTER TABLE `orden_compra` DISABLE KEYS */;
INSERT INTO `orden_compra` VALUES (3,'2026-06-04 20:30:45',3,4,3,'Conforme',NULL,NULL,0,1),(18,'2026-07-09 04:06:01',3,4,1,'Conforme','Bolsa para Transporte de Efectivo',_binary '',NULL,1),(19,'2026-07-09 04:13:46',3,4,4,'Aprobada','Chaleco Antibalas Nivel III',_binary '',NULL,1),(20,'2026-07-09 04:19:30',3,4,1,'Rechazada','Cinta de Embalaje Transparente',_binary '',NULL,1),(21,'2026-07-22 12:14:57',3,4,1,'En Revisión','Papel Térmico para Voucher',_binary '',NULL,1);
/*!40000 ALTER TABLE `orden_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedor` (
  `id_proveedor` int NOT NULL AUTO_INCREMENT,
  `ruc` varchar(11) COLLATE utf8mb4_general_ci NOT NULL,
  `razon_social` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `contacto` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `correo_proveedor` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id_proveedor`),
  UNIQUE KEY `ruc` (`ruc`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor`
--

LOCK TABLES `proveedor` WRITE;
/*!40000 ALTER TABLE `proveedor` DISABLE KEYS */;
INSERT INTO `proveedor` VALUES (1,'20100100101','Seguridad Industrial S.A.C.','Ing. Alberto Rossi','ventas@seguridadind.com.pe',1),(2,'20554433221','Suministros Globales Perú','Sra. Maria Torres','pedidos@suministros.pe',1),(3,'20887766554','Tech Logistics S.A.','Sr. Kevin Huamán','corporativo@techlogistics.com',1),(4,'10780080090','LAURENTE CARRASCO JEAN FRANCO ANTONIO','Ing Jean Laurente','inversioneslogsac@mail.log.com',1),(5,'20512345678','Blindajes del Perú S.A.','Carlos Alva','ventas@blindajes.pe',1),(6,'20698765432','Equipos Tácticos S.A.C.','Luis Torres','contacto@tacticos.com.pe',1),(7,'20411223344','Suministros Bancarios S.A.','Ana Mendoza','pedidos@suministrosbancarios.pe',1),(8,'20199887766','Papelera del Sur S.A.C.','Jorge Ruiz','distribucion@papelerasur.com',1),(9,'20555666777','Uniformes y Dotaciones S.A.C.','Elena Vargas','corporativo@uniformes.pe',1),(10,'20777888999','Tecnología en Seguridad S.A.','Miguel Castro','ventas@tecnoseguridad.com',1),(11,'20121212121','Cámaras y Sensores S.A.C.','Rosa Linares','proyectos@camarasyensores.pe',1),(12,'20343434343','Plásticos y Precintos S.A.C.','David Gomez','logistica@precintos.com.pe',1),(13,'20565656565','Herramientas Mantenimiento S.A.','Julio Caceres','ventas@herramientas.pe',1),(14,'20787878787','Sistemas de Alarma S.A.C.','Carmen Iberico','soporte@alarmas.com',1),(15,'20909090909','Mobiliario Metálico S.A.','Andres Bustamante','cotizaciones@mobiliario.pe',1),(16,'20131313131','Comunicaciones y Radios S.A.','Silvia Luna','ventas@comunicaciones.com',1),(17,'20242424242','Llantas y Repuestos Blindados S.A.C.','Roberto Mendoza','flota@llantasblindadas.pe',1),(18,'20353535353','GPS y Monitoreo S.A.','Patricia Noni','comercial@gpsmonitoreo.com',1),(19,'20464646464','Extintores y Seguridad Industrial S.A.','Ricardo Holder','ventas@extintores.pe',1),(20,'20575757575','Limpieza y Saneamiento S.A.','Maria Lopez','servicios@limpiezaindustrial.com',1),(21,'20686868686','Ferretería Industrial S.A.C.','Jose Ramirez','pedidos@ferreteriaind.pe',1),(22,'20797979797','Equipos de Computo S.A.','Laura Quispe','ventas@equiposcomputo.com',1),(23,'20818181818','Textiles Especiales S.A.C.','Fernando Rojas','contacto@textiles.pe',1),(24,'20929292929','Soluciones de Embalaje S.A.','Sofia Carrillo','ventas@embalajes.com',1);
/*!40000 ALTER TABLE `proveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solicitud`
--

DROP TABLE IF EXISTS `solicitud`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitud` (
  `id_solicitud` int NOT NULL AUTO_INCREMENT,
  `id_empleado` int DEFAULT NULL,
  `id_area` int DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado_solicitud` varchar(30) COLLATE utf8mb4_general_ci DEFAULT 'Pendiente',
  `descripcion` text COLLATE utf8mb4_general_ci,
  `cantidad` int DEFAULT NULL,
  `id_articulo` int DEFAULT NULL,
  PRIMARY KEY (`id_solicitud`),
  KEY `id_empleado` (`id_empleado`),
  KEY `id_area` (`id_area`),
  KEY `FKr0demkus14xfe7aor9f5n2a8r` (`id_articulo`),
  CONSTRAINT `FKr0demkus14xfe7aor9f5n2a8r` FOREIGN KEY (`id_articulo`) REFERENCES `articulo` (`id_articulo`),
  CONSTRAINT `solicitud_ibfk_1` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `solicitud_ibfk_2` FOREIGN KEY (`id_area`) REFERENCES `area_trabajo` (`id_area`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitud`
--

LOCK TABLES `solicitud` WRITE;
/*!40000 ALTER TABLE `solicitud` DISABLE KEYS */;
INSERT INTO `solicitud` VALUES (1,1,3,'2026-06-04 20:30:45','Pendiente','Solicitud mensual de precintos y bolsas para el área de procesamiento',NULL,NULL),(2,7,8,'2026-06-10 03:43:40','Pendiente','',NULL,NULL),(4,7,8,'2026-06-10 03:57:57','Pendiente','A la espera de la aprobación de la solicitud',NULL,NULL),(5,7,8,'2026-06-23 05:07:52','Pendiente','Req de prueba',NULL,NULL),(6,7,6,'2026-06-23 13:06:36','Aprobada','REQ Prueba',7,3),(7,2,1,'2026-06-23 13:39:30','Rechazada','REQ Prueba | Motivo rechazo: No hay stock',1,3),(8,5,1,'2026-06-23 13:39:50','Entregada','REQ Prueba',39,2),(9,2,1,'2026-06-24 04:14:45','Entregada','REQ Prueba',15,6),(10,1,3,'2026-06-24 04:24:48','Entregada','REQ Prueba',1,1),(11,3,2,'2026-06-24 04:25:36','Entregada','REQ Prueba',1,1),(12,8,2,'2026-06-24 04:26:25','Entregada','REQ Prueba',51,2),(13,3,2,'2026-06-24 20:33:12','Aprobada','REQ Prueba',200,1),(14,7,6,'2026-06-25 05:11:46','Entregada','REQ Prueba',30,1),(15,2,1,'2026-06-25 05:42:28','Entregada','REQ Prueba',30,2),(16,6,6,'2026-07-02 14:08:08','Entregada','Requerimiento mensual de Julio',2,2),(17,6,6,'2026-07-02 14:28:16','Rechazada','Req Prueba',2,2),(18,6,6,'2026-07-02 14:28:17','Entregada','Req Prueba | Motivo rechazo: Falta de stock',2,3),(19,6,6,'2026-07-02 18:35:52','Entregada','Requerido mensual',1,3),(20,6,6,'2026-07-02 18:35:52','Rechazada','Requerido mensual',1,2),(21,6,6,'2026-07-02 18:35:52','Aprobada','Requerido mensual',1,5),(22,6,6,'2026-07-02 19:38:45','Entregada','REQ Prueba',3,2),(23,1,3,'2026-07-16 04:53:43','Aprobada','Prueba',10,7),(24,6,6,'2026-07-22 23:19:02','Pendiente','Prueba',15,19),(25,6,6,'2026-07-22 23:19:02','Pendiente','Prueba',32,17);
/*!40000 ALTER TABLE `solicitud` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'gestion_oc_alerta'
--

--
-- Dumping routines for database 'gestion_oc_alerta'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-22 21:16:58
