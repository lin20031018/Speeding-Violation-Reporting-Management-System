-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: illegalvehical
-- ------------------------------------------------------
-- Server version	8.0.37

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
-- Table structure for table `ai辨識資料表`
--

DROP TABLE IF EXISTS `ai辨識資料表`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai辨識資料表` (
  `AI辨識資料表ID` int NOT NULL AUTO_INCREMENT,
  `違規單號` varchar(45) NOT NULL,
  `AI辨識信心水準` decimal(5,2) NOT NULL,
  `AI模型版本` varchar(20) NOT NULL,
  PRIMARY KEY (`AI辨識資料表ID`),
  KEY `違規單號_idx` (`違規單號`),
  CONSTRAINT `違規單號` FOREIGN KEY (`違規單號`) REFERENCES `violation_of_speeding` (`違規單號`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai辨識資料表`
--

LOCK TABLES `ai辨識資料表` WRITE;
/*!40000 ALTER TABLE `ai辨識資料表` DISABLE KEYS */;
INSERT INTO `ai辨識資料表` VALUES (1,'AB01',0.90,'V0.1'),(2,'AB02',0.90,'V0.1'),(3,'AB03',0.80,'V0.1');
/*!40000 ALTER TABLE `ai辨識資料表` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `board`
--

DROP TABLE IF EXISTS `board`;
/*!50001 DROP VIEW IF EXISTS `board`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `board` AS SELECT 
 1 AS `行政區`,
 1 AS `違規地點`,
 1 AS `道路速限`,
 1 AS `車輛時速`,
 1 AS `超速速度`,
 1 AS `超速級距`,
 1 AS `經度`,
 1 AS `緯度`,
 1 AS `違規時間`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `employeeID` int NOT NULL,
  `password` varchar(45) NOT NULL,
  PRIMARY KEY (`employeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (11144133,'123');
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `speedingfines`
--

DROP TABLE IF EXISTS `speedingfines`;
/*!50001 DROP VIEW IF EXISTS `speedingfines`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `speedingfines` AS SELECT 
 1 AS `違規單號`,
 1 AS `車牌號碼`,
 1 AS `違規地點`,
 1 AS `違規時間`,
 1 AS `道路速限`,
 1 AS `車輛時速`,
 1 AS `違規照片`,
 1 AS `speed_over_limit`,
 1 AS `fine_amount`,
 1 AS `車主姓名`,
 1 AS `車輛類型`,
 1 AS `寄送地址`,
 1 AS `狀態`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `violation_of_speeding`
--

DROP TABLE IF EXISTS `violation_of_speeding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `violation_of_speeding` (
  `違規單號` varchar(10) NOT NULL,
  `違規照片` varchar(225) NOT NULL,
  `車牌號碼` varchar(20) DEFAULT NULL,
  `違規地點` varchar(225) NOT NULL,
  `違規時間` datetime NOT NULL,
  `紀錄設備ID` varchar(10) NOT NULL,
  `道路速限` int NOT NULL,
  `車輛時速` int NOT NULL,
  `經度` decimal(10,6) DEFAULT NULL,
  `緯度` decimal(10,6) DEFAULT NULL,
  `狀態` varchar(10) NOT NULL,
  `車牌確認狀態` varchar(10),
  PRIMARY KEY (`違規單號`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `violation_of_speeding`
--

LOCK TABLES `violation_of_speeding` WRITE;
/*!40000 ALTER TABLE `violation_of_speeding` DISABLE KEYS */;
INSERT INTO `violation_of_speeding` VALUES ('TT01','tt01.jpg','3033XY','台北市北投區西安街一段275號','2001-12-28 00:00:00','CM01',40,70,0.100000,0.100000,'已送出','已確認'),('TT02','tt01.jpg','3033XY','台北市北投區西安街一段275號','2001-12-28 00:00:00','CM01',40,60,0.100000,0.100000,'已送出','已確認');

/*!40000 ALTER TABLE `violation_of_speeding` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `violationpaymentstatus`
--

DROP TABLE IF EXISTS `violationpaymentstatus`;
/*!50001 DROP VIEW IF EXISTS `violationpaymentstatus`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `violationpaymentstatus` AS SELECT 
 1 AS `違規單號`,
 1 AS `車牌號碼`,
 1 AS `車主姓名`,
 1 AS `身分證字號`,
 1 AS `違規時間`,
 1 AS `狀態`,
 1 AS `繳費時限`,
 1 AS `罰單金額`,
 1 AS `繳費狀態`,
 1 AS `繳費時間`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `交通部管理帳號資料表`
--

DROP TABLE IF EXISTS `交通部管理帳號資料表`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `交通部管理帳號資料表` (
  `員工編號` varchar(20) NOT NULL,
  `密碼` varchar(45) NOT NULL,
  PRIMARY KEY (`員工編號`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `交通部管理帳號資料表`
--

LOCK TABLES `交通部管理帳號資料表` WRITE;
INSERT INTO `交通部管理帳號資料表` (`員工編號`, `密碼`)VALUES ('11144122', '1234');
/*!40000 ALTER TABLE `交通部管理帳號資料表` DISABLE KEYS */;
/*!40000 ALTER TABLE `交通部管理帳號資料表` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `人工辨識資料表`
--

DROP TABLE IF EXISTS `人工辨識資料表`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `人工辨識資料表` (
  `id人工辨識資料表` int NOT NULL AUTO_INCREMENT,
  `違規單號` varchar(10) NOT NULL,
  `交通佐理員員工ID` varchar(20) NOT NULL,
  `時間` datetime NOT NULL,
  `處理機IP位置` varchar(50) NOT NULL,
  `事件類型` enum('未處理','已處理','未送出') NOT NULL,
  `辨識車牌號碼` varchar(20) DEFAULT NULL,
  `處理時間` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id人工辨識資料表`),
  UNIQUE KEY `違規單號_UNIQUE` (`違規單號`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `人工辨識資料表`
--

LOCK TABLES `人工辨識資料表` WRITE;
/*!40000 ALTER TABLE `人工辨識資料表` DISABLE KEYS */;
/*!40000 ALTER TABLE `人工辨識資料表` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `罰單列印紀錄資料表`
--

DROP TABLE IF EXISTS `罰單列印紀錄資料表`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `罰單列印紀錄資料表` (
  `罰單列印紀錄ID` int NOT NULL AUTO_INCREMENT,
  `違規單號` varchar(10) NOT NULL,
  `列印員工ID` varchar(20) NOT NULL,
  `列印時間` datetime NOT NULL,
  `處理機IP位置` varchar(50) NOT NULL,
  `罰單金額` int NOT NULL,
  `繳費時限` datetime DEFAULT NULL,
  `繳費時間` datetime DEFAULT NULL,
  `繳費狀態` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`罰單列印紀錄ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `罰單列印紀錄資料表`
--

LOCK TABLES `罰單列印紀錄資料表` WRITE;
/*!40000 ALTER TABLE `罰單列印紀錄資料表` DISABLE KEYS */;
INSERT INTO `罰單列印紀錄資料表`(`違規單號`,`列印員工ID`, `列印時間`, `處理機IP位置`, `罰單金額`, `繳費時限`, `繳費時間`, `繳費狀態`)VALUES ("TT01","11144121", "2025-01-10 21:31:00", "172.20.10.12", "1600", "2025-02-09 00:00:00", "2025-01-10 21:31:00", "已繳費"),("TT02","11144121", "2025-01-10 21:31:00", "172.20.10.12", "1600", "2025-02-09 00:00:00", "2025-01-10 21:31:00", "未繳費");
/*!40000 ALTER TABLE `罰單列印紀錄資料表` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `車輛行照資料表`
--

DROP TABLE IF EXISTS `車輛行照資料表`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `車輛行照資料表` (
  `車牌號碼` varchar(10) NOT NULL,
  `車輛類型` varchar(10) DEFAULT NULL,
  `車色` varchar(8) DEFAULT NULL,
  `車主姓名` varchar(45) DEFAULT NULL,
  `身分證字號` varchar(10) DEFAULT NULL,
  `車牌狀態` varchar(10) DEFAULT NULL,
  `登記地址` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`車牌號碼`),
  UNIQUE KEY `車牌號碼_UNIQUE` (`車牌號碼`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `車輛行照資料表`
--

LOCK TABLES `車輛行照資料表` WRITE;
/*!40000 ALTER TABLE `車輛行照資料表` DISABLE KEYS */;
INSERT INTO `車輛行照資料表` VALUES ('AFF0666', '轎車', '銀色', '劉阿豪','F123456789','有效車牌', '桃園市八德區永福路8號'),('BGR-5851', '轎車', '白色', '劉士豪','J123456789','有效車牌', '桃園市缺德路87號'),('ABC1111','小客車','黃','老三','A123456789','已上牌','老三家'),('ABC1234','小客車','紅','老一','B123456789','已上牌','老一家'),('ABC5678','小客車','橘','老二','C123456789','已上牌','老二家'),('3033XY','小客車','銀','老三','A123456789','已上牌','老三家');
/*!40000 ALTER TABLE `車輛行照資料表` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `board`
--

/*!50001 DROP VIEW IF EXISTS `board`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `board` AS select substr(`violation_of_speeding`.`違規地點`,4,3) AS `行政區`,`violation_of_speeding`.`違規地點` AS `違規地點`,`violation_of_speeding`.`道路速限` AS `道路速限`,`violation_of_speeding`.`車輛時速` AS `車輛時速`,(`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) AS `超速速度`,(case when ((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) <= 20) then '20以下' when (((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) > 20) and ((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) <= 40)) then '20到40' when (((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) > 40) and ((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) <= 60)) then '40到60' when (((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) > 60) and ((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) <= 80)) then '60到80' when ((`violation_of_speeding`.`車輛時速` - `violation_of_speeding`.`道路速限`) > 80) then '80以上' else '未超速' end) AS `超速級距`,`violation_of_speeding`.`經度` AS `經度`,`violation_of_speeding`.`緯度` AS `緯度`,`violation_of_speeding`.`違規時間` AS `違規時間` from `violation_of_speeding` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `speedingfines`
--

/*!50001 DROP VIEW IF EXISTS `speedingfines`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `speedingfines` AS select `v`.`違規單號` AS `違規單號`,`v`.`車牌號碼` AS `車牌號碼`,`v`.`違規地點` AS `違規地點`,`v`.`違規時間` AS `違規時間`,`v`.`道路速限` AS `道路速限`,`v`.`車輛時速` AS `車輛時速`,`v`.`違規照片` AS `違規照片`,(`v`.`車輛時速` - `v`.`道路速限`) AS `speed_over_limit`,(case when ((`v`.`車輛時速` - `v`.`道路速限`) <= 20) then 1600 when (((`v`.`車輛時速` - `v`.`道路速限`) > 20) and ((`v`.`車輛時速` - `v`.`道路速限`) <= 40)) then 1800 when (((`v`.`車輛時速` - `v`.`道路速限`) > 40) and ((`v`.`車輛時速` - `v`.`道路速限`) <= 60)) then 2000 when (((`v`.`車輛時速` - `v`.`道路速限`) > 60) and ((`v`.`車輛時速` - `v`.`道路速限`) <= 80)) then 8000 when (((`v`.`車輛時速` - `v`.`道路速限`) > 80) and ((`v`.`車輛時速` - `v`.`道路速限`) <= 100)) then 12000 when ((`v`.`車輛時速` - `v`.`道路速限`) > 100) then 24000 else 0 end) AS `fine_amount`,`c`.`車主姓名` AS `車主姓名`,`c`.`車輛類型` AS `車輛類型`,`c`.`登記地址` AS `寄送地址`,`v`.`狀態` AS `狀態` from (`violation_of_speeding` `v` left join `車輛行照資料表` `c` on((`v`.`車牌號碼` = `c`.`車牌號碼`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `violationpaymentstatus`
--

/*!50001 DROP VIEW IF EXISTS `violationpaymentstatus`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `violationpaymentstatus` AS select `v`.`違規單號` AS `違規單號`,`c`.`車牌號碼` AS `車牌號碼`,`c`.`車主姓名` AS `車主姓名`,`c`.`身分證字號` AS `身分證字號`,`v`.`違規時間` AS `違規時間`,`v`.`狀態` AS `狀態`,`p`.`繳費時限` AS `繳費時限`,`p`.`罰單金額` AS `罰單金額`,`p`.`繳費狀態` AS `繳費狀態`,`p`.`繳費時間` AS `繳費時間` from ((`violation_of_speeding` `v` left join `車輛行照資料表` `c` on((`v`.`車牌號碼` = `c`.`車牌號碼`))) left join `罰單列印紀錄資料表` `p` on((`v`.`違規單號` = `p`.`違規單號`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-01-08 13:55:34
