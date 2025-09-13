
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parkme/constant.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingSuccessful extends StatefulWidget {
  final Map<String, dynamic> spot;
  final Map data;
  const BookingSuccessful({Key? key, required this.spot, required this.data}) : super(key: key);
  
  @override
  _BookingSuccessfulState createState() => _BookingSuccessfulState();
}

class _BookingSuccessfulState extends State<BookingSuccessful> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyTicketID() {
    Clipboard.setData(ClipboardData(text: widget.data['ticketID']));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket ID copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: kprimaryColor,
      ),
    );
  }

  void _saveToGallery() {
    // Implementation for saving QR code to gallery
    // You might want to use a package like 'gallery_saver' or 'image_gallery_saver'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR code saved to gallery'),
        duration: Duration(seconds: 2),
        backgroundColor: kprimaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: kprimaryBgColor,
      appBar: AppBar(
        backgroundColor: kprimaryBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ksecondaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking Confirmed',
          style: TextStyle(
            color: ksecondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                
                // Success Icon with Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: height * 0.15,
                    width: width,
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: kprimaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Success Message
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Parking Reserved Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: ksecondaryColor,
                    ),
                  ),
                ),
                
                SizedBox(height: 10),
                
                // Transaction ID (if available)
                if (widget.data['transactionID'] != null && widget.data['transactionID'] != '')
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Transaction ID: ${widget.data['transactionID']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                
                // QR Code Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Show this QR code at the parking entrance',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child:  QrImageView(
                          data: widget.data['ticketID'] ?? '',
                          version: QrVersions.auto,
                          size: 150.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ticket ID: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.data['ticketID'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: ksecondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: _copyTicketID,
                            child: Icon(
                              Icons.copy,
                              size: 18,
                              color: kprimaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveToGallery,
                            icon: Icon(Icons.download, size: 18),
                            label: Text('Save QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kprimaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Share functionality
                            },
                            icon: Icon(Icons.share, size: 18),
                            label: Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kprimaryColor,
                              side: BorderSide(color: kprimaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Booking Details
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ksecondaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: SuccessTokens(
                              label: 'Location',
                              value: widget.data['centre'] ?? 'N/A',
                              icon: Icons.location_on,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: SuccessTokens(
                              label: 'Date',
                              value: widget.data['date'] ?? 'N/A',
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: SuccessTokens(
                              label: 'Check-in',
                              value: widget.data['checkin'] ?? 'N/A',
                              icon: Icons.access_time,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: SuccessTokens(
                              label: 'Check-out',
                              value: widget.data['checkout'] ?? 'N/A',
                              icon: Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: SuccessTokens(
                              label: 'Total Cost',
                              value: widget.data['cost'] ?? 'N/A',
                              icon: Icons.payment,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: SuccessTokens(
                              label: 'Vehicle Number',
                              value: widget.data['vehicleNumber'] ?? 'N/A',
                              icon: Icons.directions_car,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Action Buttons
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessTokens extends StatelessWidget {
  const SuccessTokens({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);
  
  final String label, value;
  final IconData? icon;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: kprimaryColor,
                ),
                SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ksecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}