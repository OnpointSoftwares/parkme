<?php
/**
 * Configuration file for USSD Parking System
 */

// Database configuration
define('DB_HOST', 'localhost');
define('DB_NAME', 'parkme');
define('DB_USER', 'root');
define('DB_PASS', '');

// Firebase Realtime Database configuration
define('FIREBASE_URL', 'https://your-project-id.firebaseio.com');
define('FIREBASE_SECRET', 'your-firebase-secret-key');

// Timezone
date_default_timezone_set('Africa/Nairobi');

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/logs/error.log');

// USSD Configuration
define('USSD_SERVICE_CODE', '*384*55555#'); // Your USSD short code
define('USSD_TIMEOUT', 180); // Session timeout in seconds

// Violation penalties
define('ILLEGAL_PARKING_PENALTY', 2000); // KES
define('NO_PAYMENT_PENALTY', 1500); // KES
define('OVERSTAY_PENALTY', 500); // KES per hour

// Application settings
define('APP_NAME', 'ParkMe Officer Portal');
define('APP_VERSION', '1.0.0');
?>
