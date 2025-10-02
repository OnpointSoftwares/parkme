# Owner Dashboard Module

A production-ready, modular owner dashboard for the ParkMe parking management system.

## 📁 Structure

```
owner/
├── models/
│   └── parking_spot_model.dart       # Data model for parking spots
├── services/
│   └── parking_spot_service.dart     # Business logic and Firebase operations
├── screens/
│   ├── my_parking_spots_screen.dart  # Main parking spots management screen
│   ├── my_bookings_screen.dart       # Bookings management screen
│   └── add_edit_parking_spot_screen.dart # Add/Edit parking spot form
├── widgets/
│   ├── parking_spot_card.dart        # Reusable parking spot card widget
│   ├── booking_card.dart             # Reusable booking card widget
│   ├── statistics_card.dart          # Statistics display widget
│   └── location_picker_widget.dart   # Map-based location picker
├── owner_dashboard_main.dart         # Main dashboard with navigation
└── README.md                         # This file
```

## 🚀 Features

### Parking Spot Management
- ✅ Add new parking spots with complete details
- ✅ Edit existing parking spots
- ✅ Delete parking spots with confirmation
- ✅ View detailed parking spot information
- ✅ Toggle active/inactive status
- ✅ Real-time updates from Firebase

### Location Features
- ✅ Interactive map-based location picker
- ✅ Drag-and-drop marker positioning
- ✅ Automatic address geocoding
- ✅ Current location detection
- ✅ Fallback to coordinates if address unavailable

### Booking Management
- ✅ View all bookings for owned parking spots
- ✅ Filter bookings (All, Today, Upcoming, Completed)
- ✅ Detailed booking information
- ✅ Real-time booking updates

### Statistics & Analytics
- ✅ Total parking spots count
- ✅ Active spots tracking
- ✅ Total capacity calculation
- ✅ Occupancy rate percentage
- ✅ Available spots monitoring

## 🔒 Security Features

- **Authentication**: All operations require valid Firebase authentication
- **Authorization**: Owners can only manage their own parking spots
- **Validation**: Comprehensive input validation on all forms
- **Error Handling**: Graceful error handling with user-friendly messages

## 📊 Data Validation

### Parking Spot Validation
- Name, address, and city are required
- Total spots must be greater than 0
- Occupied spots cannot be negative or exceed total spots
- Cost per hour cannot be negative
- Location coordinates are required for new spots

## 🎨 UI/UX Features

- **Material Design**: Modern, clean interface
- **Responsive**: Works on various screen sizes
- **Loading States**: Clear feedback during operations
- **Error States**: Helpful error messages and retry options
- **Empty States**: Guidance when no data is available
- **Pull to Refresh**: Easy data refresh on list screens
- **Smooth Animations**: Professional transitions and interactions

## 🔧 Usage

### Import the Dashboard

```dart
import 'package:parkme/owner/owner_dashboard_main.dart';

// Navigate to owner dashboard
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const OwnerDashboard()),
);
```

### Using Individual Components

```dart
// Use parking spot service
import 'package:parkme/owner/services/parking_spot_service.dart';

final service = ParkingSpotService();
final spots = await service.getOwnerParkingSpots();

// Use parking spot model
import 'package:parkme/owner/models/parking_spot_model.dart';

final spot = ParkingSpot(
  id: DateTime.now().millisecondsSinceEpoch,
  name: 'Downtown Parking',
  address: '123 Main St',
  // ... other fields
);

// Use widgets
import 'package:parkme/owner/widgets/parking_spot_card.dart';

ParkingSpotCard(
  spot: spot,
  onEdit: () => editSpot(spot),
  onDelete: () => deleteSpot(spot),
);
```

## 🗄️ Firebase Structure

### Parking Centres Node
```json
{
  "parkingCentres": {
    "uniqueId": {
      "name": "Downtown Parking",
      "address": "123 Main St",
      "city": "Nairobi",
      "state": "Nairobi",
      "zipCode": "00100",
      "totalSpots": 50,
      "occupiedSpots": 30,
      "costPerHour": 100,
      "ownerId": "user-uid",
      "type": "Covered",
      "size": "Standard",
      "amenities": ["Security Camera", "Lighting"],
      "description": "Secure parking in downtown",
      "isActive": true,
      "position": {
        "latitude": -1.2921,
        "longitude": 36.8219
      }
    }
  }
}
```

### Reservations Node
```json
{
  "reservations": {
    "bookingId": {
      "centre": "Downtown Parking",
      "vehicleNumber": "KAA 123A",
      "date": "15/10/2025",
      "checkin": "09:00",
      "checkout": "17:00",
      "cost": "800",
      "uid": "user-uid"
    }
  }
}
```

## 🧪 Testing Checklist

- [ ] Add parking spot with all required fields
- [ ] Add parking spot without location (should show error)
- [ ] Edit existing parking spot
- [ ] Delete parking spot
- [ ] Toggle active/inactive status
- [ ] View parking spot details
- [ ] Pick location on map
- [ ] Use current location
- [ ] View bookings
- [ ] Filter bookings by status
- [ ] View booking details
- [ ] Check statistics accuracy
- [ ] Test error handling (network issues, invalid data)
- [ ] Test with no parking spots
- [ ] Test with no bookings

## 📱 Dependencies

Required packages (add to `pubspec.yaml`):
```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  firebase_database: ^latest
  google_maps_flutter: ^latest
  geocoding: ^latest
  geolocator: ^latest
  intl: ^latest
```

## 🐛 Known Issues & Limitations

1. **Deletion**: Currently uses spot ID for deletion. In production, store Firebase keys with spots.
2. **Image Upload**: Placeholder image URL used. Implement Firebase Storage for real images.
3. **Notifications**: Basic notification system. Implement FCM for push notifications.
4. **Offline Support**: Limited offline functionality. Consider implementing local caching.

## 🔄 Migration from Old Dashboard

The old monolithic `owner_dashboard.dart` has been refactored into this modular structure. To migrate:

1. Replace imports:
   ```dart
   // Old
   import 'package:parkme/owner/owner_dashboard.dart';
   
   // New
   import 'package:parkme/owner/owner_dashboard_main.dart';
   ```

2. Update navigation:
   ```dart
   // Old
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => OwnerDashboardPage()
   ));
   
   // New
   Navigator.push(context, MaterialPageRoute(
     builder: (context) => const OwnerDashboard()
   ));
   ```

## 📝 Best Practices

1. **Error Handling**: Always wrap Firebase operations in try-catch blocks
2. **Loading States**: Show loading indicators during async operations
3. **Validation**: Validate all user inputs before submission
4. **User Feedback**: Provide clear success/error messages
5. **Security**: Never expose sensitive data in error messages
6. **Performance**: Use StreamBuilder for real-time data, FutureBuilder for one-time fetches

## 🤝 Contributing

When adding new features:
1. Follow the existing modular structure
2. Add proper error handling
3. Include loading and empty states
4. Write clear documentation
5. Test thoroughly before committing

## 📄 License

Part of the ParkMe parking management system.
