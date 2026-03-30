import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class AutoEmailScreen extends StatefulWidget {
  const AutoEmailScreen({super.key});

  @override
  State<AutoEmailScreen> createState() => _AutoEmailScreenState();
}

class _AutoEmailScreenState extends State<AutoEmailScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Nitin Pathak");
  String _selectedDistrict = 'Ghaziabad';
  String _selectedIssue = 'Sanitation';
  Position? _currentPosition;
  bool _isLocating = false;

  final List<String> _districts = ['Ghaziabad', 'East Delhi', 'South Delhi', 'Noida'];
  final List<String> _issues = ['Sanitation', 'Broken Roads', 'Water Supply', 'Street Lights'];

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLocating = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLocating = false);
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _isLocating = false;
    });
  }

  Future<void> _generateEmail() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fetch location first!')));
      return;
    }

    final String subject = "Urgent Civic Issue: $_selectedIssue in $_selectedDistrict";
    final String body = "Dear Municipal Authority,\n\nMy name is ${_nameController.text}. I am formally reporting a severe $_selectedIssue issue in $_selectedDistrict.\n\nExact GPS Coordinates of the issue:\nLatitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}\n\nPlease take immediate action to resolve this matter.\n\nSincerely,\n${_nameController.text}";
    
    // Guaranteed to open the email app
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@civicai.org',
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Email app. Please check your phone settings.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Write Email', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _nameController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 20),
            
            const Text('District Authority', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDistrict = val!),
            ),
            const SizedBox(height: 20),

            const Text('Issue Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedIssue,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: _issues.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (val) => setState(() => _selectedIssue = val!),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLocating ? null : _getLocation,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: _isLocating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.mapPin),
                label: Text(_currentPosition == null ? 'Attach Live GPS Location' : 'Location Attached!'),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                onPressed: _generateEmail,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: const Icon(LucideIcons.mail, color: Colors.white),
                label: const Text('Generate & Open Gmail', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}