import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/kanjo_models.dart';

/// Service class for kanjo officer operations
class KanjoService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current kanjo officer's profile
  Future<KanjoOfficer?> getCurrentOfficer() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final snapshot = await _db.ref('kanjo_officers/${user.uid}').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return KanjoOfficer.fromMap(data);
    }
    return null;
  }

  /// Create kanjo officer profile
  Future<void> createOfficerProfile(KanjoOfficer officer) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _db.ref('kanjo_officers/${user.uid}').set(officer.toMap());
  }

  /// Record a parking violation
  Future<String> recordViolation(ParkingViolation violation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Verify officer exists and is active
    final officer = await getCurrentOfficer();
    if (officer == null || !officer.isActive) {
      throw Exception('Officer profile not found or inactive');
    }

    // Generate violation ID
    final violationId = 'V_${DateTime.now().millisecondsSinceEpoch}';

    // Create violation with officer details
    final violationWithOfficer = violation.copyWith(
      id: violationId,
      officerId: officer.id,
      officerName: officer.name,
    );

    // Save to violations collection
    await _db.ref('parking_violations/$violationId').set(violationWithOfficer.toMap());

    // Add to officer's daily report
    await _addViolationToOfficerReport(violationId, officer.id);

    return violationId;
  }

  /// Get violations recorded by current officer
  Stream<List<ParkingViolation>> getOfficerViolations({int limit = 50}) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _db
        .ref('parking_violations')
        .orderByChild('officerId')
        .equalTo(user.uid)
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        return ParkingViolation.fromMap(entry.value);
      }).toList();
    });
  }

  /// Get all violations (admin/kanjo supervisor access)
  Stream<List<ParkingViolation>> getAllViolations({int limit = 100}) {
    return _db
        .ref('parking_violations')
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        return ParkingViolation.fromMap(entry.value);
      }).toList();
    });
  }

  /// Update violation payment status
  Future<void> updateViolationPayment(String violationId, bool isPaid) async {
    await _db.ref('parking_violations/$violationId').update({
      'isPaid': isPaid,
      'paidAt': isPaid ? DateTime.now().toIso8601String() : null,
    });
  }

  /// Get enforcement statistics for current officer
  Future<EnforcementStats> getOfficerStats() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final violationsSnapshot = await _db
        .ref('parking_violations')
        .orderByChild('officerId')
        .equalTo(user.uid)
        .get();

    final data = violationsSnapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return EnforcementStats.empty();

    final violations = data.entries.map((entry) {
      return ParkingViolation.fromMap(entry.value);
    }).toList();

    final totalViolations = violations.length;
    final totalRevenue = violations
        .where((v) => v.isPaid)
        .fold(0.0, (sum, v) => sum + v.penaltyAmount);

    final pendingViolations = violations.where((v) => !v.isPaid).length;
    final resolvedViolations = violations.where((v) => v.isPaid).length;

    // Group violations by type
    final violationsByType = <String, int>{};
    for (var violation in violations) {
      violationsByType[violation.violationType] =
          (violationsByType[violation.violationType] ?? 0) + 1;
    }

    // Group revenue by zone (placeholder - would need zone data)
    final revenueByZone = <String, double>{};

    return EnforcementStats(
      totalViolations: totalViolations,
      totalRevenue: totalRevenue,
      pendingViolations: pendingViolations,
      resolvedViolations: resolvedViolations,
      violationsByType: violationsByType,
      revenueByZone: revenueByZone,
    );
  }

  /// Get daily report for current officer
  Future<DailyReport> getDailyReport(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final officer = await getCurrentOfficer();
    if (officer == null) throw Exception('Officer profile not found');

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final violationsSnapshot = await _db
        .ref('parking_violations')
        .orderByChild('officerId')
        .equalTo(user.uid)
        .get();

    final data = violationsSnapshot.value as Map<dynamic, dynamic>?;
    if (data == null) {
      return DailyReport(
        date: date,
        officerId: officer.id,
        officerName: officer.name,
        violations: [],
        totalRevenue: 0.0,
        totalViolations: 0,
        violationsByType: {},
      );
    }

    final violations = data.entries
        .map((entry) => ParkingViolation.fromMap(entry.value))
        .where((v) =>
            v.timestamp.isAfter(startOfDay) && v.timestamp.isBefore(endOfDay))
        .toList();

    final totalRevenue = violations
        .where((v) => v.isPaid)
        .fold(0.0, (sum, v) => sum + v.penaltyAmount);

    final violationsByType = <String, int>{};
    for (var violation in violations) {
      violationsByType[violation.violationType] =
          (violationsByType[violation.violationType] ?? 0) + 1;
    }

    return DailyReport(
      date: date,
      officerId: officer.id,
      officerName: officer.name,
      violations: violations,
      totalRevenue: totalRevenue,
      totalViolations: violations.length,
      violationsByType: violationsByType,
    );
  }

  /// Submit daily report
  Future<void> submitDailyReport(DailyReport report) async {
    final reportId = 'REPORT_${report.officerId}_${report.date.millisecondsSinceEpoch}';
    await _db.ref('daily_reports/$reportId').set(report.toMap());
  }

  /// Get violation types and their penalties
  Map<String, double> getViolationTypes() {
    return {
      'illegal_parking': 2000.0,
      'expired_meter': 1500.0,
      'no_permit': 3000.0,
      'blocking_driveway': 2500.0,
      'double_parking': 2000.0,
      'parking_wrong_direction': 1500.0,
      'parking_disabled_spot': 5000.0,
      'parking_loading_zone': 3000.0,
    };
  }

  /// Get common violation locations
  List<String> getCommonLocations() {
    return [
      'CBD - Kenyatta Avenue',
      'CBD - Moi Avenue',
      'CBD - Kimathi Street',
      'Westlands - Waiyaki Way',
      'Kilimani - Ngong Road',
      'Karen - Langata Road',
      'Eastleigh - Jogoo Road',
      'Kasarani - Thika Road',
    ];
  }

  /// Add violation to officer's daily report
  Future<void> _addViolationToOfficerReport(String violationId, String officerId) async {
    final today = DateTime.now();
    final reportId = 'REPORT_${officerId}_${today.millisecondsSinceEpoch}';

    final reportRef = _db.ref('daily_reports/$reportId');
    final snapshot = await reportRef.get();

    if (snapshot.exists) {
      final report = DailyReport.fromMap(snapshot.value as Map<String, dynamic>);
      // Update existing report
      final updatedReport = report.copyWith(
        totalViolations: report.totalViolations + 1,
      );
      await reportRef.update(updatedReport.toMap());
    }
  }

  /// Get violations by status
  Future<List<ParkingViolation>> getViolationsByStatus(bool isPaid) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final violationsSnapshot = await _db
        .ref('parking_violations')
        .orderByChild('officerId')
        .equalTo(user.uid)
        .get();

    final data = violationsSnapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];

    return data.entries
        .map((entry) => ParkingViolation.fromMap(entry.value))
        .where((v) => v.isPaid == isPaid)
        .toList();
  }

  /// Search violations by vehicle number
  Future<List<ParkingViolation>> searchViolationsByVehicle(String vehicleNumber) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final violationsSnapshot = await _db
        .ref('parking_violations')
        .orderByChild('vehicleNumber')
        .equalTo(vehicleNumber)
        .get();

    final data = violationsSnapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return [];

    return data.entries.map((entry) {
      return ParkingViolation.fromMap(entry.value);
    }).toList();
  }

  /// Validate officer permissions for area
  Future<bool> canEnforceInArea(String area) async {
    final officer = await getCurrentOfficer();
    if (officer == null) return false;

    return officer.assignedAreas.contains(area) || officer.assignedAreas.isEmpty;
  }

  /// Get officer's assigned areas
  Future<List<String>> getAssignedAreas() async {
    final officer = await getCurrentOfficer();
    return officer?.assignedAreas ?? [];
  }
}
