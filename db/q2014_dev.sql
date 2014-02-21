-- MySQL dump 10.13  Distrib 5.5.35, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: q2014_dev
-- ------------------------------------------------------
-- Server version	5.5.35-0ubuntu0.13.10.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `actions`
--

DROP TABLE IF EXISTS `actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `round_id` int(11) NOT NULL,
  `question` int(11) NOT NULL,
  `action` int(11) NOT NULL,
  `data` varchar(255) NOT NULL DEFAULT '',
  `qm_team` int(11) DEFAULT NULL,
  `seat` int(11) DEFAULT NULL,
  `identifier` varchar(255) NOT NULL DEFAULT '',
  `quiz_team_id` int(11) DEFAULT NULL,
  `quizzer_id` int(11) DEFAULT NULL,
  `action_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `original` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_actions_on_round_id_and_question_and_action` (`round_id`,`question`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actions`
--

LOCK TABLES `actions` WRITE;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audits`
--

DROP TABLE IF EXISTS `audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditable_id` int(11) DEFAULT NULL,
  `auditable_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `changes` text,
  `version` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `user_index` (`user_id`,`user_type`),
  KEY `index_audits_on_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audits`
--

LOCK TABLES `audits` WRITE;
/*!40000 ALTER TABLE `audits` DISABLE KEYS */;
/*!40000 ALTER TABLE `audits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buildings`
--

DROP TABLE IF EXISTS `buildings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `buildings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `air_conditioned` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buildings`
--

LOCK TABLES `buildings` WRITE;
/*!40000 ALTER TABLE `buildings` DISABLE KEYS */;
/*!40000 ALTER TABLE `buildings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `districts`
--

DROP TABLE IF EXISTS `districts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `districts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `director` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `phone` varchar(255) DEFAULT '',
  `mobile_phone` varchar(255) DEFAULT '',
  `region_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `districts`
--

LOCK TABLES `districts` WRITE;
/*!40000 ALTER TABLE `districts` DISABLE KEYS */;
INSERT INTO `districts` VALUES (1,'Canada Atlantic','Jon Lochbihler','oxfordyouth@gmail.com','(902) 447-2539','(902) 447-2539',1),(2,'Canada Central','','','','',1),(3,'Canada Quebec','Manfred Jeanty','jeantymtt@hotmail.com','(514) 388-5908','(514) 388-5908',1),(4,'Chicago Central','Scott & Sara Christensen','CCDQUIZ@yahoo.com','(815) 929-0493','(815) 929-0493',2),(5,'Eastern Michigan','Robert Flowers','reviceman@att.net','810-577-7721','810-577-7721',2),(6,'Illinois','Julie Marlar','marler824@gmail.com','','217-620-8941',2),(7,'Indianapolis','Tamara Tolley','indyquiz@gmail.com','','317-408-5610 ',2),(8,'Michigan','Martha Baker','marthabaker1040@gmail.com','(269) 945-4204','(269) 804-9237',2),(9,'Northeast Indiana','Debby Freeland','neiteenbiblequiz@gmail.com','260-388-2718','260-388-2718',2),(10,'Northern Michigan','Jon Schott','johnschott@sbcglobal.net','(231) 627-5580','(231) 627-5580',2),(11,'Northwest Indiana','Brad Osborne','bradleyosborne2353@msn.com','765-413-2603','765-413-2603',2),(12,'Northwestern Illinois','','','','',2),(13,'Southwest Indiana','Michael Taylor','jantaylor@att.net','812-890-6051','812-882-5963',2),(14,'Wisconsin','Stephen Hruska','stephenhruska@gmail.com','517-282-4597','',2),(15,'Central Ohio','Joe Buxie','jbuxie@wisesnacks.com','(614) 681-9177','(614) 681-9177',3),(16,'East Ohio','Tim Lee','TGL4QUIZ@aol.com','(330) 424-0549','(330) 424-0549',3),(17,'Eastern Kentucky','','','','',3),(18,'North Central Ohio','Sandy Davila','sdavila5@hotmail.com','(440) 998-5199','(440) 998-5199',3),(19,'Northwestern Ohio','Teresa   Borton','tborton@fourcounty.net','(419) 267-5168','(419) 267-5168',3),(20,'Southwest Ohio','Kent Davenport','kentdvnprt@gmail.com','','815-549-0706',3),(21,'West Virginia North','Jena Llewellyn ','ladyllew@gmail.com  ','','',3),(22,'West Virginia South','Brieanna DeLong','nhcnsing@hotmail.com','','304-741-4556',3),(23,'Maine','Kevin  Driscoll','kevmoses@juno.com','','',4),(24,'Metro New York','Yakima Brown','Bikewashnoil@aol.com','','718-809-2081',4),(25,'Mid Atlantic','James Moots','trajam@zoominternet.net','(410) 420-1620','(410) 420-1620',4),(26,'New England','Lori Jeffrey','lori_jeffrey@comcast.net','(603) 893-6298','(603) 893-6298',4),(27,'Philadelphia','Pamela Heglund','SchPgh@aol.com','732-818-0461','732-244-5463',4),(28,'Pittsburgh','Michael Mallek','mjmallek33@yahoo.com','(724) 588-4084','(724) 588-4084',4),(29,'Upstate New York','Doug Braun','braun@rockfootball.com','716-316-8064','',4),(30,'Virginia','Tate Love','wrnbldg@gmail.com ','','',4),(31,'Prairie Lakes','Bud Stiles','hstiles@usbr.gov or bitbender@inorbit.com','(605) 224-1698','(605) 224-1698',5),(32,'Iowa','Todd Butler','tmbutler04@gmail.com','319-350-2807','319-350-2807',5),(33,'Joplin','Vicki Sokolnik','jvsokolnik@gmail.com','417-767-4330','417-839-7941',5),(34,'Kansas','Megan Duerksen','megan_alan97@hotmail.com','816-341-2244','',5),(35,'Kansas City','Debbie Jasiczek','dbuxie@hotmail.com','913-481-7255','913-481-7255',5),(37,'Missouri','Janette Cole','wordoflifenazarene@juno.com','636-234-5344','636-234-5344',5),(38,'Nebraska','Bethany Gooden','bethany.l.gooden@gmail.com','','',5),(39,'Alaska','Mike Zahare','Mike.Zahare@Matthewszahare.com','(907) 345-2374','(907) 345-2374',6),(40,'Colorado','','','','',6),(41,'Intermountain','Jennifer Chase','jrchase@NNU.Edu','(208) 250-2052','(208) 250-2052',6),(42,'Northwest','Vernon Reihle','vern@spokanebethelnaz.org','(509) 926-0335','(509) 926-0335',6),(43,'Oregon Pacific','Henry Miller','hchhquiz@msn.com','(541) 330-1443','(541) 330-1443',6),(44,'Rocky Mountain','Ben Finch','benfinch@gmx.com','307-856-8952','307-840-2939',6),(45,'Washington Pacific','Roger Sauter','rlsauter@gmail.com','425-338-3419','',6),(46,'Dallas','Kale Woods','kale.woods@tenethealth.com','(972) 673-0999','(972) 673-0999',7),(47,'Louisiana','J.D. Sailors','jdnteresa@gmail.com','','314-910-7378',7),(48,'North Arkansas','Melissa Mullen','Mejamu@juno.com','479-841-4404','479-841-4404',7),(49,'Northeast Oklahoma','Josh Williams','josh@sococommunity.com','918-853-9928','',7),(50,'Oklahoma','Becky Seville','creedlily@yahoo.com','405-248-1025','405-248-1025',7),(51,'South Arkansas','Marcia Church','thequeenmac@hotmail.com','(501) 690-6198','(501) 690-6198',7),(52,'South Texas','Patrick Wheeler','patrick.wheeler@gmail.com','','314-489-8194',7),(54,'Southwest Oklahoma','Bill Kinnamon','SWOTeenQuizzing@gmail.com','405-973-7051','405-973-7051',7),(55,'Texas-Oklahoma Latin','Adriana  Alvarado','adreez350@hotmail.com','(210) 326-1310','(210) 326-1310',7),(56,'West Texas','Mary Beckworth','mbeckworth@springtownisd.net','(817) 220-6601','(817) 220-6601',7),(57,'Alabama North','Cindy Hagood','cindyhagood@gmail.com','(205) 384-5061','(205) 384-5061',8),(58,'Alabama South','Tracy Hornaday','Tracyhornaday69@yahoo.com','(334) 209-0598','(334) 209-0598',8),(59,'Central Florida','Pam Roy','pam_ster@hotmail.com','(407) 348-0997','(407) 348-0997',8),(60,'East Tennessee','Elizabeth Smith','izzi-b@live.com','865-850-8301','865-850-8301',8),(61,'Georgia','Brandon Foskey','brandon.foskey@gmail.com','(478) 279-2824','(478) 279-2824',8),(62,'Kentucky','Jan Shoopman','janmshoopman@gmail.com','270-932-1185','270-932-1185',8),(63,'Mississippi','David Phillips','d2phillips@comcast.net','601-259-9983','601-259-9983',8),(64,'North Carolina','Mark Medley','pastormark@nc.rr.com','(910) 483-3605','(910) 483-3605',8),(65,'North Florida','Stan Wade','opnaz1@bellsouth.net','','',8),(66,'South Carolina','','teenbiblequizzing.sc@gmail.com','','',8),(67,'Southern Florida','Tim Bottles','tbottles@hotmail.com','(239) 995-7483','(239) 995-7483',8),(68,'Tennessee','James Hodge','jthomasbiz@yahoo.com','(615) 452-6659','(615) 452-6659',8),(69,'Anaheim','','','','',9),(70,'Arizona','Lisa Dennis','LisaDD63@cox.net','(623) 547-2276','(623) 547-2276',9),(71,'Central California','Ken Freed','kfreed@csicv.com','559-923-4793','559-362-9940',9),(72,'Hawaii Pacific','','','','',9),(73,'Los Angeles','Timothy Lew','lew.timothy@gmail.com','(909) 618-4161','(909) 618-4161',9),(74,'New Mexico','Penny Pogue','ppogue3@comcast.net','505-401-4840','505-401-4840',9),(75,'Northern California','Rick Powers','rtrickpowers@aol.com','(707) 557-1833','(707) 557-1833',9),(76,'Sacramento','Larry  Finney','finney@wildblue.net.','(530) 823-0749','(530) 823-0749',9),(77,'Southern California','Jerry Goodwin','jerryandsuegoodwin@san.rr.com','(858) 484-8847','(858) 484-8847',9),(78,'Southwest Indian','Laverne Wilson',NULL,NULL,NULL,9),(79,'Southwest Latin American','Benjamin Lopez',NULL,'(505) 647-0371','(505) 647-0371',9),(80,'Western Latin American','Frank & Yolanda McHodgkins','yolimc@yahoo.com','(626) 797-2478','(626) 797-2478',9),(81,'A Non-Nazarene District','Non-Nazarene','horningwlh@gmail.com','','',11),(82,'Leeward Virgin Islands','Ruth Lawrence','','','',10),(83,'Papua New Guinea','Bill McCoy','wmccoy@reachone.com','815-555-1212','815-555-1212',12);
/*!40000 ALTER TABLE `districts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `divisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `price_in_cents` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `divisions`
--

LOCK TABLES `divisions` WRITE;
/*!40000 ALTER TABLE `divisions` DISABLE KEYS */;
INSERT INTO `divisions` VALUES (1,'District Experienced',15000),(2,'District Novice',15000),(3,'Local Experienced',10000),(4,'Local Novice',10000),(5,'Regional A',0),(6,'Regional B',0);
/*!40000 ALTER TABLE `divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipment_type` varchar(255) DEFAULT NULL,
  `equipment_registration_id` int(11) DEFAULT NULL,
  `details` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment_registrations`
--

DROP TABLE IF EXISTS `equipment_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipment_registrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment_registrations`
--

LOCK TABLES `equipment_registrations` WRITE;
/*!40000 ALTER TABLE `equipment_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipment_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluations`
--

DROP TABLE IF EXISTS `evaluations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `sent_to_name` varchar(255) DEFAULT NULL,
  `sent_to_email` varchar(255) DEFAULT NULL,
  `official_id` int(11) DEFAULT NULL,
  `complete` tinyint(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `best_suited` varchar(255) DEFAULT NULL,
  `where_observed` text,
  `reading` varchar(255) DEFAULT NULL,
  `reading_explanation` text,
  `ruling` varchar(255) DEFAULT NULL,
  `ruling_explanation` text,
  `knowledge_material` varchar(255) DEFAULT NULL,
  `knowledge_material_explanation` text,
  `knowledge_ruling` varchar(255) DEFAULT NULL,
  `knowledge_ruling_explanation` text,
  `position` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `levels` text,
  `best_suited_level` varchar(255) DEFAULT NULL,
  `interpersonal_skills` text,
  `handles_conflict` text,
  `content_judge_utilization` text,
  `additional_comments` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluations`
--

LOCK TABLES `evaluations` WRITE;
/*!40000 ALTER TABLE `evaluations` DISABLE KEYS */;
INSERT INTO `evaluations` VALUES (1,'9688d6a9c49df19f056910ace9d657ea','Scott & Sara Christensen','CCDQUIZ@yahoo.com',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2014-01-29 00:10:41','2014-01-29 00:10:41','--- []\n\n',NULL,NULL,NULL,NULL,NULL),(2,'789fb3f94b69e9f24da1535b4c46b658','Bill Horning','horningwlh@gmail.com',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2014-01-29 00:10:41','2014-01-29 00:10:41','--- []\n\n',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `evaluations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `housing_rooms`
--

DROP TABLE IF EXISTS `housing_rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housing_rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `building_id` int(11) DEFAULT NULL,
  `number` varchar(255) DEFAULT NULL,
  `keycode` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `housing_rooms`
--

LOCK TABLES `housing_rooms` WRITE;
/*!40000 ALTER TABLE `housing_rooms` DISABLE KEYS */;
/*!40000 ALTER TABLE `housing_rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ministry_projects`
--

DROP TABLE IF EXISTS `ministry_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ministry_projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ministry_projects`
--

LOCK TABLES `ministry_projects` WRITE;
/*!40000 ALTER TABLE `ministry_projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `ministry_projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `officials`
--

DROP TABLE IF EXISTS `officials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `officials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `roles` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `officials`
--

LOCK TABLES `officials` WRITE;
/*!40000 ALTER TABLE `officials` DISABLE KEYS */;
INSERT INTO `officials` VALUES (1,5,2,4,'Bill','Horning','1234567890','bill.horning@att.net','--- \n- Quizmaster\n- Content Judge\n','2014-01-29 00:10:40','2014-01-29 00:10:40');
/*!40000 ALTER TABLE `officials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `body` text,
  `published` tinyint(1) DEFAULT '1',
  `show_on_menu` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (1,'Basic Information','Basic Information','','<h1>Q2014</h1>\r\n<p>June 30th - July 5th, 2014 on the campus of Trevecca Nazarene University in Nashville, TN.</p>\r\n<p>Hope to see you there!</p>\r\n<p>Officials, register your interest <a title=\"Q2014 Officials Page\" href=\"/officials/new\" target=\"_blank\">here</a>. &nbsp;(Only register at one of these two links, not both)</p>\r\n<p>Volunteers, register your interest <a title=\"Q2014 Volunteer Registration Interest\" href=\"http://www.quizstuff.com/Q2014volunteer.php\" target=\"_blank\">here</a>. (Only register at one of these two links, not both)</p>\r\n<p>USA/Canada NYI</p>',1,1,'2014-01-29 00:15:05','2014-01-30 19:25:57'),(2,'Officials and Volunteer Registration','Officials and Volunteer Registration','','<h1>Q2014</h1>\r\n<p>June 30th - July 5th, 2014 on the campus of Trevecca Nazarene University in Nashville, TN.</p>\r\n<p>Hope to see you there!</p>\r\n<p>Officials, register your interest&nbsp;<a title=\"Q2014 Officials Page\" href=\"/officials/new\" target=\"_blank\">here</a>. &nbsp;(Only register at one of these two links, not both)</p>\r\n<p>Volunteers, register your interest&nbsp;<a title=\"Q2014 Volunteer Registration Interest\" href=\"http://www.quizstuff.com/Q2014volunteer.php\" target=\"_blank\">here</a>. (Only register at one of these two links, not both)</p>\r\n<p>USA/Canada NYI</p>',1,1,'2014-01-30 19:27:14','2014-01-30 19:27:14'),(3,'Home','Home','','<h1>Welcome to Q2014.org!</h1>\r\n<p>More information is coming very very soon!</p>',1,0,'2014-01-30 22:54:53','2014-01-30 22:55:04');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_registration_users`
--

DROP TABLE IF EXISTS `participant_registration_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participant_registration_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_registration_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `owner` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_registration_users`
--

LOCK TABLES `participant_registration_users` WRITE;
/*!40000 ALTER TABLE `participant_registration_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `participant_registration_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participant_registrations`
--

DROP TABLE IF EXISTS `participant_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participant_registrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `promotion_agree` varchar(255) DEFAULT NULL,
  `hide_from_others` tinyint(1) DEFAULT NULL,
  `registration_type` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `most_recent_grade` varchar(255) DEFAULT NULL,
  `home_phone` varchar(255) DEFAULT NULL,
  `mobile_phone` varchar(255) DEFAULT NULL,
  `team1_id` int(11) DEFAULT NULL,
  `team2_id` int(11) DEFAULT NULL,
  `team3_id` int(11) DEFAULT NULL,
  `group_leader` varchar(255) DEFAULT NULL,
  `local_church` varchar(255) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `shirt_size` varchar(255) DEFAULT NULL,
  `roommate_preference_1` varchar(255) DEFAULT NULL,
  `roommate_preference_2` varchar(255) DEFAULT NULL,
  `food_allergies` varchar(255) DEFAULT NULL,
  `food_allergies_details` text,
  `special_needs` varchar(255) DEFAULT NULL,
  `special_needs_details` text,
  `past_events_attended` varchar(255) DEFAULT NULL,
  `reminder` tinyint(1) DEFAULT NULL,
  `reminder_days` int(11) DEFAULT NULL,
  `paid` tinyint(1) DEFAULT '0',
  `audit` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `travel_type` varchar(255) DEFAULT NULL,
  `arrival_airline` varchar(255) DEFAULT NULL,
  `airline_arrival_date` varchar(255) DEFAULT NULL,
  `airline_arrival_time` varchar(255) DEFAULT NULL,
  `airline_arrival_from` varchar(255) DEFAULT NULL,
  `need_arrival_shuttle` tinyint(1) DEFAULT '0',
  `departure_airline` varchar(255) DEFAULT NULL,
  `airline_departure_date` varchar(255) DEFAULT NULL,
  `airline_departure_time` varchar(255) DEFAULT NULL,
  `need_departure_shuttle` tinyint(1) DEFAULT '0',
  `driving_arrival_date` varchar(255) DEFAULT NULL,
  `driving_arrival_time` varchar(255) DEFAULT NULL,
  `registration_code` varchar(255) DEFAULT NULL,
  `num_extra_group_photos` int(11) DEFAULT NULL,
  `num_dvd` int(11) DEFAULT NULL,
  `housing_saturday` tinyint(1) DEFAULT NULL,
  `housing_sunday` tinyint(1) DEFAULT NULL,
  `breakfast_monday` tinyint(1) DEFAULT NULL,
  `lunch_monday` tinyint(1) DEFAULT NULL,
  `need_floorfan` tinyint(1) DEFAULT NULL,
  `need_pillow` tinyint(1) DEFAULT NULL,
  `num_extra_small_shirts` int(11) DEFAULT NULL,
  `num_extra_medium_shirts` int(11) DEFAULT NULL,
  `num_extra_large_shirts` int(11) DEFAULT NULL,
  `num_extra_xlarge_shirts` int(11) DEFAULT NULL,
  `num_extra_2xlarge_shirts` int(11) DEFAULT NULL,
  `num_extra_3xlarge_shirts` int(11) DEFAULT NULL,
  `num_extra_4xlarge_shirts` int(11) DEFAULT NULL,
  `num_extra_5xlarge_shirts` int(11) DEFAULT NULL,
  `guardian` varchar(255) DEFAULT NULL,
  `school_id` int(11) DEFAULT NULL,
  `school_fax` varchar(255) DEFAULT NULL,
  `exhibitor_housing` varchar(255) DEFAULT NULL,
  `participant_housing` varchar(255) DEFAULT NULL,
  `arrival_flight_number` varchar(255) DEFAULT NULL,
  `departure_flight_number` varchar(255) DEFAULT NULL,
  `registration_fee` int(11) DEFAULT '0',
  `family_registrations` varchar(255) DEFAULT NULL,
  `num_extra_youth_small_shirts` int(11) DEFAULT NULL,
  `num_extra_youth_medium_shirts` int(11) DEFAULT NULL,
  `num_extra_youth_large_shirts` int(11) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `discount_in_cents` int(11) DEFAULT NULL,
  `discount_description` text,
  `extras_fee` int(11) DEFAULT '0',
  `building_id` int(11) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  `medical_liability` tinyint(1) DEFAULT '0',
  `background_check` tinyint(1) DEFAULT '0',
  `ministry_project_id` int(11) DEFAULT NULL,
  `ministry_project_group` varchar(255) DEFAULT NULL,
  `arrival_airport` varchar(255) DEFAULT NULL,
  `departure_airport` varchar(255) DEFAULT NULL,
  `num_sv_tickets` int(11) DEFAULT NULL,
  `sv_transportation` tinyint(1) DEFAULT NULL,
  `nazsafe` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participant_registrations`
--

LOCK TABLES `participant_registrations` WRITE;
/*!40000 ALTER TABLE `participant_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `participant_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `participants`
--

DROP TABLE IF EXISTS `participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `participant_registration_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `participants`
--

LOCK TABLES `participants` WRITE;
/*!40000 ALTER TABLE `participants` DISABLE KEYS */;
/*!40000 ALTER TABLE `participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `passwords`
--

DROP TABLE IF EXISTS `passwords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `passwords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `reset_code` varchar(255) DEFAULT NULL,
  `expiration_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `passwords`
--

LOCK TABLES `passwords` WRITE;
/*!40000 ALTER TABLE `passwords` DISABLE KEYS */;
INSERT INTO `passwords` VALUES (1,436,'0058d59110880f5be20b6514d55a7249a84bec6e','2014-02-14 05:07:59','2014-01-31 05:07:59','2014-01-31 05:07:59'),(2,1,'f0d309c090c5669348987e1c3456d617a23427db','2014-02-14 05:09:00','2014-01-31 05:09:00','2014-01-31 05:09:00');
/*!40000 ALTER TABLE `passwords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `team_registration_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `credit_card_number` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `amount_in_cents` int(11) DEFAULT NULL,
  `response` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `participant_registration_id` int(11) DEFAULT NULL,
  `details` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_divisions`
--

DROP TABLE IF EXISTS `quiz_divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quiz_divisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_divisions`
--

LOCK TABLES `quiz_divisions` WRITE;
/*!40000 ALTER TABLE `quiz_divisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_divisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_teams`
--

DROP TABLE IF EXISTS `quiz_teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quiz_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quiz_division_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `pool` varchar(255) DEFAULT NULL,
  `rounds` int(11) DEFAULT '0',
  `wins` int(11) DEFAULT '0',
  `losses` int(11) DEFAULT '0',
  `total_points` int(11) DEFAULT '0',
  `rank` int(11) DEFAULT '0',
  `manual_rank` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_teams`
--

LOCK TABLES `quiz_teams` WRITE;
/*!40000 ALTER TABLE `quiz_teams` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quizzers`
--

DROP TABLE IF EXISTS `quizzers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quizzers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quiz_division_id` int(11) DEFAULT NULL,
  `quiz_team_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `total_rounds` int(11) DEFAULT '0',
  `actual_rounds` int(11) DEFAULT '0',
  `points` int(11) DEFAULT '0',
  `average` decimal(8,2) DEFAULT '0.00',
  `total_correct` int(11) DEFAULT '0',
  `total_errors` int(11) DEFAULT '0',
  `rank` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quizzers`
--

LOCK TABLES `quizzers` WRITE;
/*!40000 ALTER TABLE `quizzers` DISABLE KEYS */;
/*!40000 ALTER TABLE `quizzers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT '',
  `director` varchar(255) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  `phone` varchar(255) DEFAULT '',
  `mobile_phone` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regions`
--

LOCK TABLES `regions` WRITE;
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
INSERT INTO `regions` VALUES (1,'Canada','Taryn Williams','tmew83@hotmail.com','613-435-3154','613-435-3154'),(2,'Central USA','Bill Horning','horningwlh@gmail.com','815-341-8299','815-341-8299'),(3,'East Central USA','Todd Thomas','tlathomas@fuse.net','513-874-1974','513-207-7152'),(4,'Eastern USA','Matt and Melissa Mosher','steelersmom8@aol.com, pastormattmoser@gmail.com','410-282-2084','410-409-7097'),(5,'North Central USA','Chad Lynn','chadandmegan@comcast.net','','913-220-8636'),(6,'Northwest USA','Henry Miller','hchhquiz@msn.com','541-330-1443','541-419-4846'),(7,'South Central USA','Darrik Acre','piedmontnaz@att.net','405-245-1581','405-245-1581'),(8,'Southeast USA','Matt Thrasher','matt.thrasher@jefferson.kyschools.us','502-368-6610',NULL),(9,'Southwest USA','John Shearer','shearerfamily@att.net','530-623-2677','530-604-1928'),(10,'MesoAmerica','Ruth Lawrence','mrmrlawrence@yahoo.com','',''),(11,'Non-Nazarene','','','',''),(12,'Asia-Pacific','Bill McCoy','wmccoy@reachone.com','815-555-1212','815-555-1212');
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registerable_items`
--

DROP TABLE IF EXISTS `registerable_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registerable_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `price_in_cents` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registerable_items`
--

LOCK TABLES `registerable_items` WRITE;
/*!40000 ALTER TABLE `registerable_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `registerable_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registration_items`
--

DROP TABLE IF EXISTS `registration_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registration_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `participant_registration_id` int(11) DEFAULT NULL,
  `registerable_item_id` int(11) DEFAULT NULL,
  `count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registration_items`
--

LOCK TABLES `registration_items` WRITE;
/*!40000 ALTER TABLE `registration_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `registration_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin'),(2,'housing_admin'),(3,'paperwork_admin'),(4,'ministry_project_admin'),(5,'seminar_admin'),(6,'equipment_admin'),(7,'official_admin');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles_users`
--

DROP TABLE IF EXISTS `roles_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles_users` (
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  KEY `index_roles_users_on_role_id` (`role_id`),
  KEY `index_roles_users_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles_users`
--

LOCK TABLES `roles_users` WRITE;
/*!40000 ALTER TABLE `roles_users` DISABLE KEYS */;
INSERT INTO `roles_users` VALUES (1,1),(1,2),(1,3),(1,4);
/*!40000 ALTER TABLE `roles_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rooms`
--

DROP TABLE IF EXISTS `rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rooms`
--

LOCK TABLES `rooms` WRITE;
/*!40000 ALTER TABLE `rooms` DISABLE KEYS */;
/*!40000 ALTER TABLE `rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `round_quizzers`
--

DROP TABLE IF EXISTS `round_quizzers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `round_quizzers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `round_id` int(11) DEFAULT NULL,
  `quizzer_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT '0',
  `total_correct` int(11) DEFAULT '0',
  `total_errors` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `round_quizzers`
--

LOCK TABLES `round_quizzers` WRITE;
/*!40000 ALTER TABLE `round_quizzers` DISABLE KEYS */;
/*!40000 ALTER TABLE `round_quizzers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `round_teams`
--

DROP TABLE IF EXISTS `round_teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `round_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `round_id` int(11) DEFAULT NULL,
  `quiz_team_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `place` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `round_teams`
--

LOCK TABLES `round_teams` WRITE;
/*!40000 ALTER TABLE `round_teams` DISABLE KEYS */;
/*!40000 ALTER TABLE `round_teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rounds`
--

DROP TABLE IF EXISTS `rounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `room_id` int(11) DEFAULT NULL,
  `quiz_division_id` int(11) DEFAULT NULL,
  `number` varchar(255) DEFAULT NULL,
  `questions` int(11) DEFAULT '0',
  `visible` tinyint(1) DEFAULT '1',
  `complete` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rounds`
--

LOCK TABLES `rounds` WRITE;
/*!40000 ALTER TABLE `rounds` DISABLE KEYS */;
/*!40000 ALTER TABLE `rounds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('1'),('10'),('11'),('12'),('13'),('14'),('15'),('16'),('17'),('18'),('19'),('2'),('20'),('21'),('22'),('23'),('24'),('25'),('26'),('27'),('28'),('29'),('3'),('30'),('31'),('32'),('33'),('34'),('35'),('36'),('37'),('38'),('39'),('4'),('40'),('41'),('42'),('43'),('44'),('45'),('46'),('47'),('48'),('49'),('5'),('50'),('51'),('6'),('7'),('8'),('9');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schools`
--

DROP TABLE IF EXISTS `schools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `paid` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schools`
--

LOCK TABLES `schools` WRITE;
/*!40000 ALTER TABLE `schools` DISABLE KEYS */;
INSERT INTO `schools` VALUES (1,'Eastern Nazarene College (ENC)',1,'2010-03-16 04:25:56','2012-07-02 20:24:22'),(2,'MidAmerica Nazarene University (MNU)',1,'2010-03-16 04:25:56','2012-06-04 21:29:47'),(3,'Mount Vernon Nazarene University (NNU)',1,'2010-03-16 04:25:56','2012-06-07 18:59:52'),(4,'Northwest Nazarene University (NNU)',1,'2010-03-16 04:25:56','2012-06-16 18:17:22'),(5,'Olivet Nazarene University (ONU)',1,'2010-03-16 04:25:56',NULL),(6,'Point Loma Nazarene University (PLNU)',0,'2010-03-16 04:25:56',NULL),(7,'Southern Nazarene University (SNU)',1,'2010-03-16 04:25:56','2012-06-01 21:28:56'),(8,'Trevecca Nazarene University (TNU)',1,'2010-03-16 04:25:56','2012-06-07 18:06:46'),(9,'Nazarene Bible College',0,'2010-03-16 04:25:56','2010-03-16 04:25:56'),(10,'Nazarene Theological Seminary',0,'2010-03-16 04:25:56','2010-03-16 04:25:56'),(11,'Amherst College',0,'2012-04-05 20:20:56',NULL);
/*!40000 ALTER TABLE `schools` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seminar_registrations`
--

DROP TABLE IF EXISTS `seminar_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seminar_registrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `seminar_1` tinyint(1) DEFAULT NULL,
  `seminar_1_session` varchar(255) DEFAULT NULL,
  `seminar_2` tinyint(1) DEFAULT NULL,
  `seminar_2_session` varchar(255) DEFAULT NULL,
  `seminar_3` tinyint(1) DEFAULT NULL,
  `seminar_3_session` varchar(255) DEFAULT NULL,
  `seminar_4` tinyint(1) DEFAULT NULL,
  `seminar_4_session` varchar(255) DEFAULT NULL,
  `seminar_5` tinyint(1) DEFAULT NULL,
  `seminar_5_session` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `seminar_6` tinyint(1) DEFAULT NULL,
  `seminar_6_session` varchar(255) DEFAULT NULL,
  `seminar_7` tinyint(1) DEFAULT NULL,
  `seminar_7_session` varchar(255) DEFAULT NULL,
  `seminar_8` tinyint(1) DEFAULT NULL,
  `seminar_8_session` varchar(255) DEFAULT NULL,
  `seminar_9` tinyint(1) DEFAULT NULL,
  `seminar_9_session` varchar(255) DEFAULT NULL,
  `seminar_10` tinyint(1) DEFAULT NULL,
  `seminar_10_session` varchar(255) DEFAULT NULL,
  `seminar_11` tinyint(1) DEFAULT NULL,
  `seminar_11_session` varchar(255) DEFAULT NULL,
  `seminar_12` tinyint(1) DEFAULT NULL,
  `seminar_12_session` varchar(255) DEFAULT NULL,
  `seminar_13` tinyint(1) DEFAULT NULL,
  `seminar_13_session` varchar(255) DEFAULT NULL,
  `seminar_14` tinyint(1) DEFAULT NULL,
  `seminar_14_session` varchar(255) DEFAULT NULL,
  `seminar_15` tinyint(1) DEFAULT NULL,
  `seminar_15_session` varchar(255) DEFAULT NULL,
  `seminar_16` tinyint(1) DEFAULT NULL,
  `seminar_16_session` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seminar_registrations`
--

LOCK TABLES `seminar_registrations` WRITE;
/*!40000 ALTER TABLE `seminar_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `seminar_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (1,'f87bc7d27646855025a216de23279eaf','BAh7CDoMdXNlcl9pZGkGOhBfY3NyZl90b2tlbiIxdVYzSm56VW9waVlGRC9o\nZEgxUXJ6NDcxZlhtMHZ1Qm1OWldVZSt3MnE4TT0iCmZsYXNoSUM6J0FjdGlv\nbkNvbnRyb2xsZXI6OkZsYXNoOjpGbGFzaEhhc2h7AAY6CkB1c2VkewA=\n','2014-01-30 23:01:44','2014-01-31 05:01:03'),(2,'fc61b8e0faeade02ea8da89377095936','BAh7ByIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNo\nSGFzaHsGOgtub3RpY2UiHllvdSBoYXZlIGJlZW4gbG9nZ2VkIG91dC4GOgpA\ndXNlZHsGOwZGOg5yZXR1cm5fdG8w\n','2014-01-31 05:04:27','2014-01-31 05:07:44'),(3,'caba885a07bdd04e006564cf68aad6e6','BAh7BzoQX2NzcmZfdG9rZW4iMUVWUTBEbkUwRDRVemUwQnVQdVRuSlhOT2tN\nOFlnTUhkK3c1K0VwQjhMLzA9IgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVy\nOjpGbGFzaDo6Rmxhc2hIYXNoewY6C25vdGljZSJMQSBsaW5rIHRvIGNoYW5n\nZSB5b3VyIHBhc3N3b3JkIGhhcyBiZWVuIHNlbnQgdG8gamRyaXNjb2xsQHJl\nYWxuZXRzLmNvbS4GOgpAdXNlZHsGOwdU\n','2014-01-31 05:07:44','2014-01-31 05:09:01'),(4,'c0413a6fe2745550f834a2214451c9de','BAh7BzoQX2NzcmZfdG9rZW4iMW40UjlUNEFadDhlSlgxN3NJVTgwZ2NOSUFR\nZEdvL2psNnBUWXFEci91Mms9IgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVy\nOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n','2014-01-31 05:08:41','2014-01-31 05:08:41'),(5,'db0f4403c99769f6143099cf2703ef42','BAh7BzoQX2NzcmZfdG9rZW4iMWJBQWZ5V3hLb2NSQkozWXMrK29zeCtyMC9G\nK21Eb2Y1SXZ4R0NaZG9kUUU9IgpmbGFzaElDOidBY3Rpb25Db250cm9sbGVy\nOjpGbGFzaDo6Rmxhc2hIYXNoewAGOgpAdXNlZHsA\n','2014-01-31 05:09:46','2014-01-31 05:09:46');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `body` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statistics`
--

LOCK TABLES `statistics` WRITE;
/*!40000 ALTER TABLE `statistics` DISABLE KEYS */;
/*!40000 ALTER TABLE `statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `team_registrations`
--

DROP TABLE IF EXISTS `team_registrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `team_registrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `amount_in_cents` int(11) DEFAULT NULL,
  `paid` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `audit` text,
  `regional_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `team_registrations`
--

LOCK TABLES `team_registrations` WRITE;
/*!40000 ALTER TABLE `team_registrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `team_registrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_registration_id` int(11) DEFAULT NULL,
  `division_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `amount_in_cents` int(11) DEFAULT NULL,
  `discounted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `communicate_by_email` tinyint(1) DEFAULT NULL,
  `crypted_password` varchar(40) DEFAULT NULL,
  `salt` varchar(40) DEFAULT NULL,
  `remember_token` varchar(40) DEFAULT NULL,
  `activation_code` varchar(40) DEFAULT NULL,
  `state` varchar(255) NOT NULL DEFAULT 'passive',
  `remember_token_expires_at` datetime DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=437 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Jeremy','Driscoll','jdriscoll@realnets.com','312-375-8674',1,'cae03ca1341f8a8daeb54fbb8dc5529d251b64b7','419ae7fb200a06cda39b3a8dd26630ea0eaddbfd',NULL,NULL,'active',NULL,'2009-12-16 07:25:39',NULL,'2009-12-16 07:25:39','2012-02-28 01:01:15',4),(2,'Admin','Bill Horning','admin@nazquizzing.org','1234567890',0,'23b232c42ceda8e3ca0dfdde4c49656abfc80671','93f637b45c5b337e86f50d59ebef9dfa0074b71a',NULL,NULL,'active',NULL,NULL,NULL,'2009-12-16 07:39:11','2014-01-25 18:30:19',4),(3,'Bill','Horning','bill.horning@att.net','815-341-8299',1,'3b33c5b57aa20a2dc355ef0b323c40c58d0553f8','aa1cbbec65a51baf4fe266ba9c7907a64f4e482a',NULL,NULL,'active',NULL,'2009-12-19 15:40:43',NULL,'2009-12-19 15:40:43','2012-05-03 03:09:21',4),(4,'Chad','Lynn','chadandmegan@comcast.net','913-220-8636',1,'8301ec5f526d6ceeee63775e757287b2b01bb072','e530a0323b1fcb8e7bac550a3a2b8b88a9efc8ec','a7521cc2badd736a2454b57d1dd7beaa05a3a7f6',NULL,'active','2013-11-14 13:17:38','2012-04-07 13:21:50',NULL,'2012-04-07 13:21:50','2013-10-31 12:17:38',35),(436,'Jeremy','Driscoll','jeremy@ccdquiz.org','312-375-8674',1,'1da2e63af9d3ba9d84c80bf884950f3c6eed81bf','9871b429a9e75611edf0317219eecaf53548a9fa',NULL,NULL,'active',NULL,'2014-01-31 05:07:32',NULL,'2014-01-31 05:07:32','2014-01-31 05:07:32',4);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-01-30 23:16:30
