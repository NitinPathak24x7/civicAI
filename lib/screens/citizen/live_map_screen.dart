import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';

class LiveMapScreen extends StatefulWidget {
  final bool isAdmin; 
  const LiveMapScreen({super.key, this.isAdmin = false});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polygon> _polygons = {};
  
  String _activeFilter = 'All'; 
  
  int _activeCount = 0;
  int _pendingCount = 0;
  int _resolvedCount = 0;

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.6692, 77.4538), 
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchReportsFromFirestore();
    if (widget.isAdmin) _drawAdminPolygons();
  }

  // FIXED: Explicitly request permission when map loads
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  void _fetchReportsFromFirestore() {
    FirebaseFirestore.instance.collection('reports').snapshots().listen((snapshot) {
      Set<Marker> newMarkers = {};
      int tempActive = 0, tempPending = 0, tempResolved = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          String status = data['status'] ?? 'Pending';
          
          if (status == 'Active' || status == 'Unresolved') tempActive++;
          else if (status == 'Pending') tempPending++;
          else if (status == 'Resolved') tempResolved++;

          if (!widget.isAdmin && _activeFilter != 'All' && status != _activeFilter) continue;

          double markerHue = BitmapDescriptor.hueOrange; 
          if (status == 'Resolved') markerHue = BitmapDescriptor.hueGreen;
          if (status == 'Active' || status == 'Unresolved') markerHue = BitmapDescriptor.hueRed;

          newMarkers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(data['latitude'], data['longitude']),
              infoWindow: InfoWindow(title: data['title'], snippet: 'Status: $status | Upvotes: ${data['upvotes']}'),
              icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
            ),
          );
        }
      }

      setState(() {
        _markers = newMarkers;
        _activeCount = tempActive;
        _pendingCount = tempPending;
        _resolvedCount = tempResolved;
      });
    });
  }

  void _drawAdminPolygons() {
    if (_activeFilter == 'Hide Regions') {
      setState(() => _polygons = {});
      return;
    }

    Set<Polygon> newPolygons = {};

    if (_activeFilter == 'All' || _activeFilter == 'Worst Regions') {
      newPolygons.add(Polygon(
        polygonId: const PolygonId('ghaziabad_zone'),
        points: const [LatLng(28.72, 77.40), LatLng(28.72, 77.50), LatLng(28.62, 77.50), LatLng(28.62, 77.40)],
        fillColor: Colors.red.withOpacity(0.3), strokeColor: Colors.red, strokeWidth: 2,
      ));
    }

    if (_activeFilter == 'All') {
      newPolygons.add(Polygon(
        polygonId: const PolygonId('east_delhi_zone'),
        points: const [LatLng(28.65, 77.25), LatLng(28.65, 77.35), LatLng(28.58, 77.35), LatLng(28.58, 77.25)],
        fillColor: Colors.orange.withOpacity(0.3), strokeColor: Colors.orange, strokeWidth: 2,
      ));
    }

    if (_activeFilter == 'All' || _activeFilter == 'Best Regions') {
      newPolygons.add(Polygon(
        polygonId: const PolygonId('central_delhi_zone'),
        points: const [LatLng(28.65, 77.15), LatLng(28.65, 77.25), LatLng(28.55, 77.25), LatLng(28.55, 77.15)],
        fillColor: Colors.green.withOpacity(0.3), strokeColor: Colors.green, strokeWidth: 2,
      ));
    }

    setState(() => _polygons = newPolygons);
  }

  Future<void> _findVulnerableNearMe() async {
    setState(() => _activeFilter = 'Active'); 
    _fetchReportsFromFirestore();

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polygons: _polygons, 
            myLocationEnabled: true, 
            myLocationButtonEnabled: false, 
            onMapCreated: (GoogleMapController controller) => _mapController = controller,
          ),
          
          Positioned(top: 45, left: 15, right: 15, child: _buildGlobalStats()),

          Positioned(top: 120, left: 15, right: 15, child: widget.isAdmin ? _buildAdminFilters() : _buildCitizenFilters()),

          if (!widget.isAdmin)
            Positioned(
              bottom: 120, left: 60, right: 60, 
              child: ElevatedButton.icon(
                onPressed: _findVulnerableNearMe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, 
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                label: const Text('Vulnerable Near Me', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.error_outline, 'Active', _activeCount, Colors.red),
          _statItem(Icons.access_time, 'Pending', _pendingCount, Colors.orange),
          _statItem(Icons.check_circle_outline, 'Resolved', _resolvedCount, Colors.green),
          if (widget.isAdmin) _statItem(Icons.score, 'Avg Score', 68, AppTheme.primaryTeal), 
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))]),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }

  Widget _buildCitizenFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Pending', 'Active', 'Resolved'].map((filter) {
          bool isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
              selected: isSelected,
              selectedColor: AppTheme.primaryTeal,
              backgroundColor: Colors.white,
              onSelected: (bool value) {
                setState(() => _activeFilter = filter);
                _fetchReportsFromFirestore();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdminFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Best Regions', 'Worst Regions', 'Hide Regions'].map((filter) {
          bool isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
              selected: isSelected,
              selectedColor: Colors.blueGrey,
              backgroundColor: Colors.white,
              onSelected: (bool value) {
                setState(() => _activeFilter = filter);
                _drawAdminPolygons(); 
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}