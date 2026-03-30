import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> helplines = [
      {'title': 'MCD Call Center', 'number': '155305', 'icon': LucideIcons.phoneCall, 'color': Colors.blue},
      {'title': 'Anti Corruption', 'number': '1031', 'icon': LucideIcons.shieldAlert, 'color': Colors.red},
      {'title': 'Fire', 'number': '101', 'icon': LucideIcons.flame, 'color': Colors.orange},
      {'title': 'Police', 'number': '112', 'icon': LucideIcons.siren, 'color': Colors.indigo},
      {'title': 'Ambulance', 'number': '102', 'icon': LucideIcons.activity, 'color': Colors.green},
      {'title': 'Civic Centre Room', 'number': '01123220010', 'icon': LucideIcons.building, 'color': Colors.brown},
      {'title': 'Water Board', 'number': '1916', 'icon': LucideIcons.droplets, 'color': Colors.lightBlue},
      {'title': 'Disaster Mgmt', 'number': '1077', 'icon': LucideIcons.alertTriangle, 'color': Colors.amber},
      {'title': 'Animal Rescue', 'number': '01123899354', 'icon': LucideIcons.dog, 'color': Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Helpline Numbers', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: helplines.length,
        itemBuilder: (context, index) {
          final item = helplines[index];
          return GestureDetector(
            onTap: () => _makePhoneCall(item['number']),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(backgroundColor: item['color'].withOpacity(0.1), radius: 25, child: Icon(item['icon'], color: item['color'], size: 28)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(item['title'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15))), child: const Icon(LucideIcons.chevronRight, color: Colors.white, size: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}