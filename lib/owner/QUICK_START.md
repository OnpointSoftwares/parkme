# Owner Dashboard - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### 1. Import the Dashboard

```dart
import 'package:parkme/owner/owner_dashboard_main.dart';
```

### 2. Navigate to Dashboard

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OwnerDashboard(),
  ),
);
```

### 3. That's it! 🎉

The dashboard is fully functional with:
- Parking spot management
- Booking tracking
- Statistics
- Location picker

---

## 📱 Main Features

### Add Parking Spot
1. Tap **"Add Spot"** button
2. Fill in basic information (name, address, city)
3. Tap map icon to pick location
4. Set parking details (spots, type, size)
5. Add pricing and owner info
6. Select amenities
7. Tap **"Add Parking Spot"**

### Edit Parking Spot
1. Tap **Edit** icon on any spot card
2. Modify fields as needed
3. Tap **"Update Parking Spot"**

### View Statistics
1. Tap analytics icon in header
2. View real-time metrics:
   - Total spots
   - Active spots
   - Capacity & occupancy
   - Occupancy rate

### Manage Bookings
1. Switch to **"Bookings"** tab
2. Use filters: All, Today, Upcoming, Completed
3. Tap any booking for details

---

## 🎨 UI Components

### Available Widgets

```dart
// Parking Spot Card
import 'package:parkme/owner/widgets/parking_spot_card.dart';

ParkingSpotCard(
  spot: parkingSpot,
  onEdit: () => editSpot(),
  onDelete: () => deleteSpot(),
);

// Booking Card
import 'package:parkme/owner/widgets/booking_card.dart';

BookingCard(
  booking: bookingData,
  onTap: () => showDetails(),
);

// Statistics Card
import 'package:parkme/owner/widgets/statistics_card.dart';

StatisticsCard(
  statistics: statsData,
);

// Location Picker
import 'package:parkme/owner/widgets/location_picker_widget.dart';

final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LocationPickerWidget(
      initialPosition: LatLng(-1.2921, 36.8219),
    ),
  ),
);
```

---

## 🔧 Using the Service Layer

```dart
import 'package:parkme/owner/services/parking_spot_service.dart';

final service = ParkingSpotService();

// Get owner's parking spots (Stream)
Stream<List<ParkingSpot>> spots = service.getOwnerParkingSpots();

// Add parking spot
await service.addParkingSpot(newSpot);

// Update parking spot
await service.updateParkingSpot(spotId, updatedSpot);

// Delete parking spot
await service.deleteParkingSpot(spotId);

// Get bookings
List<Map<String, dynamic>> bookings = await service.getOwnerBookings();

// Get statistics
Map<String, dynamic> stats = await service.getOwnerStatistics();
```

---

## 📦 Data Models

```dart
import 'package:parkme/owner/models/parking_spot_model.dart';

// Create parking spot
final spot = ParkingSpot(
  id: DateTime.now().millisecondsSinceEpoch,
  name: 'Downtown Parking',
  address: '123 Main St',
  city: 'Nairobi',
  state: 'Nairobi',
  zipCode: '00100',
  totalSpots: 50,
  occupiedSpots: 20,
  imageUrl: 'https://example.com/image.jpg',
  costPerHour: 100,
  owner: 'John Doe',
  type: 'Covered',
  size: 'Standard',
  amenities: ['Security Camera', 'Lighting'],
  description: 'Secure parking in downtown',
  isActive: true,
  position: LatLng(-1.2921, 36.8219),
);

// Convert to Firebase format
Map<String, dynamic> data = spot.toMap(ownerId);

// Create from Firebase data
ParkingSpot spot = ParkingSpot.fromMap(key, firebaseData);

// Get computed properties
int available = spot.availableSpots;
double occupancy = spot.occupancyPercentage;
```

---

## 🎯 Common Tasks

### Task 1: Add Validation to Form
```dart
validator: (value) {
  if (value?.isEmpty ?? true) return 'Required';
  if (int.tryParse(value!) == null) return 'Invalid number';
  return null;
}
```

### Task 2: Show Loading State
```dart
bool _isLoading = false;

// Start loading
setState(() => _isLoading = true);

// Stop loading
setState(() => _isLoading = false);

// In UI
_isLoading 
  ? CircularProgressIndicator() 
  : YourWidget()
```

### Task 3: Handle Errors
```dart
try {
  await service.addParkingSpot(spot);
  // Show success
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Success!'), backgroundColor: Colors.green),
  );
} catch (e) {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
  );
}
```

### Task 4: Navigate Between Screens
```dart
// Push new screen
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Pop with result
Navigator.pop(context, resultData);
```

---

## 🔍 Debugging Tips

### Check Firebase Connection
```dart
final snapshot = await FirebaseDatabase.instance
    .ref('parkingCentres')
    .get();
print('Data exists: ${snapshot.exists}');
```

### Check Authentication
```dart
final user = FirebaseAuth.instance.currentUser;
print('User ID: ${user?.uid}');
print('Email: ${user?.email}');
```

### Check Location Permissions
```dart
final permission = await Geolocator.checkPermission();
print('Permission: $permission');
```

### Debug Print Statements
```dart
debugPrint('Spot data: ${spot.toMap(ownerId)}');
debugPrint('Position: ${position.latitude}, ${position.longitude}');
```

---

## ⚠️ Common Issues & Solutions

### Issue: Map not showing
**Solution**: Check Google Maps API key in `AndroidManifest.xml` and `Info.plist`

### Issue: Location permission denied
**Solution**: Request permissions in `AndroidManifest.xml` and `Info.plist`

### Issue: Data not saving
**Solution**: Check Firebase authentication and database rules

### Issue: Null safety errors
**Solution**: Use null-aware operators (`?.`, `??`, `!`)

---

## 📚 File Structure Reference

```
lib/owner/
├── models/
│   └── parking_spot_model.dart
├── services/
│   └── parking_spot_service.dart
├── screens/
│   ├── my_parking_spots_screen.dart
│   ├── my_bookings_screen.dart
│   └── add_edit_parking_spot_screen.dart
├── widgets/
│   ├── parking_spot_card.dart
│   ├── booking_card.dart
│   ├── statistics_card.dart
│   └── location_picker_widget.dart
├── owner_dashboard_main.dart (USE THIS)
├── owner_dashboard.dart (DEPRECATED)
├── README.md
├── PRODUCTION_CHECKLIST.md
├── QUICK_START.md (this file)
└── OWNER_DASHBOARD_MIGRATION.md
```

---

## 🎓 Learning Resources

1. **README.md** - Complete API documentation
2. **PRODUCTION_CHECKLIST.md** - Production readiness guide
3. **OWNER_DASHBOARD_MIGRATION.md** - Migration from old version
4. **Code Comments** - Inline documentation in all files

---

## 💡 Pro Tips

1. **Use StreamBuilder** for real-time data (parking spots)
2. **Use FutureBuilder** for one-time fetches (bookings, stats)
3. **Always validate** user input before saving
4. **Show feedback** for all user actions
5. **Handle errors gracefully** with try-catch
6. **Test on real devices** for location features
7. **Use const constructors** where possible for performance
8. **Dispose controllers** in dispose() method

---

## ✅ Quick Checklist

Before deploying:
- [ ] Test add parking spot
- [ ] Test edit parking spot
- [ ] Test delete parking spot
- [ ] Test location picker
- [ ] Test bookings view
- [ ] Test statistics
- [ ] Test on real device
- [ ] Check Firebase rules
- [ ] Verify authentication
- [ ] Test error scenarios

---

**Need Help?** Check the README.md or PRODUCTION_CHECKLIST.md for detailed information.

**Ready to Deploy?** Follow the PRODUCTION_CHECKLIST.md for deployment steps.
