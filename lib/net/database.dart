import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Adds a new vehicle to the user's vehicles list
  /// Returns the ID of the newly created vehicle
  Future<String> addVehicle({
    required String title,
    required String owner,
    required String vehicleNumber,
  }) async {
    try {
      // Validate input
      if (title.isEmpty || owner.isEmpty || vehicleNumber.isEmpty) {
        throw Exception('All fields are required');
      }

      // Create a new vehicle entry
      final newVehicleRef = _dbRef.child('vehicles').push();
      
      final vehicleData = {
        'title': title,
        'owner': owner,
        'vehicleNumber': vehicleNumber,
        'uid': uid,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      await newVehicleRef.set(vehicleData);
      debugPrint('Vehicle added with ID: ${newVehicleRef.key}');
      
      return newVehicleRef.key!;
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      rethrow;
    }
  }

  /// Updates an existing vehicle's information
  Future<void> updateVehicle({
    required String vehicleId,
    String? title,
    String? owner,
    String? vehicleNumber,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': ServerValue.timestamp,
      };

      if (title != null) updates['title'] = title;
      if (owner != null) updates['owner'] = owner;
      if (vehicleNumber != null) updates['vehicleNumber'] = vehicleNumber;

      await _dbRef.child('vehicles/$vehicleId').update(updates);
      debugPrint('Vehicle $vehicleId updated successfully');
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      rethrow;
    }
  }

  /// Deletes a vehicle from the database
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _dbRef.child('vehicles/$vehicleId').remove();
      debugPrint('Vehicle $vehicleId deleted successfully');
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      rethrow;
    }
  }

  /// Gets all vehicles for the current user
  Stream<Map<String, dynamic>> getUserVehicles() {
    return _dbRef
        .child('vehicles')
        .orderByChild('uid')
        .equalTo(uid)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return {};
          
          final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          final Map<String, dynamic> vehicles = {};
          
          data.forEach((key, value) {
            vehicles[key] = value;
          });
          
          return vehicles;
        });
  }
}
