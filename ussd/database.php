<?php
/**
 * Database class for USSD Parking System
 * Connects to Firebase Realtime Database
 */

class Database {
    private $firebaseUrl;
    private $firebaseSecret;
    
    public function __construct() {
        $this->firebaseUrl = FIREBASE_URL;
        $this->firebaseSecret = FIREBASE_SECRET;
    }
    
    /**
     * Make Firebase request
     */
    private function firebaseRequest($path, $method = 'GET', $data = null) {
        $url = $this->firebaseUrl . $path . '.json';
        
        if ($this->firebaseSecret) {
            $url .= '?auth=' . $this->firebaseSecret;
        }
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        if ($method == 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        } elseif ($method == 'PUT') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        } elseif ($method == 'PATCH') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode >= 200 && $httpCode < 300) {
            return json_decode($response, true);
        }
        
        return null;
    }
    
    /**
     * Check vehicle payment status
     */
    public function checkVehiclePayment($vehicleNumber) {
        $today = date('Y-m-d');
        
        // Get all reservations
        $reservations = $this->firebaseRequest('/reservations');
        
        if (!$reservations) {
            return null;
        }
        
        // Find matching vehicle for today
        foreach ($reservations as $id => $reservation) {
            if (isset($reservation['vehicleNumber']) && 
                strtoupper($reservation['vehicleNumber']) == strtoupper($vehicleNumber)) {
                
                // Check if booking is for today
                $bookingDate = isset($reservation['date']) ? $reservation['date'] : '';
                
                if (strpos($bookingDate, $today) !== false || 
                    $this->isToday($bookingDate)) {
                    
                    return [
                        'id' => $id,
                        'vehicleNumber' => $reservation['vehicleNumber'],
                        'location' => $reservation['centre'] ?? 'N/A',
                        'date' => $reservation['date'] ?? 'N/A',
                        'checkin' => $reservation['checkin'] ?? 'N/A',
                        'checkout' => $reservation['checkout'] ?? 'N/A',
                        'cost' => $reservation['cost'] ?? '0',
                        'transactionID' => $reservation['transactionID'] ?? 'N/A',
                        'isPaid' => isset($reservation['transactionID']) && 
                                   !empty($reservation['transactionID']) &&
                                   $reservation['transactionID'] != 'N/A',
                        'status' => $reservation['status'] ?? 'pending'
                    ];
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get today's bookings
     */
    public function getTodayBookings() {
        $today = date('Y-m-d');
        $bookings = [];
        
        $reservations = $this->firebaseRequest('/reservations');
        
        if (!$reservations) {
            return $bookings;
        }
        
        foreach ($reservations as $id => $reservation) {
            $bookingDate = isset($reservation['date']) ? $reservation['date'] : '';
            
            if (strpos($bookingDate, $today) !== false || $this->isToday($bookingDate)) {
                $bookings[] = [
                    'id' => $id,
                    'vehicleNumber' => $reservation['vehicleNumber'] ?? 'N/A',
                    'location' => $reservation['centre'] ?? 'N/A',
                    'isPaid' => isset($reservation['transactionID']) && 
                               !empty($reservation['transactionID']),
                    'cost' => $reservation['cost'] ?? '0'
                ];
            }
        }
        
        return $bookings;
    }
    
    /**
     * Record parking violation
     */
    public function recordViolation($vehicleNumber, $officerPhone, $violationType) {
        $violation = [
            'vehicleNumber' => $vehicleNumber,
            'officerPhone' => $officerPhone,
            'violationType' => $violationType,
            'timestamp' => date('Y-m-d H:i:s'),
            'location' => 'Field Report',
            'penaltyAmount' => ILLEGAL_PARKING_PENALTY,
            'isPaid' => false,
            'status' => 'pending',
            'description' => 'Reported via USSD by field officer'
        ];
        
        $result = $this->firebaseRequest('/violations', 'POST', $violation);
        
        if ($result && isset($result['name'])) {
            return $result['name'];
        }
        
        return null;
    }
    
    /**
     * Record issue report
     */
    public function recordIssue($officerPhone, $issueType, $details) {
        $issue = [
            'officerPhone' => $officerPhone,
            'issueType' => $issueType,
            'details' => $details,
            'timestamp' => date('Y-m-d H:i:s'),
            'status' => 'open',
            'priority' => 'medium'
        ];
        
        $result = $this->firebaseRequest('/issues', 'POST', $issue);
        
        if ($result && isset($result['name'])) {
            return substr($result['name'], 0, 8);
        }
        
        return null;
    }
    
    /**
     * Get officer statistics
     */
    public function getOfficerStats($phoneNumber) {
        $today = date('Y-m-d');
        
        $stats = [
            'checks' => 0,
            'violations' => 0,
            'reports' => 0,
            'activeBookings' => 0
        ];
        
        // Get violations by this officer today
        $violations = $this->firebaseRequest('/violations');
        if ($violations) {
            foreach ($violations as $violation) {
                if (isset($violation['officerPhone']) && 
                    $violation['officerPhone'] == $phoneNumber &&
                    strpos($violation['timestamp'], $today) !== false) {
                    $stats['violations']++;
                }
            }
        }
        
        // Get issues reported today
        $issues = $this->firebaseRequest('/issues');
        if ($issues) {
            foreach ($issues as $issue) {
                if (isset($issue['officerPhone']) && 
                    $issue['officerPhone'] == $phoneNumber &&
                    strpos($issue['timestamp'], $today) !== false) {
                    $stats['reports']++;
                }
            }
        }
        
        // Get USSD interactions (checks)
        $interactions = $this->firebaseRequest('/ussd_logs');
        if ($interactions) {
            foreach ($interactions as $interaction) {
                if (isset($interaction['phoneNumber']) && 
                    $interaction['phoneNumber'] == $phoneNumber &&
                    strpos($interaction['timestamp'], $today) !== false) {
                    $stats['checks']++;
                }
            }
        }
        
        // Get active bookings
        $bookings = $this->getTodayBookings();
        $stats['activeBookings'] = count($bookings);
        
        return $stats;
    }
    
    /**
     * Log USSD interaction
     */
    public function logUssdInteraction($sessionId, $phoneNumber, $input, $response) {
        $log = [
            'sessionId' => $sessionId,
            'phoneNumber' => $phoneNumber,
            'input' => $input,
            'response' => substr($response, 0, 100), // First 100 chars
            'timestamp' => date('Y-m-d H:i:s')
        ];
        
        $this->firebaseRequest('/ussd_logs', 'POST', $log);
    }
    
    /**
     * Check if date string is today
     */
    private function isToday($dateString) {
        $today = date('Y-m-d');
        $formats = ['Y-m-d', 'd/m/Y', 'm/d/Y', 'd-m-Y'];
        
        foreach ($formats as $format) {
            $date = DateTime::createFromFormat($format, $dateString);
            if ($date && $date->format('Y-m-d') == $today) {
                return true;
            }
        }
        
        return false;
    }
}
?>
