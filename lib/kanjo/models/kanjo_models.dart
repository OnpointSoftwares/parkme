import 'package:flutter/material.dart';

/// Model for parking violations issued by kanjo officers
class ParkingViolation {
  final String id;
  final String vehicleNumber;
  final String location;
  final String violationType;
  final String description;
  final double penaltyAmount;
  final DateTime timestamp;
  final String officerId;
  final String officerName;
  final String? imageUrl;
  final Map<String, dynamic>? locationData;
  final bool isPaid;
  final DateTime? paidAt;

  ParkingViolation({
    required this.id,
    required this.vehicleNumber,
    required this.location,
    required this.violationType,
    required this.description,
    required this.penaltyAmount,
    required this.timestamp,
    required this.officerId,
    required this.officerName,
    this.imageUrl,
    this.locationData,
    this.isPaid = false,
    this.paidAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'location': location,
      'violationType': violationType,
      'description': description,
      'penaltyAmount': penaltyAmount,
      'timestamp': timestamp.toIso8601String(),
      'officerId': officerId,
      'officerName': officerName,
      'imageUrl': imageUrl,
      'locationData': locationData,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory ParkingViolation.fromMap(Map<String, dynamic> map) {
    return ParkingViolation(
      id: map['id'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      location: map['location'] ?? '',
      violationType: map['violationType'] ?? '',
      description: map['description'] ?? '',
      penaltyAmount: (map['penaltyAmount'] ?? 0).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      officerId: map['officerId'] ?? '',
      officerName: map['officerName'] ?? '',
      imageUrl: map['imageUrl'],
      locationData: map['locationData'],
      isPaid: map['isPaid'] ?? false,
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
    );
  }

  ParkingViolation copyWith({
    String? id,
    String? vehicleNumber,
    String? location,
    String? violationType,
    String? description,
    double? penaltyAmount,
    DateTime? timestamp,
    String? officerId,
    String? officerName,
    String? imageUrl,
    Map<String, dynamic>? locationData,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return ParkingViolation(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      location: location ?? this.location,
      violationType: violationType ?? this.violationType,
      description: description ?? this.description,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      timestamp: timestamp ?? this.timestamp,
      officerId: officerId ?? this.officerId,
      officerName: officerName ?? this.officerName,
      imageUrl: imageUrl ?? this.imageUrl,
      locationData: locationData ?? this.locationData,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

/// Model for kanjo officer profile
class KanjoOfficer {
  final String id;
  final String name;
  final String badgeNumber;
  final String department;
  final String zone;
  final String contactNumber;
  final bool isActive;
  final DateTime joinedDate;
  final List<String> assignedAreas;

  KanjoOfficer({
    required this.id,
    required this.name,
    required this.badgeNumber,
    required this.department,
    required this.zone,
    required this.contactNumber,
    this.isActive = true,
    required this.joinedDate,
    this.assignedAreas = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'badgeNumber': badgeNumber,
      'department': department,
      'zone': zone,
      'contactNumber': contactNumber,
      'isActive': isActive,
      'joinedDate': joinedDate.toIso8601String(),
      'assignedAreas': assignedAreas,
    };
  }

  factory KanjoOfficer.fromMap(Map<String, dynamic> map) {
    return KanjoOfficer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      badgeNumber: map['badgeNumber'] ?? '',
      department: map['department'] ?? '',
      zone: map['zone'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      isActive: map['isActive'] ?? true,
      joinedDate: DateTime.parse(map['joinedDate'] ?? DateTime.now().toIso8601String()),
      assignedAreas: List<String>.from(map['assignedAreas'] ?? []),
    );
  }
}

/// Model for enforcement statistics
class EnforcementStats {
  final int totalViolations;
  final double totalRevenue;
  final int pendingViolations;
  final int resolvedViolations;
  final Map<String, int> violationsByType;
  final Map<String, double> revenueByZone;

  EnforcementStats({
    required this.totalViolations,
    required this.totalRevenue,
    required this.pendingViolations,
    required this.resolvedViolations,
    required this.violationsByType,
    required this.revenueByZone,
  });

  factory EnforcementStats.empty() {
    return EnforcementStats(
      totalViolations: 0,
      totalRevenue: 0.0,
      pendingViolations: 0,
      resolvedViolations: 0,
      violationsByType: {},
      revenueByZone: {},
    );
  }
}

/// Model for daily enforcement report
class DailyReport {
  final DateTime date;
  final String officerId;
  final String officerName;
  final List<ParkingViolation> violations;
  final double totalRevenue;
  final int totalViolations;
  final Map<String, int> violationsByType;
  final String notes;

  DailyReport({
    required this.date,
    required this.officerId,
    required this.officerName,
    required this.violations,
    required this.totalRevenue,
    required this.totalViolations,
    required this.violationsByType,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'officerId': officerId,
      'officerName': officerName,
      'violations': violations.map((v) => v.toMap()).toList(),
      'totalRevenue': totalRevenue,
      'totalViolations': totalViolations,
      'violationsByType': violationsByType,
      'notes': notes,
    };
  }

  factory DailyReport.fromMap(Map<String, dynamic> map) {
    return DailyReport(
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      officerId: map['officerId'] ?? '',
      officerName: map['officerName'] ?? '',
      violations: (map['violations'] as List<dynamic>?)
              ?.map((v) => ParkingViolation.fromMap(v))
              .toList() ??
          [],
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      totalViolations: map['totalViolations'] ?? 0,
      violationsByType: Map<String, int>.from(map['violationsByType'] ?? {}),
      notes: map['notes'] ?? '',
    );
  }

  DailyReport copyWith({
    DateTime? date,
    String? officerId,
    String? officerName,
    List<ParkingViolation>? violations,
    double? totalRevenue,
    int? totalViolations,
    Map<String, int>? violationsByType,
    String? notes,
  }) {
    return DailyReport(
      date: date ?? this.date,
      officerId: officerId ?? this.officerId,
      officerName: officerName ?? this.officerName,
      violations: violations ?? this.violations,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalViolations: totalViolations ?? this.totalViolations,
      violationsByType: violationsByType ?? this.violationsByType,
      notes: notes ?? this.notes,
    );
  }
}
