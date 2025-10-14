# Kanjo Officer Module - Complete Documentation

## 📋 Overview

The Kanjo Officer module provides a comprehensive enforcement and compliance management system for Nairobi City County parking enforcement officers (commonly known as "kanjo"). This module enables digital violation recording, real-time monitoring, revenue tracking, and automated reporting.

---

## 🏗️ Architecture

### Folder Structure

```
lib/kanjo/
├── models/
│   └── kanjo_models.dart           # Data models
├── services/
│   └── kanjo_service.dart          # Business logic & Firebase operations
├── screens/
│   ├── kanjo_dashboard.dart        # Main dashboard
│   ├── record_violation_screen.dart # Violation recording
│   └── daily_report_screen.dart    # Daily reports
├── widgets/
│   └── kanjo_widgets.dart          # Reusable UI components
└── README.md                        # This file
```

---

## 📦 Data Models

### 1. **ParkingViolation**

Represents a parking violation issued by a kanjo officer.

```dart
ParkingViolation(
  id: 'V_1234567890',
  vehicleNumber: 'KAA 123A',
  location: 'CBD - Kenyatta Avenue',
  violationType: 'illegal_parking',
  description: 'Vehicle parked in no-parking zone',
  penaltyAmount: 2000.0,
  timestamp: DateTime.now(),
  officerId: 'officer_uid',
  officerName: 'John Doe',
  imageUrl: 'https://...',
  locationData: {'latitude': -1.2921, 'longitude': 36.8219},
  isPaid: false,
)
```

**Fields:**
- `id`: Unique violation identifier
- `vehicleNumber`: Vehicle registration number
- `location`: Human-readable location
- `violationType`: Type of violation (see violation types below)
- `description`: Detailed description
- `penaltyAmount`: Fine amount in KES
- `timestamp`: When violation was recorded
- `officerId`: Officer who recorded it
- `officerName`: Officer's name
- `imageUrl`: Optional evidence photo
- `locationData`: GPS coordinates
- `isPaid`: Payment status

### 2. **KanjoOfficer**

Represents a kanjo officer profile.

```dart
KanjoOfficer(
  id: 'officer_uid',
  name: 'John Doe',
  badgeNumber: 'NCC-001',
  department: 'Parking Enforcement',
  zone: 'CBD',
  contactNumber: '+254712345678',
  isActive: true,
  joinedDate: DateTime(2024, 1, 1),
  assignedAreas: ['CBD', 'Westlands'],
)
```

### 3. **EnforcementStats**

Statistics for enforcement activities.

```dart
EnforcementStats(
  totalViolations: 150,
  totalRevenue: 300000.0,
  pendingViolations: 50,
  resolvedViolations: 100,
  violationsByType: {
    'illegal_parking': 80,
    'expired_meter': 40,
    'no_permit': 30,
  },
  revenueByZone: {
    'CBD': 200000.0,
    'Westlands': 100000.0,
  },
)
```

### 4. **DailyReport**

Daily enforcement report for an officer.

```dart
DailyReport(
  date: DateTime(2025, 10, 14),
  officerId: 'officer_uid',
  officerName: 'John Doe',
  violations: [...],
  totalRevenue: 50000.0,
  totalViolations: 25,
  violationsByType: {...},
  notes: 'Heavy traffic in CBD today',
)
```

---

## 🔧 Services

### KanjoService

Main service class for all kanjo officer operations.

#### Officer Management

```dart
// Get current officer profile
KanjoOfficer? officer = await service.getCurrentOfficer();

// Create officer profile
await service.createOfficerProfile(officer);
```

#### Violation Management

```dart
// Record a violation
String violationId = await service.recordViolation(violation);

// Get officer's violations (real-time stream)
Stream<List<ParkingViolation>> violations = service.getOfficerViolations(limit: 50);

// Get all violations (admin access)
Stream<List<ParkingViolation>> allViolations = service.getAllViolations(limit: 100);

// Update payment status
await service.updateViolationPayment(violationId, true);

// Search by vehicle number
List<ParkingViolation> violations = await service.searchViolationsByVehicle('KAA 123A');

// Get violations by status
List<ParkingViolation> pending = await service.getViolationsByStatus(false);
```

#### Statistics & Reports

```dart
// Get officer statistics
EnforcementStats stats = await service.getOfficerStats();

// Get daily report
DailyReport report = await service.getDailyReport(DateTime.now());

// Submit daily report
await service.submitDailyReport(report);
```

#### Utilities

```dart
// Get violation types and penalties
Map<String, double> types = service.getViolationTypes();

// Get common locations
List<String> locations = service.getCommonLocations();

// Check area permissions
bool canEnforce = await service.canEnforceInArea('CBD');

// Get assigned areas
List<String> areas = await service.getAssignedAreas();
```

---

## 🎨 UI Components

### Screens

#### 1. **KanjoDashboard**

Main dashboard with:
- Officer profile header
- Today's statistics (violations, revenue, pending, resolved)
- Quick actions (Record Violation, Daily Report, Search Vehicle)
- Recent violations list
- Menu (Profile, Settings, Logout)

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const KanjoDashboard()),
);
```

#### 2. **RecordViolationScreen**

Form for recording violations with:
- Vehicle number input
- Location picker with GPS
- Violation type dropdown
- Automatic penalty calculation
- Description field
- Submit button

```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RecordViolationScreen()),
);
```

#### 3. **DailyReportScreen**

Daily report view with:
- Date selector
- Officer information
- Summary statistics
- Violation breakdown chart
- List of recorded violations
- Notes section
- Submit report button

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DailyReportScreen()),
);
```

### Widgets

#### 1. **ViolationCard**

Displays violation information in a card format.

```dart
ViolationCard(
  violation: violation,
  onTap: () => showDetails(violation),
)
```

#### 2. **StatsCard**

Displays a single statistic with icon and color.

```dart
StatsCard(
  title: 'Total Violations',
  value: '150',
  icon: Icons.warning,
  color: Colors.red,
)
```

#### 3. **ViolationTypeChart**

Bar chart showing violation distribution by type.

```dart
ViolationTypeChart(
  violationsByType: {
    'illegal_parking': 80,
    'expired_meter': 40,
  },
)
```

#### 4. **OfficerInfoCard**

Displays officer profile information.

```dart
OfficerInfoCard(
  officer: officer,
)
```

---

## 🚨 Violation Types & Penalties

```dart
{
  'illegal_parking': 2000.0,        // KES 2,000
  'expired_meter': 1500.0,          // KES 1,500
  'no_permit': 3000.0,              // KES 3,000
  'blocking_driveway': 2500.0,      // KES 2,500
  'double_parking': 2000.0,         // KES 2,000
  'parking_wrong_direction': 1500.0, // KES 1,500
  'parking_disabled_spot': 5000.0,  // KES 5,000
  'parking_loading_zone': 3000.0,   // KES 3,000
}
```

---

## 🔐 Security & Permissions

### Authentication
- All operations require Firebase authentication
- Officer profile must exist and be active

### Authorization
- Officers can only view/manage their own violations
- Admin/supervisor roles can view all violations
- Area-based enforcement permissions

### Data Validation
- Vehicle number format validation
- Location verification
- Penalty amount validation
- Officer authorization checks

---

## 🗄️ Firebase Database Structure

```
firebase-realtime-database/
├── kanjo_officers/
│   └── {officerId}/
│       ├── id
│       ├── name
│       ├── badgeNumber
│       ├── department
│       ├── zone
│       ├── contactNumber
│       ├── isActive
│       ├── joinedDate
│       └── assignedAreas[]
│
├── parking_violations/
│   └── {violationId}/
│       ├── id
│       ├── vehicleNumber
│       ├── location
│       ├── violationType
│       ├── description
│       ├── penaltyAmount
│       ├── timestamp
│       ├── officerId
│       ├── officerName
│       ├── imageUrl
│       ├── locationData
│       ├── isPaid
│       └── paidAt
│
└── daily_reports/
    └── {reportId}/
        ├── date
        ├── officerId
        ├── officerName
        ├── violations[]
        ├── totalRevenue
        ├── totalViolations
        ├── violationsByType
        └── notes
```

---

## 📱 Usage Examples

### Complete Workflow Example

```dart
// 1. Initialize service
final service = KanjoService();

// 2. Get current officer
final officer = await service.getCurrentOfficer();

// 3. Record a violation
final violation = ParkingViolation(
  id: '',
  vehicleNumber: 'KAA 123A',
  location: 'CBD - Kenyatta Avenue',
  violationType: 'illegal_parking',
  description: 'Parked in no-parking zone',
  penaltyAmount: 2000.0,
  timestamp: DateTime.now(),
  officerId: '',
  officerName: '',
);

final violationId = await service.recordViolation(violation);

// 4. Get today's statistics
final stats = await service.getOfficerStats();
print('Total violations: ${stats.totalViolations}');
print('Total revenue: KES ${stats.totalRevenue}');

// 5. Generate daily report
final report = await service.getDailyReport(DateTime.now());
await service.submitDailyReport(report);
```

---

## 🔄 Integration with Authentication

### Sign Up

Users can select "Kanjo Officer" during registration:

```dart
// In signUp.dart
String _selectedUserType = 'kanjo'; // 'user', 'owner', or 'kanjo'
```

### Sign In

Kanjo officers are automatically redirected to their dashboard:

```dart
// In signIn.dart
case 'kanjo':
  destination = const KanjoDashboard();
  break;
```

---

## ✅ Features Checklist

### Core Features
- [x] Officer profile management
- [x] Violation recording with GPS
- [x] Real-time violation tracking
- [x] Payment status updates
- [x] Daily statistics
- [x] Daily report generation
- [x] Vehicle search
- [x] Violation type management

### UI/UX
- [x] Modern dashboard design
- [x] Quick action buttons
- [x] Real-time data updates
- [x] Loading states
- [x] Error handling
- [x] Empty states
- [x] Pull-to-refresh

### Security
- [x] Authentication required
- [x] Officer authorization
- [x] Data validation
- [x] Area permissions
- [x] Audit trails

---

## 🚀 Future Enhancements

### Phase 1 (Immediate)
- [ ] Image upload for violation evidence
- [ ] Offline mode support
- [ ] Push notifications
- [ ] Export reports to PDF

### Phase 2 (Short-term)
- [ ] Integration with county payment systems
- [ ] Real-time violation alerts
- [ ] Advanced analytics dashboard
- [ ] Multi-language support (English/Swahili)

### Phase 3 (Long-term)
- [ ] AI-powered violation detection
- [ ] Vehicle plate recognition
- [ ] Predictive analytics
- [ ] Mobile app for field officers

---

## 🧪 Testing

### Unit Tests
```dart
// Test violation recording
test('Record violation successfully', () async {
  final service = KanjoService();
  final violationId = await service.recordViolation(testViolation);
  expect(violationId, isNotEmpty);
});

// Test statistics calculation
test('Calculate officer statistics', () async {
  final service = KanjoService();
  final stats = await service.getOfficerStats();
  expect(stats.totalViolations, greaterThan(0));
});
```

### Integration Tests
- Test complete violation recording flow
- Test daily report generation
- Test payment status updates
- Test real-time data synchronization

---

## 📞 Support & Maintenance

### Common Issues

**Issue**: Officer profile not found
**Solution**: Complete officer profile setup in dashboard

**Issue**: Location not working
**Solution**: Enable location permissions in device settings

**Issue**: Violations not syncing
**Solution**: Check internet connection and Firebase configuration

---

## 📊 Performance Considerations

- Use `StreamBuilder` for real-time violation updates
- Implement pagination for large violation lists
- Cache officer profile locally
- Optimize Firebase queries with indexes
- Compress images before upload

---

## 🎯 Best Practices

1. **Always validate input** before recording violations
2. **Use GPS coordinates** for accurate location tracking
3. **Take photos** as evidence when possible
4. **Submit daily reports** at end of shift
5. **Keep officer profile updated**
6. **Review pending violations** regularly

---

**Status**: ✅ **PRODUCTION READY**

**Version**: 1.0.0  
**Last Updated**: October 14, 2025  
**Maintainer**: ParkMe Development Team
