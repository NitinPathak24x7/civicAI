import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';

class MyRegionScreen extends StatefulWidget {
  const MyRegionScreen({super.key});

  @override
  State<MyRegionScreen> createState() => _MyRegionScreenState();
}

class _MyRegionScreenState extends State<MyRegionScreen> {
  bool _isLoading = true;
  Position? _currentPosition;
  String _temp = "--°C";
  String _aqi = "--";
  String _pollen = "--";
  String _solar = "--";
  int _civicScore = 85;

  @override
  void initState() {
    super.initState();
    _fetchRegionData();
  }

  Future<void> _fetchRegionData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Explicitly check and request Location Permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          setState(() => _isLoading = false);
          return;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

      // 2. Fetch Temp (Open-Meteo)
      final weatherRes = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}&longitude=${pos.longitude}&current_weather=true'));
      if (weatherRes.statusCode == 200) {
        _temp = "${jsonDecode(weatherRes.body)['current_weather']['temperature'].round()}°C";
      }

      // 3. Fetch AQI (Google Air Quality API)
      if (apiKey.isNotEmpty) {
        final aqiRes = await http.post(
          Uri.parse('https://airquality.googleapis.com/v1/currentConditions:lookup?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"location": {"latitude": pos.latitude, "longitude": pos.longitude}}),
        );
        if (aqiRes.statusCode == 200) {
          final aqiData = jsonDecode(aqiRes.body);
          _aqi = aqiData['indexes'][0]['aqi'].toString();
          if (int.parse(_aqi) > 100) _civicScore -= 5; 
        }

        // 4. Fetch Pollen
        final pollenRes = await http.get(Uri.parse('https://pollen.googleapis.com/v1/forecast:lookup?key=$apiKey&location.longitude=${pos.longitude}&location.latitude=${pos.latitude}&days=1'));
        if (pollenRes.statusCode == 200) {
          _pollen = "Active"; 
        } else {
          _pollen = "Low";
        }
        
        _solar = "High"; // Mocked solar availability for UI
      }

      setState(() {
        _currentPosition = pos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching region data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Region', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_currentPosition != null ? '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}' : 'Fetching...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _fetchRegionData,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        icon: const Icon(LucideIcons.mapPin, color: Colors.white, size: 16),
                        label: const Text('Locate', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Civic Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkTeal]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))]),
                  child: Column(
                    children: [
                      const Text('Overall Civic Score', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text('$_civicScore / 100', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('Your area is performing well, but air quality needs attention.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Live Environment Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _envCard('Weather', _temp, LucideIcons.cloudSun, Colors.blue),
                    _envCard('Air Quality', 'AQI $_aqi', LucideIcons.wind, Colors.orange),
                    _envCard('Pollen Count', _pollen, LucideIcons.flower, Colors.pink),
                    _envCard('Solar Potential', _solar, LucideIcons.sun, Colors.amber),
                  ],
                )
              ],
            ),
          ),
    );
  }

  Widget _envCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}