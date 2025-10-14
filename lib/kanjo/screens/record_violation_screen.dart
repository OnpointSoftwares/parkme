import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/kanjo_service.dart';
import '../models/kanjo_models.dart';

/// Screen for recording parking violations
class RecordViolationScreen extends StatefulWidget {
  const RecordViolationScreen({Key? key}) : super(key: key);

  @override
  State<RecordViolationScreen> createState() => _RecordViolationScreenState();
}

class _RecordViolationScreenState extends State<RecordViolationScreen> {
  final KanjoService _service = KanjoService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // State
  String _selectedViolationType = '';
  String? _selectedVehicleNumber;
  double _penaltyAmount = 0.0;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _isLoadingVehicles = true;
  Position? _currentPosition;

  final Map<String, double> _violationTypes = {};
  List<Map<String, dynamic>> _registeredVehicles = [];

  @override
  void initState() {
    super.initState();
    _violationTypes.addAll(_service.getViolationTypes());
    if (_violationTypes.isNotEmpty) {
      _selectedViolationType = _violationTypes.keys.first;
      _penaltyAmount = _violationTypes[_selectedViolationType]!;
    }
    _loadRegisteredVehicles();
  }

  Future<void> _loadRegisteredVehicles() async {
    setState(() => _isLoadingVehicles = true);
    
    try {
      final db = FirebaseDatabase.instance;
      final snapshot = await db.ref('vehicles').get();
      
      if (snapshot.exists) {
        final vehiclesMap = snapshot.value as Map<dynamic, dynamic>;
        final vehicles = <Map<String, dynamic>>[];
        
        vehiclesMap.forEach((key, value) {
          final vehicle = Map<String, dynamic>.from(value as Map);
          if (vehicle['vehicleNumber'] != null) {
            vehicles.add({
              'id': key,
              'vehicleNumber': vehicle['vehicleNumber'],
              'title': vehicle['title'] ?? 'Unknown',
              'owner': vehicle['owner'] ?? 'Unknown',
            });
          }
        });
        
        setState(() {
          _registeredVehicles = vehicles;
          _isLoadingVehicles = false;
        });
      } else {
        setState(() => _isLoadingVehicles = false);
      }
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      setState(() => _isLoadingVehicles = false);
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Violation'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Vehicle Information'),
              _buildVehicleDropdown(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[400]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _vehicleNumberController,
                label: 'Enter Vehicle Number Manually',
                icon: Icons.edit,
                hint: 'e.g., KAA 123A',
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Location'),
              _buildLocationField(),
              const SizedBox(height: 24),

              _buildSectionTitle('Violation Details'),
              _buildViolationTypeDropdown(),
              const SizedBox(height: 16),
              _buildPenaltyDisplay(),
              const SizedBox(height: 24),

              _buildSectionTitle('Description'),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                hint: 'Describe the violation in detail...',
              ),
              const SizedBox(height: 32),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
    );
  }

  Widget _buildLocationField() {
    return Column(
      children: [
        _buildTextField(
          controller: _locationController,
          label: 'Location',
          icon: Icons.location_on,
          hint: 'Enter location or use current location',
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
            icon: _isGettingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(_isGettingLocation ? 'Getting Location...' : 'Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedVehicleNumber,
          decoration: InputDecoration(
            labelText: 'Select Registered Vehicle',
            prefixIcon: Icon(Icons.directions_car),
            suffixIcon: _isLoadingVehicles
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: _registeredVehicles.map<DropdownMenuItem<String>>((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle['vehicleNumber'] as String,
              child: Text(
                '${vehicle['vehicleNumber']} (${vehicle['title']})',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _isLoadingVehicles
              ? null
              : (value) {
                  setState(() {
                    _selectedVehicleNumber = value;
                    _vehicleNumberController.text = value ?? '';
                  });
                },
          hint: Text(_isLoadingVehicles
              ? 'Loading vehicles...'
              : _registeredVehicles.isEmpty
                  ? 'No registered vehicles found'
                  : 'Select a vehicle'),
        ),
        if (_registeredVehicles.isEmpty && !_isLoadingVehicles)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'No registered vehicles in database. Enter manually below.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildViolationTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedViolationType,
      decoration: InputDecoration(
        labelText: 'Violation Type',
        prefixIcon: Icon(Icons.warning),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _violationTypes.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(_getViolationDisplayName(entry.key)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedViolationType = value!;
          _penaltyAmount = _violationTypes[_selectedViolationType]!;
        });
      },
      validator: (value) => value?.isEmpty ?? true ? 'Please select violation type' : null,
    );
  }

  Widget _buildPenaltyDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.orange[800]),
              const SizedBox(width: 8),
              const Text(
                'Penalty Amount:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'KES ${_penaltyAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitViolation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Record Violation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _getViolationDisplayName(String key) {
    return key.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      await _getAddressFromCoordinates(position);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location acquired successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];

        // Build address parts safely
        final addressParts = <String>[];

        void addIfNotEmpty(String? value) {
          if (value != null && value.trim().isNotEmpty) {
            addressParts.add(value);
          }
        }

        addIfNotEmpty(place.street);
        addIfNotEmpty(place.subLocality);
        addIfNotEmpty(place.locality);

        setState(() {
          _locationController.text = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _locationController.text = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    }
  }

  Future<void> _submitViolation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get location data if position is available
      Map<String, dynamic>? locationData;
      if (_currentPosition != null) {
        locationData = {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'accuracy': _currentPosition!.accuracy,
        };
      }

      final violation = ParkingViolation(
        id: '', // Will be generated by service
        vehicleNumber: _vehicleNumberController.text.trim(),
        location: _locationController.text.trim(),
        violationType: _selectedViolationType,
        description: _descriptionController.text.trim(),
        penaltyAmount: _penaltyAmount,
        timestamp: DateTime.now(),
        officerId: '', // Will be set by service
        officerName: '', // Will be set by service
        locationData: locationData,
      );

      await _service.recordViolation(violation);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording violation: $e'),
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
}
