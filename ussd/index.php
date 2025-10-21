<?php
/**
 * USSD Parking Payment Verification System
 * For field parking officers to verify customer payments
 */

header('Content-Type: text/plain');

// Database configuration
require_once 'config.php';
require_once 'database.php';

// Get USSD parameters
$sessionId = $_POST['sessionId'] ?? '';
$serviceCode = $_POST['serviceCode'] ?? '';
$phoneNumber = $_POST['phoneNumber'] ?? '';
$text = $_POST['text'] ?? '';

// Initialize database connection
$db = new Database();

// Parse user input
$textArray = explode('*', $text);
$level = count($textArray);

// Response variable
$response = '';

try {
    if ($text == '') {
        // Main menu
        $response = "CON Welcome to ParkMe Officer Portal\n";
        $response .= "1. Check Payment Status\n";
        $response .= "2. View Today's Bookings\n";
        $response .= "3. Report Issue\n";
        $response .= "4. My Stats";
        
    } elseif ($text == '1') {
        // Check payment status - ask for vehicle number
        $response = "CON Enter Vehicle Registration Number:\n";
        $response .= "(e.g., KAA 123A)";
        
    } elseif (substr($text, 0, 2) == '1*') {
        // Process vehicle number check
        $vehicleNumber = strtoupper(trim($textArray[1]));
        
        if (empty($vehicleNumber)) {
            $response = "END Invalid vehicle number. Please try again.";
        } else {
            // Check payment status
            $paymentInfo = $db->checkVehiclePayment($vehicleNumber);
            
            if ($paymentInfo) {
                $response = "END Vehicle: {$vehicleNumber}\n";
                $response .= "Status: " . ($paymentInfo['isPaid'] ? "✓ PAID" : "✗ NOT PAID") . "\n";
                $response .= "Location: {$paymentInfo['location']}\n";
                $response .= "Date: {$paymentInfo['date']}\n";
                $response .= "Time: {$paymentInfo['checkin']} - {$paymentInfo['checkout']}\n";
                $response .= "Amount: KES {$paymentInfo['cost']}\n";
                
                if ($paymentInfo['isPaid']) {
                    $response .= "Transaction: {$paymentInfo['transactionID']}";
                } else {
                    $response .= "\nAction: Request payment or issue violation";
                }
            } else {
                $response = "END Vehicle: {$vehicleNumber}\n";
                $response .= "Status: ✗ NO BOOKING FOUND\n\n";
                $response .= "This vehicle has no active parking reservation.\n";
                $response .= "Action: Issue parking violation if parked illegally.";
            }
        }
        
    } elseif ($text == '2') {
        // View today's bookings
        $todayBookings = $db->getTodayBookings();
        
        if (count($todayBookings) > 0) {
            $response = "END Today's Bookings: " . count($todayBookings) . "\n\n";
            $count = 0;
            foreach ($todayBookings as $booking) {
                if ($count >= 5) {
                    $response .= "\n...and " . (count($todayBookings) - 5) . " more";
                    break;
                }
                $status = $booking['isPaid'] ? '✓' : '✗';
                $response .= "{$status} {$booking['vehicleNumber']} - {$booking['location']}\n";
                $count++;
            }
        } else {
            $response = "END No bookings found for today.";
        }
        
    } elseif ($text == '3') {
        // Report issue menu
        $response = "CON Report Issue:\n";
        $response .= "1. Illegal Parking\n";
        $response .= "2. Payment Dispute\n";
        $response .= "3. System Error\n";
        $response .= "4. Other";
        
    } elseif ($text == '3*1') {
        // Illegal parking - ask for vehicle number
        $response = "CON Enter Vehicle Number for Illegal Parking Report:";
        
    } elseif (substr($text, 0, 4) == '3*1*') {
        // Process illegal parking report
        $vehicleNumber = strtoupper(trim($textArray[2]));
        
        if (empty($vehicleNumber)) {
            $response = "END Invalid vehicle number.";
        } else {
            // Record violation
            $violationId = $db->recordViolation($vehicleNumber, $phoneNumber, 'Illegal Parking');
            
            if ($violationId) {
                $response = "END Violation Recorded\n";
                $response .= "Vehicle: {$vehicleNumber}\n";
                $response .= "Type: Illegal Parking\n";
                $response .= "Violation ID: {$violationId}\n";
                $response .= "Officer: {$phoneNumber}\n\n";
                $response .= "Penalty notice will be issued.";
            } else {
                $response = "END Failed to record violation. Please try again.";
            }
        }
        
    } elseif ($text == '3*2' || $text == '3*3' || $text == '3*4') {
        // Other issue types
        $issueType = $textArray[1] == '2' ? 'Payment Dispute' : 
                     ($textArray[1] == '3' ? 'System Error' : 'Other');
        $response = "CON Enter details for {$issueType}:";
        
    } elseif (substr($text, 0, 4) == '3*2*' || substr($text, 0, 4) == '3*3*' || substr($text, 0, 4) == '3*4*') {
        // Process issue report
        $issueType = $textArray[1] == '2' ? 'Payment Dispute' : 
                     ($textArray[1] == '3' ? 'System Error' : 'Other');
        $details = trim($textArray[2]);
        
        $reportId = $db->recordIssue($phoneNumber, $issueType, $details);
        
        if ($reportId) {
            $response = "END Issue Reported\n";
            $response .= "Type: {$issueType}\n";
            $response .= "Report ID: {$reportId}\n";
            $response .= "Officer: {$phoneNumber}\n\n";
            $response .= "Your report has been submitted.";
        } else {
            $response = "END Failed to submit report. Please try again.";
        }
        
    } elseif ($text == '4') {
        // Officer stats
        $stats = $db->getOfficerStats($phoneNumber);
        
        $response = "END Your Stats (Today)\n\n";
        $response .= "Checks: {$stats['checks']}\n";
        $response .= "Violations: {$stats['violations']}\n";
        $response .= "Reports: {$stats['reports']}\n";
        $response .= "Active Bookings: {$stats['activeBookings']}\n\n";
        $response .= "Keep up the good work!";
        
    } else {
        // Invalid option
        $response = "END Invalid option. Please try again.";
    }
    
} catch (Exception $e) {
    error_log("USSD Error: " . $e->getMessage());
    $response = "END System error. Please try again later.";
}

// Log the interaction
$db->logUssdInteraction($sessionId, $phoneNumber, $text, $response);

// Output response
echo $response;
?>
