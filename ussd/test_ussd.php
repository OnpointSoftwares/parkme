<?php
/**
 * USSD Testing Script
 * Simulates USSD requests for testing the payment verification system
 */

require_once 'config.php';
require_once 'database.php';

echo "=== ParkMe USSD Testing Tool ===\n\n";

// Test scenarios
$testScenarios = [
    [
        'name' => 'Main Menu',
        'sessionId' => 'test-session-1',
        'phoneNumber' => '+254712345678',
        'text' => ''
    ],
    [
        'name' => 'Check Payment - Menu',
        'sessionId' => 'test-session-2',
        'phoneNumber' => '+254712345678',
        'text' => '1'
    ],
    [
        'name' => 'Check Payment - Vehicle KAA123A',
        'sessionId' => 'test-session-3',
        'phoneNumber' => '+254712345678',
        'text' => '1*KAA123A'
    ],
    [
        'name' => 'View Today\'s Bookings',
        'sessionId' => 'test-session-4',
        'phoneNumber' => '+254712345678',
        'text' => '2'
    ],
    [
        'name' => 'Report Issue Menu',
        'sessionId' => 'test-session-5',
        'phoneNumber' => '+254712345678',
        'text' => '3'
    ],
    [
        'name' => 'Report Illegal Parking',
        'sessionId' => 'test-session-6',
        'phoneNumber' => '+254712345678',
        'text' => '3*1*KBB456C'
    ],
    [
        'name' => 'Officer Stats',
        'sessionId' => 'test-session-7',
        'phoneNumber' => '+254712345678',
        'text' => '4'
    ]
];

// Run tests
foreach ($testScenarios as $scenario) {
    echo "Test: {$scenario['name']}\n";
    echo str_repeat('-', 50) . "\n";
    
    $_POST = [
        'sessionId' => $scenario['sessionId'],
        'serviceCode' => USSD_SERVICE_CODE,
        'phoneNumber' => $scenario['phoneNumber'],
        'text' => $scenario['text']
    ];
    
    ob_start();
    include 'index.php';
    $response = ob_get_clean();
    
    echo "Input: '{$scenario['text']}'\n";
    echo "Response:\n{$response}\n";
    echo str_repeat('=', 50) . "\n\n";
}

echo "Testing completed!\n";
?>
