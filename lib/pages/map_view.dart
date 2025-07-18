import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geocoding/geocoding.dart';
import 'package:parkme/Booking/Booking_Confirmation.dart';
import 'package:parkme/constant.dart';
import 'package:firebase_database/firebase_database.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final TextEditingController myController = TextEditingController();
  
  CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5);
  GoogleMapController? mapController;

  Position? _currentPosition;
  bool _showClearButton = false;

  Set<Marker> markers = {};
  BitmapDescriptor? _mapMarker;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    myController.addListener(() {
      setState(() => _showClearButton = myController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      await customMarker();
      await _getCurrentLocation();
      listenToMarkers(); // Real-time update
    } catch (e) {
      debugPrint('Map initialization error: $e');
    }
  }

  Future<void> customMarker() async {
    try {
     /* _mapMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'assets/images/parkmeIcon.png',
      );*/
      _mapMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      debugPrint('Custom marker loaded successfully');
    } catch (e) {
      debugPrint('Custom marker loading failed: $e');
      // Fallback to default marker
      _mapMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  void listenToMarkers() {
    final db = FirebaseDatabase.instance;
    db.ref('parkingCentres').onValue.listen((event) async {
      debugPrint('Firebase data received');
      Set<Marker> newMarkers = {};
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data != null) {
        debugPrint('Data found: ${data.keys.length} parking centres');
        
        for (var entry in data.entries) {
          final spot = Map<String, dynamic>.from(entry.value);
          debugPrint('Processing spot: ${spot['name']}');
          
          try {
            if (spot['name'] == null) {
              debugPrint('Skipping spot with missing name: ${spot.toString()}');
              continue;
            }

            LatLng? position = await _getLocationFromSpot(spot);
            if (position == null) {
              debugPrint('Could not get location for spot: ${spot['name']}');
              continue;
            }

            debugPrint('Final position for ${spot['name']}: ${position.latitude}, ${position.longitude}');
            
            final marker = Marker(
              markerId: MarkerId(entry.key.toString()), // Use Firebase key as ID
              position: position,
              infoWindow: InfoWindow(
                title: spot['name'],
                snippet: spot['address'] ?? spot['city'] ?? 'No address available',
              ),
              icon: _mapMarker ?? BitmapDescriptor.defaultMarker,
              onTap: () => _showParkingInfo(spot),
            );
            newMarkers.add(marker);
            debugPrint('Added marker for: ${spot['name']}');
          } catch (e) {
            debugPrint('Error processing spot ${spot['name']}: $e');
          }
        }
      } else {
        debugPrint('No data found in Firebase');
      }
      
      debugPrint('Total markers to display: ${newMarkers.length}');
      setState(() {
        markers = newMarkers;
      });
    }, onError: (error) {
      debugPrint('Firebase listen error: $error');
    });
  }

  Future<LatLng?> _getLocationFromSpot(Map<String, dynamic> spot) async {
    try {
      // Check if position is a Map with latitude/longitude
      if (spot['position'] is Map) {
        final positionMap = spot['position'] as Map<dynamic, dynamic>;
        if (positionMap.containsKey('latitude') && positionMap.containsKey('longitude')) {
          final lat = positionMap['latitude'];
          final lng = positionMap['longitude'];
          debugPrint('Using coordinate position: $lat, $lng');
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
      
      // Check if position is a String address
      if (spot['position'] is String) {
        debugPrint('Using address position: ${spot['position']}');
        List<Location> locations = await locationFromAddress(spot['position']);
        if (locations.isNotEmpty) {
          Location loc = locations.first;
          return LatLng(loc.latitude, loc.longitude);
        }
      }
      
      // Fallback: try to geocode using available address fields
      String? address = spot['address'] ?? spot['city'] ?? spot['state'];
      if (address != null && address.isNotEmpty) {
        debugPrint('Fallback geocoding with: $address');
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location loc = locations.first;
          return LatLng(loc.latitude, loc.longitude);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  void _showParkingInfo(Map<String, dynamic> spot) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 260,
          decoration: const BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            children: [
              Text(
                spot['name'] ?? 'Unknown Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kprimaryColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(spot['address'] ?? 'No address')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "KES ${spot['costPerHour'] ?? 0}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text('per hour'),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      Text(
                        ((spot['totalSpots'] ?? 0) - (spot['occupiedSpots'] ?? 0)).toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text('seats left'),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BookingConfirmation(spot: spot)),
                    );
                  },
                  child: const Text(
                    'RESERVE',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Current location error: $e');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Location permissions are permanently denied.');
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _updateLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        _showSnack('Location not found');
        return;
      }

      final loc = locations.first;
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude, loc.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Update location error: $e');
      _showSnack('Location not found');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSearchBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 1))
        ]),
        child: TextField(
          controller: myController,
          onSubmitted: _updateLocation,
          style: const TextStyle(fontSize: 18),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search here',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
            suffixIcon: _showClearButton
                ? IconButton(
                    onPressed: () => myController.clear(),
                    icon: const Icon(Icons.clear),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLocationButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ClipOval(
            child: Material(
              color: kprimaryColor,
              child: InkWell(
                splashColor: Colors.blue,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.my_location, color: kBtnTextColor),
                ),
                onTap: () {
                  if (_currentPosition != null) {
                    mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                              _currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 15,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add a debug widget to show marker count
  Widget _buildDebugInfo() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Markers: ${markers.length}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialLocation,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.hybrid,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;
              debugPrint('Map controller created');
            },
          ),
          _buildSearchBar(),
          _buildMyLocationButton(),
          _buildDebugInfo(), // Add debug info
        ],
      ),
    );
  }
}