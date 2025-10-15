import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../parking/models.dart';
import '../../parking/parking_service.dart';
import '../widgets/map_location_picker.dart';

class ManageParkingSpacesScreen extends StatefulWidget {
  const ManageParkingSpacesScreen({Key? key}) : super(key: key);

  @override
  State<ManageParkingSpacesScreen> createState() => _ManageParkingSpacesScreenState();
}

class _ManageParkingSpacesScreenState extends State<ManageParkingSpacesScreen> {
  final _service = ParkingService();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Parking Spaces')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSpace,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Space'),
      ),
      body: StreamBuilder<List<ParkingSpace>>(
        stream: _service.spacesByOwner(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final spaces = snapshot.data!;
          if (spaces.isEmpty) {
            return _emptyState();
          }
          return ListView.builder(
            itemCount: spaces.length,
            itemBuilder: (context, i) => _spaceTile(spaces[i]),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_parking, size: 56, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('No parking spaces yet'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addSpace,
            icon: const Icon(Icons.add),
            label: const Text('Create your first space'),
          ),
        ],
      ),
    );
  }

  Widget _spaceTile(ParkingSpace s) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(s.title.isNotEmpty ? s.title[0].toUpperCase() : 'P')),
        title: Text(s.title),
        subtitle: Text('${s.location}\nKES ${s.hourlyRate.toStringAsFixed(0)}/hr • ${s.available}/${s.capacity} available'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) => _handleAction(v, s),
          itemBuilder: (c) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'toggle', child: Text('Activate/Deactivate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
            PopupMenuItem(value: 'bookings', child: Text('View Bookings')),
          ],
        ),
        onTap: () => _editSpace(s),
      ),
    );
  }

  Future<void> _addSpace() async {
    final now = DateTime.now();
    final user = _auth.currentUser!;
    final space = ParkingSpace(
      id: '',
      ownerId: user.uid,
      title: 'New Space',
      description: 'Describe your parking space',
      location: 'Unknown',
      latitude: 0,
      longitude: 0,
      capacity: 10,
      available: 10,
      hourlyRate: 100,
      createdAt: now,
      updatedAt: now,
      managedBy: 'kanjo',
    );
    final id = await _service.createSpace(space);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Parking space created ($id)')),
    );
  }

  void _handleAction(String action, ParkingSpace s) async {
    switch (action) {
      case 'edit':
        _editSpace(s);
        break;
      case 'toggle':
        await _service.updateSpace(s.copyWith(isActive: !s.isActive));
        break;
      case 'delete':
        await _service.deleteSpace(s.id);
        break;
      case 'bookings':
        _viewBookings(s);
        break;
    }
  }

  void _editSpace(ParkingSpace s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final title = TextEditingController(text: s.title);
        final location = TextEditingController(text: s.location);
        final desc = TextEditingController(text: s.description);
        final capacity = TextEditingController(text: s.capacity.toString());
        final available = TextEditingController(text: s.available.toString());
        final rate = TextEditingController(text: s.hourlyRate.toString());
        double selectedLat = s.latitude;
        double selectedLng = s.longitude;
        
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit Parking Space', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: location,
                          decoration: const InputDecoration(labelText: 'Location'),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapLocationPicker(
                                initialLocation: LatLng(selectedLat, selectedLng),
                                onLocationSelected: (loc, addr) {
                                  selectedLat = loc.latitude;
                                  selectedLng = loc.longitude;
                                  location.text = addr;
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(controller: capacity, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: available, decoration: const InputDecoration(labelText: 'Available'), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 8),
                  TextField(controller: rate, decoration: const InputDecoration(labelText: 'Hourly Rate (KES)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = s.copyWith(
                          title: title.text.trim(),
                          location: location.text.trim(),
                          description: desc.text.trim(),
                          capacity: int.tryParse(capacity.text) ?? s.capacity,
                          available: int.tryParse(available.text) ?? s.available,
                          hourlyRate: double.tryParse(rate.text) ?? s.hourlyRate,
                          latitude: selectedLat,
                          longitude: selectedLng,
                        );
                        await _service.updateSpace(updated);
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewBookings(ParkingSpace s) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _BookingsScreen(space: s)),
    );
  }
}

class _BookingsScreen extends StatelessWidget {
  final ParkingSpace space;
  _BookingsScreen({required this.space});
  final _service = ParkingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings • ${space.title}')),
      body: StreamBuilder(
        stream: _service.bookingsForSpace(space.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;
          if (bookings.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) {
              final b = bookings[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${b.startTime} → ${b.endTime}'),
                  subtitle: Text('Status: ${b.status.name} • KES ${b.totalAmount.toStringAsFixed(0)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'cancel') {
                        final reason = await _promptReason(context);
                        if (reason != null) {
                          await _service.cancelBooking(bookingId: b.id, reason: reason, refundIssued: true);
                        }
                      }
                    },
                    itemBuilder: (c) => const [
                      PopupMenuItem(value: 'cancel', child: Text('Cancel & Refund')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _promptReason(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancellation reason'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Reason')), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
          TextButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('Confirm')),
        ],
      ),
    );
  }
}
