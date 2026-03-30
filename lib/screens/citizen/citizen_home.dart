import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class CitizenHomeTab extends StatelessWidget {
  const CitizenHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search reports...',
              prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
              filled: true, fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Split Dash Cards (Cleanliness & Top Citizen)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkTeal]), borderRadius: BorderRadius.circular(24)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(LucideIcons.leaf, color: Colors.white, size: 28),
                    SizedBox(height: 10),
                    Text('86%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Cleanliness', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(24)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(LucideIcons.award, color: Colors.white, size: 28),
                    SizedBox(height: 10),
                    Text('Nitin', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Top Citizen', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 3. Critical Alerts
          const Text('Critical Alerts 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _criticalAlertCard('Pothole', 'Main Road', 'assets/images/pothole.jpg'),
                const SizedBox(width: 16),
                _criticalAlertCard('Water Leak', 'Sector 4', 'assets/images/waterleak.jpg'),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 4. Community Activity / Civic Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Community Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: (){}, child: const Text('My Reports', style: TextStyle(color: AppTheme.primaryBlue))),
            ],
          ),
          const SizedBox(height: 10),
          _feedPost(context, 'Garbage Dump', 'Massive garbage lying in West Delhi area. Needs immediate attention.', 'assets/images/garbage.jpg'),
          _feedPost(context, 'Broken Streetlight', 'Park avenue streetlight has been broken for 3 days.', null),
          
          const SizedBox(height: 100), // Space for nav bar
        ],
      ),
    );
  }

  Widget _criticalAlertCard(String title, String loc, String imgPath) {
    return Container(
      width: 140,
      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          // Placeholder for actual image
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Container(color: Colors.black45))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: const Text('CRITICAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _feedPost(BuildContext context, String title, String desc, String? imgPath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imgPath != null) ...[
              Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)), child: const Icon(LucideIcons.image, size: 50, color: Colors.grey)),
              const SizedBox(height: 16),
            ],
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(LucideIcons.thumbsUp, size: 20), onPressed: (){}), const Text('124'),
                    const SizedBox(width: 16),
                    IconButton(icon: const Icon(LucideIcons.messageSquare, size: 20), onPressed: (){}), const Text('12'),
                  ],
                ),
                IconButton(icon: const Icon(LucideIcons.flag, size: 20, color: Colors.red), onPressed: (){}),
              ],
            )
          ],
        ),
      ),
    );
  }
}