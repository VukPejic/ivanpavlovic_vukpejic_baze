-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 26, 2026 at 02:28 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ivanpavlovic_vukpejic_baza`
--
CREATE DATABASE IF NOT EXISTS `ivanpavlovic_vukpejic_baza` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ivanpavlovic_vukpejic_baza`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `izbrisi_sesiju`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `izbrisi_sesiju` (IN `_istrazivac_id` INT, IN `_sesija_id` INT, OUT `_izbrisani` INT)   BEGIN
    DECLARE broj_redova INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
    	SELECT 'Greska';
    	ROLLBACK;
	END;
    SELECT COUNT(*) INTO broj_redova FROM sesija;
    START TRANSACTION;
    DELETE s FROM sesija s
    JOIN izvodjenje i ON s.izvodjenje_id = i.izvodjenje_id
    JOIN dizajner_eksperiment de ON i.eksperiment_id = de.eksperiment_id
    WHERE s.sesija_id = _sesija_id AND de.istrazivac_id = _istrazivac_id;
    COMMIT;
    SELECT COUNT(*) INTO _izbrisani FROM sesija;
    SET _izbrisani = broj_redova - _izbrisani;
END$$

DROP PROCEDURE IF EXISTS `registruj_korisnika`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registruj_korisnika` (IN `_ime` VARCHAR(50), IN `_prezime` VARCHAR(50), IN `_kvalifikacije` TEXT, IN `_username` VARCHAR(100), IN `_lozinka` VARCHAR(255))   BEGIN
    DECLARE _istrazivac_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
    	SELECT 'Greska';
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO istrazivac (ime,prezime,kvalifikacije)
    VALUES (_ime,_prezime,_kvalifikacije);

    SELECT MAX(istrazivac_id) INTO _istrazivac_id FROM istrazivac;

   	INSERT INTO korisnik (istrazivac_id,username,lozinka)
    VALUES (_istrazivac_id,_username,MD5(_lozinka));

    COMMIT;
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `prijavi_korisnika`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `prijavi_korisnika` (`_username` VARCHAR(100), `_lozinka` VARCHAR(255)) RETURNS TINYINT(1)  BEGIN
    DECLARE brojac INT;
    DECLARE _hash_lozinka VARCHAR(255);
    SET _hash_lozinka = MD5(_lozinka);
    SELECT COUNT(*) INTO brojac
    FROM korisnik
    WHERE username = _username AND lozinka = _hash_lozinka;
    RETURN brojac = 1;
END$$

DROP FUNCTION IF EXISTS `prijavi_korisnika_tester`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `prijavi_korisnika_tester` () RETURNS TINYINT(1)  BEGIN
    DECLARE test1 BOOLEAN;
    DECLARE test2 BOOLEAN;
    DECLARE test3 BOOLEAN;
    DECLARE test4 BOOLEAN;
    DECLARE test5 BOOLEAN;

    SET test1 = prijavi_korisnika('test1', 'test1');
    SET test2 = prijavi_korisnika('test2', 'test3');
    SET test3 = prijavi_korisnika('test3', 'test3');
    SET test4 = prijavi_korisnika('test1', 'test4');
    SET test5 = prijavi_korisnika('test5', 'test5');

    IF test1 = TRUE AND test2 = FALSE AND test3 = TRUE AND test4 = FALSE AND test5 = TRUE THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alat`
--

DROP TABLE IF EXISTS `alat`;
CREATE TABLE `alat` (
  `alat_id` int(11) NOT NULL,
  `laboratorija_id` int(11) NOT NULL,
  `tip_alata_id` int(11) NOT NULL,
  `identifikacioni_broj` varchar(100) NOT NULL,
  `datum_nabavke` date DEFAULT NULL,
  `datum_proizvodnje` date DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alat`
--

INSERT INTO `alat` (`alat_id`, `laboratorija_id`, `tip_alata_id`, `identifikacioni_broj`, `datum_nabavke`, `datum_proizvodnje`, `status`) VALUES
(1, 1, 1, 'EL-ALAT-0001', '2020-01-21', '2017-08-22', 'u upotrebi'),
(2, 2, 2, 'EL-ALAT-0002', '2020-02-01', '2017-10-05', 'na servisu'),
(3, 3, 3, 'EL-ALAT-0003', '2020-02-12', '2018-07-08', 'rezervisan'),
(4, 4, 4, 'EL-ALAT-0004', '2020-02-23', '2019-09-28', 'neispravan'),
(5, 5, 5, 'EL-ALAT-0005', '2020-03-05', '2019-02-15', 'ispravan'),
(6, 6, 6, 'EL-ALAT-0006', '2020-03-16', '2019-10-25', 'u upotrebi'),
(7, 7, 7, 'EL-ALAT-0007', '2020-03-27', '2019-04-08', 'na servisu'),
(8, 8, 8, 'EL-ALAT-0008', '2020-04-07', '2018-03-05', 'rezervisan'),
(9, 9, 9, 'EL-ALAT-0009', '2020-04-18', '2019-03-29', 'neispravan'),
(10, 10, 10, 'EL-ALAT-0010', '2020-04-29', '2019-12-26', 'ispravan'),
(11, 11, 1, 'EL-ALAT-0011', '2020-05-10', '2018-12-08', 'u upotrebi'),
(12, 12, 2, 'EL-ALAT-0012', '2020-05-21', '2019-06-12', 'na servisu'),
(13, 13, 3, 'EL-ALAT-0013', '2020-06-01', '2019-09-11', 'rezervisan'),
(14, 14, 4, 'EL-ALAT-0014', '2020-06-12', '2019-02-05', 'neispravan'),
(15, 15, 5, 'EL-ALAT-0015', '2020-06-23', '2020-01-14', 'ispravan'),
(16, 16, 6, 'EL-ALAT-0016', '2020-07-04', '2019-04-25', 'u upotrebi'),
(17, 17, 7, 'EL-ALAT-0017', '2020-07-15', '2018-06-26', 'na servisu'),
(18, 18, 8, 'EL-ALAT-0018', '2020-07-26', '2019-11-30', 'rezervisan'),
(19, 19, 9, 'EL-ALAT-0019', '2020-08-06', '2019-12-06', 'neispravan'),
(20, 20, 10, 'EL-ALAT-0020', '2020-08-17', '2018-04-17', 'ispravan'),
(21, 21, 1, 'EL-ALAT-0021', '2020-08-28', '2018-05-16', 'u upotrebi'),
(22, 22, 2, 'EL-ALAT-0022', '2020-09-08', '2019-02-06', 'na servisu'),
(23, 23, 3, 'EL-ALAT-0023', '2020-09-19', '2020-05-02', 'rezervisan'),
(24, 24, 4, 'EL-ALAT-0024', '2020-09-30', '2019-10-18', 'neispravan'),
(25, 25, 5, 'EL-ALAT-0025', '2020-10-11', '2020-02-22', 'ispravan'),
(26, 26, 6, 'EL-ALAT-0026', '2020-10-22', '2018-09-28', 'u upotrebi'),
(27, 27, 7, 'EL-ALAT-0027', '2020-11-02', '2019-02-13', 'na servisu'),
(28, 28, 8, 'EL-ALAT-0028', '2020-11-13', '2018-07-31', 'rezervisan'),
(29, 29, 9, 'EL-ALAT-0029', '2020-11-24', '2019-04-24', 'neispravan'),
(30, 30, 10, 'EL-ALAT-0030', '2020-12-05', '2020-08-09', 'ispravan'),
(31, 31, 1, 'EL-ALAT-0031', '2020-12-16', '2020-02-13', 'u upotrebi'),
(32, 32, 2, 'EL-ALAT-0032', '2020-12-27', '2019-09-20', 'na servisu'),
(33, 33, 3, 'EL-ALAT-0033', '2021-01-07', '2020-05-05', 'rezervisan'),
(34, 34, 4, 'EL-ALAT-0034', '2021-01-18', '2019-10-09', 'neispravan'),
(35, 35, 5, 'EL-ALAT-0035', '2021-01-29', '2019-02-24', 'ispravan'),
(36, 36, 6, 'EL-ALAT-0036', '2021-02-09', '2018-09-12', 'u upotrebi'),
(37, 37, 7, 'EL-ALAT-0037', '2021-02-20', '2019-09-13', 'na servisu'),
(38, 38, 8, 'EL-ALAT-0038', '2021-03-03', '2019-07-26', 'rezervisan'),
(39, 39, 9, 'EL-ALAT-0039', '2021-03-14', '2019-04-29', 'neispravan'),
(40, 40, 10, 'EL-ALAT-0040', '2021-03-25', '2019-08-25', 'ispravan'),
(41, 41, 1, 'EL-ALAT-0041', '2021-04-05', '2020-02-25', 'u upotrebi'),
(42, 42, 2, 'EL-ALAT-0042', '2021-04-16', '2020-08-27', 'na servisu'),
(43, 43, 3, 'EL-ALAT-0043', '2021-04-27', '2019-07-30', 'rezervisan'),
(44, 44, 4, 'EL-ALAT-0044', '2021-05-08', '2019-06-16', 'neispravan'),
(45, 45, 5, 'EL-ALAT-0045', '2021-05-19', '2020-05-12', 'ispravan'),
(46, 46, 6, 'EL-ALAT-0046', '2021-05-30', '2020-10-10', 'u upotrebi'),
(47, 47, 7, 'EL-ALAT-0047', '2021-06-10', '2019-01-16', 'na servisu'),
(48, 48, 8, 'EL-ALAT-0048', '2021-06-21', '2019-03-16', 'rezervisan'),
(49, 49, 9, 'EL-ALAT-0049', '2021-07-02', '2021-03-24', 'neispravan'),
(50, 50, 10, 'EL-ALAT-0050', '2021-07-13', '2020-03-19', 'ispravan'),
(51, 51, 1, 'EL-ALAT-0051', '2021-07-24', '2019-05-25', 'u upotrebi'),
(52, 52, 2, 'EL-ALAT-0052', '2021-08-04', '2020-12-29', 'na servisu'),
(53, 53, 3, 'EL-ALAT-0053', '2021-08-15', '2019-05-16', 'rezervisan'),
(54, 54, 4, 'EL-ALAT-0054', '2021-08-26', '2021-05-04', 'neispravan'),
(55, 55, 5, 'EL-ALAT-0055', '2021-09-06', '2020-09-11', 'ispravan'),
(56, 56, 6, 'EL-ALAT-0056', '2021-09-17', '2019-10-21', 'u upotrebi'),
(57, 57, 7, 'EL-ALAT-0057', '2021-09-28', '2020-08-01', 'na servisu'),
(58, 58, 8, 'EL-ALAT-0058', '2021-10-09', '2019-09-21', 'rezervisan'),
(59, 59, 9, 'EL-ALAT-0059', '2021-10-20', '2020-11-09', 'neispravan'),
(60, 60, 10, 'EL-ALAT-0060', '2021-10-31', '2019-12-13', 'ispravan'),
(61, 61, 1, 'EL-ALAT-0061', '2021-11-11', '2020-06-08', 'u upotrebi'),
(62, 62, 2, 'EL-ALAT-0062', '2021-11-22', '2020-12-04', 'na servisu'),
(63, 63, 3, 'EL-ALAT-0063', '2021-12-03', '2019-10-06', 'rezervisan'),
(64, 64, 4, 'EL-ALAT-0064', '2021-12-14', '2020-07-27', 'neispravan'),
(65, 65, 5, 'EL-ALAT-0065', '2021-12-25', '2019-08-19', 'ispravan'),
(66, 66, 6, 'EL-ALAT-0066', '2022-01-05', '2021-05-19', 'u upotrebi'),
(67, 67, 7, 'EL-ALAT-0067', '2022-01-16', '2021-06-04', 'na servisu'),
(68, 68, 8, 'EL-ALAT-0068', '2022-01-27', '2021-06-06', 'rezervisan'),
(69, 69, 9, 'EL-ALAT-0069', '2022-02-07', '2021-08-04', 'neispravan'),
(70, 70, 10, 'EL-ALAT-0070', '2022-02-18', '2020-10-10', 'ispravan'),
(71, 71, 1, 'EL-ALAT-0071', '2022-03-01', '2021-08-27', 'u upotrebi'),
(72, 72, 2, 'EL-ALAT-0072', '2022-03-12', '2021-06-04', 'na servisu'),
(73, 73, 3, 'EL-ALAT-0073', '2022-03-23', '2021-11-28', 'rezervisan'),
(74, 74, 4, 'EL-ALAT-0074', '2022-04-03', '2020-03-17', 'neispravan'),
(75, 75, 5, 'EL-ALAT-0075', '2022-04-14', '2020-10-14', 'ispravan'),
(76, 76, 6, 'EL-ALAT-0076', '2022-04-25', '2019-11-12', 'u upotrebi'),
(77, 77, 7, 'EL-ALAT-0077', '2022-05-06', '2021-09-14', 'na servisu'),
(78, 78, 8, 'EL-ALAT-0078', '2022-05-17', '2021-12-05', 'rezervisan'),
(79, 79, 9, 'EL-ALAT-0079', '2022-05-28', '2021-10-29', 'neispravan'),
(80, 80, 10, 'EL-ALAT-0080', '2022-06-08', '2020-05-08', 'ispravan'),
(81, 81, 1, 'EL-ALAT-0081', '2022-06-19', '2021-06-06', 'u upotrebi'),
(82, 82, 2, 'EL-ALAT-0082', '2022-06-30', '2021-11-23', 'na servisu'),
(83, 83, 3, 'EL-ALAT-0083', '2022-07-11', '2021-06-05', 'rezervisan'),
(84, 84, 4, 'EL-ALAT-0084', '2022-07-22', '2020-10-19', 'neispravan'),
(85, 85, 5, 'EL-ALAT-0085', '2022-08-02', '2021-06-06', 'ispravan'),
(86, 86, 6, 'EL-ALAT-0086', '2022-08-13', '2021-04-05', 'u upotrebi'),
(87, 87, 7, 'EL-ALAT-0087', '2022-08-24', '2021-01-06', 'na servisu'),
(88, 88, 8, 'EL-ALAT-0088', '2022-09-04', '2021-10-25', 'rezervisan'),
(89, 89, 9, 'EL-ALAT-0089', '2022-09-15', '2020-09-19', 'neispravan'),
(90, 90, 10, 'EL-ALAT-0090', '2022-09-26', '2022-01-09', 'ispravan'),
(91, 91, 1, 'EL-ALAT-0091', '2022-10-07', '2022-01-05', 'u upotrebi'),
(92, 92, 2, 'EL-ALAT-0092', '2022-10-18', '2022-01-13', 'na servisu'),
(93, 93, 3, 'EL-ALAT-0093', '2022-10-29', '2021-07-10', 'rezervisan'),
(94, 94, 4, 'EL-ALAT-0094', '2022-11-09', '2022-01-17', 'neispravan'),
(95, 95, 5, 'EL-ALAT-0095', '2022-11-20', '2020-08-25', 'ispravan'),
(96, 96, 6, 'EL-ALAT-0096', '2022-12-01', '2020-08-01', 'u upotrebi'),
(97, 97, 7, 'EL-ALAT-0097', '2022-12-12', '2021-02-27', 'na servisu'),
(98, 98, 8, 'EL-ALAT-0098', '2022-12-23', '2020-08-10', 'rezervisan'),
(99, 99, 9, 'EL-ALAT-0099', '2023-01-03', '2022-08-19', 'neispravan'),
(100, 100, 10, 'EL-ALAT-0100', '2023-01-14', '2021-02-05', 'ispravan');

-- --------------------------------------------------------

--
-- Table structure for table `alat_eksperiment`
--

DROP TABLE IF EXISTS `alat_eksperiment`;
CREATE TABLE `alat_eksperiment` (
  `eksperiment_id` int(11) NOT NULL,
  `tip_alata_id` int(11) NOT NULL,
  `potrebna_kolicina` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alat_eksperiment`
--

INSERT INTO `alat_eksperiment` (`eksperiment_id`, `tip_alata_id`, `potrebna_kolicina`) VALUES
(1, 1, 3),
(2, 2, 4),
(3, 3, 2),
(4, 4, 4),
(5, 5, 3),
(6, 6, 1),
(7, 7, 1),
(8, 8, 3),
(9, 9, 2),
(10, 10, 5),
(11, 1, 4),
(12, 2, 3),
(13, 3, 1),
(14, 4, 5),
(15, 5, 1),
(16, 6, 3),
(17, 7, 2),
(18, 8, 1),
(19, 9, 3),
(20, 10, 5),
(21, 1, 2),
(22, 2, 2),
(23, 3, 1),
(24, 4, 4),
(25, 5, 4),
(26, 6, 2),
(27, 7, 4),
(28, 8, 1),
(29, 9, 5),
(30, 10, 2),
(31, 1, 4),
(32, 2, 3),
(33, 3, 5),
(34, 4, 5),
(35, 5, 3),
(36, 6, 1),
(37, 7, 3),
(38, 8, 5),
(39, 9, 5),
(40, 10, 4),
(41, 1, 2),
(42, 2, 3),
(43, 3, 1),
(44, 4, 1),
(45, 5, 3),
(46, 6, 2),
(47, 7, 2),
(48, 8, 4),
(49, 9, 5),
(50, 10, 2),
(51, 1, 4),
(52, 2, 5),
(53, 3, 4),
(54, 4, 5),
(55, 5, 4),
(56, 6, 2),
(57, 7, 1),
(58, 8, 3),
(59, 9, 3),
(60, 10, 3),
(61, 1, 4),
(62, 2, 3),
(63, 3, 3),
(64, 4, 4),
(65, 5, 4),
(66, 6, 4),
(67, 7, 5),
(68, 8, 3),
(69, 9, 5),
(70, 10, 4),
(71, 1, 2),
(72, 2, 3),
(73, 3, 2),
(74, 4, 3),
(75, 5, 2),
(76, 6, 3),
(77, 7, 4),
(78, 8, 3),
(79, 9, 4),
(80, 10, 5),
(81, 1, 5),
(82, 2, 4),
(83, 3, 2),
(84, 4, 1),
(85, 5, 3),
(86, 6, 2),
(87, 7, 1),
(88, 8, 2),
(89, 9, 1),
(90, 10, 4),
(91, 1, 4),
(92, 2, 3),
(93, 3, 2),
(94, 4, 3),
(95, 5, 4),
(96, 6, 2),
(97, 7, 4),
(98, 8, 2),
(99, 9, 2),
(100, 10, 2);

-- --------------------------------------------------------

--
-- Table structure for table `alat_sesija`
--

DROP TABLE IF EXISTS `alat_sesija`;
CREATE TABLE `alat_sesija` (
  `sesija_id` int(11) NOT NULL,
  `alat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alat_sesija`
--

INSERT INTO `alat_sesija` (`sesija_id`, `alat_id`) VALUES
(1, 1),
(2, 4),
(4, 10),
(5, 13),
(6, 16),
(7, 19),
(9, 25),
(10, 28),
(11, 31),
(12, 34),
(13, 37),
(14, 40),
(15, 43),
(16, 46),
(17, 49),
(18, 52),
(19, 55),
(20, 58),
(21, 61),
(22, 64),
(23, 67),
(24, 70),
(25, 73),
(26, 76),
(27, 79),
(28, 82),
(29, 85),
(30, 88),
(31, 91),
(32, 94),
(33, 97),
(34, 100),
(35, 3),
(36, 6),
(37, 9),
(38, 12),
(39, 15),
(40, 18),
(41, 21),
(42, 24),
(43, 27),
(44, 30),
(45, 33),
(46, 36),
(47, 39),
(48, 42),
(49, 45),
(50, 48),
(51, 51),
(52, 54),
(53, 57),
(54, 60),
(55, 63),
(56, 66),
(57, 69),
(58, 72),
(59, 75),
(60, 78),
(61, 81),
(62, 84),
(63, 87),
(64, 90),
(65, 93),
(66, 96),
(67, 99),
(68, 2),
(69, 5),
(70, 8),
(71, 11),
(72, 14),
(73, 17),
(74, 20),
(75, 23),
(76, 26),
(77, 29),
(78, 32),
(79, 35),
(80, 38),
(81, 41),
(82, 44),
(83, 47),
(84, 50),
(85, 53),
(86, 56),
(87, 59),
(88, 62),
(89, 65),
(90, 68),
(91, 71),
(92, 74),
(93, 77),
(94, 80),
(95, 83),
(96, 86),
(97, 89),
(98, 92),
(99, 95),
(100, 98);

-- --------------------------------------------------------

--
-- Stand-in structure for view `dizajneri_na_eksperimentu`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `dizajneri_na_eksperimentu`;
CREATE TABLE `dizajneri_na_eksperimentu` (
`eksperiment_id` int(11)
,`naziv` varchar(100)
,`broj_istrazivaca` bigint(21)
,`istrazivaci` mediumtext
);

-- --------------------------------------------------------

--
-- Table structure for table `dizajner_eksperiment`
--

DROP TABLE IF EXISTS `dizajner_eksperiment`;
CREATE TABLE `dizajner_eksperiment` (
  `eksperiment_id` int(11) NOT NULL,
  `istrazivac_id` int(11) NOT NULL,
  `teorija_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dizajner_eksperiment`
--

INSERT INTO `dizajner_eksperiment` (`eksperiment_id`, `istrazivac_id`, `teorija_id`) VALUES
(1, 1, 1),
(1, 101, 1),
(1, 102, 1),
(1, 103, 1),
(1, 104, 1),
(1, 105, 1),
(68, 68, 2),
(35, 35, 3),
(2, 2, 4),
(69, 69, 5),
(36, 36, 6),
(3, 3, 7),
(70, 70, 8),
(37, 37, 9),
(4, 4, 10),
(71, 71, 11),
(38, 38, 12),
(5, 5, 13),
(72, 72, 14),
(39, 39, 15),
(6, 6, 16),
(73, 73, 17),
(40, 40, 18),
(7, 7, 19),
(74, 74, 20),
(41, 41, 21),
(8, 8, 22),
(75, 75, 23),
(42, 42, 24),
(9, 9, 25),
(76, 76, 26),
(43, 43, 27),
(10, 10, 28),
(77, 77, 29),
(44, 44, 30),
(11, 11, 31),
(78, 78, 32),
(45, 45, 33),
(12, 12, 34),
(79, 79, 35),
(46, 46, 36),
(13, 13, 37),
(80, 80, 38),
(47, 47, 39),
(14, 14, 40),
(81, 81, 41),
(48, 48, 42),
(15, 15, 43),
(82, 82, 44),
(49, 49, 45),
(16, 16, 46),
(83, 83, 47),
(50, 50, 48),
(17, 17, 49),
(84, 84, 50),
(51, 51, 51),
(18, 18, 52),
(85, 85, 53),
(52, 52, 54),
(19, 19, 55),
(86, 86, 56),
(53, 53, 57),
(20, 20, 58),
(87, 87, 59),
(54, 54, 60),
(21, 21, 61),
(88, 88, 62),
(55, 55, 63),
(22, 22, 64),
(89, 89, 65),
(56, 56, 66),
(23, 23, 67),
(90, 90, 68),
(57, 57, 69),
(24, 24, 70),
(91, 91, 71),
(58, 58, 72),
(25, 25, 73),
(92, 92, 74),
(59, 59, 75),
(26, 26, 76),
(93, 93, 77),
(60, 60, 78),
(27, 27, 79),
(94, 94, 80),
(61, 61, 81),
(28, 28, 82),
(95, 95, 83),
(62, 62, 84),
(29, 29, 85),
(96, 96, 86),
(63, 63, 87),
(30, 30, 88),
(97, 97, 89),
(64, 64, 90),
(31, 31, 91),
(98, 98, 92),
(65, 65, 93),
(32, 32, 94),
(99, 99, 95),
(66, 66, 96),
(33, 33, 97),
(100, 100, 98),
(67, 67, 99),
(34, 34, 100);

-- --------------------------------------------------------

--
-- Table structure for table `eksperiment`
--

DROP TABLE IF EXISTS `eksperiment`;
CREATE TABLE `eksperiment` (
  `eksperiment_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `ciljevi` text DEFAULT NULL,
  `teorijski_okvir` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `eksperiment`
--

INSERT INTO `eksperiment` (`eksperiment_id`, `naziv`, `ciljevi`, `teorijski_okvir`, `status`) VALUES
(1, 'Ispitivanje Omovog zakona na otpornom kolu', 'Proveriti zavisnost struje od napona pri konstantnom otporu.', 'Omov zakon: I = U / R.', 'planiran'),
(2, 'Analiza redne veze otpornika', 'Izracunati i izmeriti ekvivalentni otpor redno vezanih otpornika.', 'Kod redne veze ukupni otpor je zbir pojedinacnih otpora.', 'u toku'),
(3, 'Analiza paralelne veze otpornika', 'Uporediti izmereni i izracunati ekvivalentni otpor paralelne veze.', 'Kod paralelne veze zbiraju se reciprocne vrednosti otpora.', 'zavrsen'),
(4, 'Merenje pada napona na otpornicima', 'Izmeriti pad napona na svakom otporniku u rednom kolu.', 'Kirhofov zakon napona.', 'pauziran'),
(5, 'Ispitivanje delitelja napona', 'Proveriti odnos ulaznog i izlaznog napona na delitelju.', 'Delitelj napona zasniva se na odnosu dva otpornika.', 'planiran'),
(6, 'Punjenje kondenzatora kroz otpornik', 'Pratiti promenu napona na kondenzatoru tokom punjenja.', 'Prelazni proces u RC kolu.', 'u toku'),
(7, 'Praznjenje kondenzatora kroz otpornik', 'Odrediti vremensku konstantu pri praznjenju kondenzatora.', 'Vremenska konstanta tau = R * C.', 'zavrsen'),
(8, 'Ispitivanje RC niskopropusnog filtera', 'Odrediti uticaj frekvencije na izlazni napon filtera.', 'RC niskopropusni filter propusta nize frekvencije.', 'pauziran'),
(9, 'Ispitivanje RC visokopropusnog filtera', 'Analizirati ponasanje filtera pri promeni frekvencije ulaza.', 'RC visokopropusni filter propusta vise frekvencije.', 'planiran'),
(10, 'Odredjivanje granicne frekvencije RC filtera', 'Pronaci frekvenciju pri kojoj izlazni signal opada na karakteristicnu vrednost.', 'Granicna frekvencija zavisi od R i C.', 'u toku'),
(11, 'Ispitivanje induktivnosti kalema', 'Analizirati uticaj kalema na promenu struje u kolu.', 'Kalem se suprotstavlja promeni struje.', 'zavrsen'),
(12, 'Analiza RL kola pri ukljucenju napona', 'Pratiti porast struje u kolu sa kalemom i otpornikom.', 'Prelazni proces u RL kolu.', 'pauziran'),
(13, 'Merenje napona na kalemu', 'Izmeriti napon na kalemu pri promeni struje.', 'Indukovani napon zavisi od brzine promene struje.', 'planiran'),
(14, 'Ispitivanje RLC rednog kola', 'Analizirati ponasanje rednog RLC kola pri razlicitim frekvencijama.', 'RLC kolo pokazuje rezonantno ponasanje.', 'u toku'),
(15, 'Ispitivanje RLC paralelnog kola', 'Uporediti impedansu paralelnog RLC kola za razlicite frekvencije.', 'Paralelno RLC kolo ima frekventno zavisnu impedansu.', 'zavrsen'),
(16, 'Odredjivanje rezonantne frekvencije', 'Izmeriti frekvenciju pri kojoj je odziv RLC kola najveci.', 'Rezonancija zavisi od L i C.', 'pauziran'),
(17, 'Merenje aktivne snage na otporniku', 'Izracunati snagu na otporniku pomocu napona i struje.', 'Snaga se racuna formulom P = U * I.', 'planiran'),
(18, 'Ispitivanje zagrevanja otpornika', 'Posmatrati promenu temperature otpornika pri vecoj snazi.', 'Dzulov efekat pretvara elektricnu energiju u toplotu.', 'u toku'),
(19, 'Testiranje LED diode sa zastitnim otpornikom', 'Odrediti minimalni otpornik za bezbedan rad LED diode.', 'LED dioda zahteva ogranicenje struje.', 'zavrsen'),
(20, 'Merenje karakteristike diode', 'Snimiti zavisnost struje diode od napona.', 'PN spoj ima nelinearnu karakteristiku.', 'pauziran'),
(21, 'Ispitivanje Zener diode', 'Odrediti napon stabilizacije Zener diode.', 'Zener dioda radi u probojnom rezimu.', 'planiran'),
(22, 'Stabilizacija napona Zener diodom', 'Proveriti stabilnost izlaznog napona pri promeni opterecenja.', 'Zener dioda moze sluziti kao jednostavan stabilizator.', 'u toku'),
(23, 'Ispitivanje mostnog ispravljaca', 'Analizirati pretvaranje naizmenicnog napona u jednosmerni.', 'Grecov spoj koristi cetiri diode.', 'zavrsen'),
(24, 'Merenje talasanja napona posle ispravljaca', 'Odrediti uticaj kondenzatora na smanjenje talasanja.', 'Kapacitivni filter smanjuje promenljivu komponentu napona.', 'pauziran'),
(25, 'Ispitivanje linearnog stabilizatora napona', 'Uporediti ulazni i izlazni napon stabilizatora.', 'Linearni regulator odrzava stabilan izlazni napon.', 'planiran'),
(26, 'Testiranje izvora napajanja pod opterecenjem', 'Meriti promenu izlaznog napona pri razlicitim opterecenjima.', 'Realni izvor ima unutrasnju otpornost.', 'u toku'),
(27, 'Merenje unutrasnje otpornosti izvora', 'Odrediti pad napona izvora pri porastu struje opterecenja.', 'Unutrasnja otpornost utice na stabilnost napona.', 'zavrsen'),
(28, 'Ispitivanje tranzistora kao prekidaca', 'Proveriti rad tranzistora u stanju zasicenja i zakocenja.', 'Tranzistor moze raditi kao elektronski prekidac.', 'pauziran'),
(29, 'Merenje strujnog pojacanja tranzistora', 'Odrediti odnos kolektorske i bazne struje.', 'Bipolarni tranzistor ima faktor pojacanja.', 'planiran'),
(30, 'Ispitivanje tranzistorskog pojacavaca', 'Izmeriti pojacanje malog naizmenicnog signala.', 'Pojacavac povecava amplitudu ulaznog signala.', 'u toku'),
(31, 'Analiza invertujuceg operacionog pojacavaca', 'Izmeriti pojacanje i fazni pomeraj izlaznog signala.', 'Invertujuci pojacavac daje izlaz suprotnog predznaka.', 'zavrsen'),
(32, 'Analiza neinvertujuceg operacionog pojacavaca', 'Proveriti odnos otpornika i pojacanja sklopa.', 'Neinvertujuci pojacavac zadrzava fazu ulaza.', 'pauziran'),
(33, 'Ispitivanje komparatora napona', 'Uporediti ulazni napon sa referentnim naponom.', 'Komparator daje digitalni izlaz na osnovu poredjenja.', 'planiran'),
(34, 'Testiranje senzora temperature', 'Izmeriti izlazni signal senzora pri razlicitim temperaturama.', 'Senzori pretvaraju fizicku velicinu u elektricni signal.', 'u toku'),
(35, 'Kalibracija temperaturnog senzora', 'Uporediti ocitavanja senzora sa referentnim termometrom.', 'Kalibracija smanjuje gresku merenja.', 'zavrsen'),
(36, 'Ispitivanje fotootpornika', 'Izmeriti promenu otpora pri promeni osvetljenja.', 'Otpor LDR senzora zavisi od intenziteta svetlosti.', 'pauziran'),
(37, 'Merenje osvetljenja pomocu LDR senzora', 'Napraviti delitelj napona sa fotootpornikom i pratiti izlaz.', 'Promena otpora se pretvara u promenu napona.', 'planiran'),
(38, 'Testiranje senzora vlaznosti', 'Analizirati odziv senzora na promenu vlaznosti.', 'Senzor vlaznosti daje analogni ili digitalni signal.', 'u toku'),
(39, 'Ispitivanje senzora blizine', 'Odrediti razdaljinu pri kojoj senzor menja stanje izlaza.', 'Senzor blizine detektuje objekat bez dodira.', 'zavrsen'),
(40, 'Merenje frekvencije signala osciloskopom', 'Odrediti period i frekvenciju periodicnog signala.', 'Frekvencija je recipročna vrednost perioda.', 'pauziran'),
(41, 'Analiza PWM signala', 'Izmeriti faktor ispune i srednju vrednost PWM signala.', 'PWM upravlja snagom preko odnosa ukljucenog i iskljucenog vremena.', 'planiran'),
(42, 'Ispitivanje generatora pravougaonog signala', 'Proveriti stabilnost frekvencije generisanog signala.', 'Oscilator generise periodicni signal.', 'u toku'),
(43, 'Merenje amplitude sinusnog signala', 'Odrediti vršnu i efektivnu vrednost signala.', 'Naizmenicni signal se opisuje amplitudom i frekvencijom.', 'zavrsen'),
(44, 'Poredjenje teorijskog i izmerenog otpora', 'Izracunati odstupanje izmedju deklarisane i izmerene vrednosti.', 'Tolerancija komponente izaziva razliku u vrednostima.', 'pauziran'),
(45, 'Ispitivanje tolerancije otpornika', 'Razvrstati otpornike prema odstupanju od nominalne vrednosti.', 'Otpornici imaju dozvoljenu toleranciju.', 'planiran'),
(46, 'Analiza uticaja opterecenja na delitelj napona', 'Proveriti kako potrosac menja izlazni napon delitelja.', 'Opterecenje menja ekvivalentnu otpornost izlaza.', 'u toku'),
(47, 'Testiranje elektronskog osiguraca', 'Proveriti prekid kola pri prevelikoj struji.', 'Zastitna kola ogranicavaju ili prekidaju struju.', 'zavrsen'),
(48, 'Ispitivanje relejnog sklopa', 'Proveriti aktiviranje releja preko tranzistorskog upravljanja.', 'Relej omogucava upravljanje vecim opterecenjem.', 'pauziran'),
(49, 'Analiza pada napona na sant otporniku', 'Izmeriti struju preko malog mernog otpornika.', 'Pad napona na sant otporniku proporcionalan je struji.', 'planiran'),
(50, 'Ispitivanje motora jednosmerne struje', 'Meriti promenu brzine motora pri promeni napona.', 'DC motor pretvara elektricnu energiju u mehanicku.', 'u toku'),
(51, 'PWM regulacija brzine DC motora', 'Analizirati uticaj faktora ispune na brzinu motora.', 'PWM efikasno regulise srednju vrednost napona.', 'zavrsen'),
(52, 'Ispitivanje zastite od obrnutog polariteta', 'Proveriti ponasanje kola pri pogresnom povezivanju napajanja.', 'Dioda ili MOSFET mogu zastititi kolo.', 'pauziran'),
(53, 'Analiza prenaponske zastite', 'Testirati ogranicavanje napona pomocu zastitnih elemenata.', 'Zastita sprecava ostecenje komponenata.', 'planiran'),
(54, 'Merenje kapacitivnosti kondenzatora', 'Uporediti izmerenu i nominalnu kapacitivnost.', 'Kapacitivnost odredjuje sposobnost skladistenja naelektrisanja.', 'u toku'),
(55, 'Merenje induktivnosti kalema', 'Odrediti induktivnost na osnovu odziva kola.', 'Induktivnost zavisi od geometrije i jezgra kalema.', 'zavrsen'),
(56, 'Ispitivanje serijske i paralelne kombinacije kondenzatora', 'Odrediti ukupnu kapacitivnost kombinovanih kondenzatora.', 'Kapacitivnosti se sabiraju razlicito kod redne i paralelne veze.', 'pauziran'),
(57, 'Ispitivanje serijske i paralelne kombinacije kalemova', 'Odrediti ekvivalentnu induktivnost kombinovanih kalemova.', 'Induktivnosti zavise od nacina povezivanja.', 'planiran'),
(58, 'Analiza sumova u mernom kolu', 'Posmatrati smetnje na izlaznom signalu senzora.', 'Elektricni sum utice na tacnost merenja.', 'u toku'),
(59, 'Filtriranje suma kondenzatorom', 'Proveriti kako kondenzator smanjuje brze promene signala.', 'Kondenzator moze kratko spojiti visokofrekventne smetnje.', 'zavrsen'),
(60, 'Ispitivanje uzemljenja mernog kola', 'Analizirati uticaj zajednicke mase na stabilnost merenja.', 'Nepravilno uzemljenje moze izazvati greske.', 'pauziran'),
(61, 'Merenje napona multimetrom', 'Uporediti ocitavanja multimetra sa ocekivanim vrednostima.', 'Voltmetar se povezuje paralelno sa elementom.', 'planiran'),
(62, 'Merenje struje ampermetrom', 'Izmeriti struju u grani kola pravilnim povezivanjem ampermetra.', 'Ampermetar se povezuje redno u granu.', 'u toku'),
(63, 'Provera kontinuiteta provodnika', 'Utvrditi da li postoji prekid u provodniku ili vezi.', 'Kontinuitet pokazuje postojanje provodne putanje.', 'zavrsen'),
(64, 'Ispitivanje kontaktnog otpora', 'Izmeriti uticaj konektora i spojeva na ukupni otpor.', 'Los kontakt uvodi dodatni otpor.', 'pauziran'),
(65, 'Analiza opterecenja senzorskog izlaza', 'Proveriti kako ulaz drugog kola utice na senzor.', 'Ulazna impedansa opterecenja menja izlaz senzora.', 'planiran'),
(66, 'Testiranje analogno-digitalne konverzije', 'Uporediti analogni napon i digitalno ocitavanje.', 'ADC pretvara napon u digitalnu vrednost.', 'u toku'),
(67, 'Merenje greske kvantizacije', 'Odrediti odstupanje zbog ogranicene rezolucije ADC-a.', 'Kvantizacija uvodi diskretne nivoe merenja.', 'zavrsen'),
(68, 'Ispitivanje DAC izlaza', 'Proveriti izlazni napon za zadate digitalne vrednosti.', 'DAC pretvara digitalni kod u analogni napon.', 'pauziran'),
(69, 'Analiza potrosnje elektronskog modula', 'Izmeriti struju modula u mirovanju i pri radu.', 'Potrosnja zavisi od stanja kola.', 'planiran'),
(70, 'Testiranje baterijskog napajanja', 'Pratiti pad napona baterije tokom opterecenja.', 'Kapacitet baterije zavisi od struje potrosnje.', 'u toku'),
(71, 'Ispitivanje punjenja baterije', 'Meriti napon i struju tokom procesa punjenja.', 'Punjenje baterije zahteva kontrolu napona i struje.', 'zavrsen'),
(72, 'Merenje temperature komponente pri radu', 'Posmatrati zagrevanje aktivne komponente tokom opterecenja.', 'Toplotni efekti uticu na pouzdanost sklopa.', 'pauziran'),
(73, 'Ispitivanje hladjenja elektronskog modula', 'Uporediti temperaturu komponente sa i bez hladnjaka.', 'Hladjenje smanjuje radnu temperaturu.', 'planiran'),
(74, 'Analiza kratkog spoja u kontrolisanom uslovu', 'Proveriti reakciju zastitnog sklopa pri kratkom spoju.', 'Prevelika struja zahteva zastitu kola.', 'u toku'),
(75, 'Testiranje ogranicenja struje', 'Proveriti rad sklopa koji ogranicava maksimalnu struju.', 'Ogranicenje struje stiti potrosac i izvor.', 'zavrsen'),
(76, 'Ispitivanje diferencijalnog merenja napona', 'Izmeriti razliku potencijala izmedju dve tacke koje nisu na masi.', 'Diferencijalno merenje smanjuje uticaj zajednickog signala.', 'pauziran'),
(77, 'Analiza mernog mosta', 'Koristiti mostno kolo za precizno merenje otpora.', 'Mostna kola se koriste za detekciju malih promena.', 'planiran'),
(78, 'Ispitivanje Wheatstone-ovog mosta', 'Odrediti nepoznati otpor pomocu uravnotezenja mosta.', 'Ravnoteza mosta zavisi od odnosa otpornika.', 'u toku'),
(79, 'Testiranje kapacitivnog senzora', 'Meriti promenu kapacitivnosti pri promeni rastojanja ili materijala.', 'Kapacitivni senzor reaguje na promenu dielektrika.', 'zavrsen'),
(80, 'Ispitivanje induktivnog senzora', 'Analizirati promenu signala pri prisustvu metalnog objekta.', 'Induktivni senzor koristi elektromagnetnu indukciju.', 'pauziran'),
(81, 'Merenje brzine promene signala', 'Odrediti vreme porasta i vreme opadanja impulsa.', 'Dinamika signala opisuje prelazne pojave.', 'planiran'),
(82, 'Analiza kasnjenja signala kroz kolo', 'Izmeriti vremensko kasnjenje izmedju ulaza i izlaza.', 'Svako realno kolo ima konacno vreme odziva.', 'u toku'),
(83, 'Ispitivanje integratorskog kola', 'Proveriti integraciju ulaznog signala pomocu RC sklopa ili OP pojacavaca.', 'Integrator daje izlaz proporcionalan integralu ulaza.', 'zavrsen'),
(84, 'Ispitivanje diferencijatorskog kola', 'Analizirati izlaz koji prati promenu ulaznog signala.', 'Diferencijator reaguje na brzinu promene signala.', 'pauziran'),
(85, 'Merenje impedanse kola', 'Odrediti odnos napona i struje za naizmenicni signal.', 'Impedansa zavisi od otpornosti, kapacitivnosti i induktivnosti.', 'planiran'),
(86, 'Analiza faznog pomeraja', 'Izmeriti faznu razliku izmedju ulaznog i izlaznog signala.', 'Reaktivni elementi uvode fazni pomeraj.', 'u toku'),
(87, 'Ispitivanje by-pass kondenzatora', 'Proveriti stabilizaciju napajanja pomocu kondenzatora blizu potrosaca.', 'By-pass kondenzator smanjuje smetnje na napajanju.', 'zavrsen'),
(88, 'Testiranje dekupazu napajanja', 'Uporediti rad sklopa sa i bez dekupaznih kondenzatora.', 'Dekupaza poboljsava stabilnost naponske linije.', 'pauziran'),
(89, 'Ispitivanje otvorenog kola', 'Posmatrati napon i struju kada je grana prekinuta.', 'U otvorenom kolu struja kroz prekid je jednaka nuli.', 'planiran'),
(90, 'Ispitivanje kratkospojene grane', 'Analizirati posledice vrlo male otpornosti u jednoj grani.', 'Kratak spoj drasticno povecava struju.', 'u toku'),
(91, 'Poredjenje simulacije i laboratorijskog merenja', 'Uporediti rezultate dobijene proracunom i prakticnim merenjem.', 'Model kola je priblizenje realnog sklopa.', 'zavrsen'),
(92, 'Validacija prototipa mernog modula', 'Proveriti da li modul daje tacna i ponovljiva merenja.', 'Validacija potvrdjuje ispravnost projektovanog sklopa.', 'pauziran'),
(93, 'Ispitivanje stabilnosti senzorskog izlaza', 'Meriti izlaz senzora tokom duzeg vremenskog intervala.', 'Stabilnost signala je bitna za pouzdano merenje.', 'planiran'),
(94, 'Merenje ponovljivosti rezultata', 'Izvesti vise merenja pod istim uslovima i uporediti rezultate.', 'Ponovljivost pokazuje kvalitet mernog postupka.', 'u toku'),
(95, 'Procena merne nesigurnosti', 'Izracunati odstupanja i proceniti nesigurnost merenja.', 'Merenje uvek sadrzi odredjenu gresku.', 'zavrsen'),
(96, 'Automatizovano prikupljanje mernih podataka', 'Prikupiti vise uzoraka signala pomocu mernog sistema.', 'Automatizacija olaksava obradu velikog broja merenja.', 'pauziran'),
(97, 'Ispitivanje zastite ulaza mernog uredjaja', 'Proveriti zastitu pri previsokom ulaznom naponu.', 'Zastitni elementi ogranicavaju napon na ulazu.', 'planiran'),
(98, 'Testiranje signala na prototipskoj plocici', 'Proveriti stabilnost veza i signala na breadboard plocici.', 'Prototipske plocice imaju parazitske otpore i kapacitivnosti.', 'u toku'),
(99, 'Analiza rada kola pri promeni temperature', 'Uporediti rezultate merenja na razlicitim temperaturama okoline.', 'Temperatura menja karakteristike komponenata.', 'zavrsen'),
(100, 'Ispitivanje rada kola pri promeni napajanja', 'Proveriti ponasanje sklopa za nizi i visi ulazni napon.', 'Promena napajanja utice na radne tacke kola.', 'pauziran');

-- --------------------------------------------------------

--
-- Stand-in structure for view `eksperiment_sva_kola`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `eksperiment_sva_kola`;
CREATE TABLE `eksperiment_sva_kola` (
`eksperiment_id` int(11)
,`elektricno_kolo_id` int(11)
,`naziv` varchar(100)
,`sema_kola` mediumtext
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `eksperiment_svi_prototipi`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `eksperiment_svi_prototipi`;
CREATE TABLE `eksperiment_svi_prototipi` (
`eksperiment_id` int(11)
,`prototip_id` int(11)
,`naziv` varchar(100)
,`opis` mediumtext
,`izvor` varchar(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `eksperiment_svi_senzori`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `eksperiment_svi_senzori`;
CREATE TABLE `eksperiment_svi_senzori` (
`eksperiment_id` int(11)
,`senzor_id` int(11)
,`naziv` varchar(50)
,`opis` mediumtext
,`izvor` varchar(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `elektricno_kolo`
--

DROP TABLE IF EXISTS `elektricno_kolo`;
CREATE TABLE `elektricno_kolo` (
  `elektricno_kolo_id` int(11) NOT NULL,
  `sema_kola` text DEFAULT NULL,
  `naziv` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `elektricno_kolo`
--

INSERT INTO `elektricno_kolo` (`elektricno_kolo_id`, `sema_kola`, `naziv`) VALUES
(1, 'SER(R(470Ω), PAR(L(5H), L(100mH)), R(100Ω))', 'Paralelno RLC kolo'),
(2, 'SER(PAR(R(470Ω), L(5H), L(2H), C(220nF)), C(47µF), R(4.7kΩ), PAR(R(2.2kΩ), R(220Ω)))', 'Paralelno RLC kolo'),
(3, 'SER(C(4.7µF), PAR(L(1H), L(100mH)), C(100nF))', 'Kolo za filtriranje signala'),
(4, 'SER(L(470mH), L(100mH), PAR(C(100nF), R(220Ω)), C(10µF), R(2.2kΩ))', 'RLC rezonantno kolo'),
(5, 'SER(L(5H), L(5H), PAR(R(330Ω), C(1µF), C(10µF), L(2H)), PAR(R(470Ω), R(2.2kΩ), C(470nF)))', 'Mesovito RLC kolo'),
(6, 'SER(L(5H), PAR(C(1µF), L(1H), R(1kΩ), R(470Ω)), L(470mH), C(4.7µF))', 'Paralelno RLC kolo'),
(7, 'SER(PAR(L(1H), R(100Ω)), R(330Ω), C(4.7µF), PAR(L(1H), L(470mH), L(100mH)), R(1kΩ))', 'Kolo za filtriranje signala'),
(8, 'SER(PAR(C(100nF), L(5H)), PAR(R(220Ω), L(470mH), L(2H), L(220mH)), PAR(L(2H), R(2.2kΩ)))', 'Mesovito RLC kolo'),
(9, 'SER(PAR(C(220nF), R(470Ω), L(100mH)), PAR(R(330Ω), R(10kΩ), L(220mH)), PAR(C(220nF), L(5H), L(220mH), L(470mH)))', 'RC filter'),
(10, 'SER(L(1H), PAR(R(2.2kΩ), R(470Ω)), R(220Ω), R(470Ω), PAR(C(100nF), L(220mH)))', 'Kolo za filtriranje signala'),
(11, 'SER(PAR(L(2H), L(1H)), PAR(C(220nF), R(220Ω), L(1H)), C(1µF), R(220Ω), PAR(C(47µF), R(470Ω), R(470Ω), L(1H)), PAR(C(1µF), R(220Ω)))', 'Otpornicko-kapacitivno kolo'),
(12, 'SER(PAR(L(100mH), R(470Ω), R(4.7kΩ), C(1µF)), PAR(R(330Ω), C(100nF), C(470nF)), C(470nF), L(2H), C(220nF), PAR(R(100Ω), L(470mH)), PAR(C(4.7µF), L(220mH), R(220Ω), R(220Ω)))', 'RC filter'),
(13, 'SER(R(4.7kΩ), PAR(R(100Ω), L(100mH), C(10µF), L(2H)), C(220nF))', 'Test kolo sa komponentama'),
(14, 'SER(PAR(L(5H), C(1µF)), PAR(R(10kΩ), L(2H)), R(470Ω), R(2.2kΩ))', 'Mesovito RLC kolo'),
(15, 'SER(R(10kΩ), L(470mH), L(2H), PAR(C(10µF), R(330Ω), C(100nF), R(330Ω)))', 'Paralelno RLC kolo'),
(16, 'SER(L(470mH), PAR(C(4.7µF), C(470nF), R(220Ω), L(1H)), R(100Ω), PAR(L(470mH), R(10kΩ)), C(4.7µF))', 'Otpornicko-kapacitivno kolo'),
(17, 'SER(PAR(R(100Ω), C(4.7µF), L(220mH), C(220nF)), PAR(R(2.2kΩ), R(470Ω), L(100mH)), L(1H))', 'Redno RC kolo'),
(18, 'SER(R(330Ω), R(4.7kΩ), PAR(C(47µF), C(47µF), L(5H), R(1kΩ)), PAR(R(4.7kΩ), R(10kΩ), R(470Ω), C(470nF)))', 'Test kolo sa komponentama'),
(19, 'SER(PAR(R(4.7kΩ), C(470nF), R(1kΩ), C(10µF)), L(2H), PAR(R(1kΩ), R(1kΩ)), PAR(C(470nF), L(470mH), C(4.7µF), L(100mH)))', 'Otpornicko-kapacitivno kolo'),
(20, 'SER(PAR(L(1H), R(470Ω)), R(2.2kΩ), L(100mH), C(4.7µF), PAR(C(1µF), L(470mH), L(220mH)), PAR(C(10µF), L(220mH), L(2H), C(1µF)), R(1kΩ))', 'Kolo za filtriranje signala'),
(21, 'SER(L(2H), C(1µF), R(10kΩ), L(220mH))', 'Otpornicko-kapacitivno kolo'),
(22, 'SER(L(2H), PAR(L(470mH), R(470Ω)), PAR(R(10kΩ), L(100mH)), L(2H), PAR(C(1µF), C(220nF), R(100Ω), R(4.7kΩ)))', 'Paralelno RLC kolo'),
(23, 'SER(L(2H), L(220mH), R(10kΩ), PAR(L(2H), L(2H), C(47µF)))', 'Kolo sa kalemovima'),
(24, 'SER(L(1H), L(1H), L(1H), R(1kΩ), L(1H), C(1µF), PAR(R(1kΩ), C(470nF), L(100mH)))', 'RC filter'),
(25, 'SER(PAR(R(470Ω), R(4.7kΩ), C(470nF), L(1H)), R(4.7kΩ), L(5H), PAR(C(1µF), R(2.2kΩ), C(47µF), C(47µF)))', 'Filtraciono kolo'),
(26, 'SER(L(2H), C(220nF), PAR(R(4.7kΩ), C(10µF), L(1H)), C(220nF), L(100mH), L(2H), R(4.7kΩ))', 'Kolo za filtriranje signala'),
(27, 'SER(PAR(C(470nF), R(10kΩ), C(470nF)), C(470nF), C(470nF), C(100nF), R(2.2kΩ), PAR(L(100mH), R(470Ω)))', 'Filtraciono kolo'),
(28, 'SER(R(330Ω), R(470Ω), C(47µF))', 'Kolo sa kalemovima'),
(29, 'SER(L(5H), PAR(C(100nF), L(100mH)), L(5H), C(1µF))', 'Mesovito RLC kolo'),
(30, 'SER(L(220mH), PAR(L(2H), R(100Ω), C(4.7µF)), C(100nF))', 'Kolo sa kalemovima'),
(31, 'SER(PAR(C(100nF), C(470nF), L(1H)), C(220nF), L(470mH), L(1H), L(2H))', 'RLC rezonantno kolo'),
(32, 'SER(R(1kΩ), R(10kΩ), L(1H), PAR(C(220nF), C(220nF), C(47µF)), PAR(L(5H), C(4.7µF), R(470Ω)))', 'Otpornicko-kapacitivno kolo'),
(33, 'SER(C(4.7µF), L(1H), C(1µF), R(1kΩ))', 'Paralelno RLC kolo'),
(34, 'SER(C(10µF), C(4.7µF), C(10µF), C(10µF), C(470nF), PAR(R(2.2kΩ), R(330Ω), R(470Ω), L(1H)))', 'Kolo sa kalemovima'),
(35, 'SER(L(2H), PAR(R(1kΩ), R(2.2kΩ)), PAR(L(2H), R(1kΩ)), PAR(L(470mH), L(220mH)), C(100nF), L(470mH), C(470nF))', 'Otpornicko-kapacitivno kolo'),
(36, 'SER(PAR(R(220Ω), C(1µF), R(100Ω)), PAR(C(100nF), R(220Ω), L(1H), L(2H)), R(4.7kΩ))', 'Filtraciono kolo'),
(37, 'SER(PAR(C(470nF), L(2H), R(220Ω), R(470Ω)), PAR(R(470Ω), R(220Ω)), PAR(C(10µF), L(1H), C(100nF)), PAR(C(10µF), C(100nF), L(220mH), C(47µF)), L(5H), R(4.7kΩ))', 'RC filter'),
(38, 'SER(PAR(C(47µF), R(220Ω)), PAR(L(5H), L(470mH), C(100nF)), C(10µF), C(4.7µF), C(100nF), C(10µF), PAR(R(220Ω), R(100Ω), L(470mH)))', 'Paralelno RLC kolo'),
(39, 'SER(R(10kΩ), C(470nF), PAR(C(10µF), C(100nF), C(470nF), C(470nF)))', 'Test kolo sa komponentama'),
(40, 'SER(C(1µF), C(10µF), L(100mH))', 'Mesovito RLC kolo'),
(41, 'SER(PAR(R(4.7kΩ), L(100mH), L(2H)), R(470Ω), L(1H))', 'RC filter'),
(42, 'SER(PAR(R(1kΩ), C(10µF), C(100nF), R(470Ω)), C(4.7µF), PAR(R(470Ω), R(10kΩ), R(330Ω)))', 'RC filter'),
(43, 'SER(C(1µF), C(220nF), R(4.7kΩ), PAR(L(5H), R(220Ω), C(47µF), C(470nF)), L(470mH))', 'RC filter'),
(44, 'SER(L(2H), C(47µF), PAR(C(470nF), C(4.7µF), L(1H), C(470nF)), L(220mH), R(4.7kΩ))', 'Redno RC kolo'),
(45, 'SER(L(1H), L(5H), C(100nF), PAR(C(47µF), R(10kΩ), R(10kΩ), R(330Ω)), L(220mH))', 'Redno RC kolo'),
(46, 'SER(C(470nF), C(10µF), PAR(L(2H), C(470nF), L(5H)), C(47µF), L(100mH), PAR(C(220nF), L(100mH), C(100nF), L(5H)))', 'Paralelno RLC kolo'),
(47, 'SER(PAR(R(100Ω), C(47µF), R(1kΩ)), C(220nF), PAR(L(5H), R(330Ω), R(220Ω)), C(4.7µF), C(4.7µF), PAR(L(470mH), C(470nF), L(100mH)))', 'Paralelno RLC kolo'),
(48, 'SER(R(220Ω), C(4.7µF), PAR(L(470mH), C(47µF), C(220nF)), C(100nF), PAR(C(4.7µF), C(10µF), C(100nF), L(1H)))', 'RC filter'),
(49, 'SER(L(5H), L(5H), C(47µF))', 'Otpornicko-kapacitivno kolo'),
(50, 'SER(R(470Ω), L(5H), L(220mH), L(5H), PAR(R(2.2kΩ), L(220mH), R(1kΩ)), PAR(R(470Ω), R(2.2kΩ), L(2H)), R(1kΩ))', 'Kolo sa kalemovima'),
(51, 'SER(C(47µF), PAR(R(470Ω), L(5H)), C(47µF), C(100nF), R(1kΩ))', 'RC filter'),
(52, 'SER(L(5H), L(1H), C(100nF))', 'RLC rezonantno kolo'),
(53, 'SER(PAR(C(4.7µF), R(220Ω), L(1H), L(470mH)), R(330Ω), PAR(C(1µF), R(220Ω)), PAR(R(4.7kΩ), C(470nF), L(5H), L(2H)), L(5H), PAR(L(100mH), C(4.7µF), C(470nF)))', 'Kolo sa kalemovima'),
(54, 'SER(PAR(R(2.2kΩ), R(2.2kΩ), L(5H)), C(470nF), PAR(C(100nF), L(220mH)), L(100mH), PAR(R(330Ω), L(220mH), R(470Ω)))', 'Redno RC kolo'),
(55, 'SER(R(2.2kΩ), L(100mH), PAR(R(1kΩ), R(220Ω)), R(330Ω))', 'Test kolo sa komponentama'),
(56, 'SER(R(2.2kΩ), PAR(R(330Ω), L(1H), L(100mH)), C(1µF), L(2H), PAR(R(100Ω), L(5H), L(470mH), C(10µF)))', 'Redno RC kolo'),
(57, 'SER(C(1µF), C(10µF), R(220Ω))', 'Redno RC kolo'),
(58, 'SER(PAR(C(4.7µF), L(2H)), C(1µF), L(470mH), L(1H), PAR(R(470Ω), C(1µF), R(4.7kΩ), C(47µF)), C(10µF), PAR(C(10µF), C(470nF), R(10kΩ)))', 'Mesovito RLC kolo'),
(59, 'SER(R(4.7kΩ), PAR(C(47µF), R(100Ω), L(2H), L(470mH)), C(470nF))', 'Paralelno RLC kolo'),
(60, 'SER(L(470mH), L(2H), PAR(C(220nF), R(2.2kΩ), L(470mH), R(1kΩ)))', 'Kolo za filtriranje signala'),
(61, 'SER(L(2H), L(2H), PAR(L(470mH), R(330Ω), C(10µF), C(470nF)), R(330Ω))', 'Test kolo sa komponentama'),
(62, 'SER(PAR(L(100mH), R(470Ω), C(1µF), C(470nF)), PAR(L(470mH), L(2H), R(100Ω)), PAR(R(220Ω), C(1µF), L(1H), C(4.7µF)), C(220nF), R(2.2kΩ), C(10µF))', 'Test kolo sa komponentama'),
(63, 'SER(C(100nF), PAR(R(100Ω), R(1kΩ), R(330Ω), C(470nF)), PAR(C(10µF), C(220nF)), PAR(L(220mH), L(2H), L(470mH), R(4.7kΩ)), R(4.7kΩ), PAR(C(4.7µF), C(4.7µF)))', 'Test kolo sa komponentama'),
(64, 'SER(PAR(R(2.2kΩ), R(10kΩ), L(470mH)), PAR(R(4.7kΩ), L(1H)), C(47µF), PAR(R(2.2kΩ), R(220Ω), L(5H)), PAR(R(2.2kΩ), C(10µF), L(220mH), R(220Ω)), PAR(R(330Ω), L(100mH)))', 'Kolo za filtriranje signala'),
(65, 'SER(L(2H), L(5H), L(470mH), L(470mH), PAR(C(1µF), L(470mH)), L(100mH))', 'Filtraciono kolo'),
(66, 'SER(PAR(C(100nF), R(2.2kΩ), C(100nF)), R(4.7kΩ), L(5H), C(47µF), R(2.2kΩ), L(220mH), C(100nF))', 'Mesovito RLC kolo'),
(67, 'SER(R(100Ω), PAR(C(4.7µF), L(2H), R(2.2kΩ)), C(1µF))', 'Mesovito RLC kolo'),
(68, 'SER(R(2.2kΩ), PAR(L(5H), C(470nF)), PAR(L(220mH), C(100nF), L(5H), R(2.2kΩ)), PAR(L(5H), C(220nF), L(5H), R(1kΩ)), L(470mH))', 'Kolo za filtriranje signala'),
(69, 'SER(PAR(C(4.7µF), C(100nF), C(470nF), R(470Ω)), PAR(R(470Ω), R(330Ω), R(1kΩ)), R(100Ω), L(220mH), R(330Ω), PAR(L(220mH), L(1H), R(4.7kΩ), C(10µF)), C(4.7µF))', 'Filtraciono kolo'),
(70, 'SER(PAR(C(47µF), C(47µF)), PAR(L(1H), C(47µF), C(47µF), C(4.7µF)), R(470Ω), R(1kΩ), PAR(C(4.7µF), R(220Ω), C(100nF)), C(1µF))', 'Otpornicko-kapacitivno kolo'),
(71, 'SER(R(470Ω), C(100nF), C(4.7µF), C(100nF))', 'RLC rezonantno kolo'),
(72, 'SER(PAR(L(5H), C(47µF)), PAR(C(47µF), C(10µF)), L(1H), R(220Ω))', 'Mesovito RLC kolo'),
(73, 'SER(PAR(L(5H), L(2H)), C(220nF), PAR(R(4.7kΩ), L(2H)), R(10kΩ), R(470Ω))', 'Redno RC kolo'),
(74, 'SER(L(470mH), PAR(R(220Ω), L(470mH), R(100Ω)), C(100nF), C(470nF), C(47µF))', 'Filtraciono kolo'),
(75, 'SER(PAR(L(100mH), L(5H), C(220nF), R(2.2kΩ)), L(220mH), L(1H), C(10µF), PAR(R(10kΩ), R(1kΩ)))', 'Paralelno RLC kolo'),
(76, 'SER(R(2.2kΩ), L(1H), L(1H))', 'Kolo sa kalemovima'),
(77, 'SER(R(1kΩ), R(2.2kΩ), PAR(C(1µF), L(1H), C(470nF)))', 'Otpornicko-kapacitivno kolo'),
(78, 'SER(C(47µF), R(4.7kΩ), PAR(R(1kΩ), C(100nF), R(2.2kΩ), L(470mH)), PAR(L(1H), R(10kΩ), C(1µF), R(2.2kΩ)), C(470nF), R(220Ω))', 'Filtraciono kolo'),
(79, 'SER(L(5H), PAR(R(10kΩ), R(330Ω)), PAR(C(470nF), C(4.7µF), R(330Ω), L(1H)), C(1µF), L(220mH))', 'Kolo za filtriranje signala'),
(80, 'SER(L(470mH), PAR(R(330Ω), C(4.7µF)), L(100mH), PAR(L(1H), R(1kΩ), L(1H)), PAR(R(10kΩ), R(10kΩ)))', 'RLC rezonantno kolo'),
(81, 'SER(L(100mH), C(470nF), L(5H), L(220mH), L(220mH))', 'Paralelno RLC kolo'),
(82, 'SER(R(10kΩ), PAR(L(470mH), C(47µF), L(220mH), L(100mH)), PAR(L(5H), C(4.7µF), C(47µF)), L(100mH))', 'Paralelno RLC kolo'),
(83, 'SER(C(1µF), C(220nF), L(5H), R(4.7kΩ), R(220Ω))', 'Filtraciono kolo'),
(84, 'SER(PAR(C(10µF), R(2.2kΩ)), L(470mH), C(220nF), L(470mH))', 'RLC rezonantno kolo'),
(85, 'SER(R(330Ω), L(220mH), PAR(L(2H), C(47µF), L(100mH), R(220Ω)), PAR(L(470mH), L(220mH), L(1H), L(5H)), PAR(L(470mH), L(470mH), C(220nF), L(1H)))', 'Filtraciono kolo'),
(86, 'SER(PAR(R(10kΩ), C(1µF)), C(4.7µF), PAR(C(10µF), C(1µF), R(2.2kΩ), L(2H)), PAR(C(100nF), C(1µF)), PAR(R(1kΩ), C(47µF)), R(330Ω))', 'Otpornicko-kapacitivno kolo'),
(87, 'SER(R(330Ω), L(1H), C(1µF), PAR(L(1H), R(470Ω), L(470mH)), PAR(C(4.7µF), L(5H), C(470nF)), R(4.7kΩ), PAR(L(470mH), C(470nF), R(4.7kΩ)))', 'Mesovito RLC kolo'),
(88, 'SER(C(4.7µF), PAR(L(1H), L(470mH), L(5H)), R(220Ω), C(4.7µF), R(470Ω), C(4.7µF), PAR(R(2.2kΩ), C(4.7µF)))', 'Redno RC kolo'),
(89, 'SER(L(220mH), PAR(C(220nF), C(4.7µF), L(470mH), L(470mH)), L(2H), L(470mH))', 'RC filter'),
(90, 'SER(L(100mH), L(470mH), L(5H))', 'RC filter'),
(91, 'SER(L(2H), L(100mH), R(4.7kΩ), PAR(R(100Ω), L(5H), R(470Ω), R(10kΩ)), PAR(C(10µF), R(4.7kΩ)), L(1H), L(5H))', 'Redno RC kolo'),
(92, 'SER(L(470mH), C(4.7µF), R(10kΩ), C(4.7µF))', 'Redno RC kolo'),
(93, 'SER(R(470Ω), PAR(R(1kΩ), C(10µF), R(10kΩ)), PAR(L(5H), C(470nF), R(4.7kΩ)), C(47µF), PAR(C(100nF), C(10µF)))', 'Mesovito RLC kolo'),
(94, 'SER(L(470mH), R(470Ω), C(4.7µF), R(220Ω), L(220mH))', 'Paralelno RLC kolo'),
(95, 'SER(L(220mH), R(220Ω), L(1H))', 'Kolo sa kalemovima'),
(96, 'SER(PAR(R(4.7kΩ), L(1H), C(10µF), R(1kΩ)), PAR(R(220Ω), L(2H), R(100Ω), R(4.7kΩ)), R(100Ω), C(47µF))', 'Paralelno RLC kolo'),
(97, 'SER(C(100nF), PAR(L(100mH), C(470nF), C(10µF), L(2H)), R(10kΩ), PAR(C(220nF), L(1H)))', 'RC filter'),
(98, 'SER(PAR(C(4.7µF), L(220mH), R(4.7kΩ)), L(470mH), PAR(R(330Ω), R(10kΩ), C(220nF), R(1kΩ)), C(47µF))', 'Otpornicko-kapacitivno kolo'),
(99, 'SER(PAR(L(100mH), C(10µF), C(10µF), R(100Ω)), C(470nF), PAR(L(5H), C(10µF), R(1kΩ), C(4.7µF)), PAR(C(220nF), C(10µF)), C(1µF))', 'Otpornicko-kapacitivno kolo'),
(100, 'SER(L(220mH), L(2H), R(10kΩ), C(100nF), R(100Ω), L(220mH))', 'RLC rezonantno kolo');

-- --------------------------------------------------------

--
-- Table structure for table `inventar_resursa`
--

DROP TABLE IF EXISTS `inventar_resursa`;
CREATE TABLE `inventar_resursa` (
  `laboratorija_id` int(11) NOT NULL,
  `resurs_id` int(11) NOT NULL,
  `dostupna_kolicina` decimal(15,4) NOT NULL DEFAULT 0.0000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventar_resursa`
--

INSERT INTO `inventar_resursa` (`laboratorija_id`, `resurs_id`, `dostupna_kolicina`) VALUES
(1, 7, 24.0000),
(2, 14, 244.0000),
(3, 21, 51.0000),
(4, 28, 39.0000),
(5, 35, 190.0000),
(6, 42, 78.0000),
(7, 49, 216.0000),
(8, 56, 21.0000),
(9, 63, 192.0000),
(10, 70, 48.0000),
(11, 77, 78.0000),
(12, 84, 23.0000),
(13, 91, 91.0000),
(14, 98, 235.0000),
(15, 5, 185.0000),
(16, 12, 237.0000),
(17, 19, 248.0000),
(18, 26, 222.0000),
(19, 33, 170.0000),
(20, 40, 121.0000),
(21, 47, 139.0000),
(22, 54, 99.0000),
(23, 61, 100.0000),
(24, 68, 129.0000),
(25, 75, 104.0000),
(26, 82, 82.0000),
(27, 89, 185.0000),
(28, 96, 244.0000),
(29, 3, 110.0000),
(30, 10, 137.0000),
(31, 17, 198.0000),
(32, 24, 162.0000),
(33, 31, 11.0000),
(34, 38, 162.0000),
(35, 45, 66.0000),
(36, 52, 11.0000),
(37, 59, 245.0000),
(38, 66, 60.0000),
(39, 73, 132.0000),
(40, 80, 181.0000),
(41, 87, 4.0000),
(42, 94, 147.0000),
(43, 1, 119.0000),
(44, 8, 215.0000),
(45, 15, 58.0000),
(46, 22, 14.0000),
(47, 29, 97.0000),
(48, 36, 60.0000),
(49, 43, 23.0000),
(50, 50, 129.0000),
(51, 57, 165.0000),
(52, 64, 192.0000),
(53, 71, 110.0000),
(54, 78, 50.0000),
(55, 85, 59.0000),
(56, 92, 196.0000),
(57, 99, 53.0000),
(58, 6, 106.0000),
(59, 13, 44.0000),
(60, 20, 79.0000),
(61, 27, 85.0000),
(62, 34, 213.0000),
(63, 41, 3.0000),
(64, 48, 28.0000),
(65, 55, 212.0000),
(66, 62, 240.0000),
(67, 69, 106.0000),
(68, 76, 80.0000),
(69, 83, 84.0000),
(70, 90, 93.0000),
(71, 97, 159.0000),
(72, 4, 52.0000),
(73, 11, 62.0000),
(74, 18, 120.0000),
(75, 25, 45.0000),
(76, 32, 216.0000),
(77, 39, 43.0000),
(78, 46, 57.0000),
(79, 53, 80.0000),
(80, 60, 142.0000),
(81, 67, 42.0000),
(82, 74, 113.0000),
(83, 81, 54.0000),
(84, 88, 78.0000),
(85, 95, 163.0000),
(86, 2, 34.0000),
(87, 9, 212.0000),
(88, 16, 179.0000),
(89, 23, 184.0000),
(90, 30, 107.0000),
(91, 37, 212.0000),
(92, 44, 121.0000),
(93, 51, 150.0000),
(94, 58, 155.0000),
(95, 65, 190.0000),
(96, 72, 28.0000),
(97, 79, 103.0000),
(98, 86, 210.0000),
(99, 93, 169.0000),
(100, 100, 229.0000);

-- --------------------------------------------------------

--
-- Table structure for table `ispitivanje`
--

DROP TABLE IF EXISTS `ispitivanje`;
CREATE TABLE `ispitivanje` (
  `ispitivanje_id` int(11) NOT NULL,
  `rezultat` text DEFAULT NULL,
  `izvodjenje_id` int(11) NOT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ispitivanje`
--

INSERT INTO `ispitivanje` (`ispitivanje_id`, `rezultat`, `izvodjenje_id`, `opis`) VALUES
(1, 'Elementi su pravilno povezani. Redni broj ispitivanja: 1.', 1, 'Vizuelna provera električnog kola broj 1.'),
(2, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 2.', 2, 'Funkcionalno ispitivanje električnog kola broj 2.'),
(3, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 3.', 3, 'Ispitivanje stabilnosti električnog kola broj 3.'),
(4, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 4.', 4, 'Provera odziva električnog kola broj 4.'),
(5, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 5.', 5, 'Završna provera električnog kola broj 5.'),
(6, 'Elementi su pravilno povezani. Redni broj ispitivanja: 6.', 6, 'Vizuelna provera električnog kola broj 6.'),
(7, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 7.', 7, 'Funkcionalno ispitivanje električnog kola broj 7.'),
(8, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 8.', 8, 'Ispitivanje stabilnosti električnog kola broj 8.'),
(9, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 9.', 9, 'Provera odziva električnog kola broj 9.'),
(10, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 10.', 10, 'Završna provera električnog kola broj 10.'),
(11, 'Elementi su pravilno povezani. Redni broj ispitivanja: 11.', 11, 'Vizuelna provera električnog kola broj 11.'),
(12, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 12.', 12, 'Funkcionalno ispitivanje električnog kola broj 12.'),
(13, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 13.', 13, 'Ispitivanje stabilnosti električnog kola broj 13.'),
(14, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 14.', 14, 'Provera odziva električnog kola broj 14.'),
(15, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 15.', 15, 'Završna provera električnog kola broj 15.'),
(16, 'Elementi su pravilno povezani. Redni broj ispitivanja: 16.', 16, 'Vizuelna provera električnog kola broj 16.'),
(17, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 17.', 17, 'Funkcionalno ispitivanje električnog kola broj 17.'),
(18, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 18.', 18, 'Ispitivanje stabilnosti električnog kola broj 18.'),
(19, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 19.', 19, 'Provera odziva električnog kola broj 19.'),
(20, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 20.', 20, 'Završna provera električnog kola broj 20.'),
(21, 'Elementi su pravilno povezani. Redni broj ispitivanja: 21.', 1, 'Vizuelna provera električnog kola broj 21.'),
(22, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 22.', 2, 'Funkcionalno ispitivanje električnog kola broj 22.'),
(23, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 23.', 3, 'Ispitivanje stabilnosti električnog kola broj 23.'),
(24, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 24.', 4, 'Provera odziva električnog kola broj 24.'),
(25, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 25.', 5, 'Završna provera električnog kola broj 25.'),
(26, 'Elementi su pravilno povezani. Redni broj ispitivanja: 26.', 6, 'Vizuelna provera električnog kola broj 26.'),
(27, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 27.', 7, 'Funkcionalno ispitivanje električnog kola broj 27.'),
(28, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 28.', 8, 'Ispitivanje stabilnosti električnog kola broj 28.'),
(29, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 29.', 9, 'Provera odziva električnog kola broj 29.'),
(30, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 30.', 10, 'Završna provera električnog kola broj 30.'),
(31, 'Elementi su pravilno povezani. Redni broj ispitivanja: 31.', 11, 'Vizuelna provera električnog kola broj 31.'),
(32, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 32.', 12, 'Funkcionalno ispitivanje električnog kola broj 32.'),
(33, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 33.', 13, 'Ispitivanje stabilnosti električnog kola broj 33.'),
(34, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 34.', 14, 'Provera odziva električnog kola broj 34.'),
(35, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 35.', 15, 'Završna provera električnog kola broj 35.'),
(36, 'Elementi su pravilno povezani. Redni broj ispitivanja: 36.', 16, 'Vizuelna provera električnog kola broj 36.'),
(37, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 37.', 17, 'Funkcionalno ispitivanje električnog kola broj 37.'),
(38, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 38.', 18, 'Ispitivanje stabilnosti električnog kola broj 38.'),
(39, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 39.', 19, 'Provera odziva električnog kola broj 39.'),
(40, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 40.', 20, 'Završna provera električnog kola broj 40.'),
(41, 'Elementi su pravilno povezani. Redni broj ispitivanja: 41.', 1, 'Vizuelna provera električnog kola broj 41.'),
(42, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 42.', 2, 'Funkcionalno ispitivanje električnog kola broj 42.'),
(43, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 43.', 3, 'Ispitivanje stabilnosti električnog kola broj 43.'),
(44, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 44.', 4, 'Provera odziva električnog kola broj 44.'),
(45, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 45.', 5, 'Završna provera električnog kola broj 45.'),
(46, 'Elementi su pravilno povezani. Redni broj ispitivanja: 46.', 6, 'Vizuelna provera električnog kola broj 46.'),
(47, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 47.', 7, 'Funkcionalno ispitivanje električnog kola broj 47.'),
(48, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 48.', 8, 'Ispitivanje stabilnosti električnog kola broj 48.'),
(49, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 49.', 9, 'Provera odziva električnog kola broj 49.'),
(50, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 50.', 10, 'Završna provera električnog kola broj 50.'),
(51, 'Elementi su pravilno povezani. Redni broj ispitivanja: 51.', 11, 'Vizuelna provera električnog kola broj 51.'),
(52, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 52.', 12, 'Funkcionalno ispitivanje električnog kola broj 52.'),
(53, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 53.', 13, 'Ispitivanje stabilnosti električnog kola broj 53.'),
(54, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 54.', 14, 'Provera odziva električnog kola broj 54.'),
(55, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 55.', 15, 'Završna provera električnog kola broj 55.'),
(56, 'Elementi su pravilno povezani. Redni broj ispitivanja: 56.', 16, 'Vizuelna provera električnog kola broj 56.'),
(57, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 57.', 17, 'Funkcionalno ispitivanje električnog kola broj 57.'),
(58, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 58.', 18, 'Ispitivanje stabilnosti električnog kola broj 58.'),
(59, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 59.', 19, 'Provera odziva električnog kola broj 59.'),
(60, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 60.', 20, 'Završna provera električnog kola broj 60.'),
(61, 'Elementi su pravilno povezani. Redni broj ispitivanja: 61.', 1, 'Vizuelna provera električnog kola broj 61.'),
(62, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 62.', 2, 'Funkcionalno ispitivanje električnog kola broj 62.'),
(63, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 63.', 3, 'Ispitivanje stabilnosti električnog kola broj 63.'),
(64, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 64.', 4, 'Provera odziva električnog kola broj 64.'),
(65, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 65.', 5, 'Završna provera električnog kola broj 65.'),
(66, 'Elementi su pravilno povezani. Redni broj ispitivanja: 66.', 6, 'Vizuelna provera električnog kola broj 66.'),
(67, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 67.', 7, 'Funkcionalno ispitivanje električnog kola broj 67.'),
(68, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 68.', 8, 'Ispitivanje stabilnosti električnog kola broj 68.'),
(69, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 69.', 9, 'Provera odziva električnog kola broj 69.'),
(70, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 70.', 10, 'Završna provera električnog kola broj 70.'),
(71, 'Elementi su pravilno povezani. Redni broj ispitivanja: 71.', 11, 'Vizuelna provera električnog kola broj 71.'),
(72, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 72.', 12, 'Funkcionalno ispitivanje električnog kola broj 72.'),
(73, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 73.', 13, 'Ispitivanje stabilnosti električnog kola broj 73.'),
(74, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 74.', 14, 'Provera odziva električnog kola broj 74.'),
(75, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 75.', 15, 'Završna provera električnog kola broj 75.'),
(76, 'Elementi su pravilno povezani. Redni broj ispitivanja: 76.', 16, 'Vizuelna provera električnog kola broj 76.'),
(77, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 77.', 17, 'Funkcionalno ispitivanje električnog kola broj 77.'),
(78, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 78.', 18, 'Ispitivanje stabilnosti električnog kola broj 78.'),
(79, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 79.', 19, 'Provera odziva električnog kola broj 79.'),
(80, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 80.', 20, 'Završna provera električnog kola broj 80.'),
(81, 'Elementi su pravilno povezani. Redni broj ispitivanja: 81.', 1, 'Vizuelna provera električnog kola broj 81.'),
(82, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 82.', 2, 'Funkcionalno ispitivanje električnog kola broj 82.'),
(83, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 83.', 3, 'Ispitivanje stabilnosti električnog kola broj 83.'),
(84, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 84.', 4, 'Provera odziva električnog kola broj 84.'),
(85, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 85.', 5, 'Završna provera električnog kola broj 85.'),
(86, 'Elementi su pravilno povezani. Redni broj ispitivanja: 86.', 6, 'Vizuelna provera električnog kola broj 86.'),
(87, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 87.', 7, 'Funkcionalno ispitivanje električnog kola broj 87.'),
(88, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 88.', 8, 'Ispitivanje stabilnosti električnog kola broj 88.'),
(89, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 89.', 9, 'Provera odziva električnog kola broj 89.'),
(90, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 90.', 10, 'Završna provera električnog kola broj 90.'),
(91, 'Elementi su pravilno povezani. Redni broj ispitivanja: 91.', 11, 'Vizuelna provera električnog kola broj 91.'),
(92, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 92.', 12, 'Funkcionalno ispitivanje električnog kola broj 92.'),
(93, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 93.', 13, 'Ispitivanje stabilnosti električnog kola broj 93.'),
(94, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 94.', 14, 'Provera odziva električnog kola broj 94.'),
(95, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 95.', 15, 'Završna provera električnog kola broj 95.'),
(96, 'Elementi su pravilno povezani. Redni broj ispitivanja: 96.', 16, 'Vizuelna provera električnog kola broj 96.'),
(97, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 97.', 17, 'Funkcionalno ispitivanje električnog kola broj 97.'),
(98, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 98.', 18, 'Ispitivanje stabilnosti električnog kola broj 98.'),
(99, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 99.', 19, 'Provera odziva električnog kola broj 99.'),
(100, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 100.', 20, 'Završna provera električnog kola broj 100.'),
(101, 'Elementi su pravilno povezani. Redni broj ispitivanja: 101.', 1, 'Vizuelna provera senzora broj 101.'),
(102, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 102.', 2, 'Funkcionalno ispitivanje senzora broj 102.'),
(103, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 103.', 3, 'Ispitivanje stabilnosti senzora broj 103.'),
(104, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 104.', 4, 'Provera odziva senzora broj 104.'),
(105, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 105.', 5, 'Završna provera senzora broj 105.'),
(106, 'Elementi su pravilno povezani. Redni broj ispitivanja: 106.', 6, 'Vizuelna provera senzora broj 106.'),
(107, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 107.', 7, 'Funkcionalno ispitivanje senzora broj 107.'),
(108, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 108.', 8, 'Ispitivanje stabilnosti senzora broj 108.'),
(109, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 109.', 9, 'Provera odziva senzora broj 109.'),
(110, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 110.', 10, 'Završna provera senzora broj 110.'),
(111, 'Elementi su pravilno povezani. Redni broj ispitivanja: 111.', 11, 'Vizuelna provera senzora broj 111.'),
(112, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 112.', 12, 'Funkcionalno ispitivanje senzora broj 112.'),
(113, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 113.', 13, 'Ispitivanje stabilnosti senzora broj 113.'),
(114, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 114.', 14, 'Provera odziva senzora broj 114.'),
(115, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 115.', 15, 'Završna provera senzora broj 115.'),
(116, 'Elementi su pravilno povezani. Redni broj ispitivanja: 116.', 16, 'Vizuelna provera senzora broj 116.'),
(117, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 117.', 17, 'Funkcionalno ispitivanje senzora broj 117.'),
(118, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 118.', 18, 'Ispitivanje stabilnosti senzora broj 118.'),
(119, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 119.', 19, 'Provera odziva senzora broj 119.'),
(120, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 120.', 20, 'Završna provera senzora broj 120.'),
(121, 'Elementi su pravilno povezani. Redni broj ispitivanja: 121.', 1, 'Vizuelna provera senzora broj 121.'),
(122, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 122.', 2, 'Funkcionalno ispitivanje senzora broj 122.'),
(123, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 123.', 3, 'Ispitivanje stabilnosti senzora broj 123.'),
(124, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 124.', 4, 'Provera odziva senzora broj 124.'),
(125, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 125.', 5, 'Završna provera senzora broj 125.'),
(126, 'Elementi su pravilno povezani. Redni broj ispitivanja: 126.', 6, 'Vizuelna provera senzora broj 126.'),
(127, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 127.', 7, 'Funkcionalno ispitivanje senzora broj 127.'),
(128, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 128.', 8, 'Ispitivanje stabilnosti senzora broj 128.'),
(129, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 129.', 9, 'Provera odziva senzora broj 129.'),
(130, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 130.', 10, 'Završna provera senzora broj 130.'),
(131, 'Elementi su pravilno povezani. Redni broj ispitivanja: 131.', 11, 'Vizuelna provera senzora broj 131.'),
(132, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 132.', 12, 'Funkcionalno ispitivanje senzora broj 132.'),
(133, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 133.', 13, 'Ispitivanje stabilnosti senzora broj 133.'),
(134, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 134.', 14, 'Provera odziva senzora broj 134.'),
(135, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 135.', 15, 'Završna provera senzora broj 135.'),
(136, 'Elementi su pravilno povezani. Redni broj ispitivanja: 136.', 16, 'Vizuelna provera senzora broj 136.'),
(137, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 137.', 17, 'Funkcionalno ispitivanje senzora broj 137.'),
(138, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 138.', 18, 'Ispitivanje stabilnosti senzora broj 138.'),
(139, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 139.', 19, 'Provera odziva senzora broj 139.'),
(140, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 140.', 20, 'Završna provera senzora broj 140.'),
(141, 'Elementi su pravilno povezani. Redni broj ispitivanja: 141.', 1, 'Vizuelna provera senzora broj 141.'),
(142, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 142.', 2, 'Funkcionalno ispitivanje senzora broj 142.'),
(143, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 143.', 3, 'Ispitivanje stabilnosti senzora broj 143.'),
(144, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 144.', 4, 'Provera odziva senzora broj 144.'),
(145, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 145.', 5, 'Završna provera senzora broj 145.'),
(146, 'Elementi su pravilno povezani. Redni broj ispitivanja: 146.', 6, 'Vizuelna provera senzora broj 146.'),
(147, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 147.', 7, 'Funkcionalno ispitivanje senzora broj 147.'),
(148, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 148.', 8, 'Ispitivanje stabilnosti senzora broj 148.'),
(149, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 149.', 9, 'Provera odziva senzora broj 149.'),
(150, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 150.', 10, 'Završna provera senzora broj 150.'),
(151, 'Elementi su pravilno povezani. Redni broj ispitivanja: 151.', 11, 'Vizuelna provera senzora broj 151.'),
(152, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 152.', 12, 'Funkcionalno ispitivanje senzora broj 152.'),
(153, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 153.', 13, 'Ispitivanje stabilnosti senzora broj 153.'),
(154, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 154.', 14, 'Provera odziva senzora broj 154.'),
(155, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 155.', 15, 'Završna provera senzora broj 155.'),
(156, 'Elementi su pravilno povezani. Redni broj ispitivanja: 156.', 16, 'Vizuelna provera senzora broj 156.'),
(157, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 157.', 17, 'Funkcionalno ispitivanje senzora broj 157.'),
(158, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 158.', 18, 'Ispitivanje stabilnosti senzora broj 158.'),
(159, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 159.', 19, 'Provera odziva senzora broj 159.'),
(160, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 160.', 20, 'Završna provera senzora broj 160.'),
(161, 'Elementi su pravilno povezani. Redni broj ispitivanja: 161.', 1, 'Vizuelna provera senzora broj 161.'),
(162, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 162.', 2, 'Funkcionalno ispitivanje senzora broj 162.'),
(163, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 163.', 3, 'Ispitivanje stabilnosti senzora broj 163.'),
(164, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 164.', 4, 'Provera odziva senzora broj 164.'),
(165, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 165.', 5, 'Završna provera senzora broj 165.'),
(166, 'Elementi su pravilno povezani. Redni broj ispitivanja: 166.', 6, 'Vizuelna provera senzora broj 166.'),
(167, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 167.', 7, 'Funkcionalno ispitivanje senzora broj 167.'),
(168, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 168.', 8, 'Ispitivanje stabilnosti senzora broj 168.'),
(169, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 169.', 9, 'Provera odziva senzora broj 169.'),
(170, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 170.', 10, 'Završna provera senzora broj 170.'),
(171, 'Elementi su pravilno povezani. Redni broj ispitivanja: 171.', 11, 'Vizuelna provera senzora broj 171.'),
(172, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 172.', 12, 'Funkcionalno ispitivanje senzora broj 172.'),
(173, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 173.', 13, 'Ispitivanje stabilnosti senzora broj 173.'),
(174, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 174.', 14, 'Provera odziva senzora broj 174.'),
(175, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 175.', 15, 'Završna provera senzora broj 175.'),
(176, 'Elementi su pravilno povezani. Redni broj ispitivanja: 176.', 16, 'Vizuelna provera senzora broj 176.'),
(177, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 177.', 17, 'Funkcionalno ispitivanje senzora broj 177.'),
(178, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 178.', 18, 'Ispitivanje stabilnosti senzora broj 178.'),
(179, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 179.', 19, 'Provera odziva senzora broj 179.'),
(180, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 180.', 20, 'Završna provera senzora broj 180.'),
(181, 'Elementi su pravilno povezani. Redni broj ispitivanja: 181.', 1, 'Vizuelna provera senzora broj 181.'),
(182, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 182.', 2, 'Funkcionalno ispitivanje senzora broj 182.'),
(183, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 183.', 3, 'Ispitivanje stabilnosti senzora broj 183.'),
(184, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 184.', 4, 'Provera odziva senzora broj 184.'),
(185, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 185.', 5, 'Završna provera senzora broj 185.'),
(186, 'Elementi su pravilno povezani. Redni broj ispitivanja: 186.', 6, 'Vizuelna provera senzora broj 186.'),
(187, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 187.', 7, 'Funkcionalno ispitivanje senzora broj 187.'),
(188, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 188.', 8, 'Ispitivanje stabilnosti senzora broj 188.'),
(189, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 189.', 9, 'Provera odziva senzora broj 189.'),
(190, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 190.', 10, 'Završna provera senzora broj 190.'),
(191, 'Elementi su pravilno povezani. Redni broj ispitivanja: 191.', 11, 'Vizuelna provera senzora broj 191.'),
(192, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 192.', 12, 'Funkcionalno ispitivanje senzora broj 192.'),
(193, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 193.', 13, 'Ispitivanje stabilnosti senzora broj 193.'),
(194, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 194.', 14, 'Provera odziva senzora broj 194.'),
(195, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 195.', 15, 'Završna provera senzora broj 195.'),
(196, 'Elementi su pravilno povezani. Redni broj ispitivanja: 196.', 16, 'Vizuelna provera senzora broj 196.'),
(197, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 197.', 17, 'Funkcionalno ispitivanje senzora broj 197.'),
(198, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 198.', 18, 'Ispitivanje stabilnosti senzora broj 198.'),
(199, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 199.', 19, 'Provera odziva senzora broj 199.'),
(200, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 200.', 20, 'Završna provera senzora broj 200.'),
(201, 'Elementi su pravilno povezani. Redni broj ispitivanja: 201.', 1, 'Vizuelna provera prototipa broj 201.'),
(202, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 202.', 2, 'Funkcionalno ispitivanje prototipa broj 202.'),
(203, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 203.', 3, 'Ispitivanje stabilnosti prototipa broj 203.'),
(204, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 204.', 4, 'Provera odziva prototipa broj 204.'),
(205, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 205.', 5, 'Završna provera prototipa broj 205.'),
(206, 'Elementi su pravilno povezani. Redni broj ispitivanja: 206.', 6, 'Vizuelna provera prototipa broj 206.'),
(207, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 207.', 7, 'Funkcionalno ispitivanje prototipa broj 207.'),
(208, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 208.', 8, 'Ispitivanje stabilnosti prototipa broj 208.'),
(209, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 209.', 9, 'Provera odziva prototipa broj 209.'),
(210, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 210.', 10, 'Završna provera prototipa broj 210.'),
(211, 'Elementi su pravilno povezani. Redni broj ispitivanja: 211.', 11, 'Vizuelna provera prototipa broj 211.'),
(212, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 212.', 12, 'Funkcionalno ispitivanje prototipa broj 212.'),
(213, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 213.', 13, 'Ispitivanje stabilnosti prototipa broj 213.'),
(214, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 214.', 14, 'Provera odziva prototipa broj 214.'),
(215, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 215.', 15, 'Završna provera prototipa broj 215.'),
(216, 'Elementi su pravilno povezani. Redni broj ispitivanja: 216.', 16, 'Vizuelna provera prototipa broj 216.'),
(217, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 217.', 17, 'Funkcionalno ispitivanje prototipa broj 217.'),
(218, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 218.', 18, 'Ispitivanje stabilnosti prototipa broj 218.'),
(219, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 219.', 19, 'Provera odziva prototipa broj 219.'),
(220, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 220.', 20, 'Završna provera prototipa broj 220.'),
(221, 'Elementi su pravilno povezani. Redni broj ispitivanja: 221.', 1, 'Vizuelna provera prototipa broj 221.'),
(222, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 222.', 2, 'Funkcionalno ispitivanje prototipa broj 222.'),
(223, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 223.', 3, 'Ispitivanje stabilnosti prototipa broj 223.'),
(224, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 224.', 4, 'Provera odziva prototipa broj 224.'),
(225, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 225.', 5, 'Završna provera prototipa broj 225.'),
(226, 'Elementi su pravilno povezani. Redni broj ispitivanja: 226.', 6, 'Vizuelna provera prototipa broj 226.'),
(227, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 227.', 7, 'Funkcionalno ispitivanje prototipa broj 227.'),
(228, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 228.', 8, 'Ispitivanje stabilnosti prototipa broj 228.'),
(229, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 229.', 9, 'Provera odziva prototipa broj 229.'),
(230, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 230.', 10, 'Završna provera prototipa broj 230.'),
(231, 'Elementi su pravilno povezani. Redni broj ispitivanja: 231.', 11, 'Vizuelna provera prototipa broj 231.'),
(232, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 232.', 12, 'Funkcionalno ispitivanje prototipa broj 232.'),
(233, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 233.', 13, 'Ispitivanje stabilnosti prototipa broj 233.'),
(234, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 234.', 14, 'Provera odziva prototipa broj 234.'),
(235, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 235.', 15, 'Završna provera prototipa broj 235.'),
(236, 'Elementi su pravilno povezani. Redni broj ispitivanja: 236.', 16, 'Vizuelna provera prototipa broj 236.'),
(237, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 237.', 17, 'Funkcionalno ispitivanje prototipa broj 237.'),
(238, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 238.', 18, 'Ispitivanje stabilnosti prototipa broj 238.'),
(239, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 239.', 19, 'Provera odziva prototipa broj 239.'),
(240, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 240.', 20, 'Završna provera prototipa broj 240.'),
(241, 'Elementi su pravilno povezani. Redni broj ispitivanja: 241.', 1, 'Vizuelna provera prototipa broj 241.'),
(242, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 242.', 2, 'Funkcionalno ispitivanje prototipa broj 242.'),
(243, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 243.', 3, 'Ispitivanje stabilnosti prototipa broj 243.'),
(244, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 244.', 4, 'Provera odziva prototipa broj 244.'),
(245, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 245.', 5, 'Završna provera prototipa broj 245.'),
(246, 'Elementi su pravilno povezani. Redni broj ispitivanja: 246.', 6, 'Vizuelna provera prototipa broj 246.'),
(247, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 247.', 7, 'Funkcionalno ispitivanje prototipa broj 247.'),
(248, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 248.', 8, 'Ispitivanje stabilnosti prototipa broj 248.'),
(249, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 249.', 9, 'Provera odziva prototipa broj 249.'),
(250, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 250.', 10, 'Završna provera prototipa broj 250.'),
(251, 'Elementi su pravilno povezani. Redni broj ispitivanja: 251.', 11, 'Vizuelna provera prototipa broj 251.'),
(252, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 252.', 12, 'Funkcionalno ispitivanje prototipa broj 252.'),
(253, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 253.', 13, 'Ispitivanje stabilnosti prototipa broj 253.'),
(254, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 254.', 14, 'Provera odziva prototipa broj 254.'),
(255, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 255.', 15, 'Završna provera prototipa broj 255.'),
(256, 'Elementi su pravilno povezani. Redni broj ispitivanja: 256.', 16, 'Vizuelna provera prototipa broj 256.'),
(257, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 257.', 17, 'Funkcionalno ispitivanje prototipa broj 257.'),
(258, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 258.', 18, 'Ispitivanje stabilnosti prototipa broj 258.'),
(259, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 259.', 19, 'Provera odziva prototipa broj 259.'),
(260, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 260.', 20, 'Završna provera prototipa broj 260.'),
(261, 'Elementi su pravilno povezani. Redni broj ispitivanja: 261.', 1, 'Vizuelna provera prototipa broj 261.'),
(262, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 262.', 2, 'Funkcionalno ispitivanje prototipa broj 262.'),
(263, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 263.', 3, 'Ispitivanje stabilnosti prototipa broj 263.'),
(264, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 264.', 4, 'Provera odziva prototipa broj 264.'),
(265, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 265.', 5, 'Završna provera prototipa broj 265.'),
(266, 'Elementi su pravilno povezani. Redni broj ispitivanja: 266.', 6, 'Vizuelna provera prototipa broj 266.'),
(267, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 267.', 7, 'Funkcionalno ispitivanje prototipa broj 267.'),
(268, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 268.', 8, 'Ispitivanje stabilnosti prototipa broj 268.'),
(269, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 269.', 9, 'Provera odziva prototipa broj 269.'),
(270, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 270.', 10, 'Završna provera prototipa broj 270.'),
(271, 'Elementi su pravilno povezani. Redni broj ispitivanja: 271.', 11, 'Vizuelna provera prototipa broj 271.'),
(272, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 272.', 12, 'Funkcionalno ispitivanje prototipa broj 272.'),
(273, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 273.', 13, 'Ispitivanje stabilnosti prototipa broj 273.'),
(274, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 274.', 14, 'Provera odziva prototipa broj 274.'),
(275, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 275.', 15, 'Završna provera prototipa broj 275.'),
(276, 'Elementi su pravilno povezani. Redni broj ispitivanja: 276.', 16, 'Vizuelna provera prototipa broj 276.'),
(277, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 277.', 17, 'Funkcionalno ispitivanje prototipa broj 277.'),
(278, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 278.', 18, 'Ispitivanje stabilnosti prototipa broj 278.'),
(279, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 279.', 19, 'Provera odziva prototipa broj 279.'),
(280, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 280.', 20, 'Završna provera prototipa broj 280.'),
(281, 'Elementi su pravilno povezani. Redni broj ispitivanja: 281.', 1, 'Vizuelna provera prototipa broj 281.'),
(282, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 282.', 2, 'Funkcionalno ispitivanje prototipa broj 282.'),
(283, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 283.', 3, 'Ispitivanje stabilnosti prototipa broj 283.'),
(284, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 284.', 4, 'Provera odziva prototipa broj 284.'),
(285, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 285.', 5, 'Završna provera prototipa broj 285.'),
(286, 'Elementi su pravilno povezani. Redni broj ispitivanja: 286.', 6, 'Vizuelna provera prototipa broj 286.'),
(287, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 287.', 7, 'Funkcionalno ispitivanje prototipa broj 287.'),
(288, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 288.', 8, 'Ispitivanje stabilnosti prototipa broj 288.'),
(289, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 289.', 9, 'Provera odziva prototipa broj 289.'),
(290, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 290.', 10, 'Završna provera prototipa broj 290.'),
(291, 'Elementi su pravilno povezani. Redni broj ispitivanja: 291.', 11, 'Vizuelna provera prototipa broj 291.'),
(292, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 292.', 12, 'Funkcionalno ispitivanje prototipa broj 292.'),
(293, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 293.', 13, 'Ispitivanje stabilnosti prototipa broj 293.'),
(294, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 294.', 14, 'Provera odziva prototipa broj 294.'),
(295, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 295.', 15, 'Završna provera prototipa broj 295.'),
(296, 'Elementi su pravilno povezani. Redni broj ispitivanja: 296.', 16, 'Vizuelna provera prototipa broj 296.'),
(297, 'Rad je u očekivanim granicama. Redni broj ispitivanja: 297.', 17, 'Funkcionalno ispitivanje prototipa broj 297.'),
(298, 'Sistem radi stabilno tokom sesije. Redni broj ispitivanja: 298.', 18, 'Ispitivanje stabilnosti prototipa broj 298.'),
(299, 'Odziv je zabeležen i prihvatljiv. Redni broj ispitivanja: 299.', 19, 'Provera odziva prototipa broj 299.'),
(300, 'Ispitivanje je uspešno evidentirano. Redni broj ispitivanja: 300.', 20, 'Završna provera prototipa broj 300.');

-- --------------------------------------------------------

--
-- Table structure for table `ispitivanje_elektricnog_kola`
--

DROP TABLE IF EXISTS `ispitivanje_elektricnog_kola`;
CREATE TABLE `ispitivanje_elektricnog_kola` (
  `ispitivanje_id` int(11) NOT NULL,
  `elektricno_kolo_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ispitivanje_elektricnog_kola`
--

INSERT INTO `ispitivanje_elektricnog_kola` (`ispitivanje_id`, `elektricno_kolo_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),
(51, 51),
(52, 52),
(53, 53),
(54, 54),
(55, 55),
(56, 56),
(57, 57),
(58, 58),
(59, 59),
(60, 60),
(61, 61),
(62, 62),
(63, 63),
(64, 64),
(65, 65),
(66, 66),
(67, 67),
(68, 68),
(69, 69),
(70, 70),
(71, 71),
(72, 72),
(73, 73),
(74, 74),
(75, 75),
(76, 76),
(77, 77),
(78, 78),
(79, 79),
(80, 80),
(81, 81),
(82, 82),
(83, 83),
(84, 84),
(85, 85),
(86, 86),
(87, 87),
(88, 88),
(89, 89),
(90, 90),
(91, 91),
(92, 92),
(93, 93),
(94, 94),
(95, 95),
(96, 96),
(97, 97),
(98, 98),
(99, 99),
(100, 100);

-- --------------------------------------------------------

--
-- Table structure for table `ispitivanje_prototipa`
--

DROP TABLE IF EXISTS `ispitivanje_prototipa`;
CREATE TABLE `ispitivanje_prototipa` (
  `ispitivanje_id` int(11) NOT NULL,
  `prototip_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ispitivanje_prototipa`
--

INSERT INTO `ispitivanje_prototipa` (`ispitivanje_id`, `prototip_id`) VALUES
(201, 1),
(202, 2),
(203, 3),
(204, 4),
(205, 5),
(206, 6),
(207, 7),
(208, 8),
(209, 9),
(210, 10),
(211, 11),
(212, 12),
(213, 13),
(214, 14),
(215, 15),
(216, 16),
(217, 17),
(218, 18),
(219, 19),
(220, 20),
(221, 21),
(222, 22),
(223, 23),
(224, 24),
(225, 25),
(226, 26),
(227, 27),
(228, 28),
(229, 29),
(230, 30),
(231, 31),
(232, 32),
(233, 33),
(234, 34),
(235, 35),
(236, 36),
(237, 37),
(238, 38),
(239, 39),
(240, 40),
(241, 41),
(242, 42),
(243, 43),
(244, 44),
(245, 45),
(246, 46),
(247, 47),
(248, 48),
(249, 49),
(250, 50),
(251, 51),
(252, 52),
(253, 53),
(254, 54),
(255, 55),
(256, 56),
(257, 57),
(258, 58),
(259, 59),
(260, 60),
(261, 61),
(262, 62),
(263, 63),
(264, 64),
(265, 65),
(266, 66),
(267, 67),
(268, 68),
(269, 69),
(270, 70),
(271, 71),
(272, 72),
(273, 73),
(274, 74),
(275, 75),
(276, 76),
(277, 77),
(278, 78),
(279, 79),
(280, 80),
(281, 81),
(282, 82),
(283, 83),
(284, 84),
(285, 85),
(286, 86),
(287, 87),
(288, 88),
(289, 89),
(290, 90),
(291, 91),
(292, 92),
(293, 93),
(294, 94),
(295, 95),
(296, 96),
(297, 97),
(298, 98),
(299, 99),
(300, 100);

-- --------------------------------------------------------

--
-- Table structure for table `ispitivanje_senzora`
--

DROP TABLE IF EXISTS `ispitivanje_senzora`;
CREATE TABLE `ispitivanje_senzora` (
  `ispitivanje_id` int(11) NOT NULL,
  `senzor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ispitivanje_senzora`
--

INSERT INTO `ispitivanje_senzora` (`ispitivanje_id`, `senzor_id`) VALUES
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5),
(106, 6),
(107, 7),
(108, 8),
(109, 9),
(110, 10),
(111, 11),
(112, 12),
(113, 13),
(114, 14),
(115, 15),
(116, 16),
(117, 17),
(118, 18),
(119, 19),
(120, 20),
(121, 21),
(122, 22),
(123, 23),
(124, 24),
(125, 25),
(126, 26),
(127, 27),
(128, 28),
(129, 29),
(130, 30),
(131, 31),
(132, 32),
(133, 33),
(134, 34),
(135, 35),
(136, 36),
(137, 37),
(138, 38),
(139, 39),
(140, 40),
(141, 41),
(142, 42),
(143, 43),
(144, 44),
(145, 45),
(146, 46),
(147, 47),
(148, 48),
(149, 49),
(150, 50),
(151, 51),
(152, 52),
(153, 53),
(154, 54),
(155, 55),
(156, 56),
(157, 57),
(158, 58),
(159, 59),
(160, 60),
(161, 61),
(162, 62),
(163, 63),
(164, 64),
(165, 65),
(166, 66),
(167, 67),
(168, 68),
(169, 69),
(170, 70),
(171, 71),
(172, 72),
(173, 73),
(174, 74),
(175, 75),
(176, 76),
(177, 77),
(178, 78),
(179, 79),
(180, 80),
(181, 81),
(182, 82),
(183, 83),
(184, 84),
(185, 85),
(186, 86),
(187, 87),
(188, 88),
(189, 89),
(190, 90),
(191, 91),
(192, 92),
(193, 93),
(194, 94),
(195, 95),
(196, 96),
(197, 97),
(198, 98),
(199, 99),
(200, 100);

-- --------------------------------------------------------

--
-- Table structure for table `istrazivac`
--

DROP TABLE IF EXISTS `istrazivac`;
CREATE TABLE `istrazivac` (
  `istrazivac_id` int(11) NOT NULL,
  `ime` varchar(50) NOT NULL,
  `prezime` varchar(50) NOT NULL,
  `kvalifikacije` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `istrazivac`
--

INSERT INTO `istrazivac` (`istrazivac_id`, `ime`, `prezime`, `kvalifikacije`) VALUES
(1, 'Marko', 'Nikolic', 'Elektrotehnika - merenja i instrumentacija'),
(2, 'Nikola', 'Ilic', 'Elektronika i razvoj analognih kola'),
(3, 'Jovan', 'Milosevic', 'Digitalna elektronika i mikrokontroleri'),
(4, 'Stefan', 'Ristic', 'Energetska elektronika i napajanja'),
(5, 'Luka', 'Matic', 'Senzorski sistemi i obrada signala'),
(6, 'Milos', 'Vasic', 'Automatika i upravljanje sistemima'),
(7, 'Petar', 'Petrovic', 'Telekomunikacije i analiza signala'),
(8, 'Aleksa', 'Markovic', 'Primena osciloskopa i mernih metoda'),
(9, 'Andrej', 'Djordjevic', 'Projektovanje PCB prototipova'),
(10, 'Vuk', 'Simic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(11, 'Ana', 'Kovacevic', 'Elektrotehnika - merenja i instrumentacija'),
(12, 'Milica', 'Lazic', 'Elektronika i razvoj analognih kola'),
(13, 'Jelena', 'Obradovic', 'Digitalna elektronika i mikrokontroleri'),
(14, 'Teodora', 'Jovanovic', 'Energetska elektronika i napajanja'),
(15, 'Sara', 'Stojanovic', 'Senzorski sistemi i obrada signala'),
(16, 'Marija', 'Pavlovic', 'Automatika i upravljanje sistemima'),
(17, 'Katarina', 'Savic', 'Telekomunikacije i analiza signala'),
(18, 'Ivana', 'Popovic', 'Primena osciloskopa i mernih metoda'),
(19, 'Dunja', 'Todorovic', 'Projektovanje PCB prototipova'),
(20, 'Tamara', 'Kostic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(21, 'Marko', 'Nikolic', 'Elektrotehnika - merenja i instrumentacija'),
(22, 'Nikola', 'Ilic', 'Elektronika i razvoj analognih kola'),
(23, 'Jovan', 'Milosevic', 'Digitalna elektronika i mikrokontroleri'),
(24, 'Stefan', 'Ristic', 'Energetska elektronika i napajanja'),
(25, 'Luka', 'Matic', 'Senzorski sistemi i obrada signala'),
(26, 'Milos', 'Vasic', 'Automatika i upravljanje sistemima'),
(27, 'Petar', 'Petrovic', 'Telekomunikacije i analiza signala'),
(28, 'Aleksa', 'Markovic', 'Primena osciloskopa i mernih metoda'),
(29, 'Andrej', 'Djordjevic', 'Projektovanje PCB prototipova'),
(30, 'Vuk', 'Simic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(31, 'Ana', 'Kovacevic', 'Elektrotehnika - merenja i instrumentacija'),
(32, 'Milica', 'Lazic', 'Elektronika i razvoj analognih kola'),
(33, 'Jelena', 'Obradovic', 'Digitalna elektronika i mikrokontroleri'),
(34, 'Teodora', 'Jovanovic', 'Energetska elektronika i napajanja'),
(35, 'Sara', 'Stojanovic', 'Senzorski sistemi i obrada signala'),
(36, 'Marija', 'Pavlovic', 'Automatika i upravljanje sistemima'),
(37, 'Katarina', 'Savic', 'Telekomunikacije i analiza signala'),
(38, 'Ivana', 'Popovic', 'Primena osciloskopa i mernih metoda'),
(39, 'Dunja', 'Todorovic', 'Projektovanje PCB prototipova'),
(40, 'Tamara', 'Kostic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(41, 'Marko', 'Nikolic', 'Elektrotehnika - merenja i instrumentacija'),
(42, 'Nikola', 'Ilic', 'Elektronika i razvoj analognih kola'),
(43, 'Jovan', 'Milosevic', 'Digitalna elektronika i mikrokontroleri'),
(44, 'Stefan', 'Ristic', 'Energetska elektronika i napajanja'),
(45, 'Luka', 'Matic', 'Senzorski sistemi i obrada signala'),
(46, 'Milos', 'Vasic', 'Automatika i upravljanje sistemima'),
(47, 'Petar', 'Petrovic', 'Telekomunikacije i analiza signala'),
(48, 'Aleksa', 'Markovic', 'Primena osciloskopa i mernih metoda'),
(49, 'Andrej', 'Djordjevic', 'Projektovanje PCB prototipova'),
(50, 'Vuk', 'Simic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(51, 'Ana', 'Kovacevic', 'Elektrotehnika - merenja i instrumentacija'),
(52, 'Milica', 'Lazic', 'Elektronika i razvoj analognih kola'),
(53, 'Jelena', 'Obradovic', 'Digitalna elektronika i mikrokontroleri'),
(54, 'Teodora', 'Jovanovic', 'Energetska elektronika i napajanja'),
(55, 'Sara', 'Stojanovic', 'Senzorski sistemi i obrada signala'),
(56, 'Marija', 'Pavlovic', 'Automatika i upravljanje sistemima'),
(57, 'Katarina', 'Savic', 'Telekomunikacije i analiza signala'),
(58, 'Ivana', 'Popovic', 'Primena osciloskopa i mernih metoda'),
(59, 'Dunja', 'Todorovic', 'Projektovanje PCB prototipova'),
(60, 'Tamara', 'Kostic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(61, 'Marko', 'Nikolic', 'Elektrotehnika - merenja i instrumentacija'),
(62, 'Nikola', 'Ilic', 'Elektronika i razvoj analognih kola'),
(63, 'Jovan', 'Milosevic', 'Digitalna elektronika i mikrokontroleri'),
(64, 'Stefan', 'Ristic', 'Energetska elektronika i napajanja'),
(65, 'Luka', 'Matic', 'Senzorski sistemi i obrada signala'),
(66, 'Milos', 'Vasic', 'Automatika i upravljanje sistemima'),
(67, 'Petar', 'Petrovic', 'Telekomunikacije i analiza signala'),
(68, 'Aleksa', 'Markovic', 'Primena osciloskopa i mernih metoda'),
(69, 'Andrej', 'Djordjevic', 'Projektovanje PCB prototipova'),
(70, 'Vuk', 'Simic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(71, 'Ana', 'Kovacevic', 'Elektrotehnika - merenja i instrumentacija'),
(72, 'Milica', 'Lazic', 'Elektronika i razvoj analognih kola'),
(73, 'Jelena', 'Obradovic', 'Digitalna elektronika i mikrokontroleri'),
(74, 'Teodora', 'Jovanovic', 'Energetska elektronika i napajanja'),
(75, 'Sara', 'Stojanovic', 'Senzorski sistemi i obrada signala'),
(76, 'Marija', 'Pavlovic', 'Automatika i upravljanje sistemima'),
(77, 'Katarina', 'Savic', 'Telekomunikacije i analiza signala'),
(78, 'Ivana', 'Popovic', 'Primena osciloskopa i mernih metoda'),
(79, 'Dunja', 'Todorovic', 'Projektovanje PCB prototipova'),
(80, 'Tamara', 'Kostic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(81, 'Marko', 'Nikolic', 'Elektrotehnika - merenja i instrumentacija'),
(82, 'Nikola', 'Ilic', 'Elektronika i razvoj analognih kola'),
(83, 'Jovan', 'Milosevic', 'Digitalna elektronika i mikrokontroleri'),
(84, 'Stefan', 'Ristic', 'Energetska elektronika i napajanja'),
(85, 'Luka', 'Matic', 'Senzorski sistemi i obrada signala'),
(86, 'Milos', 'Vasic', 'Automatika i upravljanje sistemima'),
(87, 'Petar', 'Petrovic', 'Telekomunikacije i analiza signala'),
(88, 'Aleksa', 'Markovic', 'Primena osciloskopa i mernih metoda'),
(89, 'Andrej', 'Djordjevic', 'Projektovanje PCB prototipova'),
(90, 'Vuk', 'Simic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(91, 'Ana', 'Kovacevic', 'Elektrotehnika - merenja i instrumentacija'),
(92, 'Milica', 'Lazic', 'Elektronika i razvoj analognih kola'),
(93, 'Jelena', 'Obradovic', 'Digitalna elektronika i mikrokontroleri'),
(94, 'Teodora', 'Jovanovic', 'Energetska elektronika i napajanja'),
(95, 'Sara', 'Stojanovic', 'Senzorski sistemi i obrada signala'),
(96, 'Marija', 'Pavlovic', 'Automatika i upravljanje sistemima'),
(97, 'Katarina', 'Savic', 'Telekomunikacije i analiza signala'),
(98, 'Ivana', 'Popovic', 'Primena osciloskopa i mernih metoda'),
(99, 'Dunja', 'Todorovic', 'Projektovanje PCB prototipova'),
(100, 'Tamara', 'Kostic', 'Ispitivanje RLC kola i mernih nesigurnosti'),
(101, 'Andrej', 'Nikolic', 'Master elektrotehnike, oblast elektronska kola i merenja'),
(102, 'Tamara', 'Petrovic', 'Diplomirani inzenjer elektrotehnike, oblast senzori i instrumentacija'),
(103, 'Viktor', 'Jovanovic', 'Student master studija elektrotehnike, oblast laboratorijska merenja'),
(104, 'Lena', 'Markovic', 'Inzenjer elektrotehnike, oblast prototipovi i ispitivanje kola'),
(105, 'Filip', 'Stankovic', 'Doktorand elektrotehnike, oblast analogna elektronika'),
(106, 'test1', 'test1', 'test1'),
(107, 'test2', 'test2', 'test2'),
(108, 'test3', 'test3', 'test3'),
(109, 'test4', 'test4', 'test4'),
(110, 'test5', 'test5', 'test5');

-- --------------------------------------------------------

--
-- Stand-in structure for view `izradjeni_eksperimenti`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `izradjeni_eksperimenti`;
CREATE TABLE `izradjeni_eksperimenti` (
`naziv` varchar(100)
,`ciljevi` text
,`teorijski_okvir` text
);

-- --------------------------------------------------------

--
-- Table structure for table `izvodjenje`
--

DROP TABLE IF EXISTS `izvodjenje`;
CREATE TABLE `izvodjenje` (
  `izvodjenje_id` int(11) NOT NULL,
  `eksperiment_id` int(11) NOT NULL,
  `laboratorija_id` int(11) NOT NULL,
  `datum` date DEFAULT NULL,
  `status_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `izvodjenje`
--

INSERT INTO `izvodjenje` (`izvodjenje_id`, `eksperiment_id`, `laboratorija_id`, `datum`, `status_id`) VALUES
(1, 1, 1, '2024-02-01', 1),
(2, 2, 6, '2024-02-03', 2),
(3, 3, 11, '2024-02-05', 3),
(4, 4, 16, '2024-02-07', 4),
(5, 5, 21, '2024-02-09', 5),
(6, 6, 26, '2024-02-11', 1),
(7, 7, 31, '2024-02-13', 2),
(8, 8, 36, '2024-02-15', 3),
(9, 9, 41, '2024-02-17', 4),
(10, 10, 46, '2024-02-19', 5),
(11, 11, 51, '2024-02-21', 1),
(12, 12, 56, '2024-02-23', 2),
(13, 13, 61, '2024-02-25', 3),
(14, 14, 66, '2024-02-27', 4),
(15, 15, 71, '2024-02-29', 5),
(16, 16, 76, '2024-03-02', 1),
(17, 17, 81, '2024-03-04', 2),
(18, 18, 86, '2024-03-06', 3),
(19, 19, 91, '2024-03-08', 4),
(20, 20, 96, '2024-03-10', 5),
(21, 21, 1, '2024-03-12', 1),
(22, 22, 6, '2024-03-14', 2),
(23, 23, 11, '2024-03-16', 3),
(24, 24, 16, '2024-03-18', 4),
(25, 25, 21, '2024-03-20', 5),
(26, 26, 26, '2024-03-22', 1),
(27, 27, 31, '2024-03-24', 2),
(28, 28, 36, '2024-03-26', 3),
(29, 29, 41, '2024-03-28', 4),
(30, 30, 46, '2024-03-30', 5),
(31, 31, 51, '2024-04-01', 1),
(32, 32, 56, '2024-04-03', 2),
(33, 33, 61, '2024-04-05', 3),
(34, 34, 66, '2024-04-07', 4),
(35, 35, 71, '2024-04-09', 5),
(36, 36, 76, '2024-04-11', 1),
(37, 37, 81, '2024-04-13', 2),
(38, 38, 86, '2024-04-15', 3),
(39, 39, 91, '2024-04-17', 4),
(40, 40, 96, '2024-04-19', 5),
(41, 41, 1, '2024-04-21', 1),
(42, 42, 6, '2024-04-23', 2),
(43, 43, 11, '2024-04-25', 3),
(44, 44, 16, '2024-04-27', 4),
(45, 45, 21, '2024-04-29', 5),
(46, 46, 26, '2024-05-01', 1),
(47, 47, 31, '2024-05-03', 2),
(48, 48, 36, '2024-05-05', 3),
(49, 49, 41, '2024-05-07', 4),
(50, 50, 46, '2024-05-09', 5),
(51, 51, 51, '2024-05-11', 1),
(52, 52, 56, '2024-05-13', 2),
(53, 53, 61, '2024-05-15', 3),
(54, 54, 66, '2024-05-17', 4),
(55, 55, 71, '2024-05-19', 5),
(56, 56, 76, '2024-05-21', 1),
(57, 57, 81, '2024-05-23', 2),
(58, 58, 86, '2024-05-25', 3),
(59, 59, 91, '2024-05-27', 4),
(60, 60, 96, '2024-05-29', 5),
(61, 61, 1, '2024-05-31', 1),
(62, 62, 6, '2024-06-02', 2),
(63, 63, 11, '2024-06-04', 3),
(64, 64, 16, '2024-06-06', 4),
(65, 65, 21, '2024-06-08', 5),
(66, 66, 26, '2024-06-10', 1),
(67, 67, 31, '2024-06-12', 2),
(68, 68, 36, '2024-06-14', 3),
(69, 69, 41, '2024-06-16', 4),
(70, 70, 46, '2024-06-18', 5),
(71, 71, 51, '2024-06-20', 1),
(72, 72, 56, '2024-06-22', 2),
(73, 73, 61, '2024-06-24', 3),
(74, 74, 66, '2024-06-26', 4),
(75, 75, 71, '2024-06-28', 5),
(76, 76, 76, '2024-06-30', 1),
(77, 77, 81, '2024-07-02', 2),
(78, 78, 86, '2024-07-04', 3),
(79, 79, 91, '2024-07-06', 4),
(80, 80, 96, '2024-07-08', 5),
(81, 81, 1, '2024-07-10', 1),
(82, 82, 6, '2024-07-12', 2),
(83, 83, 11, '2024-07-14', 3),
(84, 84, 16, '2024-07-16', 4),
(85, 85, 21, '2024-07-18', 5),
(86, 86, 26, '2024-07-20', 1),
(87, 87, 31, '2024-07-22', 2),
(88, 88, 36, '2024-07-24', 3),
(89, 89, 41, '2024-07-26', 4),
(90, 90, 46, '2024-07-28', 5),
(91, 91, 51, '2024-07-30', 1),
(92, 92, 56, '2024-08-01', 2),
(93, 93, 61, '2024-08-03', 3),
(94, 94, 66, '2024-08-05', 4),
(95, 95, 71, '2024-08-07', 5),
(96, 96, 76, '2024-08-09', 1),
(97, 97, 81, '2024-08-11', 2),
(98, 98, 86, '2024-08-13', 3),
(99, 99, 91, '2024-08-15', 4),
(100, 100, 96, '2024-08-17', 5);

-- --------------------------------------------------------

--
-- Table structure for table `korisnik`
--

DROP TABLE IF EXISTS `korisnik`;
CREATE TABLE `korisnik` (
  `korisnik_id` int(11) NOT NULL,
  `istrazivac_id` int(11) NOT NULL,
  `username` varchar(100) DEFAULT NULL,
  `lozinka` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `korisnik`
--

INSERT INTO `korisnik` (`korisnik_id`, `istrazivac_id`, `username`, `lozinka`) VALUES
(1, 1, 'marko.001@laboratorija.edu.rs', '37e09079a7f0163eb21a53a5361f7b31'),
(2, 2, 'nikola.002@laboratorija.edu.rs', 'a5672217bf5da2c732bba0def63557ac'),
(3, 3, 'stefan.003@laboratorija.edu.rs', '088df49cbaf0d68dc69b504664bb3a48'),
(4, 4, 'luka.004@laboratorija.edu.rs', '3652be3b65454116c50a8d904db2f4da'),
(5, 5, 'jovan.005@laboratorija.edu.rs', 'c14126feac2560111e80741d27a2ff19'),
(6, 6, 'petar.006@laboratorija.edu.rs', 'ab91f5ffe4cd4a58ba9b39f32985eae2'),
(7, 7, 'milos.007@laboratorija.edu.rs', '0a4fb9fa6648eb4150c6a9d3d9d96745'),
(8, 8, 'ivan.008@laboratorija.edu.rs', '8b413c06540a09699857e6d7d639d082'),
(9, 9, 'aleksandar.009@laboratorija.edu.rs', '3fcc74f2d090de1ede0bf09a2a6e12cc'),
(10, 10, 'vuk.010@laboratorija.edu.rs', '0297c16bd3b134cd292369478021a0c6'),
(11, 11, 'ana.011@laboratorija.edu.rs', 'bd25af25361982a4ac0d455cb65dc602'),
(12, 12, 'milica.012@laboratorija.edu.rs', 'a12b86c4a91f4c75e1cc9c44d5be488d'),
(13, 13, 'jelena.013@laboratorija.edu.rs', 'dabe4b3ed0d37c4061e2f4845b12d05f'),
(14, 14, 'marija.014@laboratorija.edu.rs', '4fa2553f644dd73df522857adb190f42'),
(15, 15, 'sara.015@laboratorija.edu.rs', 'dd5c23158e28be891b079c9637977cb8'),
(16, 16, 'teodora.016@laboratorija.edu.rs', '5dd7031883db872aebd9cca8c0d4130e'),
(17, 17, 'ivana.017@laboratorija.edu.rs', '6420c920bffdd28669d512445bd34f92'),
(18, 18, 'katarina.018@laboratorija.edu.rs', 'c70928a3727872d72a75c101c2dfdfe8'),
(19, 19, 'mina.019@laboratorija.edu.rs', '86434068bdfe57daee12ba428cdb81d5'),
(20, 20, 'sofija.020@laboratorija.edu.rs', '49e165b48fabd974d084ddeb53010947'),
(21, 21, 'marko.021@laboratorija.edu.rs', '3bfd36d214638378b3a21a4f4322312b'),
(22, 22, 'nikola.022@laboratorija.edu.rs', '2c899e8fe0fe391cc8857963d6263a81'),
(23, 23, 'stefan.023@laboratorija.edu.rs', 'db778f26e32ff93c39e3c7598eda02ad'),
(24, 24, 'luka.024@laboratorija.edu.rs', '76eea419498698e6a9c6ca1c9c07b579'),
(25, 25, 'jovan.025@laboratorija.edu.rs', 'ea69f796654f07ae3a9cb101bab6182d'),
(26, 26, 'petar.026@laboratorija.edu.rs', 'b5b26daada7090d3bef0d4328a1c69db'),
(27, 27, 'milos.027@laboratorija.edu.rs', '8d88a432306e039fe6bd1fb246972468'),
(28, 28, 'ivan.028@laboratorija.edu.rs', 'a467db6e4adaefab07f52dac7d7df307'),
(29, 29, 'aleksandar.029@laboratorija.edu.rs', 'a8e7c2881f0373e740e5e71d1d1ddb20'),
(30, 30, 'vuk.030@laboratorija.edu.rs', 'b31456693132ec71b3489461ed22121a'),
(31, 31, 'ana.031@laboratorija.edu.rs', 'b427820f6efb12eb25d5fb8ac5ab782a'),
(32, 32, 'milica.032@laboratorija.edu.rs', 'a4126ed009342399460b5eded4d935d2'),
(33, 33, 'jelena.033@laboratorija.edu.rs', 'cc0fcb7c085f72c11cba11002b0128e6'),
(34, 34, 'marija.034@laboratorija.edu.rs', '0b49c2a344f2ec4a3f1348b43fb0da4b'),
(35, 35, 'sara.035@laboratorija.edu.rs', '6203fdd4f3e151f5a47b0a71cfecd03e'),
(36, 36, 'teodora.036@laboratorija.edu.rs', '64499a62eb6ad632b9ab1edc480020e0'),
(37, 37, 'ivana.037@laboratorija.edu.rs', 'ea08a4a0077450ac9bb2df685e272bec'),
(38, 38, 'katarina.038@laboratorija.edu.rs', '5aee7227ef6d8de863677bb4450e4a97'),
(39, 39, 'mina.039@laboratorija.edu.rs', '09eac88aed2f46ed10e94ffd9fc2c468'),
(40, 40, 'sofija.040@laboratorija.edu.rs', '74bf396b84e1d3c60ab4c9a900c9e7b5'),
(41, 41, 'marko.041@laboratorija.edu.rs', '32caf67cd782505d8e32588f690b1206'),
(42, 42, 'nikola.042@laboratorija.edu.rs', '219998af0e492ca036cf34fc8e36dbbc'),
(43, 43, 'stefan.043@laboratorija.edu.rs', 'ac9957a5ee736e444121845629a2e95a'),
(44, 44, 'luka.044@laboratorija.edu.rs', 'e62a6e54b16736a0050d13b1ad54c9f9'),
(45, 45, 'jovan.045@laboratorija.edu.rs', 'dc8af667510ed5dfb14e0aaef5a8256d'),
(46, 46, 'petar.046@laboratorija.edu.rs', '2f8645836b4f1550d2db5469b15207a7'),
(47, 47, 'milos.047@laboratorija.edu.rs', '019d7b10cf401b7cbb537df591cf5309'),
(48, 48, 'ivan.048@laboratorija.edu.rs', '88b96107849e658f707258f326fa0497'),
(49, 49, 'aleksandar.049@laboratorija.edu.rs', '90d4d2164e3dce4220ab4bbbc8351c2c'),
(50, 50, 'vuk.050@laboratorija.edu.rs', 'ed128785b6baf882e2dc53b5604ca33c'),
(51, 51, 'ana.051@laboratorija.edu.rs', '925423988eb2fc42675f16fbe3f90935'),
(52, 52, 'milica.052@laboratorija.edu.rs', 'c4bc4d9a3e3a1fc1cd3a30e5deeefc7b'),
(53, 53, 'jelena.053@laboratorija.edu.rs', '478b372bdf57b4466e2888bfde6d9a11'),
(54, 54, 'marija.054@laboratorija.edu.rs', '2aa3daf6bfa474ff81e801683352934a'),
(55, 55, 'sara.055@laboratorija.edu.rs', '579c2781786cdc12889d3ae844b51d80'),
(56, 56, 'teodora.056@laboratorija.edu.rs', '6be646a43bf755bdb0b0b098ea1a66f2'),
(57, 57, 'ivana.057@laboratorija.edu.rs', 'c1b112f1a688c83962e1572fcb00852e'),
(58, 58, 'katarina.058@laboratorija.edu.rs', 'acb49e299697c9904787268cc1727c8b'),
(59, 59, 'mina.059@laboratorija.edu.rs', '29cfe1a2c313f50cdaf1e1df6337481d'),
(60, 60, 'sofija.060@laboratorija.edu.rs', '852f95abdb02150a2201c9256de7acbc'),
(61, 61, 'marko.061@laboratorija.edu.rs', '948f3d838744098b26a98bc3ded6c68b'),
(62, 62, 'nikola.062@laboratorija.edu.rs', 'f4f1beb11327ff1ac93eaf5af723b004'),
(63, 63, 'stefan.063@laboratorija.edu.rs', '83c9b538e8850634d8d40ccf97547f67'),
(64, 64, 'luka.064@laboratorija.edu.rs', '79fdcf2eb3431f993483da9b9399159c'),
(65, 65, 'jovan.065@laboratorija.edu.rs', '1d1248d4bf321dc2f96d4b015d1f51fe'),
(66, 66, 'petar.066@laboratorija.edu.rs', 'c2c66f65f8ce9c65a955b405a4be5216'),
(67, 67, 'milos.067@laboratorija.edu.rs', '57e6c0615cb384a68102a3dd2e456f52'),
(68, 68, 'ivan.068@laboratorija.edu.rs', '1a3fc02277c10a427a89b34ba3eb1f91'),
(69, 69, 'aleksandar.069@laboratorija.edu.rs', '57b6fc42acd3d218070328a4a4babbea'),
(70, 70, 'vuk.070@laboratorija.edu.rs', '845a0f4223f6b2d790cb3f144a636b86'),
(71, 71, 'ana.071@laboratorija.edu.rs', '1b117fc3431e2126a6269ee0a5bd1bb6'),
(72, 72, 'milica.072@laboratorija.edu.rs', '2d901fae52d73cf4e5f679b911d7c047'),
(73, 73, 'jelena.073@laboratorija.edu.rs', 'd64b36405f5002029d1ca69fefb0b78f'),
(74, 74, 'marija.074@laboratorija.edu.rs', '079740af90bab962fcb635bffc2fb341'),
(75, 75, 'sara.075@laboratorija.edu.rs', 'a8f20195d6faff515a3e5ec714c9adff'),
(76, 76, 'teodora.076@laboratorija.edu.rs', '8215ed0e54767175e51fdd662778cc6b'),
(77, 77, 'ivana.077@laboratorija.edu.rs', 'dc66c82487c695b0ed435cbb2d0505ab'),
(78, 78, 'katarina.078@laboratorija.edu.rs', '179c73a746f69c382a2ea5753b8e30a2'),
(79, 79, 'mina.079@laboratorija.edu.rs', '36031aa9e966815608d95aeb9ce4ea5e'),
(80, 80, 'sofija.080@laboratorija.edu.rs', '3c5ad59230fec878b9670150b012eae8'),
(81, 81, 'marko.081@laboratorija.edu.rs', '58e56877326a35ec9d331924742b4feb'),
(82, 82, 'nikola.082@laboratorija.edu.rs', '009cf01ffc3536c8796040d2afd816a3'),
(83, 83, 'stefan.083@laboratorija.edu.rs', 'bcc0a1f0d156de8e60e5ceb21f4ead91'),
(84, 84, 'luka.084@laboratorija.edu.rs', 'ab1a1f96188dd5b02862f49ed4ec4b61'),
(85, 85, 'jovan.085@laboratorija.edu.rs', '227cc27f419331f181ce3e61a57e7220'),
(86, 86, 'petar.086@laboratorija.edu.rs', 'f9cb7d67ebd23858e157e1eed465967d'),
(87, 87, 'milos.087@laboratorija.edu.rs', '4ebce14e6e1a6419828b407339e047e7'),
(88, 88, 'ivan.088@laboratorija.edu.rs', 'd7b8e76a0a403a72a428085182f2b1a1'),
(89, 89, 'aleksandar.089@laboratorija.edu.rs', '862aedfb327df1bb0964caa9651c7804'),
(90, 90, 'vuk.090@laboratorija.edu.rs', '94151f17a2124e88a3c09620a8123fd1'),
(91, 91, 'ana.091@laboratorija.edu.rs', 'c855a892f3829ae11057387f44d2e229'),
(92, 92, 'milica.092@laboratorija.edu.rs', 'f17adb7c7f51fa1a27ff4ae46fe65cd2'),
(93, 93, 'jelena.093@laboratorija.edu.rs', '6652846915d83df8653b84ebfbf545c3'),
(94, 94, 'marija.094@laboratorija.edu.rs', 'fda5483f41d380a6bce69f1d00caccd1'),
(95, 95, 'sara.095@laboratorija.edu.rs', 'f8ce80f9604d4cb8c00422bb93ddc9b3'),
(96, 96, 'teodora.096@laboratorija.edu.rs', '1909ebd4199ed5c956773cbaa95fe396'),
(97, 97, 'ivana.097@laboratorija.edu.rs', '637f68de2de494b85a889cdc714bc71c'),
(98, 98, 'katarina.098@laboratorija.edu.rs', '562841a0f21651f44ea69bc397bb4d4d'),
(99, 99, 'mina.099@laboratorija.edu.rs', 'dc18b460165f4dc4d3033cf7c7598c15'),
(100, 100, 'sofija.100@laboratorija.edu.rs', '5c90a4fc351ff0262fcd03344e809446'),
(101, 106, 'test1', '5a105e8b9d40e1329780d62ea2265d8a'),
(102, 107, 'test2', 'ad0234829205b9033196ba818f7a872b'),
(103, 108, 'test3', '8ad8757baa8564dc136c1e07507f4a98'),
(104, 109, 'test4', '86985e105f79b95d6bc918fb45ec7727'),
(105, 110, 'test5', 'e3d704f3542b44a621ebed70dc0efe13');

-- --------------------------------------------------------

--
-- Table structure for table `laboratorija`
--

DROP TABLE IF EXISTS `laboratorija`;
CREATE TABLE `laboratorija` (
  `laboratorija_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `opis_lokacije` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `laboratorija`
--

INSERT INTO `laboratorija` (`laboratorija_id`, `naziv`, `opis_lokacije`) VALUES
(1, 'Laboratorija za merenje elektricnih velicina 001', 'Zgrada A, sprat 1, prostorija 101. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(2, 'Laboratorija za ispitivanje kola 002', 'Zgrada A, sprat 2, prostorija 102. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(3, 'Laboratorija za senzore i aktuatorske sisteme 003', 'Zgrada B, sprat 1, prostorija 103. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(4, 'Laboratorija za elektroniku snage 004', 'Zgrada B, sprat 3, prostorija 104. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(5, 'Laboratorija za analogna kola 005', 'Elektro blok, sprat 0, prostorija 105. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(6, 'Laboratorija za digitalnu elektroniku 006', 'Elektro blok, sprat 2, prostorija 106. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(7, 'Laboratorija za mikrokontrolere 007', 'Ispitni centar, hala 1, sektor 107. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(8, 'Laboratorija za elektromagnetiku 008', 'Ispitni centar, hala 2, sektor 108. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(9, 'Laboratorija za napajanja 009', 'Zgrada A, sprat 1, prostorija 109. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(10, 'Laboratorija za prototipove 010', 'Zgrada A, sprat 2, prostorija 110. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(11, 'Laboratorija za merenje elektricnih velicina 011', 'Zgrada B, sprat 1, prostorija 111. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(12, 'Laboratorija za ispitivanje kola 012', 'Zgrada B, sprat 3, prostorija 112. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(13, 'Laboratorija za senzore i aktuatorske sisteme 013', 'Elektro blok, sprat 0, prostorija 113. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(14, 'Laboratorija za elektroniku snage 014', 'Elektro blok, sprat 2, prostorija 114. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(15, 'Laboratorija za analogna kola 015', 'Ispitni centar, hala 1, sektor 115. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(16, 'Laboratorija za digitalnu elektroniku 016', 'Ispitni centar, hala 2, sektor 116. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(17, 'Laboratorija za mikrokontrolere 017', 'Zgrada A, sprat 1, prostorija 117. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(18, 'Laboratorija za elektromagnetiku 018', 'Zgrada A, sprat 2, prostorija 118. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(19, 'Laboratorija za napajanja 019', 'Zgrada B, sprat 1, prostorija 119. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(20, 'Laboratorija za prototipove 020', 'Zgrada B, sprat 3, prostorija 120. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(21, 'Laboratorija za merenje elektricnih velicina 021', 'Elektro blok, sprat 0, prostorija 121. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(22, 'Laboratorija za ispitivanje kola 022', 'Elektro blok, sprat 2, prostorija 122. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(23, 'Laboratorija za senzore i aktuatorske sisteme 023', 'Ispitni centar, hala 1, sektor 123. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(24, 'Laboratorija za elektroniku snage 024', 'Ispitni centar, hala 2, sektor 124. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(25, 'Laboratorija za analogna kola 025', 'Zgrada A, sprat 1, prostorija 125. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(26, 'Laboratorija za digitalnu elektroniku 026', 'Zgrada A, sprat 2, prostorija 126. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(27, 'Laboratorija za mikrokontrolere 027', 'Zgrada B, sprat 1, prostorija 127. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(28, 'Laboratorija za elektromagnetiku 028', 'Zgrada B, sprat 3, prostorija 128. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(29, 'Laboratorija za napajanja 029', 'Elektro blok, sprat 0, prostorija 129. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(30, 'Laboratorija za prototipove 030', 'Elektro blok, sprat 2, prostorija 130. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(31, 'Laboratorija za merenje elektricnih velicina 031', 'Ispitni centar, hala 1, sektor 131. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(32, 'Laboratorija za ispitivanje kola 032', 'Ispitni centar, hala 2, sektor 132. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(33, 'Laboratorija za senzore i aktuatorske sisteme 033', 'Zgrada A, sprat 1, prostorija 133. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(34, 'Laboratorija za elektroniku snage 034', 'Zgrada A, sprat 2, prostorija 134. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(35, 'Laboratorija za analogna kola 035', 'Zgrada B, sprat 1, prostorija 135. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(36, 'Laboratorija za digitalnu elektroniku 036', 'Zgrada B, sprat 3, prostorija 136. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(37, 'Laboratorija za mikrokontrolere 037', 'Elektro blok, sprat 0, prostorija 137. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(38, 'Laboratorija za elektromagnetiku 038', 'Elektro blok, sprat 2, prostorija 138. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(39, 'Laboratorija za napajanja 039', 'Ispitni centar, hala 1, sektor 139. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(40, 'Laboratorija za prototipove 040', 'Ispitni centar, hala 2, sektor 140. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(41, 'Laboratorija za merenje elektricnih velicina 041', 'Zgrada A, sprat 1, prostorija 141. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(42, 'Laboratorija za ispitivanje kola 042', 'Zgrada A, sprat 2, prostorija 142. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(43, 'Laboratorija za senzore i aktuatorske sisteme 043', 'Zgrada B, sprat 1, prostorija 143. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(44, 'Laboratorija za elektroniku snage 044', 'Zgrada B, sprat 3, prostorija 144. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(45, 'Laboratorija za analogna kola 045', 'Elektro blok, sprat 0, prostorija 145. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(46, 'Laboratorija za digitalnu elektroniku 046', 'Elektro blok, sprat 2, prostorija 146. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(47, 'Laboratorija za mikrokontrolere 047', 'Ispitni centar, hala 1, sektor 147. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(48, 'Laboratorija za elektromagnetiku 048', 'Ispitni centar, hala 2, sektor 148. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(49, 'Laboratorija za napajanja 049', 'Zgrada A, sprat 1, prostorija 149. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(50, 'Laboratorija za prototipove 050', 'Zgrada A, sprat 2, prostorija 150. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(51, 'Laboratorija za merenje elektricnih velicina 051', 'Zgrada B, sprat 1, prostorija 151. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(52, 'Laboratorija za ispitivanje kola 052', 'Zgrada B, sprat 3, prostorija 152. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(53, 'Laboratorija za senzore i aktuatorske sisteme 053', 'Elektro blok, sprat 0, prostorija 153. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(54, 'Laboratorija za elektroniku snage 054', 'Elektro blok, sprat 2, prostorija 154. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(55, 'Laboratorija za analogna kola 055', 'Ispitni centar, hala 1, sektor 155. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(56, 'Laboratorija za digitalnu elektroniku 056', 'Ispitni centar, hala 2, sektor 156. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(57, 'Laboratorija za mikrokontrolere 057', 'Zgrada A, sprat 1, prostorija 157. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(58, 'Laboratorija za elektromagnetiku 058', 'Zgrada A, sprat 2, prostorija 158. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(59, 'Laboratorija za napajanja 059', 'Zgrada B, sprat 1, prostorija 159. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(60, 'Laboratorija za prototipove 060', 'Zgrada B, sprat 3, prostorija 160. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(61, 'Laboratorija za merenje elektricnih velicina 061', 'Elektro blok, sprat 0, prostorija 161. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(62, 'Laboratorija za ispitivanje kola 062', 'Elektro blok, sprat 2, prostorija 162. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(63, 'Laboratorija za senzore i aktuatorske sisteme 063', 'Ispitni centar, hala 1, sektor 163. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(64, 'Laboratorija za elektroniku snage 064', 'Ispitni centar, hala 2, sektor 164. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(65, 'Laboratorija za analogna kola 065', 'Zgrada A, sprat 1, prostorija 165. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(66, 'Laboratorija za digitalnu elektroniku 066', 'Zgrada A, sprat 2, prostorija 166. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(67, 'Laboratorija za mikrokontrolere 067', 'Zgrada B, sprat 1, prostorija 167. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(68, 'Laboratorija za elektromagnetiku 068', 'Zgrada B, sprat 3, prostorija 168. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(69, 'Laboratorija za napajanja 069', 'Elektro blok, sprat 0, prostorija 169. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(70, 'Laboratorija za prototipove 070', 'Elektro blok, sprat 2, prostorija 170. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(71, 'Laboratorija za merenje elektricnih velicina 071', 'Ispitni centar, hala 1, sektor 171. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(72, 'Laboratorija za ispitivanje kola 072', 'Ispitni centar, hala 2, sektor 172. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(73, 'Laboratorija za senzore i aktuatorske sisteme 073', 'Zgrada A, sprat 1, prostorija 173. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(74, 'Laboratorija za elektroniku snage 074', 'Zgrada A, sprat 2, prostorija 174. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(75, 'Laboratorija za analogna kola 075', 'Zgrada B, sprat 1, prostorija 175. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(76, 'Laboratorija za digitalnu elektroniku 076', 'Zgrada B, sprat 3, prostorija 176. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(77, 'Laboratorija za mikrokontrolere 077', 'Elektro blok, sprat 0, prostorija 177. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(78, 'Laboratorija za elektromagnetiku 078', 'Elektro blok, sprat 2, prostorija 178. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(79, 'Laboratorija za napajanja 079', 'Ispitni centar, hala 1, sektor 179. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(80, 'Laboratorija za prototipove 080', 'Ispitni centar, hala 2, sektor 180. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(81, 'Laboratorija za merenje elektricnih velicina 081', 'Zgrada A, sprat 1, prostorija 181. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(82, 'Laboratorija za ispitivanje kola 082', 'Zgrada A, sprat 2, prostorija 182. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(83, 'Laboratorija za senzore i aktuatorske sisteme 083', 'Zgrada B, sprat 1, prostorija 183. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(84, 'Laboratorija za elektroniku snage 084', 'Zgrada B, sprat 3, prostorija 184. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(85, 'Laboratorija za analogna kola 085', 'Elektro blok, sprat 0, prostorija 185. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(86, 'Laboratorija za digitalnu elektroniku 086', 'Elektro blok, sprat 2, prostorija 186. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(87, 'Laboratorija za mikrokontrolere 087', 'Ispitni centar, hala 1, sektor 187. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(88, 'Laboratorija za elektromagnetiku 088', 'Ispitni centar, hala 2, sektor 188. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(89, 'Laboratorija za napajanja 089', 'Zgrada A, sprat 1, prostorija 189. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(90, 'Laboratorija za prototipove 090', 'Zgrada A, sprat 2, prostorija 190. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(91, 'Laboratorija za merenje elektricnih velicina 091', 'Zgrada B, sprat 1, prostorija 191. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(92, 'Laboratorija za ispitivanje kola 092', 'Zgrada B, sprat 3, prostorija 192. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(93, 'Laboratorija za senzore i aktuatorske sisteme 093', 'Elektro blok, sprat 0, prostorija 193. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(94, 'Laboratorija za elektroniku snage 094', 'Elektro blok, sprat 2, prostorija 194. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(95, 'Laboratorija za analogna kola 095', 'Ispitni centar, hala 1, sektor 195. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(96, 'Laboratorija za digitalnu elektroniku 096', 'Ispitni centar, hala 2, sektor 196. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(97, 'Laboratorija za mikrokontrolere 097', 'Zgrada A, sprat 1, prostorija 197. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(98, 'Laboratorija za elektromagnetiku 098', 'Zgrada A, sprat 2, prostorija 198. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(99, 'Laboratorija za napajanja 099', 'Zgrada B, sprat 1, prostorija 199. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.'),
(100, 'Laboratorija za prototipove 100', 'Zgrada B, sprat 3, prostorija 200. Namenjena za elektrotehnicka merenja, razvoj prototipova i analizu rezultata.');

-- --------------------------------------------------------

--
-- Table structure for table `merenje`
--

DROP TABLE IF EXISTS `merenje`;
CREATE TABLE `merenje` (
  `merenje_id` int(11) NOT NULL,
  `tip_merenja_id` int(11) DEFAULT NULL,
  `rezultat` decimal(15,4) DEFAULT NULL,
  `opis` text DEFAULT NULL,
  `izvodjenje_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merenje`
--

INSERT INTO `merenje` (`merenje_id`, `tip_merenja_id`, `rezultat`, `opis`, `izvodjenje_id`) VALUES
(1, 1, 1.1570, 'Merenje broj 1 u okviru laboratorijskog izvodjenja.', 1),
(2, 2, 1.3140, 'Merenje broj 2 u okviru laboratorijskog izvodjenja.', 2),
(3, 1, 1.4710, 'Merenje broj 3 u okviru laboratorijskog izvodjenja.', 3),
(4, 2, 1.6280, 'Merenje broj 4 u okviru laboratorijskog izvodjenja.', 4),
(5, 1, 1.7850, 'Merenje broj 5 u okviru laboratorijskog izvodjenja.', 5),
(6, 2, 1.9420, 'Merenje broj 6 u okviru laboratorijskog izvodjenja.', 6),
(7, 1, 2.0990, 'Merenje broj 7 u okviru laboratorijskog izvodjenja.', 7),
(8, 2, 2.2560, 'Merenje broj 8 u okviru laboratorijskog izvodjenja.', 8),
(9, 1, 2.4130, 'Merenje broj 9 u okviru laboratorijskog izvodjenja.', 9),
(10, 2, 2.5700, 'Merenje broj 10 u okviru laboratorijskog izvodjenja.', 10),
(11, 1, 2.7270, 'Merenje broj 11 u okviru laboratorijskog izvodjenja.', 11),
(12, 2, 2.8840, 'Merenje broj 12 u okviru laboratorijskog izvodjenja.', 12),
(13, 1, 3.0410, 'Merenje broj 13 u okviru laboratorijskog izvodjenja.', 13),
(14, 2, 3.1980, 'Merenje broj 14 u okviru laboratorijskog izvodjenja.', 14),
(15, 1, 3.3550, 'Merenje broj 15 u okviru laboratorijskog izvodjenja.', 15),
(16, 2, 3.5120, 'Merenje broj 16 u okviru laboratorijskog izvodjenja.', 16),
(17, 1, 3.6690, 'Merenje broj 17 u okviru laboratorijskog izvodjenja.', 17),
(18, 2, 3.8260, 'Merenje broj 18 u okviru laboratorijskog izvodjenja.', 18),
(19, 1, 3.9830, 'Merenje broj 19 u okviru laboratorijskog izvodjenja.', 19),
(20, 2, 4.1400, 'Merenje broj 20 u okviru laboratorijskog izvodjenja.', 20),
(21, 1, 4.2970, 'Merenje broj 21 u okviru laboratorijskog izvodjenja.', 1),
(22, 2, 4.4540, 'Merenje broj 22 u okviru laboratorijskog izvodjenja.', 2),
(23, 1, 4.6110, 'Merenje broj 23 u okviru laboratorijskog izvodjenja.', 3),
(24, 2, 4.7680, 'Merenje broj 24 u okviru laboratorijskog izvodjenja.', 4),
(25, 1, 4.9250, 'Merenje broj 25 u okviru laboratorijskog izvodjenja.', 5),
(26, 2, 5.0820, 'Merenje broj 26 u okviru laboratorijskog izvodjenja.', 6),
(27, 1, 5.2390, 'Merenje broj 27 u okviru laboratorijskog izvodjenja.', 7),
(28, 2, 5.3960, 'Merenje broj 28 u okviru laboratorijskog izvodjenja.', 8),
(29, 1, 5.5530, 'Merenje broj 29 u okviru laboratorijskog izvodjenja.', 9),
(30, 2, 5.7100, 'Merenje broj 30 u okviru laboratorijskog izvodjenja.', 10),
(31, 1, 5.8670, 'Merenje broj 31 u okviru laboratorijskog izvodjenja.', 11),
(32, 2, 6.0240, 'Merenje broj 32 u okviru laboratorijskog izvodjenja.', 12),
(33, 1, 6.1810, 'Merenje broj 33 u okviru laboratorijskog izvodjenja.', 13),
(34, 2, 6.3380, 'Merenje broj 34 u okviru laboratorijskog izvodjenja.', 14),
(35, 1, 6.4950, 'Merenje broj 35 u okviru laboratorijskog izvodjenja.', 15),
(36, 2, 6.6520, 'Merenje broj 36 u okviru laboratorijskog izvodjenja.', 16),
(37, 1, 6.8090, 'Merenje broj 37 u okviru laboratorijskog izvodjenja.', 17),
(38, 2, 6.9660, 'Merenje broj 38 u okviru laboratorijskog izvodjenja.', 18),
(39, 1, 7.1230, 'Merenje broj 39 u okviru laboratorijskog izvodjenja.', 19),
(40, 2, 7.2800, 'Merenje broj 40 u okviru laboratorijskog izvodjenja.', 20),
(41, 1, 7.4370, 'Merenje broj 41 u okviru laboratorijskog izvodjenja.', 1),
(42, 2, 7.5940, 'Merenje broj 42 u okviru laboratorijskog izvodjenja.', 2),
(43, 1, 7.7510, 'Merenje broj 43 u okviru laboratorijskog izvodjenja.', 3),
(44, 2, 7.9080, 'Merenje broj 44 u okviru laboratorijskog izvodjenja.', 4),
(45, 1, 8.0650, 'Merenje broj 45 u okviru laboratorijskog izvodjenja.', 5),
(46, 2, 8.2220, 'Merenje broj 46 u okviru laboratorijskog izvodjenja.', 6),
(47, 1, 8.3790, 'Merenje broj 47 u okviru laboratorijskog izvodjenja.', 7),
(48, 2, 8.5360, 'Merenje broj 48 u okviru laboratorijskog izvodjenja.', 8),
(49, 1, 8.6930, 'Merenje broj 49 u okviru laboratorijskog izvodjenja.', 9),
(50, 2, 8.8500, 'Merenje broj 50 u okviru laboratorijskog izvodjenja.', 10),
(51, 1, 9.0070, 'Merenje broj 51 u okviru laboratorijskog izvodjenja.', 11),
(52, 2, 9.1640, 'Merenje broj 52 u okviru laboratorijskog izvodjenja.', 12),
(53, 1, 9.3210, 'Merenje broj 53 u okviru laboratorijskog izvodjenja.', 13),
(54, 2, 9.4780, 'Merenje broj 54 u okviru laboratorijskog izvodjenja.', 14),
(55, 1, 9.6350, 'Merenje broj 55 u okviru laboratorijskog izvodjenja.', 15),
(56, 2, 9.7920, 'Merenje broj 56 u okviru laboratorijskog izvodjenja.', 16),
(57, 1, 9.9490, 'Merenje broj 57 u okviru laboratorijskog izvodjenja.', 17),
(58, 2, 10.1060, 'Merenje broj 58 u okviru laboratorijskog izvodjenja.', 18),
(59, 1, 10.2630, 'Merenje broj 59 u okviru laboratorijskog izvodjenja.', 19),
(60, 2, 10.4200, 'Merenje broj 60 u okviru laboratorijskog izvodjenja.', 20),
(61, 1, 10.5770, 'Merenje broj 61 u okviru laboratorijskog izvodjenja.', 1),
(62, 2, 10.7340, 'Merenje broj 62 u okviru laboratorijskog izvodjenja.', 2),
(63, 1, 10.8910, 'Merenje broj 63 u okviru laboratorijskog izvodjenja.', 3),
(64, 2, 11.0480, 'Merenje broj 64 u okviru laboratorijskog izvodjenja.', 4),
(65, 1, 11.2050, 'Merenje broj 65 u okviru laboratorijskog izvodjenja.', 5),
(66, 2, 11.3620, 'Merenje broj 66 u okviru laboratorijskog izvodjenja.', 6),
(67, 1, 11.5190, 'Merenje broj 67 u okviru laboratorijskog izvodjenja.', 7),
(68, 2, 11.6760, 'Merenje broj 68 u okviru laboratorijskog izvodjenja.', 8),
(69, 1, 11.8330, 'Merenje broj 69 u okviru laboratorijskog izvodjenja.', 9),
(70, 2, 11.9900, 'Merenje broj 70 u okviru laboratorijskog izvodjenja.', 10),
(71, 1, 12.1470, 'Merenje broj 71 u okviru laboratorijskog izvodjenja.', 11),
(72, 2, 12.3040, 'Merenje broj 72 u okviru laboratorijskog izvodjenja.', 12),
(73, 1, 12.4610, 'Merenje broj 73 u okviru laboratorijskog izvodjenja.', 13),
(74, 2, 12.6180, 'Merenje broj 74 u okviru laboratorijskog izvodjenja.', 14),
(75, 1, 12.7750, 'Merenje broj 75 u okviru laboratorijskog izvodjenja.', 15),
(76, 2, 12.9320, 'Merenje broj 76 u okviru laboratorijskog izvodjenja.', 16),
(77, 1, 13.0890, 'Merenje broj 77 u okviru laboratorijskog izvodjenja.', 17),
(78, 2, 13.2460, 'Merenje broj 78 u okviru laboratorijskog izvodjenja.', 18),
(79, 1, 13.4030, 'Merenje broj 79 u okviru laboratorijskog izvodjenja.', 19),
(80, 2, 13.5600, 'Merenje broj 80 u okviru laboratorijskog izvodjenja.', 20),
(81, 1, 13.7170, 'Merenje broj 81 u okviru laboratorijskog izvodjenja.', 1),
(82, 2, 13.8740, 'Merenje broj 82 u okviru laboratorijskog izvodjenja.', 2),
(83, 1, 14.0310, 'Merenje broj 83 u okviru laboratorijskog izvodjenja.', 3),
(84, 2, 14.1880, 'Merenje broj 84 u okviru laboratorijskog izvodjenja.', 4),
(85, 1, 14.3450, 'Merenje broj 85 u okviru laboratorijskog izvodjenja.', 5),
(86, 2, 14.5020, 'Merenje broj 86 u okviru laboratorijskog izvodjenja.', 6),
(87, 1, 14.6590, 'Merenje broj 87 u okviru laboratorijskog izvodjenja.', 7),
(88, 2, 14.8160, 'Merenje broj 88 u okviru laboratorijskog izvodjenja.', 8),
(89, 1, 14.9730, 'Merenje broj 89 u okviru laboratorijskog izvodjenja.', 9),
(90, 2, 15.1300, 'Merenje broj 90 u okviru laboratorijskog izvodjenja.', 10),
(91, 1, 15.2870, 'Merenje broj 91 u okviru laboratorijskog izvodjenja.', 11),
(92, 2, 15.4440, 'Merenje broj 92 u okviru laboratorijskog izvodjenja.', 12),
(93, 1, 15.6010, 'Merenje broj 93 u okviru laboratorijskog izvodjenja.', 13),
(94, 2, 15.7580, 'Merenje broj 94 u okviru laboratorijskog izvodjenja.', 14),
(95, 1, 15.9150, 'Merenje broj 95 u okviru laboratorijskog izvodjenja.', 15),
(96, 2, 16.0720, 'Merenje broj 96 u okviru laboratorijskog izvodjenja.', 16),
(97, 1, 16.2290, 'Merenje broj 97 u okviru laboratorijskog izvodjenja.', 17),
(98, 2, 16.3860, 'Merenje broj 98 u okviru laboratorijskog izvodjenja.', 18),
(99, 1, 16.5430, 'Merenje broj 99 u okviru laboratorijskog izvodjenja.', 19),
(100, 2, 16.7000, 'Merenje broj 100 u okviru laboratorijskog izvodjenja.', 20),
(101, 1, 16.8570, 'Merenje broj 101 u okviru laboratorijskog izvodjenja.', 1),
(102, 2, 17.0140, 'Merenje broj 102 u okviru laboratorijskog izvodjenja.', 2),
(103, 1, 17.1710, 'Merenje broj 103 u okviru laboratorijskog izvodjenja.', 3),
(104, 2, 17.3280, 'Merenje broj 104 u okviru laboratorijskog izvodjenja.', 4),
(105, 1, 17.4850, 'Merenje broj 105 u okviru laboratorijskog izvodjenja.', 5),
(106, 2, 17.6420, 'Merenje broj 106 u okviru laboratorijskog izvodjenja.', 6),
(107, 1, 17.7990, 'Merenje broj 107 u okviru laboratorijskog izvodjenja.', 7),
(108, 2, 17.9560, 'Merenje broj 108 u okviru laboratorijskog izvodjenja.', 8),
(109, 1, 18.1130, 'Merenje broj 109 u okviru laboratorijskog izvodjenja.', 9),
(110, 2, 18.2700, 'Merenje broj 110 u okviru laboratorijskog izvodjenja.', 10),
(111, 1, 18.4270, 'Merenje broj 111 u okviru laboratorijskog izvodjenja.', 11),
(112, 2, 18.5840, 'Merenje broj 112 u okviru laboratorijskog izvodjenja.', 12),
(113, 1, 18.7410, 'Merenje broj 113 u okviru laboratorijskog izvodjenja.', 13),
(114, 2, 18.8980, 'Merenje broj 114 u okviru laboratorijskog izvodjenja.', 14),
(115, 1, 19.0550, 'Merenje broj 115 u okviru laboratorijskog izvodjenja.', 15),
(116, 2, 19.2120, 'Merenje broj 116 u okviru laboratorijskog izvodjenja.', 16),
(117, 1, 19.3690, 'Merenje broj 117 u okviru laboratorijskog izvodjenja.', 17),
(118, 2, 19.5260, 'Merenje broj 118 u okviru laboratorijskog izvodjenja.', 18),
(119, 1, 19.6830, 'Merenje broj 119 u okviru laboratorijskog izvodjenja.', 19),
(120, 2, 19.8400, 'Merenje broj 120 u okviru laboratorijskog izvodjenja.', 20),
(121, 1, 19.9970, 'Merenje broj 121 u okviru laboratorijskog izvodjenja.', 1),
(122, 2, 20.1540, 'Merenje broj 122 u okviru laboratorijskog izvodjenja.', 2),
(123, 1, 20.3110, 'Merenje broj 123 u okviru laboratorijskog izvodjenja.', 3),
(124, 2, 20.4680, 'Merenje broj 124 u okviru laboratorijskog izvodjenja.', 4),
(125, 1, 20.6250, 'Merenje broj 125 u okviru laboratorijskog izvodjenja.', 5),
(126, 2, 20.7820, 'Merenje broj 126 u okviru laboratorijskog izvodjenja.', 6),
(127, 1, 20.9390, 'Merenje broj 127 u okviru laboratorijskog izvodjenja.', 7),
(128, 2, 21.0960, 'Merenje broj 128 u okviru laboratorijskog izvodjenja.', 8),
(129, 1, 21.2530, 'Merenje broj 129 u okviru laboratorijskog izvodjenja.', 9),
(130, 2, 21.4100, 'Merenje broj 130 u okviru laboratorijskog izvodjenja.', 10),
(131, 1, 21.5670, 'Merenje broj 131 u okviru laboratorijskog izvodjenja.', 11),
(132, 2, 21.7240, 'Merenje broj 132 u okviru laboratorijskog izvodjenja.', 12),
(133, 1, 21.8810, 'Merenje broj 133 u okviru laboratorijskog izvodjenja.', 13),
(134, 2, 22.0380, 'Merenje broj 134 u okviru laboratorijskog izvodjenja.', 14),
(135, 1, 22.1950, 'Merenje broj 135 u okviru laboratorijskog izvodjenja.', 15),
(136, 2, 22.3520, 'Merenje broj 136 u okviru laboratorijskog izvodjenja.', 16),
(137, 1, 22.5090, 'Merenje broj 137 u okviru laboratorijskog izvodjenja.', 17),
(138, 2, 22.6660, 'Merenje broj 138 u okviru laboratorijskog izvodjenja.', 18),
(139, 1, 22.8230, 'Merenje broj 139 u okviru laboratorijskog izvodjenja.', 19),
(140, 2, 22.9800, 'Merenje broj 140 u okviru laboratorijskog izvodjenja.', 20),
(141, 1, 23.1370, 'Merenje broj 141 u okviru laboratorijskog izvodjenja.', 1),
(142, 2, 23.2940, 'Merenje broj 142 u okviru laboratorijskog izvodjenja.', 2),
(143, 1, 23.4510, 'Merenje broj 143 u okviru laboratorijskog izvodjenja.', 3),
(144, 2, 23.6080, 'Merenje broj 144 u okviru laboratorijskog izvodjenja.', 4),
(145, 1, 23.7650, 'Merenje broj 145 u okviru laboratorijskog izvodjenja.', 5),
(146, 2, 23.9220, 'Merenje broj 146 u okviru laboratorijskog izvodjenja.', 6),
(147, 1, 24.0790, 'Merenje broj 147 u okviru laboratorijskog izvodjenja.', 7),
(148, 2, 24.2360, 'Merenje broj 148 u okviru laboratorijskog izvodjenja.', 8),
(149, 1, 24.3930, 'Merenje broj 149 u okviru laboratorijskog izvodjenja.', 9),
(150, 2, 24.5500, 'Merenje broj 150 u okviru laboratorijskog izvodjenja.', 10),
(151, 1, 24.7070, 'Merenje broj 151 u okviru laboratorijskog izvodjenja.', 11),
(152, 2, 24.8640, 'Merenje broj 152 u okviru laboratorijskog izvodjenja.', 12),
(153, 1, 25.0210, 'Merenje broj 153 u okviru laboratorijskog izvodjenja.', 13),
(154, 2, 25.1780, 'Merenje broj 154 u okviru laboratorijskog izvodjenja.', 14),
(155, 1, 25.3350, 'Merenje broj 155 u okviru laboratorijskog izvodjenja.', 15),
(156, 2, 25.4920, 'Merenje broj 156 u okviru laboratorijskog izvodjenja.', 16),
(157, 1, 25.6490, 'Merenje broj 157 u okviru laboratorijskog izvodjenja.', 17),
(158, 2, 25.8060, 'Merenje broj 158 u okviru laboratorijskog izvodjenja.', 18),
(159, 1, 25.9630, 'Merenje broj 159 u okviru laboratorijskog izvodjenja.', 19),
(160, 2, 26.1200, 'Merenje broj 160 u okviru laboratorijskog izvodjenja.', 20),
(161, 1, 26.2770, 'Merenje broj 161 u okviru laboratorijskog izvodjenja.', 1),
(162, 2, 26.4340, 'Merenje broj 162 u okviru laboratorijskog izvodjenja.', 2),
(163, 1, 26.5910, 'Merenje broj 163 u okviru laboratorijskog izvodjenja.', 3),
(164, 2, 26.7480, 'Merenje broj 164 u okviru laboratorijskog izvodjenja.', 4),
(165, 1, 26.9050, 'Merenje broj 165 u okviru laboratorijskog izvodjenja.', 5),
(166, 2, 27.0620, 'Merenje broj 166 u okviru laboratorijskog izvodjenja.', 6),
(167, 1, 27.2190, 'Merenje broj 167 u okviru laboratorijskog izvodjenja.', 7),
(168, 2, 27.3760, 'Merenje broj 168 u okviru laboratorijskog izvodjenja.', 8),
(169, 1, 27.5330, 'Merenje broj 169 u okviru laboratorijskog izvodjenja.', 9),
(170, 2, 27.6900, 'Merenje broj 170 u okviru laboratorijskog izvodjenja.', 10),
(171, 1, 27.8470, 'Merenje broj 171 u okviru laboratorijskog izvodjenja.', 11),
(172, 2, 28.0040, 'Merenje broj 172 u okviru laboratorijskog izvodjenja.', 12),
(173, 1, 28.1610, 'Merenje broj 173 u okviru laboratorijskog izvodjenja.', 13),
(174, 2, 28.3180, 'Merenje broj 174 u okviru laboratorijskog izvodjenja.', 14),
(175, 1, 28.4750, 'Merenje broj 175 u okviru laboratorijskog izvodjenja.', 15),
(176, 2, 28.6320, 'Merenje broj 176 u okviru laboratorijskog izvodjenja.', 16),
(177, 1, 28.7890, 'Merenje broj 177 u okviru laboratorijskog izvodjenja.', 17),
(178, 2, 28.9460, 'Merenje broj 178 u okviru laboratorijskog izvodjenja.', 18),
(179, 1, 29.1030, 'Merenje broj 179 u okviru laboratorijskog izvodjenja.', 19),
(180, 2, 29.2600, 'Merenje broj 180 u okviru laboratorijskog izvodjenja.', 20),
(181, 1, 29.4170, 'Merenje broj 181 u okviru laboratorijskog izvodjenja.', 1),
(182, 2, 29.5740, 'Merenje broj 182 u okviru laboratorijskog izvodjenja.', 2),
(183, 1, 29.7310, 'Merenje broj 183 u okviru laboratorijskog izvodjenja.', 3),
(184, 2, 29.8880, 'Merenje broj 184 u okviru laboratorijskog izvodjenja.', 4),
(185, 1, 30.0450, 'Merenje broj 185 u okviru laboratorijskog izvodjenja.', 5),
(186, 2, 30.2020, 'Merenje broj 186 u okviru laboratorijskog izvodjenja.', 6),
(187, 1, 30.3590, 'Merenje broj 187 u okviru laboratorijskog izvodjenja.', 7),
(188, 2, 30.5160, 'Merenje broj 188 u okviru laboratorijskog izvodjenja.', 8),
(189, 1, 30.6730, 'Merenje broj 189 u okviru laboratorijskog izvodjenja.', 9),
(190, 2, 30.8300, 'Merenje broj 190 u okviru laboratorijskog izvodjenja.', 10),
(191, 1, 30.9870, 'Merenje broj 191 u okviru laboratorijskog izvodjenja.', 11),
(192, 2, 31.1440, 'Merenje broj 192 u okviru laboratorijskog izvodjenja.', 12),
(193, 1, 31.3010, 'Merenje broj 193 u okviru laboratorijskog izvodjenja.', 13),
(194, 2, 31.4580, 'Merenje broj 194 u okviru laboratorijskog izvodjenja.', 14),
(195, 1, 31.6150, 'Merenje broj 195 u okviru laboratorijskog izvodjenja.', 15),
(196, 2, 31.7720, 'Merenje broj 196 u okviru laboratorijskog izvodjenja.', 16),
(197, 1, 31.9290, 'Merenje broj 197 u okviru laboratorijskog izvodjenja.', 17),
(198, 2, 32.0860, 'Merenje broj 198 u okviru laboratorijskog izvodjenja.', 18),
(199, 1, 32.2430, 'Merenje broj 199 u okviru laboratorijskog izvodjenja.', 19),
(200, 2, 32.4000, 'Merenje broj 200 u okviru laboratorijskog izvodjenja.', 20),
(201, 1, 32.5570, 'Merenje broj 201 u okviru laboratorijskog izvodjenja.', 1),
(202, 2, 32.7140, 'Merenje broj 202 u okviru laboratorijskog izvodjenja.', 2),
(203, 1, 32.8710, 'Merenje broj 203 u okviru laboratorijskog izvodjenja.', 3),
(204, 2, 33.0280, 'Merenje broj 204 u okviru laboratorijskog izvodjenja.', 4),
(205, 1, 33.1850, 'Merenje broj 205 u okviru laboratorijskog izvodjenja.', 5),
(206, 2, 33.3420, 'Merenje broj 206 u okviru laboratorijskog izvodjenja.', 6),
(207, 1, 33.4990, 'Merenje broj 207 u okviru laboratorijskog izvodjenja.', 7),
(208, 2, 33.6560, 'Merenje broj 208 u okviru laboratorijskog izvodjenja.', 8),
(209, 1, 33.8130, 'Merenje broj 209 u okviru laboratorijskog izvodjenja.', 9),
(210, 2, 33.9700, 'Merenje broj 210 u okviru laboratorijskog izvodjenja.', 10),
(211, 1, 34.1270, 'Merenje broj 211 u okviru laboratorijskog izvodjenja.', 11),
(212, 2, 34.2840, 'Merenje broj 212 u okviru laboratorijskog izvodjenja.', 12),
(213, 1, 34.4410, 'Merenje broj 213 u okviru laboratorijskog izvodjenja.', 13),
(214, 2, 34.5980, 'Merenje broj 214 u okviru laboratorijskog izvodjenja.', 14),
(215, 1, 34.7550, 'Merenje broj 215 u okviru laboratorijskog izvodjenja.', 15),
(216, 2, 34.9120, 'Merenje broj 216 u okviru laboratorijskog izvodjenja.', 16),
(217, 1, 35.0690, 'Merenje broj 217 u okviru laboratorijskog izvodjenja.', 17),
(218, 2, 35.2260, 'Merenje broj 218 u okviru laboratorijskog izvodjenja.', 18),
(219, 1, 35.3830, 'Merenje broj 219 u okviru laboratorijskog izvodjenja.', 19),
(220, 2, 35.5400, 'Merenje broj 220 u okviru laboratorijskog izvodjenja.', 20),
(221, 1, 35.6970, 'Merenje broj 221 u okviru laboratorijskog izvodjenja.', 1),
(222, 2, 35.8540, 'Merenje broj 222 u okviru laboratorijskog izvodjenja.', 2),
(223, 1, 36.0110, 'Merenje broj 223 u okviru laboratorijskog izvodjenja.', 3),
(224, 2, 36.1680, 'Merenje broj 224 u okviru laboratorijskog izvodjenja.', 4),
(225, 1, 36.3250, 'Merenje broj 225 u okviru laboratorijskog izvodjenja.', 5),
(226, 2, 36.4820, 'Merenje broj 226 u okviru laboratorijskog izvodjenja.', 6),
(227, 1, 36.6390, 'Merenje broj 227 u okviru laboratorijskog izvodjenja.', 7),
(228, 2, 36.7960, 'Merenje broj 228 u okviru laboratorijskog izvodjenja.', 8),
(229, 1, 36.9530, 'Merenje broj 229 u okviru laboratorijskog izvodjenja.', 9),
(230, 2, 37.1100, 'Merenje broj 230 u okviru laboratorijskog izvodjenja.', 10),
(231, 1, 37.2670, 'Merenje broj 231 u okviru laboratorijskog izvodjenja.', 11),
(232, 2, 37.4240, 'Merenje broj 232 u okviru laboratorijskog izvodjenja.', 12),
(233, 1, 37.5810, 'Merenje broj 233 u okviru laboratorijskog izvodjenja.', 13),
(234, 2, 37.7380, 'Merenje broj 234 u okviru laboratorijskog izvodjenja.', 14),
(235, 1, 37.8950, 'Merenje broj 235 u okviru laboratorijskog izvodjenja.', 15),
(236, 2, 38.0520, 'Merenje broj 236 u okviru laboratorijskog izvodjenja.', 16),
(237, 1, 38.2090, 'Merenje broj 237 u okviru laboratorijskog izvodjenja.', 17),
(238, 2, 38.3660, 'Merenje broj 238 u okviru laboratorijskog izvodjenja.', 18),
(239, 1, 38.5230, 'Merenje broj 239 u okviru laboratorijskog izvodjenja.', 19),
(240, 2, 38.6800, 'Merenje broj 240 u okviru laboratorijskog izvodjenja.', 20),
(241, 1, 38.8370, 'Merenje broj 241 u okviru laboratorijskog izvodjenja.', 1),
(242, 2, 38.9940, 'Merenje broj 242 u okviru laboratorijskog izvodjenja.', 2),
(243, 1, 39.1510, 'Merenje broj 243 u okviru laboratorijskog izvodjenja.', 3),
(244, 2, 39.3080, 'Merenje broj 244 u okviru laboratorijskog izvodjenja.', 4),
(245, 1, 39.4650, 'Merenje broj 245 u okviru laboratorijskog izvodjenja.', 5),
(246, 2, 39.6220, 'Merenje broj 246 u okviru laboratorijskog izvodjenja.', 6),
(247, 1, 39.7790, 'Merenje broj 247 u okviru laboratorijskog izvodjenja.', 7),
(248, 2, 39.9360, 'Merenje broj 248 u okviru laboratorijskog izvodjenja.', 8),
(249, 1, 40.0930, 'Merenje broj 249 u okviru laboratorijskog izvodjenja.', 9),
(250, 2, 40.2500, 'Merenje broj 250 u okviru laboratorijskog izvodjenja.', 10),
(251, 1, 40.4070, 'Merenje broj 251 u okviru laboratorijskog izvodjenja.', 11),
(252, 2, 40.5640, 'Merenje broj 252 u okviru laboratorijskog izvodjenja.', 12),
(253, 1, 40.7210, 'Merenje broj 253 u okviru laboratorijskog izvodjenja.', 13),
(254, 2, 40.8780, 'Merenje broj 254 u okviru laboratorijskog izvodjenja.', 14),
(255, 1, 41.0350, 'Merenje broj 255 u okviru laboratorijskog izvodjenja.', 15),
(256, 2, 41.1920, 'Merenje broj 256 u okviru laboratorijskog izvodjenja.', 16),
(257, 1, 41.3490, 'Merenje broj 257 u okviru laboratorijskog izvodjenja.', 17),
(258, 2, 41.5060, 'Merenje broj 258 u okviru laboratorijskog izvodjenja.', 18),
(259, 1, 41.6630, 'Merenje broj 259 u okviru laboratorijskog izvodjenja.', 19),
(260, 2, 41.8200, 'Merenje broj 260 u okviru laboratorijskog izvodjenja.', 20),
(261, 1, 41.9770, 'Merenje broj 261 u okviru laboratorijskog izvodjenja.', 1),
(262, 2, 42.1340, 'Merenje broj 262 u okviru laboratorijskog izvodjenja.', 2),
(263, 1, 42.2910, 'Merenje broj 263 u okviru laboratorijskog izvodjenja.', 3),
(264, 2, 42.4480, 'Merenje broj 264 u okviru laboratorijskog izvodjenja.', 4),
(265, 1, 42.6050, 'Merenje broj 265 u okviru laboratorijskog izvodjenja.', 5),
(266, 2, 42.7620, 'Merenje broj 266 u okviru laboratorijskog izvodjenja.', 6),
(267, 1, 42.9190, 'Merenje broj 267 u okviru laboratorijskog izvodjenja.', 7),
(268, 2, 43.0760, 'Merenje broj 268 u okviru laboratorijskog izvodjenja.', 8),
(269, 1, 43.2330, 'Merenje broj 269 u okviru laboratorijskog izvodjenja.', 9),
(270, 2, 43.3900, 'Merenje broj 270 u okviru laboratorijskog izvodjenja.', 10),
(271, 1, 43.5470, 'Merenje broj 271 u okviru laboratorijskog izvodjenja.', 11),
(272, 2, 43.7040, 'Merenje broj 272 u okviru laboratorijskog izvodjenja.', 12),
(273, 1, 43.8610, 'Merenje broj 273 u okviru laboratorijskog izvodjenja.', 13),
(274, 2, 44.0180, 'Merenje broj 274 u okviru laboratorijskog izvodjenja.', 14),
(275, 1, 44.1750, 'Merenje broj 275 u okviru laboratorijskog izvodjenja.', 15),
(276, 2, 44.3320, 'Merenje broj 276 u okviru laboratorijskog izvodjenja.', 16),
(277, 1, 44.4890, 'Merenje broj 277 u okviru laboratorijskog izvodjenja.', 17),
(278, 2, 44.6460, 'Merenje broj 278 u okviru laboratorijskog izvodjenja.', 18),
(279, 1, 44.8030, 'Merenje broj 279 u okviru laboratorijskog izvodjenja.', 19),
(280, 2, 44.9600, 'Merenje broj 280 u okviru laboratorijskog izvodjenja.', 20),
(281, 1, 45.1170, 'Merenje broj 281 u okviru laboratorijskog izvodjenja.', 1),
(282, 2, 45.2740, 'Merenje broj 282 u okviru laboratorijskog izvodjenja.', 2),
(283, 1, 45.4310, 'Merenje broj 283 u okviru laboratorijskog izvodjenja.', 3),
(284, 2, 45.5880, 'Merenje broj 284 u okviru laboratorijskog izvodjenja.', 4),
(285, 1, 45.7450, 'Merenje broj 285 u okviru laboratorijskog izvodjenja.', 5),
(286, 2, 45.9020, 'Merenje broj 286 u okviru laboratorijskog izvodjenja.', 6),
(287, 1, 46.0590, 'Merenje broj 287 u okviru laboratorijskog izvodjenja.', 7),
(288, 2, 46.2160, 'Merenje broj 288 u okviru laboratorijskog izvodjenja.', 8),
(289, 1, 46.3730, 'Merenje broj 289 u okviru laboratorijskog izvodjenja.', 9),
(290, 2, 46.5300, 'Merenje broj 290 u okviru laboratorijskog izvodjenja.', 10),
(291, 1, 46.6870, 'Merenje broj 291 u okviru laboratorijskog izvodjenja.', 11),
(292, 2, 46.8440, 'Merenje broj 292 u okviru laboratorijskog izvodjenja.', 12),
(293, 1, 47.0010, 'Merenje broj 293 u okviru laboratorijskog izvodjenja.', 13),
(294, 2, 47.1580, 'Merenje broj 294 u okviru laboratorijskog izvodjenja.', 14),
(295, 1, 47.3150, 'Merenje broj 295 u okviru laboratorijskog izvodjenja.', 15),
(296, 2, 47.4720, 'Merenje broj 296 u okviru laboratorijskog izvodjenja.', 16),
(297, 1, 47.6290, 'Merenje broj 297 u okviru laboratorijskog izvodjenja.', 17),
(298, 2, 47.7860, 'Merenje broj 298 u okviru laboratorijskog izvodjenja.', 18),
(299, 1, 47.9430, 'Merenje broj 299 u okviru laboratorijskog izvodjenja.', 19),
(300, 2, 48.1000, 'Merenje broj 300 u okviru laboratorijskog izvodjenja.', 20);

-- --------------------------------------------------------

--
-- Table structure for table `merenje_elektricnog_kola`
--

DROP TABLE IF EXISTS `merenje_elektricnog_kola`;
CREATE TABLE `merenje_elektricnog_kola` (
  `merenje_id` int(11) NOT NULL,
  `elektricno_kolo_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merenje_elektricnog_kola`
--

INSERT INTO `merenje_elektricnog_kola` (`merenje_id`, `elektricno_kolo_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50),
(51, 51),
(52, 52),
(53, 53),
(54, 54),
(55, 55),
(56, 56),
(57, 57),
(58, 58),
(59, 59),
(60, 60),
(61, 61),
(62, 62),
(63, 63),
(64, 64),
(65, 65),
(66, 66),
(67, 67),
(68, 68),
(69, 69),
(70, 70),
(71, 71),
(72, 72),
(73, 73),
(74, 74),
(75, 75),
(76, 76),
(77, 77),
(78, 78),
(79, 79),
(80, 80),
(81, 81),
(82, 82),
(83, 83),
(84, 84),
(85, 85),
(86, 86),
(87, 87),
(88, 88),
(89, 89),
(90, 90),
(91, 91),
(92, 92),
(93, 93),
(94, 94),
(95, 95),
(96, 96),
(97, 97),
(98, 98),
(99, 99),
(100, 100);

-- --------------------------------------------------------

--
-- Table structure for table `merenje_prototipa`
--

DROP TABLE IF EXISTS `merenje_prototipa`;
CREATE TABLE `merenje_prototipa` (
  `merenje_id` int(11) NOT NULL,
  `prototip_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merenje_prototipa`
--

INSERT INTO `merenje_prototipa` (`merenje_id`, `prototip_id`) VALUES
(201, 1),
(202, 2),
(203, 3),
(204, 4),
(205, 5),
(206, 6),
(207, 7),
(208, 8),
(209, 9),
(210, 10),
(211, 11),
(212, 12),
(213, 13),
(214, 14),
(215, 15),
(216, 16),
(217, 17),
(218, 18),
(219, 19),
(220, 20),
(221, 21),
(222, 22),
(223, 23),
(224, 24),
(225, 25),
(226, 26),
(227, 27),
(228, 28),
(229, 29),
(230, 30),
(231, 31),
(232, 32),
(233, 33),
(234, 34),
(235, 35),
(236, 36),
(237, 37),
(238, 38),
(239, 39),
(240, 40),
(241, 41),
(242, 42),
(243, 43),
(244, 44),
(245, 45),
(246, 46),
(247, 47),
(248, 48),
(249, 49),
(250, 50),
(251, 51),
(252, 52),
(253, 53),
(254, 54),
(255, 55),
(256, 56),
(257, 57),
(258, 58),
(259, 59),
(260, 60),
(261, 61),
(262, 62),
(263, 63),
(264, 64),
(265, 65),
(266, 66),
(267, 67),
(268, 68),
(269, 69),
(270, 70),
(271, 71),
(272, 72),
(273, 73),
(274, 74),
(275, 75),
(276, 76),
(277, 77),
(278, 78),
(279, 79),
(280, 80),
(281, 81),
(282, 82),
(283, 83),
(284, 84),
(285, 85),
(286, 86),
(287, 87),
(288, 88),
(289, 89),
(290, 90),
(291, 91),
(292, 92),
(293, 93),
(294, 94),
(295, 95),
(296, 96),
(297, 97),
(298, 98),
(299, 99),
(300, 100);

-- --------------------------------------------------------

--
-- Table structure for table `merenje_senzora`
--

DROP TABLE IF EXISTS `merenje_senzora`;
CREATE TABLE `merenje_senzora` (
  `merenje_id` int(11) NOT NULL,
  `senzor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merenje_senzora`
--

INSERT INTO `merenje_senzora` (`merenje_id`, `senzor_id`) VALUES
(101, 1),
(102, 2),
(103, 3),
(104, 4),
(105, 5),
(106, 6),
(107, 7),
(108, 8),
(109, 9),
(110, 10),
(111, 11),
(112, 12),
(113, 13),
(114, 14),
(115, 15),
(116, 16),
(117, 17),
(118, 18),
(119, 19),
(120, 20),
(121, 21),
(122, 22),
(123, 23),
(124, 24),
(125, 25),
(126, 26),
(127, 27),
(128, 28),
(129, 29),
(130, 30),
(131, 31),
(132, 32),
(133, 33),
(134, 34),
(135, 35),
(136, 36),
(137, 37),
(138, 38),
(139, 39),
(140, 40),
(141, 41),
(142, 42),
(143, 43),
(144, 44),
(145, 45),
(146, 46),
(147, 47),
(148, 48),
(149, 49),
(150, 50),
(151, 51),
(152, 52),
(153, 53),
(154, 54),
(155, 55),
(156, 56),
(157, 57),
(158, 58),
(159, 59),
(160, 60),
(161, 61),
(162, 62),
(163, 63),
(164, 64),
(165, 65),
(166, 66),
(167, 67),
(168, 68),
(169, 69),
(170, 70),
(171, 71),
(172, 72),
(173, 73),
(174, 74),
(175, 75),
(176, 76),
(177, 77),
(178, 78),
(179, 79),
(180, 80),
(181, 81),
(182, 82),
(183, 83),
(184, 84),
(185, 85),
(186, 86),
(187, 87),
(188, 88),
(189, 89),
(190, 90),
(191, 91),
(192, 92),
(193, 93),
(194, 94),
(195, 95),
(196, 96),
(197, 97),
(198, 98),
(199, 99),
(200, 100);

-- --------------------------------------------------------

--
-- Table structure for table `merna_jedinica`
--

DROP TABLE IF EXISTS `merna_jedinica`;
CREATE TABLE `merna_jedinica` (
  `merna_jedinica_id` int(11) NOT NULL,
  `naziv` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `merna_jedinica`
--

INSERT INTO `merna_jedinica` (`merna_jedinica_id`, `naziv`) VALUES
(1, 'om (Ω)'),
(2, 'amper (A)'),
(3, 'volt (V)'),
(4, 'vat (W)'),
(5, 'farad (F)'),
(6, 'henri (H)'),
(7, 'herc (Hz)'),
(8, 'kulon (C)'),
(9, 'džul (J)'),
(10, 'sekunda (s)'),
(11, 'miliamper (mA)'),
(12, 'milivolt (mV)'),
(13, 'kiloom (kΩ)'),
(14, 'megaom (MΩ)'),
(15, 'mikrofarad (µF)'),
(16, 'nanofarad (nF)'),
(17, 'milihenri (mH)'),
(18, 'stepen Celzijusa (°C)'),
(19, 'lumen (lm)'),
(20, 'procenat (%)');

-- --------------------------------------------------------

--
-- Stand-in structure for view `planirani_eksperimenti`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `planirani_eksperimenti`;
CREATE TABLE `planirani_eksperimenti` (
`naziv` varchar(100)
,`ciljevi` text
,`teorijski_okvir` text
);

-- --------------------------------------------------------

--
-- Table structure for table `prototip`
--

DROP TABLE IF EXISTS `prototip`;
CREATE TABLE `prototip` (
  `prototip_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `prototip`
--

INSERT INTO `prototip` (`prototip_id`, `naziv`, `opis`) VALUES
(1, 'Modul delitelja napona', 'Mali prototip sa dva otpornika namenjen proveri odnosa ulaznog i izlaznog napona.'),
(2, 'RC modul za punjenje kondenzatora', 'Sklop sa otpornikom, kondenzatorom i prekidacem za posmatranje prelaznog procesa.'),
(3, 'RC filter niskih frekvencija', 'Prototip za demonstraciju slabljenja visokofrekventnih komponenti signala.'),
(4, 'RC filter visokih frekvencija', 'Prototip koji propusta brze promene signala, a slabi spore promene.'),
(5, 'RL demonstracioni modul', 'Sklop sa kalemom i otpornikom za ispitivanje promene struje.'),
(6, 'RLC rezonantni modul', 'Prototip za posmatranje rezonantnog odziva kola sa R, L i C elementima.'),
(7, 'LED indikator napona', 'Jednostavan sklop sa LED diodom i zastitnim otpornikom.'),
(8, 'Test modul za diode', 'Prototip namenjen merenju pada napona i karakteristike diode.'),
(9, 'Zener stabilizator', 'Sklop za osnovnu stabilizaciju napona pomocu Zener diode.'),
(10, 'Mostni ispravljac', 'Prototip sa cetiri diode za ispravljanje naizmenicnog napona.'),
(11, 'Kapacitivni filter napajanja', 'Modul koji koristi kondenzator za smanjenje talasanja napona.'),
(12, 'Linearni stabilizator 5V', 'Prototip izvora stabilnog napona od 5 V za male potrosace.'),
(13, 'Podesivo laboratorijsko napajanje', 'Sklop za regulisanje izlaznog napona u ogranicenom opsegu.'),
(14, 'Modul za merenje struje preko santa', 'Prototip sa malim otpornikom za indirektno merenje struje.'),
(15, 'Elektronski osigurac', 'Zastitni prototip koji prekida ili ogranicava struju pri preopterecenju.'),
(16, 'Prenaponska zastita', 'Sklop za ogranicavanje previsokog napona na ulazu uredjaja.'),
(17, 'Zastita od obrnutog polariteta', 'Prototip koji stiti elektronsko kolo od pogresno povezanog napajanja.'),
(18, 'Tranzistorski prekidac', 'Modul za ukljucivanje potrosaca pomocu upravljackog signala.'),
(19, 'Relejni upravljacki modul', 'Sklop koji pomocu tranzistora aktivira relej za vece opterecenje.'),
(20, 'PWM upravljac LED diode', 'Prototip za promenu osvetljaja LED diode pomocu PWM signala.'),
(21, 'PWM regulator DC motora', 'Sklop za regulaciju brzine jednosmernog motora.'),
(22, 'Generator pravougaonog signala', 'Modul za generisanje periodicnog digitalnog signala.'),
(23, 'Astabilni multivibrator', 'Tranzistorski oscilator za dobijanje pravougaonog signala.'),
(24, 'Bistabilni tranzistorski sklop', 'Prototip sa dva stabilna stanja za demonstraciju memorijskog efekta.'),
(25, 'Operacioni pojacavac invertujuci', 'Modul za pojacanje signala sa promenom faze.'),
(26, 'Operacioni pojacavac neinvertujuci', 'Modul za pojacanje signala bez promene faze.'),
(27, 'Komparator napona', 'Prototip koji poredi ulazni i referentni napon.'),
(28, 'Integrator signala', 'Sklop za dobijanje izlaza proporcionalnog integralu ulaza.'),
(29, 'Diferencijator signala', 'Sklop koji reaguje na brze promene ulaznog napona.'),
(30, 'Senzorski modul temperature', 'Prototip za pretvaranje temperature u elektricni signal.'),
(31, 'Kalibrisani temperaturni modul', 'Modul sa senzorom temperature namenjen preciznijem ocitavanju.'),
(32, 'Fotootpornicki senzor svetlosti', 'Sklop sa LDR elementom za detekciju nivoa osvetljenja.'),
(33, 'Opticki prekidac', 'Prototip koji detektuje prekid svetlosnog snopa.'),
(34, 'Senzor vlaznosti', 'Modul za merenje vlaznosti preko promenljivog elektricnog signala.'),
(35, 'Senzor blizine', 'Sklop za detekciju objekta na malom rastojanju.'),
(36, 'Kapacitivni senzor dodira', 'Prototip koji reaguje na promenu kapacitivnosti prilikom dodira.'),
(37, 'Induktivni senzor metala', 'Modul za detekciju metalnih objekata pomocu kalema.'),
(38, 'Merni most za otpornike', 'Prototip mostnog kola za preciznije merenje nepoznatog otpora.'),
(39, 'Wheatstone-ov most', 'Klasicno mostno kolo za poredjenje otpora.'),
(40, 'Modul za proveru kontinuiteta', 'Jednostavan tester koji detektuje postojanje provodne putanje.'),
(41, 'Modul za merenje kontaktnog otpora', 'Sklop za procenu kvaliteta konektora i spojeva.'),
(42, 'Ulazna zastita mernog uredjaja', 'Prototip za ogranicavanje napona na mernom ulazu.'),
(43, 'ADC test modul', 'Sklop za poredjenje analognog napona i digitalnog ocitavanja.'),
(44, 'DAC izlazni modul', 'Prototip za proveru pretvaranja digitalne vrednosti u analogni napon.'),
(45, 'Senzorski interfejs', 'Modul koji prilagodjava izlaz senzora daljoj obradi.'),
(46, 'Pojacavac malih signala', 'Sklop za povecanje slabih analognih signala.'),
(47, 'Pojacavac za senzore', 'Prototip namenjen obradi niskonaponskih senzorskih signala.'),
(48, 'Filtracioni modul protiv suma', 'Sklop za smanjenje smetnji na mernom signalu.'),
(49, 'Dekupazni modul napajanja', 'Plocica sa kondenzatorima za stabilizaciju naponske linije.'),
(50, 'By-pass kondenzatorski modul', 'Prototip koji se postavlja blizu potrosaca radi smanjenja smetnji.'),
(51, 'Test plocica za RLC kombinacije', 'Prototipska plocica za brzo povezivanje otpornika, kalemova i kondenzatora.'),
(52, 'Breadboard merni sklop', 'Eksperimentalna plocica za brzo testiranje osnovnih elektrotehnickih veza.'),
(53, 'Modul za merenje impedanse', 'Sklop namenjen proceni odnosa napona i struje kod AC signala.'),
(54, 'Fazni pomerac', 'Prototip koji demonstrira fazni pomeraj izmedju ulaza i izlaza.'),
(55, 'Modul za merenje frekvencije', 'Sklop za obradu periodicnog signala i odredjivanje frekvencije.'),
(56, 'Detektor amplitude', 'Prototip za pracenje vršne vrednosti ulaznog signala.'),
(57, 'Prototip za merenje efektivne vrednosti', 'Sklop namenjen proceni RMS vrednosti naizmenicnog signala.'),
(58, 'Signalni kondicioner', 'Modul koji filtrira i prilagodjava signal pre merenja.'),
(59, 'Test modul za opterecenje izvora', 'Sklop sa promenljivim opterecenjem za proveru izvora napajanja.'),
(60, 'Elektronsko opterecenje', 'Prototip za kontrolisano opterecivanje izvora napona.'),
(61, 'Modul za ispitivanje baterije', 'Sklop za pracenje napona baterije tokom rada pod opterecenjem.'),
(62, 'Modul za punjenje baterije', 'Prototip koji kontrolise napon i struju punjenja baterije.'),
(63, 'Temperaturni nadzor komponente', 'Sklop za pracenje temperature aktivnog elementa tokom rada.'),
(64, 'Hladnjak test modul', 'Prototip za poredjenje temperature komponente sa razlicitim hladjenjem.'),
(65, 'Kratkospojna zastita', 'Sklop koji reaguje na nagli porast struje pri kratkom spoju.'),
(66, 'Ogranicavac struje', 'Prototip koji odrzava struju ispod zadate granice.'),
(67, 'Diferencijalni merni modul', 'Sklop za merenje razlike napona izmedju dve tacke.'),
(68, 'Referentni napon modul', 'Prototip koji obezbedjuje stabilan referentni napon za merenja.'),
(69, 'Analogni prekidac', 'Sklop za elektronsko ukljucivanje i iskljucivanje analogne putanje.'),
(70, 'Merni multiplekser', 'Modul za izbor jednog od vise analognih ulaza.'),
(71, 'Sklop za automatsko uzorkovanje', 'Prototip za prikupljanje niza mernih vrednosti.'),
(72, 'Modul za evidenciju potrosnje', 'Sklop za pracenje struje i napona tokom rada uredjaja.'),
(73, 'Mini digitalni voltmetar', 'Jednostavan prototip za prikaz izmerenog napona.'),
(74, 'Mini ampermetar', 'Sklop za prikaz izmerene struje preko sant otpornika.'),
(75, 'Tester otpornika', 'Prototip za brzu proveru vrednosti otpornika.'),
(76, 'Tester kondenzatora', 'Sklop za procenu kapacitivnosti kondenzatora.'),
(77, 'Tester kalemova', 'Prototip za osnovno merenje induktivnosti.'),
(78, 'Modul za serijske veze komponenti', 'Plocica za povezivanje elemenata u rednu kombinaciju.'),
(79, 'Modul za paralelne veze komponenti', 'Plocica za povezivanje elemenata u paralelnu kombinaciju.'),
(80, 'Mesoviti SER PAR modul', 'Prototip za kombinovanje rednih i paralelnih grana.'),
(81, 'RLC edukativna plocica', 'Nastavni modul za prikaz ponasanja R, L i C elemenata.'),
(82, 'Sklop za proveru Kirhofovih zakona', 'Prototip sa vise grana za proveru napona i struja.'),
(83, 'Sklop za proveru Omovog zakona', 'Jednostavan modul sa promenljivim naponom i otpornikom.'),
(84, 'Merni adapter za osciloskop', 'Prikljucni modul za lakse povezivanje signala na osciloskop.'),
(85, 'Adapter za multimetar', 'Prototip koji olaksava merenje struje i napona na testnim tackama.'),
(86, 'Panel sa testnim tackama', 'Plocica sa izvedenim tackama za merenje napona i signala.'),
(87, 'Modul za analizu talasanja', 'Sklop za posmatranje promenljive komponente jednosmernog napona.'),
(88, 'Modul za stabilnost napajanja', 'Prototip za proveru promena naponske linije pri opterecenju.'),
(89, 'Sklop za simulaciju opterecenja senzora', 'Modul koji menja opterecenje senzorskog izlaza.'),
(90, 'Sklop za proveru ulazne otpornosti', 'Prototip za procenu uticaja mernog uredjaja na mereno kolo.'),
(91, 'Sklop za proveru izlazne otpornosti', 'Modul za odredjivanje ponasanja izvora pri promeni opterecenja.'),
(92, 'Prototip za merenje faze', 'Sklop za poredjenje faze dva periodicna signala.'),
(93, 'Prototip za testiranje suma', 'Sklop koji omogucava posmatranje smetnji u mernom lancu.'),
(94, 'Modul za filtriranje napajanja', 'Kombinacija kondenzatora i kalema za smanjenje smetnji.'),
(95, 'LC filter modul', 'Prototip filtera koji koristi kalem i kondenzator.'),
(96, 'Sklop za testiranje oscilacija', 'Modul za posmatranje uslova nastanka oscilovanja.'),
(97, 'Prototip jednostavnog oscilatora', 'Sklop koji generise periodicni signal za laboratorijska merenja.'),
(98, 'Modul za laboratorijsku demonstraciju komponenti', 'Plocica sa otpornicima, kondenzatorima i kalemovima za vezbe.'),
(99, 'Zavrsni demonstracioni RLC sistem', 'Kompletan prototip za ispitivanje vise elektrotehnickih pojava.'),
(100, 'Zavrsni demonstracioni RLC sistem', 'Kompletan prototip namenjen za ispitivanje rednih i paralelnih kombinacija otpornika, kondenzatora i kalemova u laboratorijskim uslovima.');

-- --------------------------------------------------------

--
-- Table structure for table `resurs`
--

DROP TABLE IF EXISTS `resurs`;
CREATE TABLE `resurs` (
  `resurs_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `svojstva` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resurs`
--

INSERT INTO `resurs` (`resurs_id`, `naziv`, `svojstva`) VALUES
(1, 'Otpornici 1/4W - komplet 1', 'Set otpornika razlicitih vrednosti, tolerancija 1%, za prototipove i vezbe.'),
(2, 'Kondenzatori elektrolitski - komplet 1', 'Set elektrolitskih kondenzatora za filtriranje i testiranje napajanja.'),
(3, 'Keramicki kondenzatori - komplet 1', 'Set keramickih kondenzatora za visokofrekventne i filtracione primene.'),
(4, 'Induktivnosti - komplet 1', 'Kalemovi razlicitih induktivnosti za ispitivanje RLC kola.'),
(5, 'Breadboard ploce - komplet 1', 'Eksperimentalne ploce za brzo povezivanje komponenti bez lemljenja.'),
(6, 'Jumper zice - komplet 1', 'Musko-muske, musko-zenske i zensko-zenske zice za povezivanje kola.'),
(7, 'PCB plocice - komplet 1', 'Univerzalne stampane plocice za izradu trajnih prototipova.'),
(8, 'LEM kalaj - komplet 1', 'Materijal za lemljenje elektronskih komponenti.'),
(9, 'Fluks za lemljenje - komplet 1', 'Pomocni materijal za kvalitetnije lemljenje i popravke spojeva.'),
(10, 'Termoskupljajuca creva - komplet 1', 'Izolacioni materijal za zastitu spojeva i provodnika.'),
(11, 'Signalni kablovi - komplet 1', 'Kablovi za niskonaponska merenja i prenos signala.'),
(12, 'Koaksijalni kablovi - komplet 1', 'Kablovi za merenje signala na osciloskopu i funkcijskom generatoru.'),
(13, 'Konektori - komplet 1', 'Set banana, BNC, pin-header i terminalnih konektora.'),
(14, 'LED diode - komplet 1', 'Set LED dioda razlicitih boja za indikaciju stanja u kolu.'),
(15, 'Tranzistori - komplet 1', 'BJT i MOSFET tranzistori za pojacavacka i prekidacka kola.'),
(16, 'Operacioni pojacavaci - komplet 1', 'Integrisana kola za obradu analognih signala.'),
(17, 'Mikrokontroleri - komplet 1', 'Razvojne plocice i mikrokontroleri za upravljanje senzorima.'),
(18, 'Senzori temperature - komplet 1', 'Senzori za merenje temperature u prototipovima.'),
(19, 'Senzori svetlosti - komplet 1', 'Fotootpornici i fotodiode za optoelektronska merenja.'),
(20, 'Senzori pritiska - komplet 1', 'Senzori za ispitivanje odziva i kalibraciju mernih sistema.'),
(21, 'Otpornici 1/4W - komplet 2', 'Set otpornika razlicitih vrednosti, tolerancija 1%, za prototipove i vezbe.'),
(22, 'Kondenzatori elektrolitski - komplet 2', 'Set elektrolitskih kondenzatora za filtriranje i testiranje napajanja.'),
(23, 'Keramicki kondenzatori - komplet 2', 'Set keramickih kondenzatora za visokofrekventne i filtracione primene.'),
(24, 'Induktivnosti - komplet 2', 'Kalemovi razlicitih induktivnosti za ispitivanje RLC kola.'),
(25, 'Breadboard ploce - komplet 2', 'Eksperimentalne ploce za brzo povezivanje komponenti bez lemljenja.'),
(26, 'Jumper zice - komplet 2', 'Musko-muske, musko-zenske i zensko-zenske zice za povezivanje kola.'),
(27, 'PCB plocice - komplet 2', 'Univerzalne stampane plocice za izradu trajnih prototipova.'),
(28, 'LEM kalaj - komplet 2', 'Materijal za lemljenje elektronskih komponenti.'),
(29, 'Fluks za lemljenje - komplet 2', 'Pomocni materijal za kvalitetnije lemljenje i popravke spojeva.'),
(30, 'Termoskupljajuca creva - komplet 2', 'Izolacioni materijal za zastitu spojeva i provodnika.'),
(31, 'Signalni kablovi - komplet 2', 'Kablovi za niskonaponska merenja i prenos signala.'),
(32, 'Koaksijalni kablovi - komplet 2', 'Kablovi za merenje signala na osciloskopu i funkcijskom generatoru.'),
(33, 'Konektori - komplet 2', 'Set banana, BNC, pin-header i terminalnih konektora.'),
(34, 'LED diode - komplet 2', 'Set LED dioda razlicitih boja za indikaciju stanja u kolu.'),
(35, 'Tranzistori - komplet 2', 'BJT i MOSFET tranzistori za pojacavacka i prekidacka kola.'),
(36, 'Operacioni pojacavaci - komplet 2', 'Integrisana kola za obradu analognih signala.'),
(37, 'Mikrokontroleri - komplet 2', 'Razvojne plocice i mikrokontroleri za upravljanje senzorima.'),
(38, 'Senzori temperature - komplet 2', 'Senzori za merenje temperature u prototipovima.'),
(39, 'Senzori svetlosti - komplet 2', 'Fotootpornici i fotodiode za optoelektronska merenja.'),
(40, 'Senzori pritiska - komplet 2', 'Senzori za ispitivanje odziva i kalibraciju mernih sistema.'),
(41, 'Otpornici 1/4W - komplet 3', 'Set otpornika razlicitih vrednosti, tolerancija 1%, za prototipove i vezbe.'),
(42, 'Kondenzatori elektrolitski - komplet 3', 'Set elektrolitskih kondenzatora za filtriranje i testiranje napajanja.'),
(43, 'Keramicki kondenzatori - komplet 3', 'Set keramickih kondenzatora za visokofrekventne i filtracione primene.'),
(44, 'Induktivnosti - komplet 3', 'Kalemovi razlicitih induktivnosti za ispitivanje RLC kola.'),
(45, 'Breadboard ploce - komplet 3', 'Eksperimentalne ploce za brzo povezivanje komponenti bez lemljenja.'),
(46, 'Jumper zice - komplet 3', 'Musko-muske, musko-zenske i zensko-zenske zice za povezivanje kola.'),
(47, 'PCB plocice - komplet 3', 'Univerzalne stampane plocice za izradu trajnih prototipova.'),
(48, 'LEM kalaj - komplet 3', 'Materijal za lemljenje elektronskih komponenti.'),
(49, 'Fluks za lemljenje - komplet 3', 'Pomocni materijal za kvalitetnije lemljenje i popravke spojeva.'),
(50, 'Termoskupljajuca creva - komplet 3', 'Izolacioni materijal za zastitu spojeva i provodnika.'),
(51, 'Signalni kablovi - komplet 3', 'Kablovi za niskonaponska merenja i prenos signala.'),
(52, 'Koaksijalni kablovi - komplet 3', 'Kablovi za merenje signala na osciloskopu i funkcijskom generatoru.'),
(53, 'Konektori - komplet 3', 'Set banana, BNC, pin-header i terminalnih konektora.'),
(54, 'LED diode - komplet 3', 'Set LED dioda razlicitih boja za indikaciju stanja u kolu.'),
(55, 'Tranzistori - komplet 3', 'BJT i MOSFET tranzistori za pojacavacka i prekidacka kola.'),
(56, 'Operacioni pojacavaci - komplet 3', 'Integrisana kola za obradu analognih signala.'),
(57, 'Mikrokontroleri - komplet 3', 'Razvojne plocice i mikrokontroleri za upravljanje senzorima.'),
(58, 'Senzori temperature - komplet 3', 'Senzori za merenje temperature u prototipovima.'),
(59, 'Senzori svetlosti - komplet 3', 'Fotootpornici i fotodiode za optoelektronska merenja.'),
(60, 'Senzori pritiska - komplet 3', 'Senzori za ispitivanje odziva i kalibraciju mernih sistema.'),
(61, 'Otpornici 1/4W - komplet 4', 'Set otpornika razlicitih vrednosti, tolerancija 1%, za prototipove i vezbe.'),
(62, 'Kondenzatori elektrolitski - komplet 4', 'Set elektrolitskih kondenzatora za filtriranje i testiranje napajanja.'),
(63, 'Keramicki kondenzatori - komplet 4', 'Set keramickih kondenzatora za visokofrekventne i filtracione primene.'),
(64, 'Induktivnosti - komplet 4', 'Kalemovi razlicitih induktivnosti za ispitivanje RLC kola.'),
(65, 'Breadboard ploce - komplet 4', 'Eksperimentalne ploce za brzo povezivanje komponenti bez lemljenja.'),
(66, 'Jumper zice - komplet 4', 'Musko-muske, musko-zenske i zensko-zenske zice za povezivanje kola.'),
(67, 'PCB plocice - komplet 4', 'Univerzalne stampane plocice za izradu trajnih prototipova.'),
(68, 'LEM kalaj - komplet 4', 'Materijal za lemljenje elektronskih komponenti.'),
(69, 'Fluks za lemljenje - komplet 4', 'Pomocni materijal za kvalitetnije lemljenje i popravke spojeva.'),
(70, 'Termoskupljajuca creva - komplet 4', 'Izolacioni materijal za zastitu spojeva i provodnika.'),
(71, 'Signalni kablovi - komplet 4', 'Kablovi za niskonaponska merenja i prenos signala.'),
(72, 'Koaksijalni kablovi - komplet 4', 'Kablovi za merenje signala na osciloskopu i funkcijskom generatoru.'),
(73, 'Konektori - komplet 4', 'Set banana, BNC, pin-header i terminalnih konektora.'),
(74, 'LED diode - komplet 4', 'Set LED dioda razlicitih boja za indikaciju stanja u kolu.'),
(75, 'Tranzistori - komplet 4', 'BJT i MOSFET tranzistori za pojacavacka i prekidacka kola.'),
(76, 'Operacioni pojacavaci - komplet 4', 'Integrisana kola za obradu analognih signala.'),
(77, 'Mikrokontroleri - komplet 4', 'Razvojne plocice i mikrokontroleri za upravljanje senzorima.'),
(78, 'Senzori temperature - komplet 4', 'Senzori za merenje temperature u prototipovima.'),
(79, 'Senzori svetlosti - komplet 4', 'Fotootpornici i fotodiode za optoelektronska merenja.'),
(80, 'Senzori pritiska - komplet 4', 'Senzori za ispitivanje odziva i kalibraciju mernih sistema.'),
(81, 'Otpornici 1/4W - komplet 5', 'Set otpornika razlicitih vrednosti, tolerancija 1%, za prototipove i vezbe.'),
(82, 'Kondenzatori elektrolitski - komplet 5', 'Set elektrolitskih kondenzatora za filtriranje i testiranje napajanja.'),
(83, 'Keramicki kondenzatori - komplet 5', 'Set keramickih kondenzatora za visokofrekventne i filtracione primene.'),
(84, 'Induktivnosti - komplet 5', 'Kalemovi razlicitih induktivnosti za ispitivanje RLC kola.'),
(85, 'Breadboard ploce - komplet 5', 'Eksperimentalne ploce za brzo povezivanje komponenti bez lemljenja.'),
(86, 'Jumper zice - komplet 5', 'Musko-muske, musko-zenske i zensko-zenske zice za povezivanje kola.'),
(87, 'PCB plocice - komplet 5', 'Univerzalne stampane plocice za izradu trajnih prototipova.'),
(88, 'LEM kalaj - komplet 5', 'Materijal za lemljenje elektronskih komponenti.'),
(89, 'Fluks za lemljenje - komplet 5', 'Pomocni materijal za kvalitetnije lemljenje i popravke spojeva.'),
(90, 'Termoskupljajuca creva - komplet 5', 'Izolacioni materijal za zastitu spojeva i provodnika.'),
(91, 'Signalni kablovi - komplet 5', 'Kablovi za niskonaponska merenja i prenos signala.'),
(92, 'Koaksijalni kablovi - komplet 5', 'Kablovi za merenje signala na osciloskopu i funkcijskom generatoru.'),
(93, 'Konektori - komplet 5', 'Set banana, BNC, pin-header i terminalnih konektora.'),
(94, 'LED diode - komplet 5', 'Set LED dioda razlicitih boja za indikaciju stanja u kolu.'),
(95, 'Tranzistori - komplet 5', 'BJT i MOSFET tranzistori za pojacavacka i prekidacka kola.'),
(96, 'Operacioni pojacavaci - komplet 5', 'Integrisana kola za obradu analognih signala.'),
(97, 'Mikrokontroleri - komplet 5', 'Razvojne plocice i mikrokontroleri za upravljanje senzorima.'),
(98, 'Senzori temperature - komplet 5', 'Senzori za merenje temperature u prototipovima.'),
(99, 'Senzori svetlosti - komplet 5', 'Fotootpornici i fotodiode za optoelektronska merenja.'),
(100, 'Senzori pritiska - komplet 5', 'Senzori za ispitivanje odziva i kalibraciju mernih sistema.');

-- --------------------------------------------------------

--
-- Table structure for table `resurs_eksperiment`
--

DROP TABLE IF EXISTS `resurs_eksperiment`;
CREATE TABLE `resurs_eksperiment` (
  `eksperiment_id` int(11) NOT NULL,
  `resurs_id` int(11) NOT NULL,
  `potrebna_kolicina` decimal(15,4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resurs_eksperiment`
--

INSERT INTO `resurs_eksperiment` (`eksperiment_id`, `resurs_id`, `potrebna_kolicina`) VALUES
(1, 1, 26.0000),
(2, 8, 13.0000),
(3, 15, 22.0000),
(4, 22, 12.0000),
(5, 29, 41.0000),
(6, 36, 1.0000),
(7, 43, 34.0000),
(8, 50, 50.0000),
(9, 57, 45.0000),
(10, 64, 1.0000),
(11, 71, 22.0000),
(12, 78, 44.0000),
(13, 85, 30.0000),
(14, 92, 9.0000),
(15, 99, 15.0000),
(16, 6, 8.0000),
(17, 13, 45.0000),
(18, 20, 9.0000),
(19, 27, 39.0000),
(20, 34, 12.0000),
(21, 41, 29.0000),
(22, 48, 27.0000),
(23, 55, 21.0000),
(24, 62, 43.0000),
(25, 69, 28.0000),
(26, 76, 9.0000),
(27, 83, 20.0000),
(28, 90, 11.0000),
(29, 97, 8.0000),
(30, 4, 30.0000),
(31, 11, 22.0000),
(32, 18, 4.0000),
(33, 25, 10.0000),
(34, 32, 16.0000),
(35, 39, 29.0000),
(36, 46, 13.0000),
(37, 53, 15.0000),
(38, 60, 12.0000),
(39, 67, 1.0000),
(40, 74, 16.0000),
(41, 81, 42.0000),
(42, 88, 34.0000),
(43, 95, 30.0000),
(44, 2, 34.0000),
(45, 9, 2.0000),
(46, 16, 32.0000),
(47, 23, 46.0000),
(48, 30, 25.0000),
(49, 37, 33.0000),
(50, 44, 25.0000),
(51, 51, 31.0000),
(52, 58, 33.0000),
(53, 65, 5.0000),
(54, 72, 32.0000),
(55, 79, 10.0000),
(56, 86, 25.0000),
(57, 93, 1.0000),
(58, 100, 9.0000),
(59, 7, 9.0000),
(60, 14, 28.0000),
(61, 21, 20.0000),
(62, 28, 46.0000),
(63, 35, 42.0000),
(64, 42, 2.0000),
(65, 49, 9.0000),
(66, 56, 7.0000),
(67, 63, 36.0000),
(68, 70, 34.0000),
(69, 77, 6.0000),
(70, 84, 25.0000),
(71, 91, 19.0000),
(72, 98, 22.0000),
(73, 5, 46.0000),
(74, 12, 14.0000),
(75, 19, 28.0000),
(76, 26, 24.0000),
(77, 33, 33.0000),
(78, 40, 2.0000),
(79, 47, 30.0000),
(80, 54, 46.0000),
(81, 61, 23.0000),
(82, 68, 37.0000),
(83, 75, 21.0000),
(84, 82, 39.0000),
(85, 89, 40.0000),
(86, 96, 39.0000),
(87, 3, 25.0000),
(88, 10, 11.0000),
(89, 17, 23.0000),
(90, 24, 20.0000),
(91, 31, 44.0000),
(92, 38, 28.0000),
(93, 45, 34.0000),
(94, 52, 49.0000),
(95, 59, 37.0000),
(96, 66, 22.0000),
(97, 73, 27.0000),
(98, 80, 31.0000),
(99, 87, 3.0000),
(100, 94, 41.0000);

-- --------------------------------------------------------

--
-- Table structure for table `resurs_sesija`
--

DROP TABLE IF EXISTS `resurs_sesija`;
CREATE TABLE `resurs_sesija` (
  `sesija_id` int(11) NOT NULL,
  `resurs_id` int(11) NOT NULL,
  `potrosena_kolicina` decimal(15,4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `resurs_sesija`
--

INSERT INTO `resurs_sesija` (`sesija_id`, `resurs_id`, `potrosena_kolicina`) VALUES
(1, 1, 10.0000),
(2, 10, 6.0000),
(4, 28, 17.0000),
(5, 37, 2.0000),
(6, 46, 4.0000),
(7, 55, 10.0000),
(9, 73, 3.0000),
(10, 82, 8.0000),
(11, 91, 11.0000),
(12, 100, 19.0000),
(13, 9, 18.0000),
(14, 18, 20.0000),
(15, 27, 14.0000),
(16, 36, 9.0000),
(17, 45, 10.0000),
(18, 54, 7.0000),
(19, 63, 13.0000),
(20, 72, 13.0000),
(21, 81, 14.0000),
(22, 90, 1.0000),
(23, 99, 10.0000),
(24, 8, 17.0000),
(25, 17, 8.0000),
(26, 26, 5.0000),
(27, 35, 3.0000),
(28, 44, 13.0000),
(29, 53, 2.0000),
(30, 62, 3.0000),
(31, 71, 5.0000),
(32, 80, 11.0000),
(33, 89, 2.0000),
(34, 98, 7.0000),
(35, 7, 17.0000),
(36, 16, 11.0000),
(37, 25, 14.0000),
(38, 34, 15.0000),
(39, 43, 15.0000),
(40, 52, 14.0000),
(41, 61, 4.0000),
(42, 70, 8.0000),
(43, 79, 4.0000),
(44, 88, 14.0000),
(45, 97, 10.0000),
(46, 6, 8.0000),
(47, 15, 10.0000),
(48, 24, 13.0000),
(49, 33, 10.0000),
(50, 42, 10.0000),
(51, 51, 11.0000),
(52, 60, 4.0000),
(53, 69, 6.0000),
(54, 78, 12.0000),
(55, 87, 17.0000),
(56, 96, 15.0000),
(57, 5, 20.0000),
(58, 14, 7.0000),
(59, 23, 20.0000),
(60, 32, 11.0000),
(61, 41, 10.0000),
(62, 50, 3.0000),
(63, 59, 12.0000),
(64, 68, 7.0000),
(65, 77, 17.0000),
(66, 86, 20.0000),
(67, 95, 6.0000),
(68, 4, 13.0000),
(69, 13, 1.0000),
(70, 22, 13.0000),
(71, 31, 8.0000),
(72, 40, 14.0000),
(73, 49, 4.0000),
(74, 58, 10.0000),
(75, 67, 1.0000),
(76, 76, 15.0000),
(77, 85, 19.0000),
(78, 94, 10.0000),
(79, 3, 10.0000),
(80, 12, 18.0000),
(81, 21, 9.0000),
(82, 30, 12.0000),
(83, 39, 1.0000),
(84, 48, 16.0000),
(85, 57, 7.0000),
(86, 66, 11.0000),
(87, 75, 1.0000),
(88, 84, 12.0000),
(89, 93, 11.0000),
(90, 2, 10.0000),
(91, 11, 20.0000),
(92, 20, 16.0000),
(93, 29, 18.0000),
(94, 38, 18.0000),
(95, 47, 11.0000),
(96, 56, 10.0000),
(97, 65, 1.0000),
(98, 74, 11.0000),
(99, 83, 12.0000),
(100, 92, 15.0000);

-- --------------------------------------------------------

--
-- Table structure for table `senzor`
--

DROP TABLE IF EXISTS `senzor`;
CREATE TABLE `senzor` (
  `senzor_id` int(11) NOT NULL,
  `naziv` varchar(50) DEFAULT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `senzor`
--

INSERT INTO `senzor` (`senzor_id`, `naziv`, `opis`) VALUES
(1, 'Temperaturni senzor LM35', 'Analogni senzor za merenje temperature u elektronskim kolima.'),
(2, 'Temperaturni senzor DHT11', 'Digitalni senzor za merenje temperature i vlažnosti vazduha.'),
(3, 'Temperaturni senzor DHT22', 'Precizniji digitalni senzor temperature i vlažnosti.'),
(4, 'Termistor NTC 10k', 'Senzor čiji se otpor menja u zavisnosti od temperature.'),
(5, 'Termistor PTC', 'Senzor kod koga otpor raste sa porastom temperature.'),
(6, 'Senzor vlažnosti zemljišta', 'Koristi se za merenje količine vlage u zemljištu.'),
(7, 'Senzor vlažnosti vazduha', 'Meri relativnu vlažnost vazduha u prostoriji ili laboratoriji.'),
(8, 'Fotootpornik LDR', 'Senzor svetlosti čiji se otpor menja u zavisnosti od osvetljenja.'),
(9, 'Fotodioda', 'Poluprovodnički senzor za detekciju svetlosti.'),
(10, 'Fototranzistor', 'Senzor svetlosti sa većim pojačanjem od fotodiode.'),
(11, 'PIR senzor pokreta', 'Detektuje pokret na osnovu infracrvenog zračenja tela.'),
(12, 'Ultrazvučni senzor HC-SR04', 'Meri rastojanje pomoću ultrazvučnih talasa.'),
(13, 'Infracrveni senzor prepreke', 'Koristi se za detekciju prepreka na maloj udaljenosti.'),
(14, 'Senzor blizine induktivni', 'Detektuje metalne objekte bez fizičkog kontakta.'),
(15, 'Senzor blizine kapacitivni', 'Detektuje predmete na osnovu promene kapacitivnosti.'),
(16, 'Hall senzor', 'Detektuje magnetno polje i koristi se za merenje položaja ili brzine.'),
(17, 'Magnetni reed senzor', 'Prekidački senzor koji reaguje na prisustvo magneta.'),
(18, 'Akcelerometar MPU6050', 'Meri ubrzanje po više osa i koristi se u sistemima za orijentaciju.'),
(19, 'Žiroskop MPU6050', 'Meri ugaonu brzinu i promenu orijentacije.'),
(20, 'IMU senzor', 'Kombinuje akcelerometar, žiroskop i često magnetometar.'),
(21, 'Senzor pritiska BMP180', 'Digitalni senzor atmosferskog pritiska.'),
(22, 'Senzor pritiska BMP280', 'Precizniji senzor pritiska i temperature.'),
(23, 'Senzor pritiska vode', 'Koristi se za merenje pritiska u cevima ili rezervoarima.'),
(24, 'Senzor protoka vode', 'Meri količinu vode koja protiče kroz cev.'),
(25, 'Senzor nivoa vode', 'Detektuje nivo tečnosti u posudi ili rezervoaru.'),
(26, 'Plovni senzor nivoa', 'Mehanički senzor za detekciju nivoa tečnosti.'),
(27, 'Senzor kiše', 'Detektuje prisustvo vode ili kapljica kiše na površini.'),
(28, 'Senzor gasa MQ-2', 'Detektuje dim, LPG, metan i zapaljive gasove.'),
(29, 'Senzor gasa MQ-3', 'Koristi se za detekciju alkohola u vazduhu.'),
(30, 'Senzor gasa MQ-7', 'Detektuje ugljen-monoksid.'),
(31, 'Senzor gasa MQ-135', 'Koristi se za detekciju kvaliteta vazduha i štetnih gasova.'),
(32, 'Senzor dima', 'Detektuje prisustvo dima u prostoriji.'),
(33, 'Senzor plamena', 'Detektuje infracrveno zračenje koje emituje plamen.'),
(34, 'Mikrofon senzor zvuka', 'Detektuje nivo zvuka u okolini.'),
(35, 'Senzor buke', 'Koristi se za merenje jačine zvuka.'),
(36, 'Senzor vibracija SW-420', 'Detektuje vibracije i udarce.'),
(37, 'Piezo senzor', 'Generiše električni signal pri pritisku ili vibraciji.'),
(38, 'Senzor sile FSR', 'Meri pritisak ili silu preko promene otpornosti.'),
(39, 'Load cell senzor', 'Koristi se za merenje mase ili sile.'),
(40, 'Senzor težine HX711', 'Modul za očitavanje signala sa load cell senzora.'),
(41, 'Senzor napona', 'Koristi se za merenje električnog napona u kolu.'),
(42, 'Senzor struje ACS712', 'Meri jednosmernu ili naizmeničnu struju.'),
(43, 'Senzor struje ACS758', 'Koristi se za merenje većih struja.'),
(44, 'Senzor snage', 'Meri električnu snagu potrošača.'),
(45, 'Senzor otpora', 'Koristi se za određivanje vrednosti električnog otpora.'),
(46, 'Senzor kapacitivnosti', 'Meri kapacitivnost elektronskih komponenti.'),
(47, 'Senzor induktivnosti', 'Koristi se za merenje induktivnosti kalemova.'),
(48, 'Senzor frekvencije', 'Meri frekvenciju električnog signala.'),
(49, 'Senzor faznog pomaka', 'Koristi se za određivanje fazne razlike između signala.'),
(50, 'Senzor impulsa', 'Detektuje digitalne impulse u elektronskom kolu.'),
(51, 'Senzor brzine obrtanja', 'Meri broj obrtaja motora ili osovine.'),
(52, 'Optički enkoder', 'Koristi se za merenje položaja i brzine rotacije.'),
(53, 'Rotacioni enkoder', 'Detektuje ugaoni položaj i smer okretanja.'),
(54, 'Linearni enkoder', 'Koristi se za merenje linearnog pomeraja.'),
(55, 'Potenciometarski senzor položaja', 'Meri položaj pomoću promene otpornosti.'),
(56, 'Senzor nagiba', 'Detektuje promenu nagiba ili položaja.'),
(57, 'Senzor ugla', 'Koristi se za merenje ugaonog položaja.'),
(58, 'Senzor pomeraja', 'Meri linearno ili ugaono pomeranje objekta.'),
(59, 'Senzor udaljenosti VL53L0X', 'Laserski senzor za merenje rastojanja.'),
(60, 'ToF senzor', 'Meri udaljenost na osnovu vremena leta svetlosti.'),
(61, 'GPS modul', 'Senzor za određivanje geografske lokacije.'),
(62, 'Kompas modul HMC5883L', 'Meri smer magnetnog polja Zemlje.'),
(63, 'Magnetometar', 'Koristi se za merenje jačine i pravca magnetnog polja.'),
(64, 'Senzor boje TCS3200', 'Prepoznaje boje na osnovu intenziteta svetlosti.'),
(65, 'RGB senzor', 'Meri intenzitet crvene, zelene i plave komponente svetlosti.'),
(66, 'UV senzor', 'Detektuje intenzitet ultraljubičastog zračenja.'),
(67, 'Senzor ambijentalnog svetla', 'Meri nivo osvetljenja u okolini.'),
(68, 'Senzor prašine', 'Detektuje koncentraciju čestica prašine u vazduhu.'),
(69, 'Senzor kvaliteta vazduha', 'Koristi se za praćenje zagađenja vazduha.'),
(70, 'CO2 senzor', 'Meri koncentraciju ugljen-dioksida u vazduhu.'),
(71, 'Senzor temperature DS18B20', 'Digitalni temperaturni senzor sa jednom žicom.'),
(72, 'Termopar tip K', 'Senzor za merenje visokih temperatura.'),
(73, 'Senzor infracrvene temperature', 'Meri temperaturu objekta bez kontakta.'),
(74, 'Senzor dodira TTP223', 'Kapacitivni senzor za detekciju dodira.'),
(75, 'Kapacitivni touch senzor', 'Koristi se za upravljanje dodirom bez mehaničkog prekidača.'),
(76, 'Senzor otiska prsta', 'Biometrijski senzor za identifikaciju korisnika.'),
(77, 'RFID čitač', 'Koristi se za očitavanje RFID kartica i tagova.'),
(78, 'NFC senzor', 'Omogućava kratkodometnu bežičnu identifikaciju.'),
(79, 'Senzor zvučnog signala', 'Detektuje prisustvo određenog zvučnog nivoa.'),
(80, 'Senzor udara', 'Registruje nagle udarce ili promene ubrzanja.'),
(81, 'Senzor curenja gasa', 'Koristi se za detekciju opasnog curenja gasa.'),
(82, 'Senzor curenja vode', 'Detektuje prisustvo vode na podlozi.'),
(83, 'Senzor otvorenosti vrata', 'Detektuje da li su vrata ili poklopac otvoreni.'),
(84, 'Senzor položaja prekidača', 'Koristi se za detekciju stanja mehaničkog prekidača.'),
(85, 'Krajnji prekidač', 'Senzor za detekciju krajnjeg položaja mehanizma.'),
(86, 'Senzor linije', 'Koristi se kod robota za praćenje linije.'),
(87, 'Reflektivni optički senzor', 'Detektuje refleksiju svetlosti od površine.'),
(88, 'Senzor brzine vetra', 'Meri brzinu protoka vazduha.'),
(89, 'Senzor pravca vetra', 'Određuje smer iz kog vetar duva.'),
(90, 'Senzor vlažnosti drveta', 'Koristi se za merenje vlage u materijalima.'),
(91, 'Senzor pH vrednosti', 'Meri kiselost ili baznost tečnosti.'),
(92, 'Senzor provodljivosti tečnosti', 'Meri električnu provodljivost rastvora.'),
(93, 'Senzor zamućenosti vode', 'Meri količinu nečistoća u vodi.'),
(94, 'Senzor oksidaciono-redukcionog potencijala', 'Koristi se za analizu kvaliteta vode.'),
(95, 'Senzor rastvorenog kiseonika', 'Meri količinu kiseonika rastvorenog u tečnosti.'),
(96, 'Senzor naprezanja', 'Meri deformaciju materijala pod opterećenjem.'),
(97, 'Senzor temperature PT100', 'Precizan otpornički senzor temperature.'),
(98, 'Senzor temperature PT1000', 'Otpornički senzor temperature sa većom nominalnom otpornošću.'),
(99, 'Senzor elektromagnetnog polja', 'Meri prisustvo i jačinu elektromagnetnog zračenja.'),
(100, 'Senzor jonizujućeg zračenja', 'Koristi se za detekciju nivoa radioaktivnog zračenja.');

-- --------------------------------------------------------

--
-- Table structure for table `sesija`
--

DROP TABLE IF EXISTS `sesija`;
CREATE TABLE `sesija` (
  `sesija_id` int(11) NOT NULL,
  `izvodjenje_id` int(11) NOT NULL,
  `datum` date DEFAULT NULL,
  `vreme_pocetka` time DEFAULT NULL,
  `vreme_zavrsetka` time DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sesija`
--

INSERT INTO `sesija` (`sesija_id`, `izvodjenje_id`, `datum`, `vreme_pocetka`, `vreme_zavrsetka`, `status`) VALUES
(1, 1, '2024-03-01', '08:00:00', '10:00:00', 'zakazana'),
(2, 2, '2024-03-02', '09:00:00', '11:00:00', 'u toku'),
(4, 4, '2024-03-04', '11:00:00', '13:00:00', 'prekinuta'),
(5, 5, '2024-03-05', '12:00:00', '14:00:00', 'ponoviti'),
(6, 6, '2024-03-06', '13:00:00', '15:00:00', 'zakazana'),
(7, 7, '2024-03-07', '14:00:00', '16:00:00', 'u toku'),
(9, 9, '2024-03-09', '08:00:00', '10:00:00', 'prekinuta'),
(10, 10, '2024-03-10', '09:00:00', '11:00:00', 'ponoviti'),
(11, 11, '2024-03-11', '10:00:00', '12:00:00', 'zakazana'),
(12, 12, '2024-03-12', '11:00:00', '13:00:00', 'u toku'),
(13, 13, '2024-03-13', '12:00:00', '14:00:00', 'zavrsena'),
(14, 14, '2024-03-14', '13:00:00', '15:00:00', 'prekinuta'),
(15, 15, '2024-03-15', '14:00:00', '16:00:00', 'ponoviti'),
(16, 16, '2024-03-16', '15:00:00', '17:00:00', 'zakazana'),
(17, 17, '2024-03-17', '08:00:00', '10:00:00', 'u toku'),
(18, 18, '2024-03-18', '09:00:00', '11:00:00', 'zavrsena'),
(19, 19, '2024-03-19', '10:00:00', '12:00:00', 'prekinuta'),
(20, 20, '2024-03-20', '11:00:00', '13:00:00', 'ponoviti'),
(21, 21, '2024-03-21', '12:00:00', '14:00:00', 'zakazana'),
(22, 22, '2024-03-22', '13:00:00', '15:00:00', 'u toku'),
(23, 23, '2024-03-23', '14:00:00', '16:00:00', 'zavrsena'),
(24, 24, '2024-03-24', '15:00:00', '17:00:00', 'prekinuta'),
(25, 25, '2024-03-25', '08:00:00', '10:00:00', 'ponoviti'),
(26, 26, '2024-03-26', '09:00:00', '11:00:00', 'zakazana'),
(27, 27, '2024-03-27', '10:00:00', '12:00:00', 'u toku'),
(28, 28, '2024-03-28', '11:00:00', '13:00:00', 'zavrsena'),
(29, 29, '2024-03-29', '12:00:00', '14:00:00', 'prekinuta'),
(30, 30, '2024-03-30', '13:00:00', '15:00:00', 'ponoviti'),
(31, 31, '2024-03-31', '14:00:00', '16:00:00', 'zakazana'),
(32, 32, '2024-04-01', '15:00:00', '17:00:00', 'u toku'),
(33, 33, '2024-04-02', '08:00:00', '10:00:00', 'zavrsena'),
(34, 34, '2024-04-03', '09:00:00', '11:00:00', 'prekinuta'),
(35, 35, '2024-04-04', '10:00:00', '12:00:00', 'ponoviti'),
(36, 36, '2024-04-05', '11:00:00', '13:00:00', 'zakazana'),
(37, 37, '2024-04-06', '12:00:00', '14:00:00', 'u toku'),
(38, 38, '2024-04-07', '13:00:00', '15:00:00', 'zavrsena'),
(39, 39, '2024-04-08', '14:00:00', '16:00:00', 'prekinuta'),
(40, 40, '2024-04-09', '15:00:00', '17:00:00', 'ponoviti'),
(41, 41, '2024-04-10', '08:00:00', '10:00:00', 'zakazana'),
(42, 42, '2024-04-11', '09:00:00', '11:00:00', 'u toku'),
(43, 43, '2024-04-12', '10:00:00', '12:00:00', 'zavrsena'),
(44, 44, '2024-04-13', '11:00:00', '13:00:00', 'prekinuta'),
(45, 45, '2024-04-14', '12:00:00', '14:00:00', 'ponoviti'),
(46, 46, '2024-04-15', '13:00:00', '15:00:00', 'zakazana'),
(47, 47, '2024-04-16', '14:00:00', '16:00:00', 'u toku'),
(48, 48, '2024-04-17', '15:00:00', '17:00:00', 'zavrsena'),
(49, 49, '2024-04-18', '08:00:00', '10:00:00', 'prekinuta'),
(50, 50, '2024-04-19', '09:00:00', '11:00:00', 'ponoviti'),
(51, 51, '2024-04-20', '10:00:00', '12:00:00', 'zakazana'),
(52, 52, '2024-04-21', '11:00:00', '13:00:00', 'u toku'),
(53, 53, '2024-04-22', '12:00:00', '14:00:00', 'zavrsena'),
(54, 54, '2024-04-23', '13:00:00', '15:00:00', 'prekinuta'),
(55, 55, '2024-04-24', '14:00:00', '16:00:00', 'ponoviti'),
(56, 56, '2024-04-25', '15:00:00', '17:00:00', 'zakazana'),
(57, 57, '2024-04-26', '08:00:00', '10:00:00', 'u toku'),
(58, 58, '2024-04-27', '09:00:00', '11:00:00', 'zavrsena'),
(59, 59, '2024-04-28', '10:00:00', '12:00:00', 'prekinuta'),
(60, 60, '2024-04-29', '11:00:00', '13:00:00', 'ponoviti'),
(61, 61, '2024-04-30', '12:00:00', '14:00:00', 'zakazana'),
(62, 62, '2024-05-01', '13:00:00', '15:00:00', 'u toku'),
(63, 63, '2024-05-02', '14:00:00', '16:00:00', 'zavrsena'),
(64, 64, '2024-05-03', '15:00:00', '17:00:00', 'prekinuta'),
(65, 65, '2024-05-04', '08:00:00', '10:00:00', 'ponoviti'),
(66, 66, '2024-05-05', '09:00:00', '11:00:00', 'zakazana'),
(67, 67, '2024-05-06', '10:00:00', '12:00:00', 'u toku'),
(68, 68, '2024-05-07', '11:00:00', '13:00:00', 'zavrsena'),
(69, 69, '2024-05-08', '12:00:00', '14:00:00', 'prekinuta'),
(70, 70, '2024-05-09', '13:00:00', '15:00:00', 'ponoviti'),
(71, 71, '2024-05-10', '14:00:00', '16:00:00', 'zakazana'),
(72, 72, '2024-05-11', '15:00:00', '17:00:00', 'u toku'),
(73, 73, '2024-05-12', '08:00:00', '10:00:00', 'zavrsena'),
(74, 74, '2024-05-13', '09:00:00', '11:00:00', 'prekinuta'),
(75, 75, '2024-05-14', '10:00:00', '12:00:00', 'ponoviti'),
(76, 76, '2024-05-15', '11:00:00', '13:00:00', 'zakazana'),
(77, 77, '2024-05-16', '12:00:00', '14:00:00', 'u toku'),
(78, 78, '2024-05-17', '13:00:00', '15:00:00', 'zavrsena'),
(79, 79, '2024-05-18', '14:00:00', '16:00:00', 'prekinuta'),
(80, 80, '2024-05-19', '15:00:00', '17:00:00', 'ponoviti'),
(81, 81, '2024-05-20', '08:00:00', '10:00:00', 'zakazana'),
(82, 82, '2024-05-21', '09:00:00', '11:00:00', 'u toku'),
(83, 83, '2024-05-22', '10:00:00', '12:00:00', 'zavrsena'),
(84, 84, '2024-05-23', '11:00:00', '13:00:00', 'prekinuta'),
(85, 85, '2024-05-24', '12:00:00', '14:00:00', 'ponoviti'),
(86, 86, '2024-05-25', '13:00:00', '15:00:00', 'zakazana'),
(87, 87, '2024-05-26', '14:00:00', '16:00:00', 'u toku'),
(88, 88, '2024-05-27', '15:00:00', '17:00:00', 'zavrsena'),
(89, 89, '2024-05-28', '08:00:00', '10:00:00', 'prekinuta'),
(90, 90, '2024-05-29', '09:00:00', '11:00:00', 'ponoviti'),
(91, 91, '2024-05-30', '10:00:00', '12:00:00', 'zakazana'),
(92, 92, '2024-05-31', '11:00:00', '13:00:00', 'u toku'),
(93, 93, '2024-06-01', '12:00:00', '14:00:00', 'zavrsena'),
(94, 94, '2024-06-02', '13:00:00', '15:00:00', 'prekinuta'),
(95, 95, '2024-06-03', '14:00:00', '16:00:00', 'ponoviti'),
(96, 96, '2024-06-04', '15:00:00', '17:00:00', 'zakazana'),
(97, 97, '2024-06-05', '08:00:00', '10:00:00', 'u toku'),
(98, 98, '2024-06-06', '09:00:00', '11:00:00', 'zavrsena'),
(99, 99, '2024-06-07', '10:00:00', '12:00:00', 'prekinuta'),
(100, 100, '2024-06-08', '11:00:00', '13:00:00', 'ponoviti');

-- --------------------------------------------------------

--
-- Table structure for table `status_izvodjenja`
--

DROP TABLE IF EXISTS `status_izvodjenja`;
CREATE TABLE `status_izvodjenja` (
  `status_id` int(11) NOT NULL,
  `naziv` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `status_izvodjenja`
--

INSERT INTO `status_izvodjenja` (`status_id`, `naziv`) VALUES
(3, 'otkazano'),
(1, 'planirano'),
(2, 'započeto'),
(5, 'završeno neuspešno'),
(4, 'završeno uspešno');

-- --------------------------------------------------------

--
-- Table structure for table `teorija`
--

DROP TABLE IF EXISTS `teorija`;
CREATE TABLE `teorija` (
  `teorija_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `identifikacioni_podaci` varchar(100) DEFAULT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teorija`
--

INSERT INTO `teorija` (`teorija_id`, `naziv`, `identifikacioni_podaci`, `opis`) VALUES
(1, 'Omov zakon - primena 1', 'TEO-EL-001', 'Veza izmedju napona, struje i otpornosti u linearnim otpornim kolima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(2, 'Kirhofov zakon struja - primena 1', 'TEO-EL-002', 'Zbir struja u cvoru jednak je nuli u stacionarnom rezimu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(3, 'Kirhofov zakon napona - primena 1', 'TEO-EL-003', 'Algebarski zbir napona u zatvorenoj konturi jednak je nuli. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(4, 'Tevenenova teorema - primena 1', 'TEO-EL-004', 'Slozeno linearno kolo moze se zameniti ekvivalentnim izvorom napona i otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(5, 'Nortonova teorema - primena 1', 'TEO-EL-005', 'Linearno kolo moze se zameniti izvorom struje i paralelnim otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(6, 'RC prelazni proces - primena 1', 'TEO-EL-006', 'Analiza punjenja i praznjenja kondenzatora kroz otpornik. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(7, 'RL prelazni proces - primena 1', 'TEO-EL-007', 'Analiza promene struje kroz kalem u vremenskom domenu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(8, 'RLC rezonanca - primena 1', 'TEO-EL-008', 'Pojava rezonantne frekvencije u kolima sa otpornikom, kalemom i kondenzatorom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(9, 'Filtri prvog reda - primena 1', 'TEO-EL-009', 'Niskopropusni i visokopropusni filtri zasnovani na RC elementima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(10, 'Operacioni pojacavac - primena 1', 'TEO-EL-010', 'Model idealnog op-pojacavaca i osnovne konfiguracije pojacanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(11, 'Diodna karakteristika - primena 1', 'TEO-EL-011', 'Zavisnost struje diode od napona u propusnom i zapornom smeru. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(12, 'Tranzistor kao prekidac - primena 1', 'TEO-EL-012', 'Rad BJT ili MOSFET tranzistora u rezimu zasicenja i odsecanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(13, 'PWM upravljanje - primena 1', 'TEO-EL-013', 'Regulacija srednje vrednosti napona pomocu sirinsko-impulsne modulacije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(14, 'AD konverzija - primena 1', 'TEO-EL-014', 'Pretvaranje analognog signala u digitalni oblik i uticaj rezolucije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(15, 'Merni most - primena 1', 'TEO-EL-015', 'Vinstonov most i metode preciznog merenja otpornosti. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(16, 'Senzorska kalibracija - primena 1', 'TEO-EL-016', 'Odredjivanje zavisnosti izlaznog signala senzora od merene velicine. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(17, 'Elektromagnetna indukcija - primena 1', 'TEO-EL-017', 'Nastanak elektromotorne sile usled promene magnetskog fluksa. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(18, 'Impedansa u AC kolima - primena 1', 'TEO-EL-018', 'Kompleksni otpor u kolima sa otpornicima, kalemovima i kondenzatorima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(19, 'Frekvencijski odziv - primena 1', 'TEO-EL-019', 'Analiza promene amplitude i faze u zavisnosti od frekvencije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(20, 'Merno opterecenje - primena 1', 'TEO-EL-020', 'Uticaj unutrasnje otpornosti mernog instrumenta na rezultat merenja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(21, 'Omov zakon - primena 2', 'TEO-EL-021', 'Veza izmedju napona, struje i otpornosti u linearnim otpornim kolima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(22, 'Kirhofov zakon struja - primena 2', 'TEO-EL-022', 'Zbir struja u cvoru jednak je nuli u stacionarnom rezimu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(23, 'Kirhofov zakon napona - primena 2', 'TEO-EL-023', 'Algebarski zbir napona u zatvorenoj konturi jednak je nuli. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(24, 'Tevenenova teorema - primena 2', 'TEO-EL-024', 'Slozeno linearno kolo moze se zameniti ekvivalentnim izvorom napona i otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(25, 'Nortonova teorema - primena 2', 'TEO-EL-025', 'Linearno kolo moze se zameniti izvorom struje i paralelnim otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(26, 'RC prelazni proces - primena 2', 'TEO-EL-026', 'Analiza punjenja i praznjenja kondenzatora kroz otpornik. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(27, 'RL prelazni proces - primena 2', 'TEO-EL-027', 'Analiza promene struje kroz kalem u vremenskom domenu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(28, 'RLC rezonanca - primena 2', 'TEO-EL-028', 'Pojava rezonantne frekvencije u kolima sa otpornikom, kalemom i kondenzatorom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(29, 'Filtri prvog reda - primena 2', 'TEO-EL-029', 'Niskopropusni i visokopropusni filtri zasnovani na RC elementima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(30, 'Operacioni pojacavac - primena 2', 'TEO-EL-030', 'Model idealnog op-pojacavaca i osnovne konfiguracije pojacanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(31, 'Diodna karakteristika - primena 2', 'TEO-EL-031', 'Zavisnost struje diode od napona u propusnom i zapornom smeru. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(32, 'Tranzistor kao prekidac - primena 2', 'TEO-EL-032', 'Rad BJT ili MOSFET tranzistora u rezimu zasicenja i odsecanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(33, 'PWM upravljanje - primena 2', 'TEO-EL-033', 'Regulacija srednje vrednosti napona pomocu sirinsko-impulsne modulacije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(34, 'AD konverzija - primena 2', 'TEO-EL-034', 'Pretvaranje analognog signala u digitalni oblik i uticaj rezolucije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(35, 'Merni most - primena 2', 'TEO-EL-035', 'Vinstonov most i metode preciznog merenja otpornosti. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(36, 'Senzorska kalibracija - primena 2', 'TEO-EL-036', 'Odredjivanje zavisnosti izlaznog signala senzora od merene velicine. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(37, 'Elektromagnetna indukcija - primena 2', 'TEO-EL-037', 'Nastanak elektromotorne sile usled promene magnetskog fluksa. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(38, 'Impedansa u AC kolima - primena 2', 'TEO-EL-038', 'Kompleksni otpor u kolima sa otpornicima, kalemovima i kondenzatorima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(39, 'Frekvencijski odziv - primena 2', 'TEO-EL-039', 'Analiza promene amplitude i faze u zavisnosti od frekvencije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(40, 'Merno opterecenje - primena 2', 'TEO-EL-040', 'Uticaj unutrasnje otpornosti mernog instrumenta na rezultat merenja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(41, 'Omov zakon - primena 3', 'TEO-EL-041', 'Veza izmedju napona, struje i otpornosti u linearnim otpornim kolima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(42, 'Kirhofov zakon struja - primena 3', 'TEO-EL-042', 'Zbir struja u cvoru jednak je nuli u stacionarnom rezimu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(43, 'Kirhofov zakon napona - primena 3', 'TEO-EL-043', 'Algebarski zbir napona u zatvorenoj konturi jednak je nuli. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(44, 'Tevenenova teorema - primena 3', 'TEO-EL-044', 'Slozeno linearno kolo moze se zameniti ekvivalentnim izvorom napona i otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(45, 'Nortonova teorema - primena 3', 'TEO-EL-045', 'Linearno kolo moze se zameniti izvorom struje i paralelnim otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(46, 'RC prelazni proces - primena 3', 'TEO-EL-046', 'Analiza punjenja i praznjenja kondenzatora kroz otpornik. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(47, 'RL prelazni proces - primena 3', 'TEO-EL-047', 'Analiza promene struje kroz kalem u vremenskom domenu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(48, 'RLC rezonanca - primena 3', 'TEO-EL-048', 'Pojava rezonantne frekvencije u kolima sa otpornikom, kalemom i kondenzatorom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(49, 'Filtri prvog reda - primena 3', 'TEO-EL-049', 'Niskopropusni i visokopropusni filtri zasnovani na RC elementima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(50, 'Operacioni pojacavac - primena 3', 'TEO-EL-050', 'Model idealnog op-pojacavaca i osnovne konfiguracije pojacanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(51, 'Diodna karakteristika - primena 3', 'TEO-EL-051', 'Zavisnost struje diode od napona u propusnom i zapornom smeru. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(52, 'Tranzistor kao prekidac - primena 3', 'TEO-EL-052', 'Rad BJT ili MOSFET tranzistora u rezimu zasicenja i odsecanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(53, 'PWM upravljanje - primena 3', 'TEO-EL-053', 'Regulacija srednje vrednosti napona pomocu sirinsko-impulsne modulacije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(54, 'AD konverzija - primena 3', 'TEO-EL-054', 'Pretvaranje analognog signala u digitalni oblik i uticaj rezolucije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(55, 'Merni most - primena 3', 'TEO-EL-055', 'Vinstonov most i metode preciznog merenja otpornosti. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(56, 'Senzorska kalibracija - primena 3', 'TEO-EL-056', 'Odredjivanje zavisnosti izlaznog signala senzora od merene velicine. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(57, 'Elektromagnetna indukcija - primena 3', 'TEO-EL-057', 'Nastanak elektromotorne sile usled promene magnetskog fluksa. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(58, 'Impedansa u AC kolima - primena 3', 'TEO-EL-058', 'Kompleksni otpor u kolima sa otpornicima, kalemovima i kondenzatorima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(59, 'Frekvencijski odziv - primena 3', 'TEO-EL-059', 'Analiza promene amplitude i faze u zavisnosti od frekvencije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(60, 'Merno opterecenje - primena 3', 'TEO-EL-060', 'Uticaj unutrasnje otpornosti mernog instrumenta na rezultat merenja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(61, 'Omov zakon - primena 4', 'TEO-EL-061', 'Veza izmedju napona, struje i otpornosti u linearnim otpornim kolima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(62, 'Kirhofov zakon struja - primena 4', 'TEO-EL-062', 'Zbir struja u cvoru jednak je nuli u stacionarnom rezimu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(63, 'Kirhofov zakon napona - primena 4', 'TEO-EL-063', 'Algebarski zbir napona u zatvorenoj konturi jednak je nuli. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(64, 'Tevenenova teorema - primena 4', 'TEO-EL-064', 'Slozeno linearno kolo moze se zameniti ekvivalentnim izvorom napona i otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(65, 'Nortonova teorema - primena 4', 'TEO-EL-065', 'Linearno kolo moze se zameniti izvorom struje i paralelnim otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(66, 'RC prelazni proces - primena 4', 'TEO-EL-066', 'Analiza punjenja i praznjenja kondenzatora kroz otpornik. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(67, 'RL prelazni proces - primena 4', 'TEO-EL-067', 'Analiza promene struje kroz kalem u vremenskom domenu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(68, 'RLC rezonanca - primena 4', 'TEO-EL-068', 'Pojava rezonantne frekvencije u kolima sa otpornikom, kalemom i kondenzatorom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(69, 'Filtri prvog reda - primena 4', 'TEO-EL-069', 'Niskopropusni i visokopropusni filtri zasnovani na RC elementima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(70, 'Operacioni pojacavac - primena 4', 'TEO-EL-070', 'Model idealnog op-pojacavaca i osnovne konfiguracije pojacanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(71, 'Diodna karakteristika - primena 4', 'TEO-EL-071', 'Zavisnost struje diode od napona u propusnom i zapornom smeru. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(72, 'Tranzistor kao prekidac - primena 4', 'TEO-EL-072', 'Rad BJT ili MOSFET tranzistora u rezimu zasicenja i odsecanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(73, 'PWM upravljanje - primena 4', 'TEO-EL-073', 'Regulacija srednje vrednosti napona pomocu sirinsko-impulsne modulacije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(74, 'AD konverzija - primena 4', 'TEO-EL-074', 'Pretvaranje analognog signala u digitalni oblik i uticaj rezolucije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(75, 'Merni most - primena 4', 'TEO-EL-075', 'Vinstonov most i metode preciznog merenja otpornosti. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(76, 'Senzorska kalibracija - primena 4', 'TEO-EL-076', 'Odredjivanje zavisnosti izlaznog signala senzora od merene velicine. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(77, 'Elektromagnetna indukcija - primena 4', 'TEO-EL-077', 'Nastanak elektromotorne sile usled promene magnetskog fluksa. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(78, 'Impedansa u AC kolima - primena 4', 'TEO-EL-078', 'Kompleksni otpor u kolima sa otpornicima, kalemovima i kondenzatorima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(79, 'Frekvencijski odziv - primena 4', 'TEO-EL-079', 'Analiza promene amplitude i faze u zavisnosti od frekvencije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(80, 'Merno opterecenje - primena 4', 'TEO-EL-080', 'Uticaj unutrasnje otpornosti mernog instrumenta na rezultat merenja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(81, 'Omov zakon - primena 5', 'TEO-EL-081', 'Veza izmedju napona, struje i otpornosti u linearnim otpornim kolima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(82, 'Kirhofov zakon struja - primena 5', 'TEO-EL-082', 'Zbir struja u cvoru jednak je nuli u stacionarnom rezimu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(83, 'Kirhofov zakon napona - primena 5', 'TEO-EL-083', 'Algebarski zbir napona u zatvorenoj konturi jednak je nuli. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(84, 'Tevenenova teorema - primena 5', 'TEO-EL-084', 'Slozeno linearno kolo moze se zameniti ekvivalentnim izvorom napona i otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(85, 'Nortonova teorema - primena 5', 'TEO-EL-085', 'Linearno kolo moze se zameniti izvorom struje i paralelnim otporom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(86, 'RC prelazni proces - primena 5', 'TEO-EL-086', 'Analiza punjenja i praznjenja kondenzatora kroz otpornik. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(87, 'RL prelazni proces - primena 5', 'TEO-EL-087', 'Analiza promene struje kroz kalem u vremenskom domenu. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(88, 'RLC rezonanca - primena 5', 'TEO-EL-088', 'Pojava rezonantne frekvencije u kolima sa otpornikom, kalemom i kondenzatorom. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(89, 'Filtri prvog reda - primena 5', 'TEO-EL-089', 'Niskopropusni i visokopropusni filtri zasnovani na RC elementima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(90, 'Operacioni pojacavac - primena 5', 'TEO-EL-090', 'Model idealnog op-pojacavaca i osnovne konfiguracije pojacanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(91, 'Diodna karakteristika - primena 5', 'TEO-EL-091', 'Zavisnost struje diode od napona u propusnom i zapornom smeru. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(92, 'Tranzistor kao prekidac - primena 5', 'TEO-EL-092', 'Rad BJT ili MOSFET tranzistora u rezimu zasicenja i odsecanja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(93, 'PWM upravljanje - primena 5', 'TEO-EL-093', 'Regulacija srednje vrednosti napona pomocu sirinsko-impulsne modulacije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(94, 'AD konverzija - primena 5', 'TEO-EL-094', 'Pretvaranje analognog signala u digitalni oblik i uticaj rezolucije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(95, 'Merni most - primena 5', 'TEO-EL-095', 'Vinstonov most i metode preciznog merenja otpornosti. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(96, 'Senzorska kalibracija - primena 5', 'TEO-EL-096', 'Odredjivanje zavisnosti izlaznog signala senzora od merene velicine. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(97, 'Elektromagnetna indukcija - primena 5', 'TEO-EL-097', 'Nastanak elektromotorne sile usled promene magnetskog fluksa. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(98, 'Impedansa u AC kolima - primena 5', 'TEO-EL-098', 'Kompleksni otpor u kolima sa otpornicima, kalemovima i kondenzatorima. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(99, 'Frekvencijski odziv - primena 5', 'TEO-EL-099', 'Analiza promene amplitude i faze u zavisnosti od frekvencije. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.'),
(100, 'Merno opterecenje - primena 5', 'TEO-EL-100', 'Uticaj unutrasnje otpornosti mernog instrumenta na rezultat merenja. Koristi se u elektrotehnickim merenjima, ispitivanju kola i analizi prototipova.');

-- --------------------------------------------------------

--
-- Table structure for table `tim_izvodjaca`
--

DROP TABLE IF EXISTS `tim_izvodjaca`;
CREATE TABLE `tim_izvodjaca` (
  `izvodjenje_id` int(11) NOT NULL,
  `istrazivac_id` int(11) NOT NULL,
  `opis_uloge` text DEFAULT NULL,
  `evidencije` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tim_izvodjaca`
--

INSERT INTO `tim_izvodjaca` (`izvodjenje_id`, `istrazivac_id`, `opis_uloge`, `evidencije`) VALUES
(1, 1, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(2, 3, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(3, 5, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(4, 7, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(5, 9, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(6, 11, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(7, 13, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(8, 15, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(9, 17, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(10, 19, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(11, 21, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(12, 23, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(13, 25, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(14, 27, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(15, 29, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(16, 31, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(17, 33, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(18, 35, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(19, 37, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(20, 39, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(21, 41, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(22, 43, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(23, 45, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(24, 47, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(25, 49, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(26, 51, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(27, 53, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(28, 55, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(29, 57, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(30, 59, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(31, 61, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(32, 63, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(33, 65, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(34, 67, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(35, 69, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(36, 71, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(37, 73, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(38, 75, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(39, 77, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(40, 79, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(41, 81, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(42, 83, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(43, 85, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(44, 87, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(45, 89, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(46, 91, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(47, 93, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(48, 95, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(49, 97, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(50, 99, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(51, 1, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(52, 3, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(53, 5, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(54, 7, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(55, 9, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(56, 11, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(57, 13, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(58, 15, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(59, 17, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(60, 19, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(61, 21, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(62, 23, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(63, 25, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(64, 27, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(65, 29, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(66, 31, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(67, 33, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(68, 35, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(69, 37, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(70, 39, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(71, 41, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(72, 43, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(73, 45, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(74, 47, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(75, 49, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(76, 51, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(77, 53, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(78, 55, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(79, 57, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(80, 59, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(81, 61, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(82, 63, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(83, 65, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(84, 67, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(85, 69, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(86, 71, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(87, 73, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(88, 75, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(89, 77, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(90, 79, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.'),
(91, 81, 'glavni izvodjac', 'Evidentirao parametre kola i uslove merenja.'),
(92, 83, 'asistent za merenje', 'Proverio ispravnost opreme pre pocetka rada.'),
(93, 85, 'operator opreme', 'Izvrsio seriju merenja i upisao rezultate.'),
(94, 87, 'analiticar rezultata', 'Uporedio izmerene vrednosti sa teorijskim proracunom.'),
(95, 89, 'tehnicar za pripremu kola', 'Pripremio komponente i proverio veze u kolu.'),
(96, 91, 'kontrolor bezbednosti', 'Nadgledao tok eksperimenta i evidentirao odstupanja.'),
(97, 93, 'zapisnicar merenja', 'Vodio laboratorijski zapisnik tokom izvodjenja.'),
(98, 95, 'odgovoran za kalibraciju', 'Proverio kalibraciju mernih instrumenata.'),
(99, 97, 'koordinator eksperimenta', 'Koordinisao rad tima tokom laboratorijske sesije.'),
(100, 99, 'obrada podataka', 'Obradio podatke i pripremio kratak izvestaj.');

-- --------------------------------------------------------

--
-- Table structure for table `tip_alata`
--

DROP TABLE IF EXISTS `tip_alata`;
CREATE TABLE `tip_alata` (
  `tip_alata_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL,
  `opis` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tip_alata`
--

INSERT INTO `tip_alata` (`tip_alata_id`, `naziv`, `opis`) VALUES
(1, 'Digitalni multimetar', 'Merenje napona, struje, otpora, kontinuiteta i diode.'),
(2, 'Osciloskop', 'Prikaz i analiza vremenskog oblika elektricnih signala.'),
(3, 'Funkcijski generator', 'Generisanje sinusnog, pravougaonog i trougaonog signala.'),
(4, 'Laboratorijsko napajanje', 'Podesivi izvor jednosmernog napona i struje.'),
(5, 'Lemilica', 'Lemljenje komponenti na PCB i izrada prototipova.'),
(6, 'Logicki analizator', 'Analiza digitalnih signala i komunikacionih protokola.'),
(7, 'LCR metar', 'Merenje induktivnosti, kapacitivnosti i otpornosti.'),
(8, 'Termalna kamera', 'Pregled zagrevanja komponenti i elektronike snage.'),
(9, 'Programator mikrokontrolera', 'Programiranje i debug mikrokontrolerskih sistema.'),
(10, 'Izolacioni tester', 'Provera izolacije i bezbednosti elektricnih sklopova.');

-- --------------------------------------------------------

--
-- Table structure for table `tip_merenja`
--

DROP TABLE IF EXISTS `tip_merenja`;
CREATE TABLE `tip_merenja` (
  `tip_merenja_id` int(11) NOT NULL,
  `naziv` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tip_merenja`
--

INSERT INTO `tip_merenja` (`tip_merenja_id`, `naziv`) VALUES
(1, 'merenje alatom'),
(2, 'matematicko ispitivanje');

-- --------------------------------------------------------

--
-- Structure for view `dizajneri_na_eksperimentu`
--
DROP TABLE IF EXISTS `dizajneri_na_eksperimentu`;

DROP VIEW IF EXISTS `dizajneri_na_eksperimentu`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dizajneri_na_eksperimentu`  AS SELECT `e`.`eksperiment_id` AS `eksperiment_id`, `e`.`naziv` AS `naziv`, count(`i`.`istrazivac_id`) AS `broj_istrazivaca`, group_concat(concat(`i`.`ime`,' ',`i`.`prezime`) separator ', ') AS `istrazivaci` FROM ((`eksperiment` `e` join `dizajner_eksperiment` `de` on(`e`.`eksperiment_id` = `de`.`eksperiment_id`)) join `istrazivac` `i` on(`de`.`istrazivac_id` = `i`.`istrazivac_id`)) GROUP BY `e`.`eksperiment_id` HAVING count(`i`.`istrazivac_id`) > 0 ;

-- --------------------------------------------------------

--
-- Structure for view `eksperiment_sva_kola`
--
DROP TABLE IF EXISTS `eksperiment_sva_kola`;

DROP VIEW IF EXISTS `eksperiment_sva_kola`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `eksperiment_sva_kola`  AS SELECT DISTINCT `e`.`eksperiment_id` AS `eksperiment_id`, `ek`.`elektricno_kolo_id` AS `elektricno_kolo_id`, `ek`.`naziv` AS `naziv`, `ek`.`sema_kola` AS `sema_kola` FROM ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `ispitivanje` `isp` on(`isp`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `ispitivanje_elektricnog_kola` `iek` on(`iek`.`ispitivanje_id` = `isp`.`ispitivanje_id`)) join `elektricno_kolo` `ek` on(`ek`.`elektricno_kolo_id` = `iek`.`elektricno_kolo_id`))union select distinct `e`.`eksperiment_id` AS `eksperiment_id`,`ek`.`elektricno_kolo_id` AS `elektricno_kolo_id`,`ek`.`naziv` AS `naziv`,`ek`.`sema_kola` AS `sema_kola` from ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `merenje` `m` on(`m`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `merenje_elektricnog_kola` `mek` on(`mek`.`merenje_id` = `m`.`merenje_id`)) join `elektricno_kolo` `ek` on(`ek`.`elektricno_kolo_id` = `mek`.`elektricno_kolo_id`))  ;

-- --------------------------------------------------------

--
-- Structure for view `eksperiment_svi_prototipi`
--
DROP TABLE IF EXISTS `eksperiment_svi_prototipi`;

DROP VIEW IF EXISTS `eksperiment_svi_prototipi`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `eksperiment_svi_prototipi`  AS SELECT DISTINCT `e`.`eksperiment_id` AS `eksperiment_id`, `p`.`prototip_id` AS `prototip_id`, `p`.`naziv` AS `naziv`, `p`.`opis` AS `opis`, 'ispitivanje' AS `izvor` FROM ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `ispitivanje` `isp` on(`isp`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `ispitivanje_prototipa` `isp_p` on(`isp_p`.`ispitivanje_id` = `isp`.`ispitivanje_id`)) join `prototip` `p` on(`p`.`prototip_id` = `isp_p`.`prototip_id`))union select distinct `e`.`eksperiment_id` AS `eksperiment_id`,`p`.`prototip_id` AS `prototip_id`,`p`.`naziv` AS `naziv`,`p`.`opis` AS `opis`,'merenje' AS `izvor` from ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `merenje` `m` on(`m`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `merenje_prototipa` `mp` on(`mp`.`merenje_id` = `m`.`merenje_id`)) join `prototip` `p` on(`p`.`prototip_id` = `mp`.`prototip_id`))  ;

-- --------------------------------------------------------

--
-- Structure for view `eksperiment_svi_senzori`
--
DROP TABLE IF EXISTS `eksperiment_svi_senzori`;

DROP VIEW IF EXISTS `eksperiment_svi_senzori`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `eksperiment_svi_senzori`  AS SELECT DISTINCT `e`.`eksperiment_id` AS `eksperiment_id`, `s`.`senzor_id` AS `senzor_id`, `s`.`naziv` AS `naziv`, `s`.`opis` AS `opis`, 'ispitivanje' AS `izvor` FROM ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `ispitivanje` `isp` on(`isp`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `ispitivanje_senzora` `isp_s` on(`isp_s`.`ispitivanje_id` = `isp`.`ispitivanje_id`)) join `senzor` `s` on(`s`.`senzor_id` = `isp_s`.`senzor_id`))union select distinct `e`.`eksperiment_id` AS `eksperiment_id`,`s`.`senzor_id` AS `senzor_id`,`s`.`naziv` AS `naziv`,`s`.`opis` AS `opis`,'merenje' AS `izvor` from ((((`eksperiment` `e` join `izvodjenje` `iz` on(`iz`.`eksperiment_id` = `e`.`eksperiment_id`)) join `merenje` `m` on(`m`.`izvodjenje_id` = `iz`.`izvodjenje_id`)) join `merenje_senzora` `ms` on(`ms`.`merenje_id` = `m`.`merenje_id`)) join `senzor` `s` on(`s`.`senzor_id` = `ms`.`senzor_id`))  ;

-- --------------------------------------------------------

--
-- Structure for view `izradjeni_eksperimenti`
--
DROP TABLE IF EXISTS `izradjeni_eksperimenti`;

DROP VIEW IF EXISTS `izradjeni_eksperimenti`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `izradjeni_eksperimenti`  AS SELECT `eksperiment`.`naziv` AS `naziv`, `eksperiment`.`ciljevi` AS `ciljevi`, `eksperiment`.`teorijski_okvir` AS `teorijski_okvir` FROM `eksperiment` WHERE `eksperiment`.`status` = 'zavrsen' ;

-- --------------------------------------------------------

--
-- Structure for view `planirani_eksperimenti`
--
DROP TABLE IF EXISTS `planirani_eksperimenti`;

DROP VIEW IF EXISTS `planirani_eksperimenti`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `planirani_eksperimenti`  AS SELECT `eksperiment`.`naziv` AS `naziv`, `eksperiment`.`ciljevi` AS `ciljevi`, `eksperiment`.`teorijski_okvir` AS `teorijski_okvir` FROM `eksperiment` WHERE `eksperiment`.`status` = 'planiran' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alat`
--
ALTER TABLE `alat`
  ADD PRIMARY KEY (`alat_id`),
  ADD UNIQUE KEY `identifikacioni_broj` (`identifikacioni_broj`),
  ADD KEY `laboratorija_id` (`laboratorija_id`),
  ADD KEY `tip_alata_id` (`tip_alata_id`);

--
-- Indexes for table `alat_eksperiment`
--
ALTER TABLE `alat_eksperiment`
  ADD PRIMARY KEY (`eksperiment_id`,`tip_alata_id`),
  ADD KEY `tip_alata_id` (`tip_alata_id`);

--
-- Indexes for table `alat_sesija`
--
ALTER TABLE `alat_sesija`
  ADD PRIMARY KEY (`sesija_id`,`alat_id`),
  ADD KEY `alat_id` (`alat_id`);

--
-- Indexes for table `dizajner_eksperiment`
--
ALTER TABLE `dizajner_eksperiment`
  ADD PRIMARY KEY (`eksperiment_id`,`istrazivac_id`),
  ADD KEY `istrazivac_id` (`istrazivac_id`),
  ADD KEY `teorija_id` (`teorija_id`);

--
-- Indexes for table `eksperiment`
--
ALTER TABLE `eksperiment`
  ADD PRIMARY KEY (`eksperiment_id`);

--
-- Indexes for table `elektricno_kolo`
--
ALTER TABLE `elektricno_kolo`
  ADD PRIMARY KEY (`elektricno_kolo_id`);

--
-- Indexes for table `inventar_resursa`
--
ALTER TABLE `inventar_resursa`
  ADD PRIMARY KEY (`laboratorija_id`,`resurs_id`),
  ADD KEY `resurs_id` (`resurs_id`);

--
-- Indexes for table `ispitivanje`
--
ALTER TABLE `ispitivanje`
  ADD PRIMARY KEY (`ispitivanje_id`),
  ADD KEY `fk_ispitivanje_izvodjenje` (`izvodjenje_id`);

--
-- Indexes for table `ispitivanje_elektricnog_kola`
--
ALTER TABLE `ispitivanje_elektricnog_kola`
  ADD PRIMARY KEY (`ispitivanje_id`),
  ADD KEY `fk_ispitivanje_kola_kolo` (`elektricno_kolo_id`);

--
-- Indexes for table `ispitivanje_prototipa`
--
ALTER TABLE `ispitivanje_prototipa`
  ADD PRIMARY KEY (`ispitivanje_id`),
  ADD KEY `fk_ispitivanje_prototipa_prototip` (`prototip_id`);

--
-- Indexes for table `ispitivanje_senzora`
--
ALTER TABLE `ispitivanje_senzora`
  ADD PRIMARY KEY (`ispitivanje_id`),
  ADD KEY `fk_ispitivanje_senzora_senzor` (`senzor_id`);

--
-- Indexes for table `istrazivac`
--
ALTER TABLE `istrazivac`
  ADD PRIMARY KEY (`istrazivac_id`);

--
-- Indexes for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  ADD PRIMARY KEY (`izvodjenje_id`),
  ADD KEY `eksperiment_id` (`eksperiment_id`),
  ADD KEY `laboratorija_id` (`laboratorija_id`);

--
-- Indexes for table `korisnik`
--
ALTER TABLE `korisnik`
  ADD PRIMARY KEY (`korisnik_id`),
  ADD UNIQUE KEY `istrazivac_id` (`istrazivac_id`),
  ADD UNIQUE KEY `email` (`username`);

--
-- Indexes for table `laboratorija`
--
ALTER TABLE `laboratorija`
  ADD PRIMARY KEY (`laboratorija_id`);

--
-- Indexes for table `merenje`
--
ALTER TABLE `merenje`
  ADD PRIMARY KEY (`merenje_id`),
  ADD KEY `tip_merenja_id` (`tip_merenja_id`),
  ADD KEY `fk_merenje_izvodjenje` (`izvodjenje_id`);

--
-- Indexes for table `merenje_elektricnog_kola`
--
ALTER TABLE `merenje_elektricnog_kola`
  ADD PRIMARY KEY (`merenje_id`),
  ADD KEY `fk_merenje_kola_kolo` (`elektricno_kolo_id`);

--
-- Indexes for table `merenje_prototipa`
--
ALTER TABLE `merenje_prototipa`
  ADD PRIMARY KEY (`merenje_id`),
  ADD KEY `fk_merenje_prototipa_prototip` (`prototip_id`);

--
-- Indexes for table `merenje_senzora`
--
ALTER TABLE `merenje_senzora`
  ADD PRIMARY KEY (`merenje_id`),
  ADD KEY `fk_merenje_senzora_senzor` (`senzor_id`);

--
-- Indexes for table `merna_jedinica`
--
ALTER TABLE `merna_jedinica`
  ADD PRIMARY KEY (`merna_jedinica_id`);

--
-- Indexes for table `prototip`
--
ALTER TABLE `prototip`
  ADD PRIMARY KEY (`prototip_id`);

--
-- Indexes for table `resurs`
--
ALTER TABLE `resurs`
  ADD PRIMARY KEY (`resurs_id`);

--
-- Indexes for table `resurs_eksperiment`
--
ALTER TABLE `resurs_eksperiment`
  ADD PRIMARY KEY (`eksperiment_id`,`resurs_id`),
  ADD KEY `resurs_id` (`resurs_id`);

--
-- Indexes for table `resurs_sesija`
--
ALTER TABLE `resurs_sesija`
  ADD PRIMARY KEY (`sesija_id`,`resurs_id`),
  ADD KEY `resurs_id` (`resurs_id`);

--
-- Indexes for table `senzor`
--
ALTER TABLE `senzor`
  ADD PRIMARY KEY (`senzor_id`);

--
-- Indexes for table `sesija`
--
ALTER TABLE `sesija`
  ADD PRIMARY KEY (`sesija_id`),
  ADD KEY `izvodjenje_id` (`izvodjenje_id`);

--
-- Indexes for table `status_izvodjenja`
--
ALTER TABLE `status_izvodjenja`
  ADD PRIMARY KEY (`status_id`),
  ADD UNIQUE KEY `naziv` (`naziv`);

--
-- Indexes for table `teorija`
--
ALTER TABLE `teorija`
  ADD PRIMARY KEY (`teorija_id`),
  ADD UNIQUE KEY `identifikacioni_podaci` (`identifikacioni_podaci`);

--
-- Indexes for table `tim_izvodjaca`
--
ALTER TABLE `tim_izvodjaca`
  ADD PRIMARY KEY (`izvodjenje_id`,`istrazivac_id`),
  ADD KEY `istrazivac_id` (`istrazivac_id`);

--
-- Indexes for table `tip_alata`
--
ALTER TABLE `tip_alata`
  ADD PRIMARY KEY (`tip_alata_id`);

--
-- Indexes for table `tip_merenja`
--
ALTER TABLE `tip_merenja`
  ADD PRIMARY KEY (`tip_merenja_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alat`
--
ALTER TABLE `alat`
  MODIFY `alat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;

--
-- AUTO_INCREMENT for table `eksperiment`
--
ALTER TABLE `eksperiment`
  MODIFY `eksperiment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `elektricno_kolo`
--
ALTER TABLE `elektricno_kolo`
  MODIFY `elektricno_kolo_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `ispitivanje`
--
ALTER TABLE `ispitivanje`
  MODIFY `ispitivanje_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `istrazivac`
--
ALTER TABLE `istrazivac`
  MODIFY `istrazivac_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  MODIFY `izvodjenje_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `korisnik`
--
ALTER TABLE `korisnik`
  MODIFY `korisnik_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT for table `laboratorija`
--
ALTER TABLE `laboratorija`
  MODIFY `laboratorija_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `merenje`
--
ALTER TABLE `merenje`
  MODIFY `merenje_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=301;

--
-- AUTO_INCREMENT for table `merna_jedinica`
--
ALTER TABLE `merna_jedinica`
  MODIFY `merna_jedinica_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `prototip`
--
ALTER TABLE `prototip`
  MODIFY `prototip_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `resurs`
--
ALTER TABLE `resurs`
  MODIFY `resurs_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `senzor`
--
ALTER TABLE `senzor`
  MODIFY `senzor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `sesija`
--
ALTER TABLE `sesija`
  MODIFY `sesija_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `status_izvodjenja`
--
ALTER TABLE `status_izvodjenja`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `teorija`
--
ALTER TABLE `teorija`
  MODIFY `teorija_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `tip_alata`
--
ALTER TABLE `tip_alata`
  MODIFY `tip_alata_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tip_merenja`
--
ALTER TABLE `tip_merenja`
  MODIFY `tip_merenja_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alat`
--
ALTER TABLE `alat`
  ADD CONSTRAINT `alat_laboratorija` FOREIGN KEY (`laboratorija_id`) REFERENCES `laboratorija` (`laboratorija_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `alat_tip_alata` FOREIGN KEY (`tip_alata_id`) REFERENCES `tip_alata` (`tip_alata_id`) ON UPDATE CASCADE;

--
-- Constraints for table `alat_eksperiment`
--
ALTER TABLE `alat_eksperiment`
  ADD CONSTRAINT `alat_eksperiment_alat` FOREIGN KEY (`tip_alata_id`) REFERENCES `tip_alata` (`tip_alata_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `alat_eksperiment_eksperiment` FOREIGN KEY (`eksperiment_id`) REFERENCES `eksperiment` (`eksperiment_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `alat_sesija`
--
ALTER TABLE `alat_sesija`
  ADD CONSTRAINT `alat_sesija_alat` FOREIGN KEY (`alat_id`) REFERENCES `alat` (`alat_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `alat_sesija_sesija` FOREIGN KEY (`sesija_id`) REFERENCES `sesija` (`sesija_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dizajner_eksperiment`
--
ALTER TABLE `dizajner_eksperiment`
  ADD CONSTRAINT `dizajner_eksperiment_eksperiment` FOREIGN KEY (`eksperiment_id`) REFERENCES `eksperiment` (`eksperiment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dizajner_eksperiment_istrazivac` FOREIGN KEY (`istrazivac_id`) REFERENCES `istrazivac` (`istrazivac_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dizajner_eksperiment_teorija` FOREIGN KEY (`teorija_id`) REFERENCES `teorija` (`teorija_id`) ON UPDATE CASCADE;

--
-- Constraints for table `inventar_resursa`
--
ALTER TABLE `inventar_resursa`
  ADD CONSTRAINT `inventar_resursa_laboratorija` FOREIGN KEY (`laboratorija_id`) REFERENCES `laboratorija` (`laboratorija_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inventar_resursa_resurs` FOREIGN KEY (`resurs_id`) REFERENCES `resurs` (`resurs_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ispitivanje`
--
ALTER TABLE `ispitivanje`
  ADD CONSTRAINT `ispitivanje_izvodjenje` FOREIGN KEY (`izvodjenje_id`) REFERENCES `izvodjenje` (`izvodjenje_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ispitivanje_elektricnog_kola`
--
ALTER TABLE `ispitivanje_elektricnog_kola`
  ADD CONSTRAINT `ispitivanje_elektricnog_kola_elektricno_kolo` FOREIGN KEY (`elektricno_kolo_id`) REFERENCES `elektricno_kolo` (`elektricno_kolo_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ispitivanje_elektricnog_kola_ispitivanje` FOREIGN KEY (`ispitivanje_id`) REFERENCES `ispitivanje` (`ispitivanje_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ispitivanje_prototipa`
--
ALTER TABLE `ispitivanje_prototipa`
  ADD CONSTRAINT `ispitivanje_prototipa_ispitivanje` FOREIGN KEY (`ispitivanje_id`) REFERENCES `ispitivanje` (`ispitivanje_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ispitivanje_prototipa_prototip` FOREIGN KEY (`prototip_id`) REFERENCES `prototip` (`prototip_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ispitivanje_senzora`
--
ALTER TABLE `ispitivanje_senzora`
  ADD CONSTRAINT `ispitivanje_senzora_ispitivanje` FOREIGN KEY (`ispitivanje_id`) REFERENCES `ispitivanje` (`ispitivanje_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ispitivanje_senzora_senzor` FOREIGN KEY (`senzor_id`) REFERENCES `senzor` (`senzor_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `izvodjenje`
--
ALTER TABLE `izvodjenje`
  ADD CONSTRAINT `izvodjenje_eksperiment` FOREIGN KEY (`eksperiment_id`) REFERENCES `eksperiment` (`eksperiment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `izvodjenje_laboratorija` FOREIGN KEY (`laboratorija_id`) REFERENCES `laboratorija` (`laboratorija_id`) ON UPDATE CASCADE;

--
-- Constraints for table `korisnik`
--
ALTER TABLE `korisnik`
  ADD CONSTRAINT `korisnik_istrazivac` FOREIGN KEY (`istrazivac_id`) REFERENCES `istrazivac` (`istrazivac_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `merenje`
--
ALTER TABLE `merenje`
  ADD CONSTRAINT `merenje_izvodjenje` FOREIGN KEY (`izvodjenje_id`) REFERENCES `izvodjenje` (`izvodjenje_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `merenje_tip_merenja` FOREIGN KEY (`tip_merenja_id`) REFERENCES `tip_merenja` (`tip_merenja_id`) ON UPDATE CASCADE;

--
-- Constraints for table `merenje_elektricnog_kola`
--
ALTER TABLE `merenje_elektricnog_kola`
  ADD CONSTRAINT `merenje_elektricnog_kola_elektricno_kolo` FOREIGN KEY (`elektricno_kolo_id`) REFERENCES `elektricno_kolo` (`elektricno_kolo_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `merenje_elektricnog_kola_merenje` FOREIGN KEY (`merenje_id`) REFERENCES `merenje` (`merenje_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `merenje_prototipa`
--
ALTER TABLE `merenje_prototipa`
  ADD CONSTRAINT `merenje_prototipa_merenje` FOREIGN KEY (`merenje_id`) REFERENCES `merenje` (`merenje_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `merenje_prototipa_prototip` FOREIGN KEY (`prototip_id`) REFERENCES `prototip` (`prototip_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `merenje_senzora`
--
ALTER TABLE `merenje_senzora`
  ADD CONSTRAINT `merenje_senzora_merenje` FOREIGN KEY (`merenje_id`) REFERENCES `merenje` (`merenje_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `merenje_senzora_senzor` FOREIGN KEY (`senzor_id`) REFERENCES `senzor` (`senzor_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `resurs_eksperiment`
--
ALTER TABLE `resurs_eksperiment`
  ADD CONSTRAINT `resurs_eksperiment_eksperiment` FOREIGN KEY (`eksperiment_id`) REFERENCES `eksperiment` (`eksperiment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `resurs_eksperiment_resurs` FOREIGN KEY (`resurs_id`) REFERENCES `resurs` (`resurs_id`) ON UPDATE CASCADE;

--
-- Constraints for table `resurs_sesija`
--
ALTER TABLE `resurs_sesija`
  ADD CONSTRAINT `resurs_sesija_resurs` FOREIGN KEY (`resurs_id`) REFERENCES `resurs` (`resurs_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `resurs_sesija_sesija` FOREIGN KEY (`sesija_id`) REFERENCES `sesija` (`sesija_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sesija`
--
ALTER TABLE `sesija`
  ADD CONSTRAINT `sesija_izvodjenje` FOREIGN KEY (`izvodjenje_id`) REFERENCES `izvodjenje` (`izvodjenje_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tim_izvodjaca`
--
ALTER TABLE `tim_izvodjaca`
  ADD CONSTRAINT `tim_izvodjaca_istrazivac` FOREIGN KEY (`istrazivac_id`) REFERENCES `istrazivac` (`istrazivac_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tim_izvodjaca_izvodjenje` FOREIGN KEY (`izvodjenje_id`) REFERENCES `izvodjenje` (`izvodjenje_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
