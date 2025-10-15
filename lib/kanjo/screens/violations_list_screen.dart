import 'package:flutter/material.dart';
import '../models/kanjo_models.dart';
import '../services/kanjo_service.dart';

class ViolationsListScreen extends StatelessWidget {
  ViolationsListScreen({Key? key}) : super(key: key);
  final _service = KanjoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Violations')),
      body: StreamBuilder<List<ParkingViolation>>(
        stream: _service.getAllViolations(limit: 200),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('No violations recorded'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final v = items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: v.isPaid ? Colors.green : Colors.orange,
                  child: Icon(v.isPaid ? Icons.check : Icons.warning, color: Colors.white),
                ),
                title: Text('${v.vehicleNumber} • KES ${v.penaltyAmount.toStringAsFixed(0)}'),
                subtitle: Text('${v.violationType.replaceAll('_', ' ')}\n${v.location}'),
                isThreeLine: true,
                trailing: Text(v.timestamp.toLocal().toString().split('.').first),
              );
            },
          );
        },
      ),
    );
  }
}
