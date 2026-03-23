import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Map<String, dynamic>? _selectedBoat;
  
  // Silver map style JSON from SnazzyMaps
  final String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#c9c9c9"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    }
  ]
  ''';

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(16.0718, 108.2245),
    zoom: 14.5,
  );

  static const CameraPosition _threeDPosition = CameraPosition(
    target: LatLng(16.0664, 108.2323),
    zoom: 15.5,
    tilt: 59.44,
    bearing: 192.83,
  );

  final List<Map<String, dynamic>> _mockBoats = [
    {
      'id': 'boat_1',
      'name': 'Tiên Sa Cruise',
      'position': const LatLng(16.0718, 108.2245),
      'status': 'Neon VIP Boat',
      'passengers': '45',
      'hue': BitmapDescriptor.hueAzure,
    },
    {
      'id': 'boat_2',
      'name': 'Rồng Vàng',
      'position': const LatLng(16.0610, 108.2272),
      'status': 'Speed Boat',
      'passengers': '20',
      'hue': BitmapDescriptor.hueBlue,
    },
  ];

  Set<Marker> _buildMarkers() {
    return _mockBoats.map((boat) {
      return Marker(
        markerId: MarkerId(boat['id']),
        position: boat['position'],
        icon: BitmapDescriptor.defaultMarkerWithHue(boat['hue']), // Neon Cyan/Blue tones
        onTap: () {
          setState(() {
            _selectedBoat = boat;
          });
          _animateToBoat(boat['position']);
        },
      );
    }).toSet();
  }

  Future<void> _animateToBoat(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: pos, zoom: 17.5, tilt: 65.0, bearing: 45.0),
    ));
  }

  Future<void> _goTo3DView() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_threeDPosition));
    setState(() => _selectedBoat = null);
  }

  Future<void> _resetView() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
    setState(() => _selectedBoat = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bản đồ Tuyến Di Chuyển', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent])),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: _resetView,
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            style: _mapStyle,
            initialCameraPosition: _initialPosition,
            markers: _buildMarkers(),
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (_) => setState(() => _selectedBoat = null),
          ),
          
          Positioned(
            right: 16,
            top: 100,
            child: FadeInRight(
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.accent,
                onPressed: _goTo3DView,
                icon: const Icon(Icons.threed_rotation, color: Colors.white),
                label: const Text('Góc nhìn 3D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          if (_selectedBoat != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 120, // Above NavBar
              child: FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 2)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.directions_boat, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedBoat!['name'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_selectedBoat!['status'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
