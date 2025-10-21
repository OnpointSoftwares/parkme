import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/kanjo_service.dart';
import '../models/kanjo_models.dart';
import '../widgets/kanjo_widgets.dart';
import '../screens/record_violation_screen.dart';
import '../screens/daily_report_screen.dart';
import '../screens/manage_parking_spaces_screen.dart';
import '../screens/violations_list_screen.dart';
import '../screens/kanjo_profile_setup_screen.dart';
import '../../utils/app_theme.dart';

/// Main dashboard for kanjo officers
class KanjoDashboard extends StatefulWidget {
  const KanjoDashboard({Key? key}) : super(key: key);

  @override
  State<KanjoDashboard> createState() => _KanjoDashboardState();
}

class _KanjoDashboardState extends State<KanjoDashboard> {
  final KanjoService _service = KanjoService();
  KanjoOfficer? _currentOfficer;
  EnforcementStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfficerData();
  }

  Future<void> _loadOfficerData() async {
    setState(() => _isLoading = true);

    try {
      _currentOfficer = await _service.getCurrentOfficer();
      _stats = await _service.getOfficerStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading officer data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
          ),
        ),
      );
    }

    if (_currentOfficer == null) {
      return _buildProfileSetupScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Kanjo Officer Dashboard'),
        backgroundColor: AppTheme.darkBackground,
        foregroundColor: AppTheme.textLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: _viewDailyReport,
            tooltip: 'Daily Report',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOfficerData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOfficerHeader(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentViolations(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recordViolation,
        icon: Icon(Icons.add, color: AppTheme.textDark),
        label: Text('Record Violation', style: TextStyle(color: AppTheme.textDark)),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }

  Widget _buildProfileSetupScreen() {
    // Navigate to profile setup screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const KanjoProfileSetupScreen(),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanjo Officer Setup'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOfficerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBackground, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryYellow, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryYellow,
            child: Text(
              _currentOfficer!.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOfficer!.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Badge: ${_currentOfficer!.badgeNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryYellow,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Zone: ${_currentOfficer!.zone}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified, color: AppTheme.primaryYellow, size: 28),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Violations',
                value: _stats!.totalViolations.toString(),
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Revenue',
                value: 'KES ${_stats!.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Pending',
                value: _stats!.pendingViolations.toString(),
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Resolved',
                value: _stats!.resolvedViolations.toString(),
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle,
                title: 'Record\nViolation',
                color: Colors.red,
                onTap: _recordViolation,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.assignment,
                title: 'Daily\nReport',
                color: Colors.blue,
                onTap: _viewDailyReport,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.local_parking,
                title: 'Manage\nSpaces',
                color: Colors.green,
                onTap: _manageSpaces,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.list_alt,
                title: 'All\nViolations',
                color: Colors.orange,
                onTap: _viewAllViolations,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentViolations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Violations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
            TextButton(
              onPressed: _viewAllViolations,
              child: Text(
                'View All',
                style: TextStyle(color: AppTheme.primaryYellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ParkingViolation>>(
          stream: _service.getOfficerViolations(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final violations = snapshot.data ?? [];

            if (violations.isEmpty) {
              return _buildEmptyViolationsState();
            }

            return Column(
              children: violations.map((violation) {
                return ViolationCard(
                  violation: violation,
                  onTap: () => _viewViolationDetails(violation),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadOfficerData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyViolationsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(
            'No Violations Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record your first violation to get started',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  void _recordViolation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordViolationScreen(),
      ),
    );

    if (result == true) {
      _loadOfficerData(); // Refresh stats and violations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Violation recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _viewDailyReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReportScreen(),
      ),
    );
  }

  void _searchVehicle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Vehicle'),
        content: const Text('Vehicle search feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewAllViolations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViolationsListScreen(),
      ),
    );
  }

  void _manageSpaces() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManageParkingSpacesScreen(),
      ),
    );
  }

  void _viewViolationDetails(ParkingViolation violation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Violation Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Vehicle Number', violation.vehicleNumber),
              _buildDetailRow('Location', violation.location),
              _buildDetailRow('Violation Type', violation.violationType),
              _buildDetailRow('Penalty', 'KES ${violation.penaltyAmount}'),
              _buildDetailRow('Status', violation.isPaid ? 'Paid' : 'Pending'),
              _buildDetailRow('Date & Time', _formatDateTime(violation.timestamp)),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(violation.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        _viewProfile();
        break;
      case 'settings':
        _viewSettings();
        break;
      case 'logout':
        _logout();
        break;
    }
  }


  void _viewProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Officer Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_currentOfficer?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Badge: ${_currentOfficer?.badgeNumber ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Zone: ${_currentOfficer?.zone ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon')),
    );
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
