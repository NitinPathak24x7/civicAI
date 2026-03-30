import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(24)),
            child: const Row(children: [CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(LucideIcons.user, color: Colors.black)), SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nitin Pathak', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text('450 Points', style: TextStyle(color: Colors.amber))]))]),
          ),
          const SizedBox(height: 20),
          _rankCard('1', 'Rahul Sharma', '1200 pts', Colors.amber),
          _rankCard('2', 'Priya Singh', '980 pts', Colors.grey),
          _rankCard('3', 'Amit Verma', '850 pts', Colors.brown),
        ],
      ),
    );
  }
  Widget _rankCard(String rank, String name, String pts, Color c) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: Text('#$rank', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18)), title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), trailing: Text(pts, style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold))));
}