import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/parking_spot_model.dart';

/// Service class for managing parking spot operations
class ParkingSpotService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  /// Get current user ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  
  /// Stream of parking spots for the current owner
  Stream<List<ParkingSpot>> getOwnerParkingSpots() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    
    return _dbRef
        .child('parkingCentres')
        .orderByChild('ownerId')
        .equalTo(_currentUserId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <ParkingSpot>[];
      
      final spotsMap = event.snapshot.value as Map<dynamic, dynamic>;
      return spotsMap.entries
          .map((entry) => ParkingSpot.fromMap(entry.key.toString(), entry.value))
          .toList();
    });
  }
  
  /// Add a new parking spot
  Future<String> addParkingSpot(ParkingSpot spot) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Validate required fields
      _validateParkingSpot(spot);
      
      final ref = _dbRef.child('parkingCentres').push();
      await ref.set(spot.toMap(_currentUserId!));
      
      debugPrint('Parking spot added with ID: ${ref.key}');
      return ref.key!;
    } catch (e) {
      debugPrint('Error adding parking spot: $e');
      rethrow;
    }
  }
  
  /// Update an existing parking spot
  Future<void> updateParkingSpot(String spotId, ParkingSpot spot) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Validate required fields
      _validateParkingSpot(spot);
      
      final ref = _dbRef.child('parkingCentres/$spotId');
      await ref.update(spot.toMap(_currentUserId!));
      
      debugPrint('Parking spot $spotId updated successfully');
    } catch (e) {
      debugPrint('Error updating parking spot: $e');
      rethrow;
    }
  }
  
  /// Delete a parking spot
  Future<void> deleteParkingSpot(String spotId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Verify ownership before deleting
      final snapshot = await _dbRef.child('parkingCentres/$spotId').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        if (data['ownerId'] != _currentUserId) {
          throw Exception('Unauthorized: You do not own this parking spot');
        }
      }
      
      await _dbRef.child('parkingCentres/$spotId').remove();
      debugPrint('Parking spot $spotId deleted successfully');
    } catch (e) {
      debugPrint('Error deleting parking spot: $e');
      rethrow;
    }
  }
  
  /// Get bookings for owner's parking spots
  Future<List<Map<String, dynamic>>> getOwnerBookings() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // First, get all parking spot names owned by this user
      final spotsSnapshot = await _dbRef
          .child('parkingCentres')
          .orderByChild('ownerId')
          .equalTo(_currentUserId)
          .get();
      
      if (!spotsSnapshot.exists) return [];
      
      final spotsMap = spotsSnapshot.value as Map<dynamic, dynamic>;
      final spotNames = spotsMap.values
          .map((spot) => spot['name'].toString())
          .toList();
      
      // Get all reservations
      final reservationsSnapshot = await _dbRef.child('reservations').get();
      
      if (!reservationsSnapshot.exists) return [];
      
      final reservationsMap = reservationsSnapshot.value as Map<dynamic, dynamic>;
      
      // Filter bookings for owner's spots
      final ownerBookings = <Map<String, dynamic>>[];
      reservationsMap.forEach((key, value) {
        final booking = Map<String, dynamic>.from(value);
        if (spotNames.contains(booking['centre'])) {
          booking['id'] = key;
          ownerBookings.add(booking);
        }
      });
      
      // Sort by date (most recent first)
      ownerBookings.sort((a, b) {
        final dateA = a['date'] ?? '';
        final dateB = b['date'] ?? '';
        return dateB.compareTo(dateA);
      });
      
      return ownerBookings;
    } catch (e) {
      debugPrint('Error getting owner bookings: $e');
      rethrow;
    }
  }

  /// Cancel a reservation owned by this owner (by reservation id) with optional reason
  Future<void> cancelReservation({
    required String reservationId,
    String? reason,
    bool refundIssued = false,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final resRef = _dbRef.child('reservations/$reservationId');
      final snapshot = await resRef.get();
      if (!snapshot.exists) {
        throw Exception('Reservation not found');
      }

      // Optional: verify this reservation belongs to one of the owner's spots
      final data = snapshot.value as Map<dynamic, dynamic>;
      final centre = (data['centre'] ?? '').toString();
      if (centre.isEmpty) {
        // proceed but warn
        debugPrint('Warning: reservation has no centre field');
      } else {
        // Confirm owner owns the centre
        final DataSnapshot? spotsSnapshot = _currentUserId == null
          ? null
          : await _dbRef
              .child('parkingCentres')
              .orderByChild('ownerId')
              .equalTo(_currentUserId)
              .get();
        if (spotsSnapshot != null && spotsSnapshot.exists) {
          final spotsMap = spotsSnapshot.value as Map<dynamic, dynamic>;
          final ownerCentres = spotsMap.values
              .map((s) => (s['name'] ?? '').toString())
              .toSet();
          if (!ownerCentres.contains(centre)) {
            throw Exception('Unauthorized: reservation is not for your parking spot');
          }
        }
      }

      await resRef.update({
        'status': 'canceled',
        'canceledAt': DateTime.now().toIso8601String(),
        'cancelReason': reason,
        'refundIssued': refundIssued,
      });
    } catch (e) {
      debugPrint('Error canceling reservation: $e');
      rethrow;
    }
  }
  
  /// Validate parking spot data
  void _validateParkingSpot(ParkingSpot spot) {
    if (spot.name.trim().isEmpty) {
      throw Exception('Parking spot name is required');
    }
    
    if (spot.address.trim().isEmpty) {
      throw Exception('Address is required');
    }
    
    if (spot.city.trim().isEmpty) {
      throw Exception('City is required');
    }
    
    if (spot.totalSpots <= 0) {
      throw Exception('Total spots must be greater than 0');
    }
    
    if (spot.occupiedSpots < 0) {
      throw Exception('Occupied spots cannot be negative');
    }
    
    if (spot.occupiedSpots > spot.totalSpots) {
      throw Exception('Occupied spots cannot exceed total spots');
    }
    
    if (spot.costPerHour < 0) {
      throw Exception('Cost per hour cannot be negative');
    }
    
    if (spot.position == null) {
      throw Exception('Location coordinates are required');
    }
  }
  
  /// Get parking spot statistics for the owner
  Future<Map<String, dynamic>> getOwnerStatistics() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      final spotsSnapshot = await _dbRef
          .child('parkingCentres')
          .orderByChild('ownerId')
          .equalTo(_currentUserId)
          .get();
      
      if (!spotsSnapshot.exists) {
        return {
          'totalSpots': 0,
          'totalCapacity': 0,
          'totalOccupied': 0,
          'totalRevenue': 0,
          'activeSpots': 0,
        };
      }
      
      final spotsMap = spotsSnapshot.value as Map<dynamic, dynamic>;
      int totalSpots = spotsMap.length;
      int totalCapacity = 0;
      int totalOccupied = 0;
      int activeSpots = 0;
      
      spotsMap.values.forEach((spot) {
        totalCapacity += (spot['totalSpots'] ?? 0) as int;
        totalOccupied += (spot['occupiedSpots'] ?? 0) as int;
        if (spot['isActive'] == true) activeSpots++;
      });
      
      return {
        'totalSpots': totalSpots,
        'totalCapacity': totalCapacity,
        'totalOccupied': totalOccupied,
        'totalAvailable': totalCapacity - totalOccupied,
        'activeSpots': activeSpots,
        'occupancyRate': totalCapacity > 0 
            ? (totalOccupied / totalCapacity * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      debugPrint('Error getting owner statistics: $e');
      rethrow;
    }
  }
}
