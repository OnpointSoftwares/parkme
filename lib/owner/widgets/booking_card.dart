import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a booking card
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onTap;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = _getBookingStatus();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking['centre'] ?? 'Unknown Spot',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.directions_car,
                'Vehicle',
                booking['vehicleNumber'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                'Date',
                booking['date'] ?? 'N/A',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.login,
                      'Check-in',
                      booking['checkin'] ?? 'N/A',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.logout,
                      'Check-out',
                      booking['checkout'] ?? 'N/A',
                    ),
                  ),
                ],
              ),
              if (booking['cost'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  'Cost',
                  'KES ${booking['cost']}',
                ),
              ],
              if (booking['uid'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person,
                  'User ID',
                  booking['uid'].toString().substring(0, 8) + '...',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getBookingStatus() {
    try {
      final dateStr = booking['date'] as String?;
      if (dateStr == null) {
        return {'label': 'Unknown', 'color': Colors.grey};
      }

      final bookingDate = DateFormat('dd/MM/yyyy').parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      if (bookingDay.isAfter(today)) {
        return {'label': 'Upcoming', 'color': Colors.blue};
      } else if (bookingDay.isAtSameMomentAs(today)) {
        return {'label': 'Today', 'color': Colors.green};
      } else {
        return {'label': 'Completed', 'color': Colors.grey};
      }
    } catch (e) {
      return {'label': 'Unknown', 'color': Colors.grey};
    }
  }
}
