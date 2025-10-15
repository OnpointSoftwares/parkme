// Parking and Booking data models
import 'package:flutter/foundation.dart';

class ParkingSpace {
  final String id;
  final String ownerId; // user id (owner or kanjo when managed by county)
  final String title;
  final String description;
  final String location; // human readable
  final double latitude;
  final double longitude;
  final int capacity;
  final int available;
  final double hourlyRate;
  final List<String> photos;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String managedBy; // 'owner' | 'kanjo'

  const ParkingSpace({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.available,
    required this.hourlyRate,
    this.photos = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.managedBy = 'owner',
  });

  ParkingSpace copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    int? capacity,
    int? available,
    double? hourlyRate,
    List<String>? photos,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? managedBy,
  }) {
    return ParkingSpace(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      available: available ?? this.available,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      photos: photos ?? this.photos,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      managedBy: managedBy ?? this.managedBy,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'capacity': capacity,
        'available': available,
        'hourlyRate': hourlyRate,
        'photos': photos,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'managedBy': managedBy,
      };

  factory ParkingSpace.fromMap(Map<String, dynamic> map) => ParkingSpace(
        id: map['id'] ?? '',
        ownerId: map['ownerId'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        location: map['location'] ?? '',
        latitude: (map['latitude'] ?? 0).toDouble(),
        longitude: (map['longitude'] ?? 0).toDouble(),
        capacity: map['capacity'] ?? 0,
        available: map['available'] ?? 0,
        hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
        photos: List<String>.from(map['photos'] ?? const []),
        isActive: map['isActive'] ?? true,
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
        managedBy: map['managedBy'] ?? 'owner',
      );
}

enum BookingStatus { pending, confirmed, checkedIn, completed, canceled }

class Booking {
  final String id;
  final String userId; // car owner
  final String spaceId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? canceledAt;
  final String? cancelReason;
  final bool refundIssued;

  const Booking({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.status = BookingStatus.pending,
    required this.createdAt,
    this.canceledAt,
    this.cancelReason,
    this.refundIssued = false,
  });

  Booking copyWith({
    String? id,
    BookingStatus? status,
    DateTime? canceledAt,
    String? cancelReason,
    bool? refundIssued,
  }) => Booking(
        id: id ?? this.id,
        userId: userId,
        spaceId: spaceId,
        startTime: startTime,
        endTime: endTime,
        totalAmount: totalAmount,
        status: status ?? this.status,
        createdAt: createdAt,
        canceledAt: canceledAt ?? this.canceledAt,
        cancelReason: cancelReason ?? this.cancelReason,
        refundIssued: refundIssued ?? this.refundIssued,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'spaceId': spaceId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalAmount': totalAmount,
        'status': describeEnum(status),
        'createdAt': createdAt.toIso8601String(),
        'canceledAt': canceledAt?.toIso8601String(),
        'cancelReason': cancelReason,
        'refundIssued': refundIssued,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        spaceId: map['spaceId'] ?? '',
        startTime: DateTime.parse(map['startTime']),
        endTime: DateTime.parse(map['endTime']),
        totalAmount: (map['totalAmount'] ?? 0).toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => describeEnum(e) == (map['status'] ?? 'pending'),
          orElse: () => BookingStatus.pending,
        ),
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
        canceledAt: map['canceledAt'] != null ? DateTime.parse(map['canceledAt']) : null,
        cancelReason: map['cancelReason'],
        refundIssued: map['refundIssued'] ?? false,
      );
}
