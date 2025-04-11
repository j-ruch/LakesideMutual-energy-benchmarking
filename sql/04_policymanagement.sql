-- MySQL dump 10.13  Distrib 8.4.4, for Linux (x86_64)
--
-- Host: localhost    Database: policymanagement
-- ------------------------------------------------------
-- Server version	8.4.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `addresses`
--

use policymanagement;

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` bigint NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses_seq`
--

DROP TABLE IF EXISTS `addresses_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses_seq`
--

LOCK TABLES `addresses_seq` WRITE;
/*!40000 ALTER TABLE `addresses_seq` DISABLE KEYS */;
INSERT INTO `addresses_seq` VALUES (1);
/*!40000 ALTER TABLE `addresses_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customerinfos`
--

DROP TABLE IF EXISTS `customerinfos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customerinfos` (
  `billing_address_id` bigint DEFAULT NULL,
  `contact_address_id` bigint DEFAULT NULL,
  `id` bigint NOT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKg14o8eplp4fw4rm42n6ydy0tw` (`billing_address_id`),
  UNIQUE KEY `UKb1xr2b3cdepfurucitb5642vn` (`contact_address_id`),
  CONSTRAINT `FKbcy3adjti8y40883tka7b988o` FOREIGN KEY (`contact_address_id`) REFERENCES `addresses` (`id`),
  CONSTRAINT `FKeg1pmresafc9mnm8qx1u7texs` FOREIGN KEY (`billing_address_id`) REFERENCES `addresses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customerinfos`
--

LOCK TABLES `customerinfos` WRITE;
/*!40000 ALTER TABLE `customerinfos` DISABLE KEYS */;
/*!40000 ALTER TABLE `customerinfos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customerinfos_seq`
--

DROP TABLE IF EXISTS `customerinfos_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customerinfos_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customerinfos_seq`
--

LOCK TABLES `customerinfos_seq` WRITE;
/*!40000 ALTER TABLE `customerinfos_seq` DISABLE KEYS */;
INSERT INTO `customerinfos_seq` VALUES (1);
/*!40000 ALTER TABLE `customerinfos_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuranceagreementitems`
--

DROP TABLE IF EXISTS `insuranceagreementitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuranceagreementitems` (
  `id` bigint NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuranceagreementitems`
--

LOCK TABLES `insuranceagreementitems` WRITE;
/*!40000 ALTER TABLE `insuranceagreementitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `insuranceagreementitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuranceagreementitems_seq`
--

DROP TABLE IF EXISTS `insuranceagreementitems_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuranceagreementitems_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuranceagreementitems_seq`
--

LOCK TABLES `insuranceagreementitems_seq` WRITE;
/*!40000 ALTER TABLE `insuranceagreementitems_seq` DISABLE KEYS */;
INSERT INTO `insuranceagreementitems_seq` VALUES (1);
/*!40000 ALTER TABLE `insuranceagreementitems_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuranceoptions`
--

DROP TABLE IF EXISTS `insuranceoptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuranceoptions` (
  `deductible_amount` decimal(38,2) DEFAULT NULL,
  `deductible_currency` varchar(3) DEFAULT NULL,
  `id` bigint NOT NULL,
  `start_date` datetime(6) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuranceoptions`
--

LOCK TABLES `insuranceoptions` WRITE;
/*!40000 ALTER TABLE `insuranceoptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `insuranceoptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuranceoptions_seq`
--

DROP TABLE IF EXISTS `insuranceoptions_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuranceoptions_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuranceoptions_seq`
--

LOCK TABLES `insuranceoptions_seq` WRITE;
/*!40000 ALTER TABLE `insuranceoptions_seq` DISABLE KEYS */;
INSERT INTO `insuranceoptions_seq` VALUES (1);
/*!40000 ALTER TABLE `insuranceoptions_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancepolicies`
--

DROP TABLE IF EXISTS `insurancepolicies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancepolicies` (
  `deductible_amount` decimal(38,2) DEFAULT NULL,
  `deductible_currency` varchar(3) DEFAULT NULL,
  `limit_amount` decimal(38,2) DEFAULT NULL,
  `limit_currency` varchar(3) DEFAULT NULL,
  `premium_amount` decimal(38,2) DEFAULT NULL,
  `premium_currency` varchar(3) DEFAULT NULL,
  `creation_date` datetime(6) DEFAULT NULL,
  `end_date` datetime(6) DEFAULT NULL,
  `insuring_agreement_id` bigint DEFAULT NULL,
  `start_date` datetime(6) DEFAULT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `id` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKb9h9htodscqfmjyy57njtbhxm` (`insuring_agreement_id`),
  CONSTRAINT `FKpdnkhhdnccpjjx157fwmxjuwk` FOREIGN KEY (`insuring_agreement_id`) REFERENCES `insuringagreements` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancepolicies`
--

LOCK TABLES `insurancepolicies` WRITE;
/*!40000 ALTER TABLE `insurancepolicies` DISABLE KEYS */;
INSERT INTO `insurancepolicies` VALUES (1500.00,'CHF',1000000.00,'CHF',250.00,'CHF','2025-04-11 16:57:27.140000','2018-02-10 00:00:00.000000',1,'2018-02-05 00:00:00.000000','rgpp0wkpec','fvo5pkqerr','Health Insurance');
/*!40000 ALTER TABLE `insurancepolicies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancequoterequests`
--

DROP TABLE IF EXISTS `insurancequoterequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancequoterequests` (
  `customer_info_id` bigint DEFAULT NULL,
  `date` datetime(6) DEFAULT NULL,
  `id` bigint NOT NULL,
  `insurance_options_id` bigint DEFAULT NULL,
  `insurance_quote_id` bigint DEFAULT NULL,
  `policy_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKq2s0n5wknu9po499icerkmxxm` (`customer_info_id`),
  UNIQUE KEY `UKqufo1apd7ib4ale3di3ij67pb` (`insurance_options_id`),
  UNIQUE KEY `UK4lor92n0it4ypm7nnputx6ibx` (`insurance_quote_id`),
  CONSTRAINT `FKa1hfsk032m5rw21ety1r6cx8j` FOREIGN KEY (`insurance_options_id`) REFERENCES `insuranceoptions` (`id`),
  CONSTRAINT `FKg7rf1qouafdxbnavfqqxkl8cy` FOREIGN KEY (`insurance_quote_id`) REFERENCES `insurancequotes` (`id`),
  CONSTRAINT `FKp3c57kdlcyadhtbdrfvapg77m` FOREIGN KEY (`customer_info_id`) REFERENCES `customerinfos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancequoterequests`
--

LOCK TABLES `insurancequoterequests` WRITE;
/*!40000 ALTER TABLE `insurancequoterequests` DISABLE KEYS */;
/*!40000 ALTER TABLE `insurancequoterequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancequoterequests_seq`
--

DROP TABLE IF EXISTS `insurancequoterequests_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancequoterequests_seq` (
  `next_val` bigint DEFAULT NULL,
  KEY `ix_insurancequoterequests_seq_next_val` (`next_val`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancequoterequests_seq`
--

LOCK TABLES `insurancequoterequests_seq` WRITE;
/*!40000 ALTER TABLE `insurancequoterequests_seq` DISABLE KEYS */;
INSERT INTO `insurancequoterequests_seq` VALUES (1001);
/*!40000 ALTER TABLE `insurancequoterequests_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancequoterequests_status_history`
--

DROP TABLE IF EXISTS `insurancequoterequests_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancequoterequests_status_history` (
  `insurance_quote_request_aggregate_root_id` bigint NOT NULL,
  `status_history_id` bigint NOT NULL,
  UNIQUE KEY `UKa729p55empa5vv2n61xmnocbx` (`status_history_id`),
  KEY `FK38w7s45kuvebas17k5j7g7j7` (`insurance_quote_request_aggregate_root_id`),
  CONSTRAINT `FK38w7s45kuvebas17k5j7g7j7` FOREIGN KEY (`insurance_quote_request_aggregate_root_id`) REFERENCES `insurancequoterequests` (`id`),
  CONSTRAINT `FKf5wxsha9a326x2rxvajx5cr7p` FOREIGN KEY (`status_history_id`) REFERENCES `requeststatuschanges` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancequoterequests_status_history`
--

LOCK TABLES `insurancequoterequests_status_history` WRITE;
/*!40000 ALTER TABLE `insurancequoterequests_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `insurancequoterequests_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancequotes`
--

DROP TABLE IF EXISTS `insurancequotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancequotes` (
  `insurance_premium_amount` decimal(38,2) DEFAULT NULL,
  `insurance_premium_currency` varchar(3) DEFAULT NULL,
  `policy_limit_amount` decimal(38,2) DEFAULT NULL,
  `policy_limit_currency` varchar(3) DEFAULT NULL,
  `expiration_date` datetime(6) DEFAULT NULL,
  `id` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancequotes`
--

LOCK TABLES `insurancequotes` WRITE;
/*!40000 ALTER TABLE `insurancequotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `insurancequotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurancequotes_seq`
--

DROP TABLE IF EXISTS `insurancequotes_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurancequotes_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurancequotes_seq`
--

LOCK TABLES `insurancequotes_seq` WRITE;
/*!40000 ALTER TABLE `insurancequotes_seq` DISABLE KEYS */;
INSERT INTO `insurancequotes_seq` VALUES (1);
/*!40000 ALTER TABLE `insurancequotes_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuringagreements`
--

DROP TABLE IF EXISTS `insuringagreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuringagreements` (
  `id` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuringagreements`
--

LOCK TABLES `insuringagreements` WRITE;
/*!40000 ALTER TABLE `insuringagreements` DISABLE KEYS */;
INSERT INTO `insuringagreements` VALUES (1);
/*!40000 ALTER TABLE `insuringagreements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuringagreements_agreement_items`
--

DROP TABLE IF EXISTS `insuringagreements_agreement_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuringagreements_agreement_items` (
  `agreement_items_id` bigint NOT NULL,
  `insuring_agreement_entity_id` bigint NOT NULL,
  UNIQUE KEY `UK5rj83w0jj8at8wi6trufpxw3o` (`agreement_items_id`),
  KEY `FKd78dk180up2xav96gw2i6m8y2` (`insuring_agreement_entity_id`),
  CONSTRAINT `FK1wpew4tyayyd24opvjbs99os4` FOREIGN KEY (`agreement_items_id`) REFERENCES `insuranceagreementitems` (`id`),
  CONSTRAINT `FKd78dk180up2xav96gw2i6m8y2` FOREIGN KEY (`insuring_agreement_entity_id`) REFERENCES `insuringagreements` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuringagreements_agreement_items`
--

LOCK TABLES `insuringagreements_agreement_items` WRITE;
/*!40000 ALTER TABLE `insuringagreements_agreement_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `insuringagreements_agreement_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insuringagreements_seq`
--

DROP TABLE IF EXISTS `insuringagreements_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insuringagreements_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insuringagreements_seq`
--

LOCK TABLES `insuringagreements_seq` WRITE;
/*!40000 ALTER TABLE `insuringagreements_seq` DISABLE KEYS */;
INSERT INTO `insuringagreements_seq` VALUES (51);
/*!40000 ALTER TABLE `insuringagreements_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requeststatuschanges`
--

DROP TABLE IF EXISTS `requeststatuschanges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requeststatuschanges` (
  `date` datetime(6) DEFAULT NULL,
  `id` bigint NOT NULL,
  `status` enum('POLICY_CREATED','QUOTE_ACCEPTED','QUOTE_EXPIRED','QUOTE_RECEIVED','QUOTE_REJECTED','REQUEST_REJECTED','REQUEST_SUBMITTED') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requeststatuschanges`
--

LOCK TABLES `requeststatuschanges` WRITE;
/*!40000 ALTER TABLE `requeststatuschanges` DISABLE KEYS */;
/*!40000 ALTER TABLE `requeststatuschanges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requeststatuschanges_seq`
--

DROP TABLE IF EXISTS `requeststatuschanges_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `requeststatuschanges_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requeststatuschanges_seq`
--

LOCK TABLES `requeststatuschanges_seq` WRITE;
/*!40000 ALTER TABLE `requeststatuschanges_seq` DISABLE KEYS */;
INSERT INTO `requeststatuschanges_seq` VALUES (1);
/*!40000 ALTER TABLE `requeststatuschanges_seq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_logins`
--

DROP TABLE IF EXISTS `user_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_logins` (
  `id` bigint DEFAULT NULL,
  `authorities` text,
  `customer_id` text,
  `email` text,
  `password` text,
  KEY `ix_user_logins_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_logins`
--

LOCK TABLES `user_logins` WRITE;
/*!40000 ALTER TABLE `user_logins` DISABLE KEYS */;
INSERT INTO `user_logins` VALUES (1,'admin@example.com','1','admin@example.com','1password');
/*!40000 ALTER TABLE `user_logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_logins_seq`
--

DROP TABLE IF EXISTS `user_logins_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_logins_seq` (
  `next_val` bigint DEFAULT NULL,
  KEY `ix_user_logins_seq_next_val` (`next_val`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_logins_seq`
--

LOCK TABLES `user_logins_seq` WRITE;
/*!40000 ALTER TABLE `user_logins_seq` DISABLE KEYS */;
INSERT INTO `user_logins_seq` VALUES (2);
/*!40000 ALTER TABLE `user_logins_seq` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-11  8:59:47
