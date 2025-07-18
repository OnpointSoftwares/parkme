import 'package:firebase_auth/firebase_auth.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkme/Booking/BookingSuccessful.dart';
import 'package:parkme/constant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class BookingConfirmation extends StatefulWidget {
  final Map<String, dynamic> spot;
  const BookingConfirmation({Key? key, required this.spot}) : super(key: key);
  
  @override
  _BookingConfirmationState createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  DateTime? _date;
  String? dropdownValue;
  late DateFormat formatter;
  int? currentOccupiedSpots;
  List<String> _vehicles = [];
  bool _isLoadingVehicles = true;
  Razorpay? _razorpay;
  TwilioFlutter? twilioFlutter;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserVehicles();
    _checkInTime = TimeOfDay.now();
    _checkOutTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
    _date = DateTime.now();
    formatter = DateFormat('yyyy-MM-dd');
    MpesaFlutterPlugin.setConsumerKey("vahwanLGhxm1NIk7AXMM6oXt4cNbq1B3");
    MpesaFlutterPlugin.setConsumerSecret("JmPtlVDNciBLLXCM");

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Initialize Twilio
    twilioFlutter = TwilioFlutter(
      accountSid: '*********************',
      authToken: '****************************',
      twilioNumber: '****************'
    );
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header with image and back button
            _buildHeader(context),
            
            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildSpotInfo(),
                    SizedBox(height: 20),
                    _buildTimeSelection(context),
                    SizedBox(height: 20),
                    _buildVehicleSelection(),
                    SizedBox(height: 20),
                    _buildPhoneInput(),
                    SizedBox(height: 20),
                    _buildTotalCost(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Payment buttons - fixed at bottom
            _buildPaymentButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        children: <Widget>[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.spot['imageUrl'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.spot['name'] ?? 'Unknown Spot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.spot['address'] ?? 'No address',
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(widget.spot['totalSpots'] ?? 0) - (widget.spot['occupiedSpots'] ?? 0)} slots available',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'KES ${widget.spot['costPerHour'] ?? 0} per hour',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeSelector(
                  context,
                  'Check-in',
                  _checkInTime,
                  (time) => setState(() => _checkInTime = time),
                ),
                _buildTimeSelector(
                  context,
                  'Check-out',
                  _checkOutTime,
                  (time) => setState(() => _checkOutTime = time),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, String label, TimeOfDay? time, Function(TimeOfDay?) onTimeSelected) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (selectedTime != null) {
              onTimeSelected(selectedTime);
            }
          },
          child: Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                time != null
                    ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
                    : "00:00",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '(Tap to edit)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _isLoadingVehicles
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _vehicles.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(height: 8),
                            Text(
                              'No vehicles found',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Please add a vehicle to your profile first',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          hint: Text('Choose Vehicle'),
                          value: dropdownValue,
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: _vehicles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'M-Pesa Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter your M-Pesa phone number',
                prefixText: '+254 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCost() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Charges',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'KES ${_calculateTotalCost()}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (_getDurationInMinutes() > 0)
              Text(
                'Duration: ${(_getDurationInMinutes() / 60).toStringAsFixed(1)} hours',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  if (_validateBooking()) {
                    addReservationToFirebase(false, null);
                  }
                },
                child: Text(
                  'PAY AT LOCATION',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kprimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  if (_validateBooking()) {
                    openCheckout();
                  }
                },
                child: Text(
                  'PAY NOW',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initUserVehicles() async {
   if (!mounted) return;
  
  setState(() {
    _isLoadingVehicles = true;
  });

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final db = FirebaseDatabase.instance;
    final vehiclesRef = db.ref('vehicles');

    // Listen for data
    vehiclesRef.orderByChild('uid').equalTo(user.uid).once().then((DatabaseEvent event) {
      List<String> vehicles = [];
      
      if (event.snapshot.exists && event.snapshot.value != null) {
        final vehiclesData = event.snapshot.value as Map<dynamic, dynamic>;
        
        vehiclesData.forEach((key, value) {
          if (value['vehicleNumber'] != null) {
            vehicles.add(value['vehicleNumber'].toString());
          }
        });
      }

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoadingVehicles = false;
        });
      }
    }).catchError((error) {
      print("Error loading vehicles: $error");
      if (mounted) {
        setState(() {
          _isLoadingVehicles = false;
        });
        Fluttertoast.showToast(
          msg: "Error loading vehicles: ${error.toString()}",
          timeInSecForIosWeb: 4,
        );
      }
    });
  } catch (e) {
    print("Error initializing vehicle loading: $e");
    if (mounted) {
      setState(() {
        _isLoadingVehicles = false;
      });
    }
  }
}
  bool _validateBooking() {
    if (_isLoadingVehicles) {
      Fluttertoast.showToast(
        msg: "Please wait while vehicles are loading",
        timeInSecForIosWeb: 4,
      );
      return false;
    }

    if (_vehicles.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please add a vehicle to your profile first",
        timeInSecForIosWeb: 4,
      );
      return false;
    }

    if (dropdownValue == null) {
      Fluttertoast.showToast(
        msg: "Please select a vehicle",
        timeInSecForIosWeb: 4,
      );
      return false;
    }

    if (_getDurationInMinutes() <= 0) {
      Fluttertoast.showToast(
        msg: "Check-out time must be after check-in time",
        timeInSecForIosWeb: 4,
      );
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your M-Pesa phone number",
        timeInSecForIosWeb: 4,
      );
      return false;
    }

    return true;
  }

  int _getDurationInMinutes() {
    if (_checkInTime == null || _checkOutTime == null) return 0;
    
    int checkInMinutes = _checkInTime!.hour * 60 + _checkInTime!.minute;
    int checkOutMinutes = _checkOutTime!.hour * 60 + _checkOutTime!.minute;
    
    // Handle next day scenario
    if (checkOutMinutes <= checkInMinutes) {
      checkOutMinutes += 24 * 60; // Add 24 hours
    }
    
    return checkOutMinutes - checkInMinutes;
  }

  int _calculateTotalCost() {
    int durationInMinutes = _getDurationInMinutes();
    if (durationInMinutes <= 0) return 0;

    double durationInHours = durationInMinutes / 60.0;
    double costPerHour = (widget.spot['costPerHour'] ?? 0).toDouble();
    return (durationInHours * costPerHour).round();
  }

  void openCheckout() async {
    int checkOutAmount = _calculateTotalCost();
    String phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your M-Pesa phone number.')),
      );
      return;
    }

    // Format phone number
    if (!phone.startsWith('254')) {
      if (phone.startsWith('0')) {
        phone = '254${phone.substring(1)}';
      } else {
        phone = '254$phone';
      }
    }

    try {
      dynamic transactionInitialisation = await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: "174379",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: checkOutAmount.toDouble(),
        partyA: phone,
        partyB: "174379",
        callBackURL: Uri.parse("https://mydomain.com/callback"),
        accountReference: "ParkMe",
        phoneNumber: phone,
        baseUri: Uri.parse("https://sandbox.safaricom.co.ke"),
        transactionDesc: "Payment of Parking Spot",
        passKey: 'vahwanLGhxm1NIk7AXMM6oXt4cNbq1B3',
      );
      
      print("M-Pesa transaction: $transactionInitialisation");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment initiated. Please check your phone.')),
      );
    } catch (e) {
      print("M-Pesa error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('M-Pesa payment failed: ${e.toString()}')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Payment successful!",
      timeInSecForIosWeb: 4,
    );
    addReservationToFirebase(true, response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External wallet: ${response.walletName}",
      timeInSecForIosWeb: 4,
    );
  }

  void addReservationToFirebase(bool paymentDone, String? transactionID) async {
    if (!mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final database = FirebaseDatabase.instance;
      final reservationsRef = database.ref('reservations').push();
      final parkingCentresRef = database.ref('parkingCentres/${widget.spot['id']}');

      await reservationsRef.set({
        'centre': widget.spot['name'],
        'vehicleNumber': dropdownValue,
        'date': formatter.format(_date!),
        'checkin': "${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}",
        'checkout': "${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}",
        'cost': _calculateTotalCost().toString(),
        'paymentMethod': paymentDone ? 'Online' : 'On Arrival',
        'transactionID': transactionID ?? '',
        'uid': user.uid,
        'status': 'confirmed',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update occupied spots
      currentOccupiedSpots = widget.spot['occupiedSpots'] ?? 0;
      await parkingCentresRef.update({
        'occupiedSpots': currentOccupiedSpots! + 1,
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BookingSuccessful(
              data: {
                'ticketID': reservationsRef.key,
                'vehicleNumber': dropdownValue,
                'centre': widget.spot['name'],
                'date': formatter.format(_date!),
                'transactionID': transactionID ?? '',
                'checkin': "${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}",
                'checkout': "${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}",
                'cost': _calculateTotalCost().toString(),
              },
              spot: widget.spot,
            ),
          ),
        );
      }
    } catch (error) {
      print("Failed to create reservation: $error");
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Booking failed: ${error.toString()}",
          timeInSecForIosWeb: 4,
        );
      }
    }
  }
}