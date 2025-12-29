-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 29, 2025 at 03:02 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_klinik`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `home_services`
--

CREATE TABLE `home_services` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `member_id` bigint UNSIGNED DEFAULT NULL,
  `service_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `schedule_date` date NOT NULL,
  `schedule_time` time NOT NULL,
  `address` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `problem_description` text COLLATE utf8mb4_unicode_ci,
  `problem_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','approved','on_process','done','canceled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `work_notes` text COLLATE utf8mb4_unicode_ci,
  `completion_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `home_services`
--

INSERT INTO `home_services` (`id`, `user_id`, `member_id`, `service_type`, `schedule_date`, `schedule_time`, `address`, `city`, `problem_description`, `problem_photo`, `status`, `work_notes`, `completion_photo`, `created_at`, `updated_at`) VALUES
(3, 4, 1, 'Ganti Sparepart', '2025-12-11', '12:05:00', 'Jl. Kenanga No. 11', 'Kediri', 'Mencoba', 'problem_photos/narr8f4XGix5NzuZVr2Obpp8C2HnvzIndJUmSR8w.png', 'done', NULL, NULL, '2025-12-11 04:06:04', '2025-12-16 03:41:31'),
(4, 1, 2, 'Ganti Suku Cadang', '2025-12-13', '10:00:00', 'Jl. Soekarno Hatta', 'Kediri', 'Mencoba Lagi', 'problem_photos/2zKmJi9wNR08JBIWOEz76pqLHozaIOSCUeIw6rSK.png', 'done', NULL, NULL, '2025-12-13 02:03:38', '2025-12-16 10:49:33'),
(5, 1, 2, 'Servis', '2025-12-19', '07:00:00', 'Jl. Soekarno Hatta', 'Plosoklaten', 'Mencoba Home Service', 'problem_photos/7JPVg5HdilxITt6Qihuz1lbrWbUcB4RIbk4DW25E.jpg', 'canceled', NULL, NULL, '2025-12-18 10:41:49', '2025-12-23 02:17:02'),
(6, 1, 2, 'Servis', '2025-12-24', '07:00:00', 'Jl. Soekarno Hatta', 'Plosoklaten', 'Mencoba Home Service', 'problem_photos/5DVBeElnkmdEbIjKaxcKp56ikBI8HfoqhTF4SnOD.png', 'on_process', NULL, NULL, '2025-12-23 02:43:11', '2025-12-23 02:46:05');

-- --------------------------------------------------------

--
-- Table structure for table `infos`
--

CREATE TABLE `infos` (
  `id` bigint UNSIGNED NOT NULL,
  `clinic_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `operational_hours` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `services` json DEFAULT NULL,
  `facilities` json DEFAULT NULL,
  `maps_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instagram` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `infos`
--

INSERT INTO `infos` (`id`, `clinic_name`, `address`, `phone`, `email`, `operational_hours`, `about`, `created_at`, `updated_at`, `description`, `services`, `facilities`, `maps_url`, `instagram`, `website`) VALUES
(1, 'BSM Service Center', 'Jl. Joyoboyo No.63, Jamsaren, Kec. Pesantren, Kota Kediri, Jawa Timur 64125', '085635661415', 'bsmservicecenter@gmail.com', 'Senin - Minggu: 24 Jam', 'Bengkel spesialis untuk semua kendala di sepeda dan motor listrik', '2025-12-08 01:01:51', '2025-12-18 03:12:25', 'BSM Service Center di Kediri adalah bengkel dan dealer sepeda serta motor listrik yang beralamat di Jl. Joyoboyo No. 63, Kota Kediri (depan SMPN 3 Kota Kediri), melayani servis, perawatan, serta penjualan sparepart, bahkan menawarkan layanan home service di area Kediri dan sekitarnya (Nganjuk, dll.).', '[\"Home Service\", \"Servis\", \"Sparepart\", \"Garansi\", \"Member\"]', '[\"Ruang Tunggu Nyaman\", \"WiFi Gratis\", \"Parkir Luas\"]', 'https://maps.app.goo.gl/ouh1MwrLkUgDAH877', 'https://instagram.com/bsm.service', 'https://sites.google.com/view/bsm-card/beranda?authuser=0');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `membership_type_id` bigint UNSIGNED DEFAULT NULL,
  `member_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `join_date` date DEFAULT NULL,
  `expired_at` date DEFAULT NULL,
  `vehicle_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_brand` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_model` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_serial_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','non_active','expired','pending') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `member_photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`id`, `user_id`, `membership_type_id`, `member_code`, `join_date`, `expired_at`, `vehicle_type`, `vehicle_brand`, `vehicle_model`, `vehicle_serial_number`, `address`, `city`, `status`, `created_at`, `updated_at`, `member_photo`) VALUES
(1, 4, 1, 'MBR-001-BLU', '2025-12-10', '2026-06-10', 'Motor Listrik', 'Alva', 'Alva One', '12345678', 'Jl. Kenanga No. 11', 'Kediri', 'active', '2025-12-10 04:00:09', '2025-12-10 04:00:09', NULL),
(2, 1, 3, 'MBR-003-PLT', '2025-12-12', '2026-12-13', 'Motor Listrik', 'Polytron', 'Polytron Fox-350', '1234567890', 'Jl. Soekarno Hatta', 'Plosoklaten', 'active', '2025-12-12 02:29:06', '2025-12-28 03:30:12', 'member_photos/VshtUGdSsEqN8ltiUh60Qbjjp1gjhiBdtmbZA8Z5.jpg'),
(3, 1, 2, 'MBR-00003', '2025-12-26', '2026-06-26', 'Sepeda Listrik', 'Avatar', 'Avatar Zero 1', '0987654321', 'Jl. Rinjani', 'Kediri', 'active', '2025-12-26 03:46:18', '2025-12-29 02:37:42', 'member_photos/4LHBNb4zG2fbT7r6cM0OxkCReCnbC7yuCnaiEoF6.png');

-- --------------------------------------------------------

--
-- Table structure for table `membership_types`
--

CREATE TABLE `membership_types` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_months` int NOT NULL DEFAULT '6',
  `benefits` json DEFAULT NULL,
  `code` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `membership_types`
--

INSERT INTO `membership_types` (`id`, `name`, `display_name`, `duration_months`, `benefits`, `code`, `created_at`, `updated_at`) VALUES
(1, 'Blue', 'BSM CARD BLUE', 6, '[\"Free service 6 bulan di bengkel BSM / toko partner\"]', 'BLU', NULL, NULL),
(2, 'Gold', 'BSM CARD GOLD', 6, '[\"Free service 6 bulan di bengkel BSM / toko partner\", \"Free ongkos home service 6 bulan\", \"Diskon sparepart 10% selama 6 bulan\"]', 'GLD', NULL, NULL),
(3, 'Platinum', 'BSM CARD PLATINUM', 12, '[\"Free service 6 bulan di bengkel BSM / toko partner\", \"Free ongkos home service 6 bulan\", \"Diskon sparepart 10% selama 12 bulan\", \"Rusak ganti baru selama 3 bulan karena bencana alam\"]', 'PLT', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_12_05_003237_create_members_table', 1),
(5, '2025_12_05_003325_create_home_services_table', 1),
(6, '2025_12_05_003357_create_promos_table', 1),
(7, '2025_12_06_024641_create_personal_access_tokens_table', 2),
(8, '2025_12_08_073603_create_infos_table', 3),
(9, '2025_12_08_075321_add_more_fields_to_infos_table', 4),
(10, '2025_12_10_085806_create_members_table', 5),
(11, '2025_12_10_090102_create_home_services_table', 5),
(12, '2025_12_10_101512_create_membership_types_table', 6),
(13, '2025_12_10_105623_add_membership_type_id_to_members_table', 7),
(14, '2025_12_11_101458_add_user_id_to_members_table', 8),
(15, '2025_12_26_095515_add_member_photo_to_members_table', 9);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'auth_token', 'c4e105611d0784f1297938ade9918291bb8528df8acbefdc50e4a2e3c4edac19', '[\"*\"]', '2025-12-05 21:03:54', NULL, '2025-12-05 19:47:21', '2025-12-05 21:03:54'),
(2, 'App\\Models\\User', 2, 'auth_token', '29c510e57cd0b4e4ed1cab904dbe54043f6e16c73e055f17f95a6328f6f2dee0', '[\"*\"]', NULL, NULL, '2025-12-06 17:02:14', '2025-12-06 17:02:14'),
(3, 'App\\Models\\User', 4, 'auth_token', 'b01c19485985446e8101f575ac987d2465cef0f4d4f42acb49472e7da762a7ad', '[\"*\"]', '2025-12-06 17:19:16', NULL, '2025-12-06 17:18:58', '2025-12-06 17:19:16'),
(4, 'App\\Models\\User', 4, 'auth_token', '0c0c26196b0060626dc9bf79fd18f43b68c0d8a725952cb60bfe4b4a3160e7e0', '[\"*\"]', '2025-12-06 17:53:52', NULL, '2025-12-06 17:24:31', '2025-12-06 17:53:52'),
(5, 'App\\Models\\User', 4, 'auth_token', 'fc8c646df8a75e3c20ab8aba452de450c7111d709050334da7741ba7ac57b51d', '[\"*\"]', '2025-12-07 01:48:52', NULL, '2025-12-06 18:05:52', '2025-12-07 01:48:52'),
(6, 'App\\Models\\User', 4, 'auth_token', '87e989aabae3169fdc3b4a107898f14ff522f99a403053a595e40e03dca8f26e', '[\"*\"]', '2025-12-07 04:13:06', NULL, '2025-12-07 01:54:31', '2025-12-07 04:13:06'),
(7, 'App\\Models\\User', 4, 'auth_token', '284005be1d3330480f88915465d53565189885c72cd85e5a467ab78dde7a752f', '[\"*\"]', NULL, NULL, '2025-12-08 00:46:24', '2025-12-08 00:46:24'),
(8, 'App\\Models\\User', 4, 'auth_token', '7a85688dc687694e7d3cd1f5b553f8452a61538a9c14fb99ceddddff296cab73', '[\"*\"]', '2025-12-08 01:03:17', NULL, '2025-12-08 00:46:41', '2025-12-08 01:03:17'),
(9, 'App\\Models\\User', 1, 'auth_token', '4cd7a0a8ad8fe04a1753c6d301cb72a06ae74b7f191164721b69e040bb4d2bfe', '[\"*\"]', '2025-12-08 01:08:10', NULL, '2025-12-08 01:03:47', '2025-12-08 01:08:10'),
(10, 'App\\Models\\User', 5, 'auth_token', 'b1f7636827b0c98771b4d87e4d03a65c5fee329d6015df4fec1a7447622570c4', '[\"*\"]', NULL, NULL, '2025-12-08 03:03:58', '2025-12-08 03:03:58'),
(11, 'App\\Models\\User', 5, 'auth_token', '066a5128132fd0f11b441aae719ed5884ceebb9f91ab90e8697bbc29e3d2aae0', '[\"*\"]', NULL, NULL, '2025-12-08 03:13:38', '2025-12-08 03:13:38'),
(12, 'App\\Models\\User', 5, 'auth_token', '196a6d91e5ffff7862553188f448e3d289174666bf58d756008482800172b85e', '[\"*\"]', '2025-12-08 04:33:20', NULL, '2025-12-08 04:12:59', '2025-12-08 04:33:20'),
(13, 'App\\Models\\User', 5, 'auth_token', '0066b204837d432a00d47d86fa01b911538044a4eeffaf8171afc65f15269244', '[\"*\"]', NULL, NULL, '2025-12-09 02:00:21', '2025-12-09 02:00:21'),
(14, 'App\\Models\\User', 5, 'auth_token', 'c87aa1097645db306f6eca77ca61f8ceb05f9f782a67d4bd21f2e52ae5e53f40', '[\"*\"]', NULL, NULL, '2025-12-09 02:00:28', '2025-12-09 02:00:28'),
(15, 'App\\Models\\User', 5, 'auth_token', '93c575dc80cbe43d76f983dfcacc9ddefbd49b68009e2bc1d3185b24e1fad125', '[\"*\"]', '2025-12-09 02:28:46', NULL, '2025-12-09 02:00:39', '2025-12-09 02:28:46'),
(16, 'App\\Models\\User', 1, 'auth_token', '7e047005e413403ee84e2f886de436200bc97830f5e6674a4591c20ea231765b', '[\"*\"]', '2025-12-09 02:31:18', NULL, '2025-12-09 02:29:37', '2025-12-09 02:31:18'),
(17, 'App\\Models\\User', 5, 'auth_token', '797b1b06b66ea90ae44384df42607ec64ce7bd6aa482997752192bda27632e2f', '[\"*\"]', '2025-12-09 02:32:35', NULL, '2025-12-09 02:31:41', '2025-12-09 02:32:35'),
(18, 'App\\Models\\User', 1, 'auth_token', 'b0a8592f86619cb3bff79665be4325ae254659855e35097faaf8b229d948628b', '[\"*\"]', '2025-12-09 02:34:02', NULL, '2025-12-09 02:33:39', '2025-12-09 02:34:02'),
(19, 'App\\Models\\User', 1, 'auth_token', '829bee14eba9dd293102871b7d906a0107f2cf58172f4f1fab9db2183993e9a5', '[\"*\"]', '2025-12-09 02:39:02', NULL, '2025-12-09 02:38:22', '2025-12-09 02:39:02'),
(20, 'App\\Models\\User', 5, 'auth_token', 'eccd805b81685790326fa1c3b1da756e6fab1a73e4038dea8feecaa6f1ff1aa4', '[\"*\"]', '2025-12-09 02:39:28', NULL, '2025-12-09 02:39:22', '2025-12-09 02:39:28'),
(21, 'App\\Models\\User', 1, 'auth_token', '2eb12822401c2f4d70c96e9f74f19de6dc13aa61944e2372f68071bbe632d0bf', '[\"*\"]', '2025-12-09 02:41:30', NULL, '2025-12-09 02:40:51', '2025-12-09 02:41:30'),
(22, 'App\\Models\\User', 5, 'auth_token', '4c3fb42d3c9fb492ffbe37bb7da1eb0f88e55e860c2abe3ce5c8a331b25b2bb5', '[\"*\"]', '2025-12-09 03:47:15', NULL, '2025-12-09 02:41:57', '2025-12-09 03:47:15'),
(23, 'App\\Models\\User', 4, 'auth_token', '4b6ce5028164e97e3ab3d52b67e7126c78ea1277111cafd2a487f79562f6459a', '[\"*\"]', '2025-12-09 03:48:38', NULL, '2025-12-09 03:47:49', '2025-12-09 03:48:38'),
(24, 'App\\Models\\User', 5, 'auth_token', '20129c94978c1b88a55be7d636e4ddb4ca306220a453d2674d78b9ffcd5e312c', '[\"*\"]', '2025-12-09 04:06:02', NULL, '2025-12-09 03:49:02', '2025-12-09 04:06:02'),
(25, 'App\\Models\\User', 4, 'auth_token', 'ee4d4cc574bae0e33faa40d62c3fc9c5bce3983f1a9b77249f946ffc58622988', '[\"*\"]', '2025-12-09 04:06:31', NULL, '2025-12-09 04:06:25', '2025-12-09 04:06:31'),
(26, 'App\\Models\\User', 4, 'auth_token', 'a1353b79e48b2af5d993183caf6acad6522b5215690f2865afa02e671e0180ab', '[\"*\"]', '2025-12-10 04:32:00', NULL, '2025-12-10 02:15:34', '2025-12-10 04:32:00'),
(27, 'App\\Models\\User', 4, 'auth_token', '57ff9c6164ce68aaacf757443b59bb9245016984decf5ee9d8ef0a931bd79246', '[\"*\"]', NULL, NULL, '2025-12-10 11:03:00', '2025-12-10 11:03:00'),
(28, 'App\\Models\\User', 4, 'auth_token', '1408683ab4ce979f2d8241d24bff338b90a5d071f1987b32e75af3c3b201dbb4', '[\"*\"]', '2025-12-10 11:10:01', NULL, '2025-12-10 11:03:09', '2025-12-10 11:10:01'),
(29, 'App\\Models\\User', 4, 'auth_token', 'f357f2144323b1b1dcea66ae5088eb3e8324cfd90aeb26649179f8ea74f958ca', '[\"*\"]', '2025-12-11 02:51:52', NULL, '2025-12-11 01:05:11', '2025-12-11 02:51:52'),
(30, 'App\\Models\\User', 4, 'auth_token', 'f7e783397782296bf9ad7df6725ec83ec75c5488eb14e4b11adc426ed5fe6058', '[\"*\"]', '2025-12-11 03:26:13', NULL, '2025-12-11 02:56:30', '2025-12-11 03:26:13'),
(31, 'App\\Models\\User', 4, 'auth_token', '461649ff63e68219125e9e5df1fabc17d1021ed1a24252b4d40ef9bc6a1f3672', '[\"*\"]', '2025-12-11 04:10:08', NULL, '2025-12-11 03:38:02', '2025-12-11 04:10:08'),
(32, 'App\\Models\\User', 1, 'auth_token', '1ac235c27f41c020ae275fdad19f87d3c00af1348f75444ae3cdec4ac9f0eb50', '[\"*\"]', '2025-12-11 04:16:37', NULL, '2025-12-11 04:12:24', '2025-12-11 04:16:37'),
(33, 'App\\Models\\User', 1, 'auth_token', 'f1db67af557357e99004775986719ce0d2ed61b6e46c05a391f917df41991596', '[\"*\"]', NULL, NULL, '2025-12-12 02:23:33', '2025-12-12 02:23:33'),
(34, 'App\\Models\\User', 1, 'auth_token', 'b207334ff31a47ed64c726ffda37c335c4d8e19b620d84231a30832921cab722', '[\"*\"]', '2025-12-12 04:16:29', NULL, '2025-12-12 02:23:49', '2025-12-12 04:16:29'),
(35, 'App\\Models\\User', 1, 'auth_token', '69fd780c6ee21265accb11e6fba5bab186bb79a425fe45482b1318c0bdfe9a4d', '[\"*\"]', NULL, NULL, '2025-12-12 04:37:10', '2025-12-12 04:37:10'),
(36, 'App\\Models\\User', 1, 'auth_token', 'eccc56b1456437365bb38e9921b1b2432a16bcbb203c2805dfc05c5e9d4a9bc9', '[\"*\"]', NULL, NULL, '2025-12-12 04:37:20', '2025-12-12 04:37:20'),
(37, 'App\\Models\\User', 1, 'auth_token', '10c3e1494267b9c273c479d8516c6b97e4b599cc78feaea4560dfdf96a5a5fd3', '[\"*\"]', NULL, NULL, '2025-12-12 04:37:25', '2025-12-12 04:37:25'),
(38, 'App\\Models\\User', 1, 'auth_token', '1fec236b6046bb79996f6eef566ae67723e84d1e29caeba0d8caa001b2c7fe40', '[\"*\"]', '2025-12-12 04:39:24', NULL, '2025-12-12 04:37:46', '2025-12-12 04:39:24'),
(39, 'App\\Models\\User', 1, 'auth_token', 'ad7103aa6742bb9f5247a4c524deba49844dfe67e7f7c42e4e19b4d422244b05', '[\"*\"]', NULL, NULL, '2025-12-12 10:08:43', '2025-12-12 10:08:43'),
(40, 'App\\Models\\User', 1, 'auth_token', '1315fc9daa1dcc463cea38d46bf63e17c8a5f794b56340395a595a4dde3ececa', '[\"*\"]', NULL, NULL, '2025-12-12 10:10:26', '2025-12-12 10:10:26'),
(41, 'App\\Models\\User', 1, 'auth_token', 'd3ff788f1dd34ca60a3af40c60df2c968418c21ee19abf5ba3d21744a0941705', '[\"*\"]', NULL, NULL, '2025-12-12 10:11:08', '2025-12-12 10:11:08'),
(42, 'App\\Models\\User', 1, 'auth_token', '905cbd5e93a89678e292ae2407d010774947d7956e00ce77bea0c0571acc805e', '[\"*\"]', NULL, NULL, '2025-12-12 10:12:34', '2025-12-12 10:12:34'),
(43, 'App\\Models\\User', 1, 'auth_token', '1e7112e973ba3a40824509fa3874ef246f531726cd20488402fec92ee827f1a3', '[\"*\"]', NULL, NULL, '2025-12-12 10:13:06', '2025-12-12 10:13:06'),
(44, 'App\\Models\\User', 1, 'auth_token', 'd8eb22514b7041148d92db0ec406bc6a5ab4281edfa0cbef8cb0abcbb608ec36', '[\"*\"]', NULL, NULL, '2025-12-12 10:13:58', '2025-12-12 10:13:58'),
(45, 'App\\Models\\User', 1, 'auth_token', '57fa937a2bf9dfb666f8932ce2bbc73aff654d41db02e53e40c9f46fc053d0c0', '[\"*\"]', NULL, NULL, '2025-12-12 10:14:17', '2025-12-12 10:14:17'),
(46, 'App\\Models\\User', 1, 'auth_token', '3a75f79153e66a520d79a0600791555f8234cf62e72aebedf36f620c89d500a1', '[\"*\"]', '2025-12-12 10:35:57', NULL, '2025-12-12 10:14:36', '2025-12-12 10:35:57'),
(47, 'App\\Models\\User', 4, 'auth_token', 'd51db60127cbc79bad529f6b4b513bfd540306c9472e31c4e4fad9631e6a8aa4', '[\"*\"]', '2025-12-12 10:36:40', NULL, '2025-12-12 10:36:30', '2025-12-12 10:36:40'),
(48, 'App\\Models\\User', 2, 'auth_token', '0288993a4ff30aaf33e5e742104de76d5612ac3b8c379278cb0fdde8f2257cc9', '[\"*\"]', '2025-12-12 10:37:13', NULL, '2025-12-12 10:37:09', '2025-12-12 10:37:13'),
(49, 'App\\Models\\User', 1, 'auth_token', 'd5ee58581374b1fcd3535b223a6522c0201d650160790ace6f1e7a671f1d91eb', '[\"*\"]', '2025-12-12 10:37:44', NULL, '2025-12-12 10:37:39', '2025-12-12 10:37:44'),
(50, 'App\\Models\\User', 1, 'auth_token', '3484c96e0f9389dcee7c1125140a6ef47b27fd1e6abeb52082e486630277fc96', '[\"*\"]', NULL, NULL, '2025-12-13 01:31:21', '2025-12-13 01:31:21'),
(51, 'App\\Models\\User', 1, 'auth_token', 'a7ee53fba0d12ab78b6dd349e759d73a82446bce6978302fe96b1aac469b0838', '[\"*\"]', '2025-12-13 01:39:49', NULL, '2025-12-13 01:35:57', '2025-12-13 01:39:49'),
(52, 'App\\Models\\User', 4, 'auth_token', '6d7678da9d74d5a425e67326ecca114a8f791255b82706308e69742531a5ebaa', '[\"*\"]', NULL, NULL, '2025-12-13 01:40:38', '2025-12-13 01:40:38'),
(53, 'App\\Models\\User', 4, 'auth_token', '67d3cc7a8c2c41b93ff4bfecd3bb0505f6366bd079d1c1d1161ab299aadd0d64', '[\"*\"]', NULL, NULL, '2025-12-13 01:41:41', '2025-12-13 01:41:41'),
(54, 'App\\Models\\User', 4, 'auth_token', '0105817dd7261d08339910066e4e58748e2c00545d28bba54319c1ed1a5a7224', '[\"*\"]', NULL, NULL, '2025-12-13 01:42:33', '2025-12-13 01:42:33'),
(55, 'App\\Models\\User', 1, 'auth_token', 'e89b17afc576c895a5f7a64fdd49533cd3e170a8f1a6aaecda57e1aff4782415', '[\"*\"]', NULL, NULL, '2025-12-13 01:59:22', '2025-12-13 01:59:22'),
(56, 'App\\Models\\User', 1, 'auth_token', '644db28e67a3ee393f4ada0ca3c432133f1f6f65426fdcdddca6f4a37804d611', '[\"*\"]', '2025-12-13 02:04:09', NULL, '2025-12-13 01:59:38', '2025-12-13 02:04:09'),
(57, 'App\\Models\\User', 2, 'auth_token', '2b73c5588990021110d18a5a4fe4de57bb685f4996d1874b752928b6622847ef', '[\"*\"]', '2025-12-13 02:18:49', NULL, '2025-12-13 02:04:31', '2025-12-13 02:18:49'),
(58, 'App\\Models\\User', 5, 'auth_token', '719e7e2275ebf401dc2df73129a718d44f11c2d780b8f864d3de6e70e8da616d', '[\"*\"]', NULL, NULL, '2025-12-13 02:27:23', '2025-12-13 02:27:23'),
(59, 'App\\Models\\User', 5, 'auth_token', '0290ff2e3236a261a41049e44b895e8bfd0ec5584a2d5d85dad23dd0191c23c2', '[\"*\"]', '2025-12-13 04:33:24', NULL, '2025-12-13 03:20:56', '2025-12-13 04:33:24'),
(60, 'App\\Models\\User', 5, 'auth_token', '8cf9d60987b4ab10f03a5c5f3bfb3d6ba62ddb96e889684225b4e690e869d75e', '[\"*\"]', '2025-12-13 04:38:13', NULL, '2025-12-13 04:37:26', '2025-12-13 04:38:13'),
(61, 'App\\Models\\User', 5, 'auth_token', '7171ea35f14cdb26b6bacf228aba619d78454e5205218d7ba87cc004a9ad4fa8', '[\"*\"]', '2025-12-13 10:42:56', NULL, '2025-12-13 09:41:02', '2025-12-13 10:42:56'),
(62, 'App\\Models\\User', 4, 'auth_token', 'ae062882e6b1206770114050a3c7076c5812faa6a20d327c89b1f836db0acffe', '[\"*\"]', '2025-12-14 00:56:01', NULL, '2025-12-14 00:55:37', '2025-12-14 00:56:01'),
(63, 'App\\Models\\User', 1, 'auth_token', '4dcaea3aaedc7ad10cc373a4417f808b96f0f1bec749af9176ef421a84e6e674', '[\"*\"]', '2025-12-14 01:01:00', NULL, '2025-12-14 00:56:34', '2025-12-14 01:01:00'),
(64, 'App\\Models\\User', 4, 'auth_token', 'e72d7340a1698e20952a66dfb7ff349b7ddd8a9815b8311abd069e8016d6a725', '[\"*\"]', NULL, NULL, '2025-12-14 01:01:35', '2025-12-14 01:01:35'),
(65, 'App\\Models\\User', 5, 'auth_token', '9170677cefc270af4e1da21596a559230ba1cf2d9c953feee7c0338eb823d12a', '[\"*\"]', '2025-12-14 01:47:42', NULL, '2025-12-14 01:02:15', '2025-12-14 01:47:42'),
(66, 'App\\Models\\User', 4, 'auth_token', 'd02907457a724f44462401ff7fdeb4b9dabf8b4a61ee65a9b973334bee79beb0', '[\"*\"]', '2025-12-14 01:53:03', NULL, '2025-12-14 01:50:00', '2025-12-14 01:53:03'),
(67, 'App\\Models\\User', 4, 'auth_token', '6fbf56e10be718d4e0c1c967a09ba9ba1ecab715f415fa20d057f34188c891ce', '[\"*\"]', '2025-12-14 01:55:25', NULL, '2025-12-14 01:54:08', '2025-12-14 01:55:25'),
(68, 'App\\Models\\User', 5, 'auth_token', '01ea3c5e60ea28a96e4f89016c2e56d2304c229a5309cc8ba1aa199ed6d68093', '[\"*\"]', '2025-12-14 04:38:48', NULL, '2025-12-14 03:10:55', '2025-12-14 04:38:48'),
(69, 'App\\Models\\User', 5, 'auth_token', '2092787a455743b2733fd591c0c47e862db538f13438d2f47de8c787b5855833', '[\"*\"]', NULL, NULL, '2025-12-14 09:47:54', '2025-12-14 09:47:54'),
(70, 'App\\Models\\User', 5, 'auth_token', '1919af15448a9750266932b7ec2c927abc648af794579eec8fad85d93c659be8', '[\"*\"]', NULL, NULL, '2025-12-14 09:49:00', '2025-12-14 09:49:00'),
(71, 'App\\Models\\User', 5, 'auth_token', 'f57b3fcfac2bf223b53f7250404ab4c4e26e4281a9808dd9bdc6887d0530399d', '[\"*\"]', NULL, NULL, '2025-12-14 09:49:09', '2025-12-14 09:49:09'),
(72, 'App\\Models\\User', 5, 'auth_token', '3f747f12cb6038534668de21add1451d0e088653ef4e54fb7185c0f6e04daddc', '[\"*\"]', NULL, NULL, '2025-12-14 09:49:10', '2025-12-14 09:49:10'),
(73, 'App\\Models\\User', 5, 'auth_token', '0bd8313089bbbcd691006cc7daaaca1268abeda0712b148d986fd8369c42b48e', '[\"*\"]', '2025-12-14 09:55:52', NULL, '2025-12-14 09:50:00', '2025-12-14 09:55:52'),
(74, 'App\\Models\\User', 5, 'auth_token', 'b1931633bf02ae4d9f268cb78b558c23ff1a248dccb2f133d53b42fc2731457d', '[\"*\"]', '2025-12-15 00:52:12', NULL, '2025-12-15 00:51:05', '2025-12-15 00:52:12'),
(75, 'App\\Models\\User', 5, 'auth_token', '3a06e0e80da3f268cdd8dd44bd2175f8890526c3195d3e52daa30d7d64782307', '[\"*\"]', '2025-12-15 01:34:43', NULL, '2025-12-15 01:02:09', '2025-12-15 01:34:43'),
(76, 'App\\Models\\User', 5, 'auth_token', 'e53078edd50da9b0fd0a98e7e261f93e32504e31fab96bcd8bd77fe974424802', '[\"*\"]', '2025-12-15 03:29:54', NULL, '2025-12-15 03:05:07', '2025-12-15 03:29:54'),
(77, 'App\\Models\\User', 4, 'auth_token', '15cdf6c149349a9d2fb4c0ec428d4723b23991e5d0a55ba1957c12be82b88a47', '[\"*\"]', NULL, NULL, '2025-12-15 03:30:37', '2025-12-15 03:30:37'),
(78, 'App\\Models\\User', 5, 'auth_token', 'b4a6753d16499bfbf3788209614480e7078835e72d5c37b222f24774bb4c9c61', '[\"*\"]', '2025-12-15 03:35:52', NULL, '2025-12-15 03:31:16', '2025-12-15 03:35:52'),
(79, 'App\\Models\\User', 5, 'auth_token', '360eaa713bfd339242e85d8e9d88050d7d05dbacfd170d088e0ec6fa16a8ed4e', '[\"*\"]', NULL, NULL, '2025-12-15 09:52:25', '2025-12-15 09:52:25'),
(80, 'App\\Models\\User', 5, 'auth_token', '492b27fd33d74eb9163f3c79f4abea2befcbc7b891cc41b18c016d47f7d70647', '[\"*\"]', NULL, NULL, '2025-12-15 09:52:36', '2025-12-15 09:52:36'),
(81, 'App\\Models\\User', 5, 'auth_token', 'e05d3e315ee04f76e941b2593bf63ad776acb3fed5edd8c3985696564bee3c23', '[\"*\"]', '2025-12-15 10:56:28', NULL, '2025-12-15 09:52:59', '2025-12-15 10:56:28'),
(82, 'App\\Models\\User', 5, 'auth_token', '992f66660c1373b66ef5f7d9cbedc5b844ff19032dcc7f4acc5799f989086749', '[\"*\"]', NULL, NULL, '2025-12-16 00:41:54', '2025-12-16 00:41:54'),
(83, 'App\\Models\\User', 5, 'auth_token', 'bc0fdec4efb03550514f24b48aed740c18a1d197b595a7d4d24be25e4e0952fd', '[\"*\"]', '2025-12-16 04:06:15', NULL, '2025-12-16 00:42:55', '2025-12-16 04:06:15'),
(84, 'App\\Models\\User', 5, 'auth_token', '2743cf15eba3460a3b9e85f15edfaad1e741b2fce1aeeb07e61acd2a8618f692', '[\"*\"]', NULL, NULL, '2025-12-16 10:33:22', '2025-12-16 10:33:22'),
(85, 'App\\Models\\User', 5, 'auth_token', 'db9cf4c23bdfe4143bc9f2016d4bd7e5d67f85d0a428aceda9c1d733506c637f', '[\"*\"]', '2025-12-16 10:53:53', NULL, '2025-12-16 10:33:27', '2025-12-16 10:53:53'),
(86, 'App\\Models\\User', 5, 'auth_token', '35a634584d9dbbd135a09da3662f8732b3c5d2c17a25cb356352e67bab46d876', '[\"*\"]', NULL, NULL, '2025-12-17 01:14:51', '2025-12-17 01:14:51'),
(87, 'App\\Models\\User', 5, 'auth_token', '44ebc617b94dc4f97f8efdc6871b23a3d7bb03a5d5ef55511029dd7250f4e477', '[\"*\"]', NULL, NULL, '2025-12-17 01:15:05', '2025-12-17 01:15:05'),
(88, 'App\\Models\\User', 5, 'auth_token', '15d7029c36bd50f86089674e1194f7fe3ddd6f16b8f523a599c812f6ff6de2aa', '[\"*\"]', NULL, NULL, '2025-12-17 01:15:15', '2025-12-17 01:15:15'),
(89, 'App\\Models\\User', 5, 'auth_token', '822bd63f8bb9fa3f9f30ede288602d5fe55b361395415600ea1a10efe67c81b8', '[\"*\"]', NULL, NULL, '2025-12-17 01:15:45', '2025-12-17 01:15:45'),
(90, 'App\\Models\\User', 5, 'auth_token', '7a6ad76ad5fbd8af5ca5433d8326bf975d3fd7045c887a781466b03ff6790b5a', '[\"*\"]', NULL, NULL, '2025-12-17 01:16:31', '2025-12-17 01:16:31'),
(91, 'App\\Models\\User', 5, 'auth_token', '5b743adf811d720102cce4a8e923dcb1b2510c9df9b74f5416d2ef021fc85738', '[\"*\"]', NULL, NULL, '2025-12-17 01:17:09', '2025-12-17 01:17:09'),
(92, 'App\\Models\\User', 5, 'auth_token', 'c28b1d4528a55a1a7ad6654c34032278ceb8e4117c15ae652d07b42d1c8a7a1d', '[\"*\"]', NULL, NULL, '2025-12-17 01:18:36', '2025-12-17 01:18:36'),
(93, 'App\\Models\\User', 5, 'auth_token', '7f2baf7406b1815a7046f835d63050651229b417417f8d9e5b6dcb1e9fe3da45', '[\"*\"]', '2025-12-17 01:29:11', NULL, '2025-12-17 01:25:04', '2025-12-17 01:29:11'),
(95, 'App\\Models\\User', 4, 'auth_token', 'dd8469dfc2692cfb862c0a2cec5ff78930447865441e47844c56d02a5a4628bc', '[\"*\"]', '2025-12-17 04:23:00', NULL, '2025-12-17 04:15:35', '2025-12-17 04:23:00'),
(96, 'App\\Models\\User', 4, 'auth_token', 'b2c3608ce3ba76ca7257154374b5605cba4e259ea194b21bab182d0ff63769eb', '[\"*\"]', NULL, NULL, '2025-12-17 10:35:49', '2025-12-17 10:35:49'),
(97, 'App\\Models\\User', 4, 'auth_token', '9eb68b368297d9c5a992ed2718ab0f82bcc95359217cb2492dc67781e745f0e3', '[\"*\"]', NULL, NULL, '2025-12-17 10:38:50', '2025-12-17 10:38:50'),
(98, 'App\\Models\\User', 4, 'auth_token', '2ae907ab9cce6c94b95e4498f0adef0bae0d95f70affb0f1ec4aa998a1714ea2', '[\"*\"]', '2025-12-18 01:27:45', NULL, '2025-12-18 01:25:09', '2025-12-18 01:27:45'),
(99, 'App\\Models\\User', 4, 'auth_token', '8737fd1afac561007edf8aceb789351a786be3ca925737daa12bffd47fd7ad52', '[\"*\"]', NULL, NULL, '2025-12-18 01:44:45', '2025-12-18 01:44:45'),
(100, 'App\\Models\\User', 4, 'auth_token', 'e9ca1f67681e97adfd0dfc6a35f0af7b02c032f746871c37d10e8ca747823d19', '[\"*\"]', NULL, NULL, '2025-12-18 01:45:36', '2025-12-18 01:45:36'),
(101, 'App\\Models\\User', 4, 'auth_token', 'b9a07751e920beb91a7cb2476c22efdeb6fe2dc009d7e3b78279507d02be4cf8', '[\"*\"]', '2025-12-18 03:08:58', NULL, '2025-12-18 02:38:22', '2025-12-18 03:08:58'),
(103, 'App\\Models\\User', 4, 'auth_token', '29669480c3aa7704cf1b74f79303e8a21a77550f467fbb78c69104265bfdb7ff', '[\"*\"]', '2025-12-18 03:59:19', NULL, '2025-12-18 03:12:58', '2025-12-18 03:59:19'),
(104, 'App\\Models\\User', 4, 'auth_token', '8418c4c88963bfc0ce77fd490e654f0b9e6c5fb31d43f0b697db719ecc9c1a21', '[\"*\"]', NULL, NULL, '2025-12-18 09:53:36', '2025-12-18 09:53:36'),
(105, 'App\\Models\\User', 4, 'auth_token', '23f7534674dfbfe12c8ec90499768b4df566467a62bbbe37537c78ce752825b2', '[\"*\"]', NULL, NULL, '2025-12-18 09:53:43', '2025-12-18 09:53:43'),
(106, 'App\\Models\\User', 4, 'auth_token', '93424dfc73bdc2cf422d15e187df32fa0d2eb4776f4a81045ce2c70156560f58', '[\"*\"]', '2025-12-18 10:24:40', NULL, '2025-12-18 09:55:36', '2025-12-18 10:24:40'),
(107, 'App\\Models\\User', 2, 'auth_token', '48476e20a41a4d4861d5210b0051b3a56a1b5b39228a0080c79d294f81864d2a', '[\"*\"]', '2025-12-18 10:29:52', NULL, '2025-12-18 10:29:07', '2025-12-18 10:29:52'),
(108, 'App\\Models\\User', 1, 'auth_token', 'bb84129db286c0e69be8b43fdb4b831827140cbf8b12ddab5e62992de1ab1186', '[\"*\"]', '2025-12-18 10:42:13', NULL, '2025-12-18 10:30:16', '2025-12-18 10:42:13'),
(109, 'App\\Models\\User', 1, 'auth_token', '8d72eaa73e81a58b78b323cada6a85f7f8028581c2c082d8afe3b63c8918c0a9', '[\"*\"]', '2025-12-19 01:33:12', NULL, '2025-12-19 01:32:58', '2025-12-19 01:33:12'),
(110, 'App\\Models\\User', 4, 'auth_token', 'e18ccfea2ed11f728b826cda76e8baaa11a23c878cbc39c78ce2486360418f5f', '[\"*\"]', '2025-12-19 01:35:14', NULL, '2025-12-19 01:33:35', '2025-12-19 01:35:14'),
(111, 'App\\Models\\User', 4, 'auth_token', '0b88ad3a91a00be429085c7e148e2009ca616f2cd38a9fbf65341edaa533970b', '[\"*\"]', '2025-12-20 03:00:45', NULL, '2025-12-20 03:00:27', '2025-12-20 03:00:45'),
(112, 'App\\Models\\User', 1, 'auth_token', '17ce109aea0afef07b1471a21678ee4c30b50f2b1ea5c266eb9db5c30ed7432c', '[\"*\"]', '2025-12-20 03:01:29', NULL, '2025-12-20 03:01:14', '2025-12-20 03:01:29'),
(113, 'App\\Models\\User', 1, 'auth_token', '525f18a219b84d8ab248d39f0bcd82aa182ec409ab73268e218e3c4480f43cbe', '[\"*\"]', '2025-12-20 03:14:27', NULL, '2025-12-20 03:14:00', '2025-12-20 03:14:27'),
(115, 'App\\Models\\User', 4, 'auth_token', '6f3dfe69a762988ec7701cfa84c3fca9c641f0b96f2d8af0bd0530b2d6054bd7', '[\"*\"]', '2025-12-20 03:23:53', NULL, '2025-12-20 03:22:15', '2025-12-20 03:23:53'),
(118, 'App\\Models\\User', 4, 'auth_token', '3edc6e2f7326cf63ac08de2e9e9d59d3130019369cdc704ca4ab13c07670d1ce', '[\"*\"]', '2025-12-20 04:17:01', NULL, '2025-12-20 04:16:58', '2025-12-20 04:17:01'),
(119, 'App\\Models\\User', 5, 'auth_token', '35815d8ef3d16725d9cb7fa0e1aeab69626a560668e522bb1fc71858e254451b', '[\"*\"]', NULL, NULL, '2025-12-20 10:13:20', '2025-12-20 10:13:20'),
(120, 'App\\Models\\User', 5, 'auth_token', 'c5975bc05bec009ef610d530cd464a38568676a160d874ef3eee75ca8aea8fbc', '[\"*\"]', NULL, NULL, '2025-12-20 10:14:06', '2025-12-20 10:14:06'),
(121, 'App\\Models\\User', 5, 'auth_token', 'eba7a83206efd59e5f5de9ee5d75a98bc45302089d3083357f4121107cb9e79f', '[\"*\"]', NULL, NULL, '2025-12-20 10:14:15', '2025-12-20 10:14:15'),
(122, 'App\\Models\\User', 5, 'auth_token', '9bcc9d676a7883ba6184f7b69cab05023e10915c440f306f7914eba3509b8e3d', '[\"*\"]', NULL, NULL, '2025-12-20 10:14:20', '2025-12-20 10:14:20'),
(123, 'App\\Models\\User', 5, 'auth_token', '272d5f4e6e7ba94b5589ef31d35c27fe1f0778d2a8f228310d5f8cf615cdd7ae', '[\"*\"]', NULL, NULL, '2025-12-20 10:14:53', '2025-12-20 10:14:53'),
(124, 'App\\Models\\User', 5, 'auth_token', 'e7a6e8c980f2122d0e35a86d82e788124925bed1948fa9f895533e70ddec13d6', '[\"*\"]', NULL, NULL, '2025-12-20 10:15:49', '2025-12-20 10:15:49'),
(125, 'App\\Models\\User', 5, 'auth_token', '5d94038ea5e971d8983debae4b31a72e85d8c9cdc7bebf27e87321033d4a1aab', '[\"*\"]', NULL, NULL, '2025-12-20 10:17:05', '2025-12-20 10:17:05'),
(126, 'App\\Models\\User', 5, 'auth_token', '2f237882846627040d5cd40b708739417236d7592cea04d8c309e46921c86188', '[\"*\"]', NULL, NULL, '2025-12-20 10:28:37', '2025-12-20 10:28:37'),
(127, 'App\\Models\\User', 5, 'auth_token', '14aebd4506e5f6eee5f865675b82aa9f886e23e7b2066abd8c65d6065033564c', '[\"*\"]', NULL, NULL, '2025-12-20 10:30:20', '2025-12-20 10:30:20'),
(129, 'App\\Models\\User', 2, 'auth_token', 'c803a2fd1b9f3776f6038e15a77f4573d6fcb4dc51e82466fbae769a726492a4', '[\"*\"]', NULL, NULL, '2025-12-20 10:35:23', '2025-12-20 10:35:23'),
(130, 'App\\Models\\User', 4, 'auth_token', 'aadd4eb913e6f44b713666872a46e3070dd3540d47561ccfe02ba83281384d8d', '[\"*\"]', '2025-12-20 10:40:43', NULL, '2025-12-20 10:40:20', '2025-12-20 10:40:43'),
(131, 'App\\Models\\User', 6, 'auth_token', '5c81147ce42c1878204b93954c4758941e962154a2ef93b6676098d9b4e605c6', '[\"*\"]', '2025-12-20 10:41:28', NULL, '2025-12-20 10:41:24', '2025-12-20 10:41:28'),
(132, 'App\\Models\\User', 4, 'auth_token', '79b961f461290777306442fc38c8eef8e54fc1cec3953181267418c65beb54eb', '[\"*\"]', NULL, NULL, '2025-12-21 02:00:04', '2025-12-21 02:00:04'),
(133, 'App\\Models\\User', 4, 'auth_token', 'ea60959407d337e551d28f4b3d391182fd3bf9dc5875cd172b6759a6e1c14bc6', '[\"*\"]', NULL, NULL, '2025-12-21 02:02:56', '2025-12-21 02:02:56'),
(135, 'App\\Models\\User', 1, 'auth_token', '6a95d3a6d1b49de91532d17eaf8143a65b3af2833131374876cea4fc2026104b', '[\"*\"]', '2025-12-21 02:33:36', NULL, '2025-12-21 02:29:28', '2025-12-21 02:33:36'),
(137, 'App\\Models\\User', 4, 'auth_token', '3d8883958df5053afac2a005acfe81586d24b9e97cecf5af4492b21ccbfd0b2c', '[\"*\"]', '2025-12-21 02:49:10', NULL, '2025-12-21 02:39:57', '2025-12-21 02:49:10'),
(138, 'App\\Models\\User', 5, 'auth_token', '029ab273a9116c48c8a26b68055cce2f5cfbab3d464718f7b22b75c457b13b87', '[\"*\"]', '2025-12-21 02:58:53', NULL, '2025-12-21 02:51:40', '2025-12-21 02:58:53'),
(139, 'App\\Models\\User', 5, 'auth_token', 'c6843447ce633434cd4f798a089515cedd1ffbe15ca91a776a57036dccf4f6ff', '[\"*\"]', NULL, NULL, '2025-12-23 00:37:00', '2025-12-23 00:37:00'),
(141, 'App\\Models\\User', 5, 'auth_token', '6b9a9e2535dcd6f0adff7ecbf69d5ec571d44eba5873f0c894503cd33efa6ad1', '[\"*\"]', NULL, NULL, '2025-12-23 00:48:38', '2025-12-23 00:48:38'),
(142, 'App\\Models\\User', 5, 'auth_token', '3cf034dbd32e2fb3ea3389d80322504dd5b63fe986d7b2f5a27ea94ed3575042', '[\"*\"]', NULL, NULL, '2025-12-23 00:48:43', '2025-12-23 00:48:43'),
(143, 'App\\Models\\User', 5, 'auth_token', '32711dbb50f05a64171d5abb4c6cf0878f34efa9cbba37962e4187ef39cc6ec7', '[\"*\"]', NULL, NULL, '2025-12-23 00:48:49', '2025-12-23 00:48:49'),
(144, 'App\\Models\\User', 5, 'auth_token', '5eafe94244856238cdae63a28ad88364bfabe4c4b93a84dc7b54b69807a185d3', '[\"*\"]', NULL, NULL, '2025-12-23 00:48:53', '2025-12-23 00:48:53'),
(145, 'App\\Models\\User', 5, 'auth_token', 'b724a25546a837bd99ed45eb56b73a1546ff4c27ed36336736498ae8877dea1f', '[\"*\"]', '2025-12-23 00:55:44', NULL, '2025-12-23 00:55:24', '2025-12-23 00:55:44'),
(146, 'App\\Models\\User', 4, 'auth_token', '4934dd2651cfe550d4fc5900f026a66f7d9a95253055988732745243c12045ce', '[\"*\"]', '2025-12-23 01:02:22', NULL, '2025-12-23 01:02:10', '2025-12-23 01:02:22'),
(147, 'App\\Models\\User', 5, 'auth_token', 'b62896e1fb4efdd7eb5abc89a8d74e5b143a60d9dced3e863c6331987a8e046f', '[\"*\"]', '2025-12-23 02:40:53', NULL, '2025-12-23 02:40:49', '2025-12-23 02:40:53'),
(148, 'App\\Models\\User', 1, 'auth_token', '0cda4c840852d4022e415e537c35459f0335a23b44863e57ce20a3683f9416b3', '[\"*\"]', '2025-12-23 02:43:08', NULL, '2025-12-23 02:41:46', '2025-12-23 02:43:08'),
(150, 'App\\Models\\User', 4, 'auth_token', 'c35ffc2a98e9f09f01e39c3ec509c326e06ca837bbd4d2d8eac55b6768be31a6', '[\"*\"]', '2025-12-23 03:01:53', NULL, '2025-12-23 03:01:42', '2025-12-23 03:01:53'),
(151, 'App\\Models\\User', 5, 'auth_token', 'f1ffaa4714214a846c46a4b84311801b44411c992de7194b1f07844169ef1a85', '[\"*\"]', '2025-12-23 03:04:52', NULL, '2025-12-23 03:04:31', '2025-12-23 03:04:52'),
(152, 'App\\Models\\User', 1, 'auth_token', '3fdc40169c8f2b50cc7109ca759336dd3d3d5b3fad9b3728a9edc09c2c3f1585', '[\"*\"]', NULL, NULL, '2025-12-26 02:09:59', '2025-12-26 02:09:59'),
(153, 'App\\Models\\User', 1, 'auth_token', '125ad538a1fff8406345b2d4a5772d65518f0e85071f6625b376181192e03e36', '[\"*\"]', '2025-12-26 02:20:44', NULL, '2025-12-26 02:10:03', '2025-12-26 02:20:44'),
(154, 'App\\Models\\User', 1, 'auth_token', '5943392c1cf94fc0372f711bbe0b298855f504270d81b6f9298a5385fb2e3518', '[\"*\"]', '2025-12-26 03:46:26', NULL, '2025-12-26 03:36:56', '2025-12-26 03:46:26'),
(155, 'App\\Models\\User', 1, 'auth_token', '3eb01135a420cbf8572453146a91f6deee98fc6513282c928e8260d21136fbe4', '[\"*\"]', '2025-12-27 03:24:57', NULL, '2025-12-27 01:58:03', '2025-12-27 03:24:57'),
(156, 'App\\Models\\User', 1, 'auth_token', '2546d0d2831d790928355f3fce197dcb8cf186b40092a685e25365b831f14a82', '[\"*\"]', NULL, NULL, '2025-12-28 01:25:51', '2025-12-28 01:25:51'),
(157, 'App\\Models\\User', 1, 'auth_token', 'f3893e99def21ae11a17062fa058b13f05da4e4b438183a8667b9c6ed15dcc91', '[\"*\"]', NULL, NULL, '2025-12-28 01:25:53', '2025-12-28 01:25:53'),
(158, 'App\\Models\\User', 1, 'auth_token', '4fd857a0b86cab0cf436e8825f2427b92078b714136a6a608ec95a67525016ef', '[\"*\"]', '2025-12-28 03:30:25', NULL, '2025-12-28 01:25:58', '2025-12-28 03:30:25'),
(159, 'App\\Models\\User', 1, 'auth_token', 'b5ebe93ab4ffa01123c0f24966c4631956c2a87374c1d3b2d1b97ef1ade1b7b1', '[\"*\"]', '2025-12-29 01:35:17', NULL, '2025-12-29 01:35:10', '2025-12-29 01:35:17'),
(161, 'App\\Models\\User', 1, 'auth_token', '81e3ef148b63ec211e34cfa9225a054183cb96ff357eb857e9ac8a969e6b6d37', '[\"*\"]', '2025-12-29 02:53:20', NULL, '2025-12-29 02:38:59', '2025-12-29 02:53:20');

-- --------------------------------------------------------

--
-- Table structure for table `promos`
--

CREATE TABLE `promos` (
  `id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `banner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `promos`
--

INSERT INTO `promos` (`id`, `title`, `banner`, `description`, `start_date`, `end_date`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Promo', 'promo/v0VWWIR2VybUZ5iZdI0xd1uQMN5qJtnWNdwxsmk3.jpg', 'Mencoba', '2025-12-15', '2026-01-15', 1, '2025-12-15 01:34:42', '2025-12-21 02:23:46'),
(2, 'Promo Lagi', 'promo/coNTAgoYeM7B6eewlU9MPGFYac1qw6WGBOueJnhE.webp', 'Mencoba Lagi', '2025-07-15', '2025-08-15', 0, '2025-12-15 03:35:50', '2025-12-16 01:25:07'),
(3, 'Promo Coba', 'promo/vHnAp9UNJis02OqQan8aBiMOT1SGcBSKCv2wKFXo.png', 'Mencoba', '2025-07-15', '2025-08-15', 0, '2025-12-15 10:42:03', '2025-12-16 01:25:07'),
(4, 'Coba', 'promo/2wTNhvDRrOFq4e8u0K6f44kKsceDEDU4zoLIiMC6.webp', 'Coba', '2025-12-01', '2025-12-31', 1, '2025-12-15 10:56:26', '2025-12-15 10:56:26');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('3Nw1fnZCx3Ed5KCismVCqTFoezmFacJsE19H5dPY', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzQyTUluSm1FdFpPTlZuTGVZdTYzRlltd1RXM29UQkVjYjc1YkxmdiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6ODU6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9tZWRpYS9tZW1iZXItcGhvdG8vSDRHNHh6UVZXSjl5bHRWbXpWaTBrTWk5ZUVoYkF5RTlMZkhJTmpNQS5wbmciO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766973551),
('adlmpKtFYLosAyTduRkHNkoDMxjj24iwSVmlzQds', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSVJGeWdKTjVXTUFUV0NVY3ZtMWNCdDI5bUQ0NUJ5RnFNRkhxcWFsUyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9Wc2h0VUdkU3NFcU44bHRpVWg2MFFiampwMWdqaGlCZHRtYlpBOFo1LmpwZz92PTE3NjY5NzU5NTY1MzkiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766975958),
('eseqefuJnxFRA2VF99Q5FqMEwl5XNPoxjU0V2ZfZ', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0VGT0NBa2Z0TGRER09ueW5ocE5jZWhQamNRcGRxSDFCNVhsVmpPZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6ODY6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9tZWRpYS9tZW1iZXJfcGhvdG9zL1ZzaHRVR2RTc0VxTjhsdGlVaDYwUWJqanAxZ2poaUJkdG1iWkE4WjUuanBnIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1766973899),
('FCMgZ6MtzHRmSwJHfxGtYDOiKm8ppcTg44ZCpSpV', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoielFYWnJoUW5QT0p3WG8yOEx2RVpzSnJjNEUxdVA0eDJ1Y1Q2YWV4SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9Wc2h0VUdkU3NFcU44bHRpVWg2MFFiampwMWdqaGlCZHRtYlpBOFo1LmpwZz92PTE3NjY4OTI2MTY5MjMiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766892617),
('g4jXzqZT7qIVXC9UXfHTw80sP5Hm9FoCXvqn6m8O', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib2RZY21FTVM4NzRkZkk4TU0zU3oydnFMOWZkMG5NVjU0enZRUkI3VyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9Wc2h0VUdkU3NFcU44bHRpVWg2MFFiampwMWdqaGlCZHRtYlpBOFo1LmpwZz92PTE3NjY5NzYzNDE3OTgiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766976342),
('gvxnwuGgk2SltUsjd1NO4vVewESgNbYhCrD8l9R5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZU5RV2tHNWlNVjdyMlJqajMya3dwdGt1endGdWdPY2NLZFR3bm02SCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9iUW1JamZZdDRyd21Fa3E2aERGUzVTVVJnRFZIZk1zdzFGN2Z3bVFkLnBuZz92PTE3NjY4OTI1ODQ0MTgiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766892585),
('J5bODda5MAZY2zrew8s6fBRVxV52kEYNWy8KmXLW', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSFJ0aTlNUUdnNFZIWXM4SE9VSHJKckJOYU1KaVlJSWZoVEJOeWpwMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9iUW1JamZZdDRyd21Fa3E2aERGUzVTVVJnRFZIZk1zdzFGN2Z3bVFkLnBuZz92PTE3NjY4OTI1NTQxOTUiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766892557),
('juGOxHjR6oESfTCFDq65KspPwlAKjTggzcXjzQHk', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZzdFMEZKRVh0dlJJU1A1UmZWenJLQ0dXUGpURFphMVA5cVR0aUlGcyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6ODY6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9tZWRpYS9tZW1iZXJfcGhvdG9zLzRMSEJOYjR6RzJmYlQ3cjZjTTBPeGtDUmVDbmJDN3l1Q25haUVvRjYucG5nIjtzOjU6InJvdXRlIjtOO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1766974382),
('RHLf28Zu6bHv0tAgSyEFpbyXGqsh5XV1DHvlBeOi', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTI0c1BiTnNKYmxxNnF5emVxemdBdVZ3cW44SzhXUXZwdFlVbzl3RCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAxOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyLXBob3RvL0g0RzR4elFWV0o5eWx0Vm16Vmkwa01pOWVFaGJBeUU5TGZISU5qTUEucG5nP3Y9MTc2Njg4NTY1Mzk0NyI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1766885661),
('s8La7UzC9XEgF70NNsnEDXACT6RqDFPVBVn6nJGu', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiamNXQ205UU1DT2VsQVhtWkc5Y0IxRHFUdEc4bW1kZUExMHBQSk12NCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAxOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyLXBob3RvL0g0RzR4elFWV0o5eWx0Vm16Vmkwa01pOWVFaGJBeUU5TGZISU5qTUEucG5nP3Y9MTc2Njg4NTY1Mzk0NyI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1766892283),
('vx9EF8wuUUgfIl8rVlxz2gQ1oVN4Ef9D5hjhw5Te', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiS0dTZ09JeUdLZlVuelVhcDVteGRSMkhNT1dldWNRWWs4NU1JVFBDTCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9Wc2h0VUdkU3NFcU44bHRpVWg2MFFiampwMWdqaGlCZHRtYlpBOFo1LmpwZz92PTE3NjY5NzIxMTc5MjkiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766972121),
('xatVJ474GO3bq6oh0XqBkbodN9mdGEn0zolyMX67', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaU01TVJua1JYQVNBWVRXaE9BSHdkMGdaUjVaWGpXM3prSUpZVzB3QSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9iUW1JamZZdDRyd21Fa3E2aERGUzVTVVJnRFZIZk1zdzFGN2Z3bVFkLnBuZz92PTE3NjY4OTI1NTQxOTUiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766892556),
('Y9JMxFkl0m2FWA8dd5j4TIJfL5Lt44xxiwJdwmpD', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZTlZMnhFeGF5V0FXM2lZck9pYzJ0TERNcVJEMzhpYVh2V21IeW9LMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MTAyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbWVkaWEvbWVtYmVyX3Bob3Rvcy9iUW1JamZZdDRyd21Fa3E2aERGUzVTVVJnRFZIZk1zdzFGN2Z3bVFkLnBuZz92PTE3NjY4OTI1ODQ0MTgiO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1766892586);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `password`, `role`, `email_verified_at`, `remember_token`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Unyilku', 'unyil@example.com', '087675777865', '$2y$12$VO62YBzEyB3QX5oGLKwHYODSNWfyLrqa.T6aQhv.kjE2UTBpZQT9a', 'user', NULL, NULL, 'active', '2025-12-05 02:57:32', '2025-12-28 03:30:12'),
(2, 'User', 'user@example.com', '085654321123', '$2y$12$S9nZvKSMOTc9eo76b1uhHeqGeCtKZ249xFwEp.arlrLqB0sQBebIG', 'user', NULL, NULL, 'active', '2025-12-06 17:01:33', '2025-12-06 17:01:33'),
(4, 'User 2', 'user2@example.com', '081999490429', '$2y$12$7NleUrLrfXsOswywJwdTG.K/A8z71lFqbELPT46Xh7wYo4bxrju6G', 'user', NULL, NULL, 'active', '2025-12-06 17:18:31', '2025-12-06 17:18:31'),
(5, 'Admin', 'admin@example.com', '085816055644', '$2y$12$5et0g56hKZQWpJdtoUY41uwC0NFbCJNj3uO7qwXoqb9IbFyk5uqkq', 'admin', NULL, NULL, 'active', '2025-12-08 03:03:38', '2025-12-29 02:38:36'),
(6, 'Admin Example', 'admin2@example.com', '081765777455', '$2y$12$ULmVKTSUCQrmQWJFT4SajOWhapq6zMa.7GKT4nOaSjALWctevkaua', 'admin', NULL, NULL, 'active', '2025-12-20 04:10:21', '2025-12-20 04:10:21');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `home_services`
--
ALTER TABLE `home_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `home_services_user_id_foreign` (`user_id`),
  ADD KEY `home_services_member_id_foreign` (`member_id`);

--
-- Indexes for table `infos`
--
ALTER TABLE `infos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `members_member_code_unique` (`member_code`),
  ADD KEY `members_membership_type_id_foreign` (`membership_type_id`),
  ADD KEY `members_user_id_foreign` (`user_id`);

--
-- Indexes for table `membership_types`
--
ALTER TABLE `membership_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `membership_types_name_unique` (`name`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `promos`
--
ALTER TABLE `promos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_phone_unique` (`phone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `home_services`
--
ALTER TABLE `home_services`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `infos`
--
ALTER TABLE `infos`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `membership_types`
--
ALTER TABLE `membership_types`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT for table `promos`
--
ALTER TABLE `promos`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `home_services`
--
ALTER TABLE `home_services`
  ADD CONSTRAINT `home_services_member_id_foreign` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `home_services_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `members_membership_type_id_foreign` FOREIGN KEY (`membership_type_id`) REFERENCES `membership_types` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `members_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
