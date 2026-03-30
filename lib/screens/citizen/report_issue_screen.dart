import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  File? _imageFile;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isLocating = false;
  String _selectedCategory = 'Infrastructure';

  final List<String> _categories = ['Infrastructure', 'Sanitation', 'Traffic', 'Water', 'Other'];

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLocating = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable location services in your phone settings.')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLocating = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLocating = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _isLocating = false;
    });
  }

  Future<void> _submitReport() async {
    if (_titleController.text.isEmpty || _imageFile == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a title, photo, and click Get Live GPS Location.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Bulletproof Firebase Storage Upload
      String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      // Await the upload task directly
      await storageRef.putFile(_imageFile!);
      
      // Grab the URL only AFTER it fully uploads
      String downloadUrl = await storageRef.getDownloadURL();

      // 2. Save to Firestore Database
      await FirebaseFirestore.instance.collection('reports').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': downloadUrl,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'status': 'Pending', 
        'upvotes': 0,
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _imageFile = null;
        _currentPosition = null;
        _titleController.clear();
        _descController.clear();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green));
      }

    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Detailed error to catch Firebase Storage Rules issues
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload Failed. Did you set Firebase Storage rules to true? Details: $e'), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report an Issue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null 
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.camera, size: 50, color: Colors.grey), SizedBox(height: 10), Text('Tap to take a photo of the issue')])
                    : const Align(alignment: Alignment.bottomRight, child: Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.edit, color: Colors.white)))),
              ),
            ),
            const SizedBox(height: 15),
            
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLocating ? null : _getLocation,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: _isLocating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.mapPin),
                label: Text(_currentPosition == null ? 'Get Live GPS Location' : 'Location Captured Successfully!'),
              ),
            ),
            
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}', style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              ),
            
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Issue Title (e.g., Massive Pothole)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 15),
            
            TextField(controller: _descController, maxLines: 4, decoration: InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Submit Report', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            
            // FIXED: Added 120px of blank space so the submit button doesn't hide behind the black taskbar
            const SizedBox(height: 120), 
          ],
        ),
      ),
    );
  }
}