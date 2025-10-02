import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Widget for picking a location on a map
class LocationPickerWidget extends StatefulWidget {
  final LatLng? initialPosition;

  const LocationPickerWidget({Key? key, this.initialPosition}) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  GoogleMapController? _mapController;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
    if (_selectedLocation != null) {
      _getAddressFromCoordinates(_selectedLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Use current location',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedLocation != null ? _confirmSelection : null,
            tooltip: 'Confirm selection',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition ?? const LatLng(-1.2921, 36.8219), // Nairobi
              zoom: 14.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                      draggable: true,
                      onDragEnd: _onMarkerDragEnd,
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          _buildAddressCard(),
          if (_isLoadingAddress) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800]),
                const SizedBox(width: 8),
                const Text(
                  'Selected Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedAddress.isEmpty
                  ? 'Tap on the map to select a location'
                  : _selectedAddress,
              style: TextStyle(
                fontSize: 14,
                color: _selectedAddress.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
            if (_selectedLocation != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Getting address...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromCoordinates(position);
  }

  void _onMarkerDragEnd(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _getAddressFromCoordinates(position);
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _selectedAddress = 'Getting address...';
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
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
        addIfNotEmpty(place.subAdministrativeArea);
        addIfNotEmpty(place.administrativeArea);
        addIfNotEmpty(place.postalCode);
        addIfNotEmpty(place.country);
        
        setState(() {
          _selectedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          _selectedAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
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

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
      });

      // Animate camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 16.0),
      );

      _getAddressFromCoordinates(location);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current location selected'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress,
      });
    }
  }
}
