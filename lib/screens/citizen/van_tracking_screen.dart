import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class VanTrackingScreen extends StatefulWidget {
  const VanTrackingScreen({super.key});

  @override
  State<VanTrackingScreen> createState() => _VanTrackingScreenState();
}

class _VanTrackingScreenState extends State<VanTrackingScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted to municipal authorities!'), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Van Tracking & Reviews', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: [
                  const Icon(LucideIcons.truck, size: 40, color: Colors.orange),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Zone 4 Garbage Van', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Next scheduled arrival: 09:30 AM', style: TextStyle(color: Colors.black54))])),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Rate Van Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40), onPressed: () => setState(() => _rating = index + 1));
              }),
            ),
            const SizedBox(height: 20),
            const Text('Report Irregularity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _reviewController, maxLines: 4, decoration: InputDecoration(hintText: 'e.g., The van did not come today...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(onPressed: _submitFeedback, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('Submit to Authorities', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            )
          ],
        ),
      ),
    );
  }
}