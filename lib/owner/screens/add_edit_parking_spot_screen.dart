import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/parking_spot_model.dart';
import '../services/parking_spot_service.dart';
import '../widgets/location_picker_widget.dart';

/// Screen for adding or editing a parking spot
class AddEditParkingSpotScreen extends StatefulWidget {
  final ParkingSpot? existingSpot;

  const AddEditParkingSpotScreen({Key? key, this.existingSpot}) : super(key: key);

  @override
  State<AddEditParkingSpotScreen> createState() => _AddEditParkingSpotScreenState();
}

class _AddEditParkingSpotScreenState extends State<AddEditParkingSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ParkingSpotService();
  
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _totalSpotsController;
  late final TextEditingController _occupiedSpotsController;
  late final TextEditingController _costPerHourController;
  late final TextEditingController _ownerController;
  late final TextEditingController _descriptionController;

  // State variables
  String _selectedType = 'Covered';
  String _selectedSize = 'Standard';
  List<String> _selectedAmenities = [];
  bool _isActive = true;
  LatLng? _positionSelected;
  bool _isLoading = false;

  // Constants
  final List<String> _parkingTypes = ['Covered', 'Open Air', 'Garage', 'Street'];
  final List<String> _parkingSizes = ['Compact', 'Standard', 'Large', 'Motorcycle'];
  final List<String> _availableAmenities = [
    'Security Camera',
    'Lighting',
    'EV Charging',
    'Reserved Spot',
    'Valet Service',
    'Car Wash',
    '24/7 Access',
    'Covered',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.existingSpot != null) {
      _populateExistingData();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipCodeController = TextEditingController();
    _totalSpotsController = TextEditingController();
    _occupiedSpotsController = TextEditingController(text: '0');
    _costPerHourController = TextEditingController();
    _ownerController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void _populateExistingData() {
    final spot = widget.existingSpot!;
    _nameController.text = spot.name;
    _addressController.text = spot.address;
    _cityController.text = spot.city;
    _stateController.text = spot.state;
    _zipCodeController.text = spot.zipCode;
    _totalSpotsController.text = spot.totalSpots.toString();
    _occupiedSpotsController.text = spot.occupiedSpots.toString();
    _costPerHourController.text = spot.costPerHour.toString();
    _ownerController.text = spot.owner.toString();
    _descriptionController.text = spot.description;
    _selectedType = spot.type;
    _selectedSize = spot.size;
    _selectedAmenities = List.from(spot.amenities);
    _isActive = spot.isActive;
    _positionSelected = spot.position;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _totalSpotsController.dispose();
    _occupiedSpotsController.dispose();
    _costPerHourController.dispose();
    _ownerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingSpot != null ? 'Edit Parking Spot' : 'Add Parking Spot'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Basic Information'),
            _buildTextField(
              controller: _nameController,
              label: 'Parking Spot Name',
              icon: Icons.local_parking,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle('Location'),
            _buildTextField(
              controller: _addressController,
              label: 'Street Address',
              icon: Icons.location_on,
              suffixIcon: IconButton(
                icon: const Icon(Icons.map),
                onPressed: _selectLocation,
                tooltip: 'Pick location on map',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter an address' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _zipCodeController,
              label: 'ZIP Code',
              icon: Icons.pin_drop,
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter ZIP code' : null,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Parking Details'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _totalSpotsController,
                    label: 'Total Spots',
                    icon: Icons.grid_view,
                    keyboardType: TextInputType.number,
                    validator: _validateTotalSpots,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _occupiedSpotsController,
                    label: 'Occupied',
                    icon: Icons.directions_car,
                    keyboardType: TextInputType.number,
                    validator: _validateOccupiedSpots,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedType,
                    label: 'Type',
                    items: _parkingTypes,
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedSize,
                    label: 'Size',
                    items: _parkingSizes,
                    onChanged: (value) => setState(() => _selectedSize = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Pricing & Owner'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _costPerHourController,
                    label: 'Cost Per Hour (KES)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(value!) == null) return 'Invalid number';
                      if (int.parse(value) < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _ownerController,
                    label: 'Owner Name',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Amenities'),
            _buildAmenitiesSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Description'),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 3,
              hint: 'Describe your parking spot...',
            ),
            const SizedBox(height: 24),
            
            _buildActiveSwitch(),
            const SizedBox(height: 32),
            
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    Widget? suffixIcon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAmenitiesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          selectedColor: Colors.blue[100],
          checkmarkColor: Colors.blue[800],
        );
      }).toList(),
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      child: SwitchListTile(
        title: const Text('Active Status'),
        subtitle: Text(_isActive ? 'Spot is visible to users' : 'Spot is hidden'),
        value: _isActive,
        onChanged: (value) => setState(() => _isActive = value),
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveParkingSpot,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.existingSpot != null ? 'Update Parking Spot' : 'Add Parking Spot',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String? _validateTotalSpots(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    final spots = int.tryParse(value!);
    if (spots == null) return 'Invalid number';
    if (spots <= 0) return 'Must be greater than 0';
    return null;
  }

  String? _validateOccupiedSpots(String? value) {
    if (value?.isEmpty ?? true) return 'Required';
    final occupied = int.tryParse(value!);
    if (occupied == null) return 'Invalid number';
    if (occupied < 0) return 'Cannot be negative';
    
    final total = int.tryParse(_totalSpotsController.text);
    if (total != null && occupied > total) {
      return 'Cannot exceed total spots';
    }
    return null;
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          initialPosition: _positionSelected,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _positionSelected = LatLng(result['latitude'], result['longitude']);
        _addressController.text = result['address'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location selected successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveParkingSpot() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate location for new spots
    if (widget.existingSpot == null && _positionSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final spot = ParkingSpot(
        id: widget.existingSpot?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        totalSpots: int.parse(_totalSpotsController.text),
        occupiedSpots: int.parse(_occupiedSpotsController.text),
        imageUrl: 'https://via.placeholder.com/150',
        costPerHour: int.parse(_costPerHourController.text),
        owner: _ownerController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        type: _selectedType,
        size: _selectedSize,
        amenities: _selectedAmenities,
        description: _descriptionController.text.trim(),
        isActive: _isActive,
        position: _positionSelected ?? widget.existingSpot?.position,
      );

      if (widget.existingSpot != null) {
        await _service.updateParkingSpot(widget.existingSpot!.id.toString(), spot);
      } else {
        await _service.addParkingSpot(spot);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
