import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model class representing a parking spot
class ParkingSpot {
  final int id;
  final String name;
  final String address;
  final int totalSpots;
  final int occupiedSpots;
  final String imageUrl;
  final int costPerHour;
  final String owner;
  final String city;
  final String state;
  final String zipCode;
  final String type;
  final String size;
  final List<String> amenities;
  final String description;
  final bool isActive;
  final LatLng? position;
  
  ParkingSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSpots,
    required this.occupiedSpots,
    required this.imageUrl,
    required this.costPerHour,
    required this.owner,
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.type = 'Covered',
    this.size = 'Standard',
    this.amenities = const [],
    this.description = '',
    this.isActive = true,
    this.position,
  });
  
  /// Getter for available spots
  int get availableSpots => totalSpots - occupiedSpots;
  
  /// Getter for occupancy percentage
  double get occupancyPercentage => 
      totalSpots > 0 ? (occupiedSpots / totalSpots) * 100 : 0;
  
  /// Create ParkingSpot from Firebase data
  factory ParkingSpot.fromMap(String key, Map<dynamic, dynamic> data) {
    return ParkingSpot(
      id: int.tryParse(key) ?? DateTime.now().millisecondsSinceEpoch,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      totalSpots: data['totalSpots'] ?? 0,
      occupiedSpots: data['occupiedSpots'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      costPerHour: data['costPerHour'] ?? 0,
      owner: data['ownerId'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      type: data['type'] ?? 'Covered',
      size: data['size'] ?? 'Standard',
      amenities: data['amenities'] != null 
          ? List<String>.from(data['amenities']) 
          : [],
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      position: data['position'] != null 
          ? LatLng(
              data['position']['latitude']?.toDouble() ?? 0.0,
              data['position']['longitude']?.toDouble() ?? 0.0,
            )
          : null,
    );
  }
  
  /// Convert ParkingSpot to Map for Firebase
  Map<String, dynamic> toMap(String ownerId) {
    final map = <String, dynamic>{
      'name': name,
      'address': address,
      'totalSpots': totalSpots,
      'occupiedSpots': occupiedSpots,
      'imageUrl': imageUrl,
      'costPerHour': costPerHour,
      'ownerId': ownerId,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'type': type,
      'size': size,
      'amenities': amenities,
      'description': description,
      'isActive': isActive,
    };
    
    if (position != null) {
      map['position'] = {
        'latitude': position!.latitude,
        'longitude': position!.longitude,
      };
    }
    
    return map;
  }
  
  /// Create a copy with updated fields
  ParkingSpot copyWith({
    int? id,
    String? name,
    String? address,
    int? totalSpots,
    int? occupiedSpots,
    String? imageUrl,
    int? costPerHour,
    String? owner,
    String? city,
    String? state,
    String? zipCode,
    String? type,
    String? size,
    List<String>? amenities,
    String? description,
    bool? isActive,
    LatLng? position,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalSpots: totalSpots ?? this.totalSpots,
      occupiedSpots: occupiedSpots ?? this.occupiedSpots,
      imageUrl: imageUrl ?? this.imageUrl,
      costPerHour: costPerHour ?? this.costPerHour,
      owner: owner ?? this.owner,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      type: type ?? this.type,
      size: size ?? this.size,
      amenities: amenities ?? this.amenities,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
    );
  }
}
