import 'package:flutter/material.dart';
import '../models/parking_spot_model.dart';
import '../services/parking_spot_service.dart';
import '../widgets/parking_spot_card.dart';
import '../widgets/statistics_card.dart';
import 'add_edit_parking_spot_screen.dart';

/// Screen for displaying owner's parking spots
class MyParkingSpotsScreen extends StatefulWidget {
  const MyParkingSpotsScreen({Key? key}) : super(key: key);

  @override
  State<MyParkingSpotsScreen> createState() => _MyParkingSpotsScreenState();
}

class _MyParkingSpotsScreenState extends State<MyParkingSpotsScreen> {
  final ParkingSpotService _service = ParkingSpotService();
  bool _showStatistics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<ParkingSpot>>(
              stream: _service.getOwnerParkingSpots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final spots = snapshot.data ?? [];

                if (spots.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_showStatistics) _buildStatisticsSection(),
                      ...spots.map((spot) => ParkingSpotCard(
                            spot: spot,
                            onEdit: () => _editParkingSpot(spot),
                            onDelete: () => _deleteParkingSpot(spot),
                            onTap: () => _showSpotDetails(spot),
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addParkingSpot,
        icon: const Icon(Icons.add),
        label: const Text('Add Spot'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Parking Spots',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your parking locations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                _showStatistics ? Icons.analytics : Icons.analytics_outlined,
                color: Colors.blue[800],
              ),
              onPressed: () {
                setState(() {
                  _showStatistics = !_showStatistics;
                });
              },
              tooltip: 'Toggle Statistics',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _service.getOwnerStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        return StatisticsCard(statistics: snapshot.data ?? {});
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Parking Spots Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first parking spot to start managing bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addParkingSpot,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Spot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Spots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _addParkingSpot() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditParkingSpotScreen(),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking spot added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editParkingSpot(ParkingSpot spot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditParkingSpotScreen(existingSpot: spot),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking spot updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteParkingSpot(ParkingSpot spot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parking Spot'),
        content: Text(
          'Are you sure you want to delete "${spot.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Find the spot ID from Firebase
        // Note: In production, you should store the Firebase key with the spot
        await _service.deleteParkingSpot(spot.id.toString());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Parking spot deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting spot: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSpotDetails(ParkingSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                spot.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${spot.address}, ${spot.city}, ${spot.state} ${spot.zipCode}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Type', spot.type),
              _buildDetailRow('Size', spot.size),
              _buildDetailRow('Total Spots', spot.totalSpots.toString()),
              _buildDetailRow('Occupied', spot.occupiedSpots.toString()),
              _buildDetailRow('Available', spot.availableSpots.toString()),
              _buildDetailRow('Cost per Hour', 'KES ${spot.costPerHour}'),
              _buildDetailRow('Status', spot.isActive ? 'Active' : 'Inactive'),
              if (spot.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(spot.description),
              ],
              if (spot.amenities.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: spot.amenities.map((amenity) {
                    return Chip(
                      label: Text(amenity),
                      backgroundColor: Colors.blue[50],
                    );
                  }).toList(),
                ),
              ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
