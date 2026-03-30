import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

// -------------------------------------------------------------
// GENERIC FALLBACK PAGE
// -------------------------------------------------------------
class GenericDummyScreen extends StatelessWidget {
  final String title;
  const GenericDummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.hardHat, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("This module is under construction.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// CITIZEN: NOTIFICATIONS SCREEN
// -------------------------------------------------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> alerts = [
      {'title': 'Issue Resolved!', 'desc': 'Your report "Massive Pothole" has been marked as resolved.', 'icon': LucideIcons.checkCircle, 'color': Colors.green, 'time': '10 mins ago'},
      {'title': 'New Badge Earned', 'desc': 'Congratulations! You earned the "Civic Hero" badge.', 'icon': LucideIcons.award, 'color': Colors.amber, 'time': '2 hours ago'},
      {'title': 'Severe Weather Alert', 'desc': 'Heavy rain expected in your zone. Drive safely.', 'icon': LucideIcons.cloudRain, 'color': Colors.blue, 'time': '5 hours ago'},
      {'title': 'Status Update', 'desc': 'Your report "Broken Streetlight" is now In Progress.', 'icon': LucideIcons.clock, 'color': Colors.orange, 'time': '1 day ago'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: alert['color'].withOpacity(0.2), child: Icon(alert['icon'], color: alert['color'])),
            title: Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(alert['desc']),
            trailing: Text(alert['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// CITIZEN: MY COMPLAINTS SCREEN
// -------------------------------------------------------------
class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> complaints = [
      {'title': 'Massive Pothole', 'loc': 'Sector 4 Road', 'status': 'Resolved', 'date': 'Oct 12, 2023'},
      {'title': 'Water Logging', 'loc': 'Park Avenue', 'status': 'In Progress', 'date': 'Oct 14, 2023'},
      {'title': 'Dead Animal', 'loc': 'Main Market', 'status': 'Pending', 'date': 'Oct 16, 2023'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final comp = complaints[index];
          Color statusColor = Colors.orange;
          if (comp['status'] == 'Resolved') statusColor = Colors.green;
          if (comp['status'] == 'Pending') statusColor = Colors.red;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(comp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(children: [const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(comp['loc'])]),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(LucideIcons.calendar, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(comp['date'])]),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
                child: Text(comp['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// CITIZEN: GAMIFICATION & BADGES
// -------------------------------------------------------------
class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gamification & Badges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Icon(LucideIcons.trophy, size: 40, color: Colors.amber)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Level 4: Civic Leader', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: 0.7, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber)),
                        const SizedBox(height: 5),
                        const Text('300 XP to next level', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text('Earned Badges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 15, crossAxisSpacing: 15,
              children: [
                _badgeIcon(LucideIcons.camera, 'First Snap', Colors.blue),
                _badgeIcon(LucideIcons.leaf, 'Eco Warrior', Colors.green),
                _badgeIcon(LucideIcons.shieldCheck, 'Verified', Colors.indigo),
                _badgeIcon(LucideIcons.flame, 'Hot Streak', Colors.orange),
                _badgeIcon(LucideIcons.users, 'Community', Colors.pink),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _badgeIcon(IconData icon, String title, Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 35, backgroundColor: color.withOpacity(0.2), child: Icon(icon, size: 30, color: color)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}

// -------------------------------------------------------------
// ADMIN: CONTRACTOR MANAGEMENT
// -------------------------------------------------------------
class ContractorManagementScreen extends StatelessWidget {
  const ContractorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> contractors = [
      {'name': 'Ramesh BuildCo', 'rating': '4.8', 'active': 12, 'completed': 140, 'color': Colors.green},
      {'name': 'Delhi Sanitations', 'rating': '4.2', 'active': 8, 'completed': 89, 'color': Colors.blue},
      {'name': 'Apex Roads Ltd', 'rating': '3.1', 'active': 3, 'completed': 45, 'color': Colors.orange},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Contractor Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contractors.length,
        itemBuilder: (context, index) {
          final con = contractors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(con['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), Text(con['rating'], style: const TextStyle(fontWeight: FontWeight.bold))])
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [Text('${con['active']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: con['color'])), const Text('Active Tasks', style: TextStyle(color: Colors.grey))]),
                      Column(children: [Text('${con['completed']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)), const Text('Completed', style: TextStyle(color: Colors.grey))]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// ADMIN: AI ANALYTICS HUB
// -------------------------------------------------------------
class AIAnalyticsHubScreen extends StatelessWidget {
  const AIAnalyticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analytics Hub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.black, AppTheme.darkTeal]), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.amber, size: 40),
                  const SizedBox(width: 15),
                  Expanded(child: const Text('AI suggests reallocating 3 Sanitation trucks to Zone 2 due to a 40% spike in reports.', style: TextStyle(color: Colors.white, fontSize: 16))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Predictive Hotspots', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _insightCard('Severe Water Logging', 'Expected in Zone 4 due to upcoming rains.', Colors.blue),
            _insightCard('Pothole Degradation', 'High risk on Main Arterial Road.', Colors.red),
            const SizedBox(height: 30),
            const Text('Resolution Efficiency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  const Text('Average Time to Resolve', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('4.2 Days', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(LucideIcons.trendingDown, color: Colors.green, size: 16), SizedBox(width: 5), Text('14% faster than last month', style: TextStyle(color: Colors.green))])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _insightCard(String title, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(LucideIcons.alertTriangle, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}

// -------------------------------------------------------------
// ADMIN: ZONE DISTRIBUTION
// -------------------------------------------------------------
class ZoneDistributionScreen extends StatelessWidget {
  const ZoneDistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> zones = [
      {'name': 'Zone 1 (Central)', 'score': 92, 'issues': 14, 'color': Colors.green},
      {'name': 'Zone 2 (East)', 'score': 74, 'issues': 45, 'color': Colors.orange},
      {'name': 'Zone 3 (South)', 'score': 88, 'issues': 22, 'color': Colors.lightGreen},
      {'name': 'Zone 4 (North)', 'score': 45, 'issues': 112, 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Zone Distribution')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final z = zones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: z['color'], width: 1.5)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(z['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('Active Issues: ${z['issues']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${z['score']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: z['color'])),
                  const Text('Health', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}