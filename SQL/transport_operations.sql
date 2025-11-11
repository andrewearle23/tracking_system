-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: transport_operations
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Table structure for table `client_ref`
--

DROP TABLE IF EXISTS `client_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_ref` (
  `client_id` int NOT NULL AUTO_INCREMENT,
  `client_name` varchar(100) NOT NULL,
  `industry_type` varchar(100) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`client_id`),
  UNIQUE KEY `client_name` (`client_name`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deal_overview`
--

DROP TABLE IF EXISTS `deal_overview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deal_overview` (
  `deal_no` varchar(20) NOT NULL,
  `client_id` int DEFAULT NULL,
  `stock_code` varchar(20) DEFAULT NULL,
  `transporter_id` int DEFAULT NULL,
  PRIMARY KEY (`deal_no`),
  KEY `client_id` (`client_id`),
  KEY `stock_code` (`stock_code`),
  KEY `transporter_id` (`transporter_id`),
  CONSTRAINT `deal_overview_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `client_ref` (`client_id`),
  CONSTRAINT `deal_overview_ibfk_2` FOREIGN KEY (`stock_code`) REFERENCES `product_ref` (`stock_code`),
  CONSTRAINT `deal_overview_ibfk_3` FOREIGN KEY (`transporter_id`) REFERENCES `transporter` (`transporter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deal_trip`
--

DROP TABLE IF EXISTS `deal_trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deal_trip` (
  `trip_id` int NOT NULL AUTO_INCREMENT,
  `deal_no` varchar(20) DEFAULT NULL,
  `load_no` int DEFAULT NULL,
  `supplier_invoice_no` varchar(20) DEFAULT NULL,
  `loading_point_id` int DEFAULT NULL,
  `border_of_exit_id` int DEFAULT NULL,
  `border_of_entry_id` int DEFAULT NULL,
  `offloading_point_id` int DEFAULT NULL,
  `current_location_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `truck_id` int DEFAULT NULL,
  `no_of_items` int DEFAULT NULL,
  `tonnage_dispatched` decimal(10,2) DEFAULT NULL,
  `date_loaded` date DEFAULT NULL,
  `date_dispatched` date DEFAULT NULL,
  `bo_exit_arrived` date DEFAULT NULL,
  `bo_exit_departed` date DEFAULT NULL,
  `bo_entry_arrived` date DEFAULT NULL,
  `bo_entry_departed` date DEFAULT NULL,
  `date_arrived_site` date DEFAULT NULL,
  `date_offloaded` date DEFAULT NULL,
  `truck_status` varchar(50) DEFAULT 'Offloaded',
  PRIMARY KEY (`trip_id`),
  KEY `deal_no` (`deal_no`),
  KEY `driver_id` (`driver_id`),
  KEY `truck_id` (`truck_id`),
  KEY `loading_point_id` (`loading_point_id`),
  KEY `border_of_exit_id` (`border_of_exit_id`),
  KEY `border_of_entry_id` (`border_of_entry_id`),
  KEY `offloading_point_id` (`offloading_point_id`),
  KEY `current_location_id` (`current_location_id`),
  CONSTRAINT `deal_trip_ibfk_1` FOREIGN KEY (`deal_no`) REFERENCES `deal_overview` (`deal_no`),
  CONSTRAINT `deal_trip_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `driver` (`driver_id`),
  CONSTRAINT `deal_trip_ibfk_3` FOREIGN KEY (`truck_id`) REFERENCES `truck` (`truck_id`),
  CONSTRAINT `deal_trip_ibfk_4` FOREIGN KEY (`loading_point_id`) REFERENCES `location_ref` (`location_id`),
  CONSTRAINT `deal_trip_ibfk_5` FOREIGN KEY (`border_of_exit_id`) REFERENCES `location_ref` (`location_id`),
  CONSTRAINT `deal_trip_ibfk_6` FOREIGN KEY (`border_of_entry_id`) REFERENCES `location_ref` (`location_id`),
  CONSTRAINT `deal_trip_ibfk_7` FOREIGN KEY (`offloading_point_id`) REFERENCES `location_ref` (`location_id`),
  CONSTRAINT `deal_trip_ibfk_8` FOREIGN KEY (`current_location_id`) REFERENCES `location_ref` (`location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9954 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `driver`
--

DROP TABLE IF EXISTS `driver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver` (
  `driver_id` int NOT NULL AUTO_INCREMENT,
  `transporter_id` int DEFAULT NULL,
  `driver_name` varchar(100) DEFAULT NULL,
  `id_no` varchar(20) DEFAULT NULL,
  `drivers_licence_no` varchar(20) DEFAULT NULL,
  `nationality` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`driver_id`),
  KEY `transporter_id` (`transporter_id`),
  CONSTRAINT `driver_ibfk_1` FOREIGN KEY (`transporter_id`) REFERENCES `transporter` (`transporter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1487 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location_ref`
--

DROP TABLE IF EXISTS `location_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location_ref` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `location_name` varchar(100) NOT NULL,
  `location_type` enum('City','Border','Mine','Warehouse','Other') DEFAULT 'City',
  `country` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `gps_lat` decimal(10,6) DEFAULT NULL,
  `gps_long` decimal(10,6) DEFAULT NULL,
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `location_name` (`location_name`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_ref`
--

DROP TABLE IF EXISTS `product_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_ref` (
  `stock_code` varchar(20) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `product_category` varchar(100) DEFAULT NULL,
  `uom` varchar(20) DEFAULT NULL,
  `hs_code` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`stock_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transporter`
--

DROP TABLE IF EXISTS `transporter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transporter` (
  `transporter_id` int NOT NULL AUTO_INCREMENT,
  `transporter_name` varchar(100) NOT NULL,
  PRIMARY KEY (`transporter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `truck`
--

DROP TABLE IF EXISTS `truck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `truck` (
  `truck_id` int NOT NULL AUTO_INCREMENT,
  `transporter_id` int DEFAULT NULL,
  `truck_reg_no` varchar(20) DEFAULT NULL,
  `trailer1_reg_no` varchar(20) DEFAULT NULL,
  `trailer2_reg_no` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`truck_id`),
  KEY `transporter_id` (`transporter_id`),
  CONSTRAINT `truck_ibfk_1` FOREIGN KEY (`transporter_id`) REFERENCES `transporter` (`transporter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8383 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-11 15:52:30
