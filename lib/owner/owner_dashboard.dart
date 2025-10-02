// DEPRECATED: This file is kept for backward compatibility only.
// Please use the new modular dashboard: owner_dashboard_main.dart
//
// The owner dashboard has been refactored into a modular, production-ready structure:
// - owner_dashboard_main.dart: Main dashboard with navigation
// - screens/: Individual screen components
// - widgets/: Reusable UI components
// - models/: Data models
// - services/: Business logic and Firebase operations
//
// See owner/README.md for complete documentation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'owner_dashboard_main.dart';

/// Deprecated: Use OwnerDashboard from owner_dashboard_main.dart instead
@Deprecated('Use OwnerDashboard from owner_dashboard_main.dart')
class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({Key? key}) : super(key: key);
  
  @override
  _OwnerDashboardPageState createState() => _OwnerDashboardPageState();
}

@Deprecated('Use OwnerDashboard from owner_dashboard_main.dart')
class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  @override
  Widget build(BuildContext context) {
    // Redirect to new modular dashboard
    return const OwnerDashboard();
  }
}

// Legacy code preserved below for reference
// ============================================

class _LegacyOwnerDashboardPage extends StatefulWidget {
  @override
  _LegacyOwnerDashboardPageState createState() => _LegacyOwnerDashboardPageState();
}

class _LegacyOwnerDashboardPageState extends State<_LegacyOwnerDashboardPage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    MyParkingSpotsTab(),
    MyBookingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'My Spots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class ParkingSpot {
  int id;
  String name;
  String address;
  var totalSpots;
  var occupiedSpots;
  String imageUrl;
  int costPerHour;
  var owner;
  // Additional fields for enhanced functionality
  String city;
  String state;
  String zipCode;
  String type;
  String size;
  List<String> amenities;
  String description;
  bool isActive;
  LatLng? position;
  
  ParkingSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSpots,
    required this.occupiedSpots,
    required this.imageUrl,
    required this.costPerHour,
    required this.owner,
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.type = 'Covered',
    this.size = 'Standard',
    this.amenities = const [],
    this.description = '',
    this.isActive = true,
    required this.position
  });
  
  // Getter for available spots
  int get availableSpots => totalSpots - occupiedSpots;
  
  // Getter for occupancy percentage
  double get occupancyPercentage => 
      totalSpots > 0 ? (occupiedSpots / totalSpots) * 100 : 0;
}

class MyParkingSpotsTab extends StatefulWidget {
  @override
  _MyParkingSpotsTabState createState() => _MyParkingSpotsTabState();
}

class _MyParkingSpotsTabState extends State<MyParkingSpotsTab> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('parkingCentres')
            .orderByChild('ownerId')
            .equalTo(user?.uid)
            .onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: ElevatedButton.icon(
              onPressed: () => _showAddParkingSpotDialog(context),
              icon: Icon(Icons.add),
              label: Text('Add Spot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ));
          }
          
          final spotsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final spots = spotsMap.entries.map((entry) {
            final spot = entry.value as Map<dynamic, dynamic>;
            return ParkingSpot(
              id: int.tryParse(entry.key.toString()) ?? DateTime.now().millisecondsSinceEpoch,
              name: spot['name'] ?? '',
              address: spot['address'] ?? '',
              totalSpots: spot['totalSpots'] ?? 0,
              occupiedSpots: spot['occupiedSpots'] ?? 0,
              imageUrl: spot['imageUrl'] ?? '',
              costPerHour: spot['costPerHour'] ?? 0,
              owner: spot['ownerId'] ?? '',
              city: spot['city'] ?? '',
              state: spot['state'] ?? '',
              zipCode: spot['zipCode'] ?? '',
              type: spot['type'] ?? 'Covered',
              size: spot['size'] ?? 'Standard',
              amenities: spot['amenities'] != null ? List<String>.from(spot['amenities']) : [],
              description: spot['description'] ?? '',
              isActive: spot['isActive'] ?? true,
              position: spot['position'] != null 
                  ? LatLng(
                      spot['position']['latitude']?.toDouble() ?? 0.0,
                      spot['position']['longitude']?.toDouble() ?? 0.0,
                    )
                  : LatLng(0, 0),
            );
          }).toList();

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Parking Spots',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          '${spots.length} spots registered',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddParkingSpotDialog(context),
                      icon: Icon(Icons.add),
                      label: Text('Add Spot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: spots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_parking, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text('No parking spots yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            SizedBox(height: 8),
                            Text('Add your first parking spot to get started', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: spots.length,
                        itemBuilder: (context, i) {
                          final spot = spots[i];
                          final dbKey = spotsMap.keys.elementAt(i);
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(spot.name),
                              subtitle: Text('${spot.address}, ${spot.city}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editParkingSpot(spot, dbKey, context),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteParkingSpot(dbKey, context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddParkingSpotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddParkingSpotDialog(),
    ).then((newSpot) async {
      if (newSpot != null) {
        try {
          final db = FirebaseDatabase.instance;
          final ref = db.ref('parkingCentres').push();
          
          Map<String, dynamic> spotData = {
            'name': newSpot.name,
            'address': newSpot.address,
            'totalSpots': newSpot.totalSpots,
            'occupiedSpots': newSpot.occupiedSpots,
            'imageUrl': newSpot.imageUrl,
            'costPerHour': newSpot.costPerHour,
            'ownerId': FirebaseAuth.instance.currentUser?.uid ?? '',
            'city': newSpot.city,
            'state': newSpot.state,
            'zipCode': newSpot.zipCode,
            'type': newSpot.type,
            'size': newSpot.size,
            'amenities': newSpot.amenities,
            'description': newSpot.description,
            'isActive': newSpot.isActive,
          };

          // Add position data if it exists
          if (newSpot.position != null) {
            spotData['position'] = {
              'latitude': newSpot.position!.latitude,
              'longitude': newSpot.position!.longitude,
            };
            print('Saving to Firebase - Position: ${newSpot.position!.latitude}, ${newSpot.position!.longitude}');
          } else {
            print('Warning: No position data available for parking spot');
          }

          await ref.set(spotData);
        } catch (e) {
          print('Error saving parking spot: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save parking spot: $e')),
          );
        }
      }
    });
  }

  void _editParkingSpot(ParkingSpot spot, String dbKey, dynamic context) {
    showDialog(
      context: context,
      builder: (context) => AddParkingSpotDialog(existingSpot: spot),
    ).then((editedSpot) async {
      if (editedSpot != null) {
        final db = FirebaseDatabase.instance;
        final ref = db.ref('parkingCentres/$dbKey');
        await ref.update({
          'name': editedSpot.name,
          'address': editedSpot.address,
          'totalSpots': editedSpot.totalSpots,
          'occupiedSpots': editedSpot.occupiedSpots,
          'imageUrl': editedSpot.imageUrl,
          'costPerHour': editedSpot.costPerHour,
          'ownerId': FirebaseAuth.instance.currentUser?.uid ?? '',
          'city': editedSpot.city,
          'state': editedSpot.state,
          'zipCode': editedSpot.zipCode,
          'type': editedSpot.type,
          'size': editedSpot.size,
          'amenities': editedSpot.amenities,
          'description': editedSpot.description,
          'isActive': editedSpot.isActive,
          'position': editedSpot.position != null 
              ? {
                  'latitude': editedSpot.position!.latitude,
                  'longitude': editedSpot.position!.longitude,
                }
              : null,
        });
      }
    });
  }

  void _deleteParkingSpot(String dbKey, dynamic context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parking Spot'),
        content: const Text('Are you sure you want to delete this parking spot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = FirebaseDatabase.instance;
              await db.ref('parkingCentres/$dbKey').remove();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

class AddParkingSpotDialog extends StatefulWidget {
  final ParkingSpot? existingSpot;

  AddParkingSpotDialog({this.existingSpot});

  @override
  _AddParkingSpotDialogState createState() => _AddParkingSpotDialogState();
}

class _AddParkingSpotDialogState extends State<AddParkingSpotDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _totalSpotsController = TextEditingController();
  final _occupiedSpotsController = TextEditingController();
  final _costPerHourController = TextEditingController();
  final _ownerController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Covered';
  String _selectedSize = 'Standard';
  List<String> _selectedAmenities = [];
  bool _isActive = true;
  LatLng? positionSelected;
  
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
    if (widget.existingSpot != null) {
      _populateExistingData();
    }
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
    positionSelected = spot.position;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            AppBar(
              title: Text(widget.existingSpot != null ? 'Edit Parking Spot' : 'Add Parking Spot'),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Parking Spot Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      _buildSectionTitle('Location'),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Street Address',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () => _selectLocation(),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a city';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a state';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              decoration: InputDecoration(
                                labelText: 'ZIP Code',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a ZIP code';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      _buildSectionTitle('Parking Details'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _totalSpotsController,
                              decoration: InputDecoration(
                                labelText: 'Total Spots',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_parking),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter total spots';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _occupiedSpotsController,
                              decoration: InputDecoration(
                                labelText: 'Occupied Spots',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_car),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter occupied spots';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: 'Parking Type',
                                border: OutlineInputBorder(),
                              ),
                              items: _parkingTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSize,
                              decoration: InputDecoration(
                                labelText: 'Size',
                                border: OutlineInputBorder(),
                              ),
                              items: _parkingSizes.map((size) {
                                return DropdownMenuItem(
                                  value: size,
                                  child: Text(size),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSize = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      _buildSectionTitle('Pricing & Owner'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costPerHourController,
                              decoration: InputDecoration(
                                labelText: 'Cost Per Hour (\$)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cost per hour';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ownerController,
                              decoration: const InputDecoration(
                                labelText: 'Owner',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter owner name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      _buildSectionTitle('Amenities'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableAmenities.map((amenity) {
                          return FilterChip(
                            label: Text(amenity),
                            selected: _selectedAmenities.contains(amenity),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add(amenity);
                                } else {
                                  _selectedAmenities.remove(amenity);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24),
                      
                      _buildSectionTitle('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Describe your parking spot...',
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveParkingSpot,
                          child: Text(
                            widget.existingSpot != null ? 'Update Parking Spot' : 'Add Parking Spot',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
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

  void _selectLocation() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LocationPickerPage()),
      );
      
      if (result != null) {
        print('Picked location: ${result['address']}');
        positionSelected = LatLng(result['latitude'], result['longitude']);
        
        // Update the address field with the selected location
        _addressController.text = result['address'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location selected: ${result['address']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _saveParkingSpot() {
    if (_formKey.currentState!.validate()) {
      // Ensure position is required for new spots
      if (widget.existingSpot == null && positionSelected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location on the map')),
        );
        return;
      }

      final newSpot = ParkingSpot(
        id: widget.existingSpot?.id ?? DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        address: _addressController.text,
        totalSpots: int.parse(_totalSpotsController.text),
        occupiedSpots: int.parse(_occupiedSpotsController.text),
        imageUrl: 'https://via.placeholder.com/150',
        costPerHour: int.parse(_costPerHourController.text),
        owner: _ownerController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        type: _selectedType,
        size: _selectedSize,
        amenities: _selectedAmenities,
        description: _descriptionController.text,
        isActive: _isActive,
        position: positionSelected ?? widget.existingSpot?.position,
      );

      if (positionSelected != null) {
        print('Saving position: ${positionSelected!.latitude}, ${positionSelected!.longitude}');
      } else {
        print('No position selected, using existing: ${widget.existingSpot?.position}');
      }

      Navigator.pop(context, newSpot);
    }
  }
}

class LocationPickerPage extends StatefulWidget {
  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? selectedLocation;
  String selectedAddress = '';
  late GoogleMapController mapController;

  void _onTap(LatLng position) async {
    setState(() {
      selectedLocation = position;
      selectedAddress = 'Getting address...';
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address parts safely
        List<String> addressParts = [];
        
        // Helper function to safely add address parts
        void addIfNotEmpty(String? value) {
          if (value != null && value.trim().isNotEmpty) {
            addressParts.add(value);
          }
        }
        
        // Add address components in order of specificity
        addIfNotEmpty(place.street);
        addIfNotEmpty(place.subLocality);
        addIfNotEmpty(place.locality);
        addIfNotEmpty(place.subAdministrativeArea);
        addIfNotEmpty(place.administrativeArea);
        addIfNotEmpty(place.postalCode);
        addIfNotEmpty(place.country);
        
        // If we couldn't get any address components, use coordinates
        String address;
        if (addressParts.isNotEmpty) {
          address = addressParts.join(', ');
        } else {
          address = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        }

        if (mounted) {
          setState(() {
            selectedAddress = address;
          });
        }
      } else {
        // If no placemarks found, use coordinates
        if (mounted) {
          setState(() {
            selectedAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          // Fallback to coordinates if geocoding fails
          selectedAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using coordinates. Could not get full address.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _confirmSelection() {
    if (selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'address': selectedAddress,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmSelection,
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-1.2921, 36.8219), // Nairobi default
          zoom: 14.0,
        ),
        onMapCreated: (controller) => mapController = controller,
        onTap: _onTap,
        markers: selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('pickedLocation'),
                  position: selectedLocation!,
                )
              }
            : {},
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          selectedAddress.isEmpty
              ? 'Tap on map to pick a location'
              : 'Selected: $selectedAddress',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
class MyBookingsTab extends StatelessWidget {
  Future<List<String>> _getOwnerSpotNames() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseDatabase.instance
        .ref('parkingCentres')
        .orderByChild('ownerId')
        .equalTo(user?.uid)
        .get();
    if (snapshot.value == null) return [];
    final map = snapshot.value as Map<dynamic, dynamic>;
    return map.values.map((e) => e['name'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getOwnerSpotNames(),
      builder: (context, spotNamesSnap) {
        if (!spotNamesSnap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final spotNames = spotNamesSnap.data ?? [];
        if (spotNames.isEmpty) {
          return Center(child: Text('No parking spots found for this owner.'));
        }

        return StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('reservations').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(child: Text('No bookings yet'));
            }

            final bookingsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final bookings = bookingsMap.values
                .where((booking) => spotNames.contains(booking['centre']))
                .toList();

            if (bookings.isEmpty) {
              return Center(child: Text('No bookings yet'));
            }

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final booking = bookings[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text('Spot: ${booking['centre']}'),
                    subtitle: Text(
                        'Vehicle: ${booking['vehicleNumber']}\n'
                        'Date: ${booking['date']}\n'
                        'Check-in: ${booking['checkin']}\n'
                        'Check-out: ${booking['checkout']}'),
                    trailing: Text('User: ${booking['uid']}'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
