import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models.dart';

class ParkingService {
  final _db = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  // Parking spaces
  Future<String> createSpace(ParkingSpace space) async {
    final id = space.id.isNotEmpty ? space.id : 'PS_${DateTime.now().millisecondsSinceEpoch}';
    final payload = space.copyWith(id: id, updatedAt: DateTime.now()).toMap();
    await _db.ref('parking_spaces/$id').set(payload);
    return id;
  }

  Future<void> updateSpace(ParkingSpace space) async {
    await _db.ref('parking_spaces/${space.id}').update(space.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteSpace(String id) async {
    await _db.ref('parking_spaces/$id').remove();
  }

  Stream<List<ParkingSpace>> spacesByOwner(String ownerId) {
    return _db
        .ref('parking_spaces')
        .orderByChild('ownerId')
        .equalTo(ownerId)
        .onValue
        .map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      return map.values
          .map((e) => ParkingSpace.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Stream<List<ParkingSpace>> allActiveSpaces() {
    return _db.ref('parking_spaces').onValue.map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      return map.values
          .map((e) => ParkingSpace.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((s) => s.isActive)
          .toList();
    });
  }

  // Bookings
  Future<String> createBooking(Booking booking) async {
    final id = booking.id.isNotEmpty ? booking.id : 'BK_${DateTime.now().millisecondsSinceEpoch}';
    await _db.ref('bookings/$id').set(booking.copyWith(id: id).toMap());
    return id;
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _db.ref('bookings/$bookingId').update({
      'status': status.name,
    });
  }

  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
    bool refundIssued = false,
  }) async {
    await _db.ref('bookings/$bookingId').update({
      'status': BookingStatus.canceled.name,
      'canceledAt': DateTime.now().toIso8601String(),
      'cancelReason': reason,
      'refundIssued': refundIssued,
    });
  }

  Stream<List<Booking>> bookingsForSpace(String spaceId) {
    return _db
        .ref('bookings')
        .orderByChild('spaceId')
        .equalTo(spaceId)
        .onValue
        .map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      return map.values
          .map((e) => Booking.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Stream<List<Booking>> bookingsForUser(String userId) {
    return _db
        .ref('bookings')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map == null) return [];
      return map.values
          .map((e) => Booking.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }
}
