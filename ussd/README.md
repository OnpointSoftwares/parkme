# ParkMe USSD Payment Verification System

## Overview
This USSD application allows field parking officers to verify customer payments in real-time using their mobile phones. Officers can check if vehicles have paid for parking without needing smartphones or internet access.

## Features

### 1. **Payment Verification**
- Enter vehicle registration number
- Instantly see payment status (PAID/NOT PAID)
- View booking details (location, time, amount)
- See transaction ID for paid bookings

### 2. **Today's Bookings**
- View all active bookings for the day
- Quick overview of paid vs unpaid vehicles
- Shows up to 5 recent bookings

### 3. **Report Issues**
- **Illegal Parking**: Record violations for vehicles parked without payment
- **Payment Disputes**: Report customer payment issues
- **System Errors**: Report technical problems
- **Other Issues**: General issue reporting

### 4. **Officer Statistics**
- View daily performance metrics
- Track number of checks performed
- See violations recorded
- Monitor active bookings

## USSD Flow

```
*384*55555#
├── 1. Check Payment Status
│   └── Enter Vehicle Number (e.g., KAA 123A)
│       ├── ✓ PAID - Shows booking details + transaction ID
│       ├── ✗ NOT PAID - Shows booking details + action required
│       └── ✗ NO BOOKING - Suggests issuing violation
│
├── 2. View Today's Bookings
│   └── Shows list of active bookings with payment status
│
├── 3. Report Issue
│   ├── 1. Illegal Parking → Enter Vehicle Number
│   ├── 2. Payment Dispute → Enter Details
│   ├── 3. System Error → Enter Details
│   └── 4. Other → Enter Details
│
└── 4. My Stats
    └── Shows daily statistics (checks, violations, reports)
```

## Installation

### Prerequisites
- PHP 7.4 or higher
- cURL extension enabled
- Firebase Realtime Database access
- USSD gateway (Africa's Talking, Safaricom, etc.)

### Setup Steps

1. **Configure Firebase**
   ```php
   // In config.php, update:
   define('FIREBASE_URL', 'https://your-project-id.firebaseio.com');
   define('FIREBASE_SECRET', 'your-firebase-secret-key');
   ```

2. **Set USSD Short Code**
   ```php
   // In config.php:
   define('USSD_SERVICE_CODE', '*384*55555#'); // Your actual code
   ```

3. **Configure USSD Gateway**
   - Point your USSD gateway callback URL to: `https://yourdomain.com/ussd/index.php`
   - Ensure POST parameters are sent: `sessionId`, `serviceCode`, `phoneNumber`, `text`

4. **Set Permissions**
   ```bash
   chmod 755 ussd/
   chmod 644 ussd/*.php
   mkdir ussd/logs
   chmod 777 ussd/logs
   ```

5. **Test the System**
   - Dial your USSD code from a registered officer phone
   - Test payment verification with existing bookings
   - Verify Firebase data is being read correctly

## Database Structure

### Firebase Realtime Database Paths

**Reservations** (`/reservations/{id}`)
```json
{
  "vehicleNumber": "KAA 123A",
  "centre": "Westlands Mall",
  "date": "2025-10-21",
  "checkin": "09:00",
  "checkout": "17:00",
  "cost": "500",
  "transactionID": "ABC123XYZ",
  "status": "confirmed",
  "uid": "user-id"
}
```

**Violations** (`/violations/{id}`)
```json
{
  "vehicleNumber": "KBB 456C",
  "officerPhone": "+254712345678",
  "violationType": "Illegal Parking",
  "timestamp": "2025-10-21 14:30:00",
  "penaltyAmount": 2000,
  "isPaid": false,
  "status": "pending"
}
```

**Issues** (`/issues/{id}`)
```json
{
  "officerPhone": "+254712345678",
  "issueType": "Payment Dispute",
  "details": "Customer claims payment not reflecting",
  "timestamp": "2025-10-21 15:00:00",
  "status": "open"
}
```

**USSD Logs** (`/ussd_logs/{id}`)
```json
{
  "sessionId": "session-123",
  "phoneNumber": "+254712345678",
  "input": "1*KAA123A",
  "response": "END Vehicle: KAA123A...",
  "timestamp": "2025-10-21 16:00:00"
}
```

## Usage Examples

### Example 1: Check Paid Vehicle
```
Officer dials: *384*55555#
System: Welcome to ParkMe Officer Portal
        1. Check Payment Status
        [Officer selects 1]

System: Enter Vehicle Registration Number:
        (e.g., KAA 123A)
        [Officer enters: KAA123A]

System: Vehicle: KAA123A
        Status: ✓ PAID
        Location: Westlands Mall
        Date: 2025-10-21
        Time: 09:00 - 17:00
        Amount: KES 500
        Transaction: ABC123XYZ
```

### Example 2: Check Unpaid Vehicle
```
[After selecting option 1 and entering vehicle number]

System: Vehicle: KBB456C
        Status: ✗ NOT PAID
        Location: CBD Parking
        Date: 2025-10-21
        Time: 10:00 - 18:00
        Amount: KES 300
        
        Action: Request payment or issue violation
```

### Example 3: Report Illegal Parking
```
Officer dials: *384*55555#
[Selects 3 - Report Issue]
[Selects 1 - Illegal Parking]

System: Enter Vehicle Number for Illegal Parking Report:
        [Officer enters: KCC789D]

System: Violation Recorded
        Vehicle: KCC789D
        Type: Illegal Parking
        Violation ID: abc12345
        Officer: +254712345678
        
        Penalty notice will be issued.
```

## Security Considerations

1. **Officer Authentication**: Only registered officer phone numbers should access the system
2. **Rate Limiting**: Implement rate limiting to prevent abuse
3. **Data Privacy**: Log only necessary information
4. **Secure Connection**: Use HTTPS for all API calls
5. **Firebase Rules**: Set proper read/write rules in Firebase

## Troubleshooting

### Common Issues

**Issue**: "System error. Please try again later."
- **Solution**: Check Firebase credentials in config.php
- Verify Firebase URL is correct
- Ensure cURL extension is enabled

**Issue**: No bookings found for valid vehicles
- **Solution**: Check date format in Firebase
- Verify timezone settings in config.php
- Ensure reservation data structure matches expected format

**Issue**: USSD session timeout
- **Solution**: Reduce menu depth
- Increase USSD_TIMEOUT in config.php
- Optimize Firebase queries

## Integration with ParkMe App

The USSD system integrates seamlessly with the ParkMe Flutter app:

1. **Shared Database**: Uses same Firebase Realtime Database
2. **Real-time Updates**: Changes reflect immediately
3. **Violation Sync**: Violations recorded via USSD appear in Kanjo dashboard
4. **Payment Status**: Reads transaction IDs from M-Pesa integration

## Customization

### Adding New Menu Options

Edit `index.php` and add new conditions:

```php
elseif ($text == '5') {
    // Your new menu option
    $response = "CON Your custom menu\n";
    $response .= "1. Option 1\n";
    $response .= "2. Option 2";
}
```

### Changing Penalty Amounts

Edit `config.php`:

```php
define('ILLEGAL_PARKING_PENALTY', 2000); // Change amount
define('NO_PAYMENT_PENALTY', 1500);
define('OVERSTAY_PENALTY', 500);
```

## Support

For issues or questions:
- Email: support@parkme.com
- Phone: +254 XXX XXX XXX

## License

Copyright © 2025 ParkMe. All rights reserved.
