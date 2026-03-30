import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../screens/auth/login_screen.dart';
import '../screens/citizen/report_issue_screen.dart';
import '../screens/citizen/live_map_screen.dart';
import '../screens/citizen/leaderboard_screen.dart';
import '../screens/citizen/ai_chatbot_screen.dart';
import '../screens/common/detailed_dummy_pages.dart';

class CivicDrawer extends StatelessWidget {
  final String userName;
  final String role;
  final List<Map<String, dynamic>> menuItems;

  const CivicDrawer({super.key, required this.userName, required this.role, required this.menuItems});

  void _navigate(BuildContext context, String title) {
    Navigator.pop(context); // Close drawer
    
    switch (title) {
      case 'Logout': Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); break;
      case 'Settings': Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); break;
      case 'Report Issue': Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen())); break;
      case 'Live Map': Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMapScreen())); break;
      case 'Civic Feed': Navigator.push(context, MaterialPageRoute(builder: (_) => const CivicFeedScreen())); break;
      case 'My Complaints': Navigator.push(context, MaterialPageRoute(builder: (_) => const MyComplaintsScreen())); break;
      case 'Gamification & Badges': Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())); break;
      case 'AI Chatbot': Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatbotScreen())); break;
      case 'Helpline Numbers': Navigator.push(context, MaterialPageRoute(builder: (_) => const HelplineScreen())); break;
      case 'Garbage Van Tracking': Navigator.push(context, MaterialPageRoute(builder: (_) => const GarbageVanScreen())); break;
      case 'Profile': Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())); break;
      
      // Admin Routes
      case 'Top Contractors': Navigator.push(context, MaterialPageRoute(builder: (_) => const TopContractorsScreen())); break;
      case 'Received Complaints Email': Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceivedEmailsScreen())); break;
      case 'Zone Management': Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoneManagementScreen())); break;
      case 'Pending Complaints': Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusComplaintsScreen(status: "Pending"))); break;
      case 'Assigned Complaints': Navigator.push(context, MaterialPageRoute(builder: (_) => const StatusComplaintsScreen(status: "Assigned"))); break;
      default: Navigator.push(context, MaterialPageRoute(builder: (_) => GenericDummyScreen(title: title)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24), color: AppTheme.primaryTeal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(LucideIcons.user, size: 40, color: Colors.grey)),
                const SizedBox(height: 15),
                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                if (item['isDivider'] == true) return const Divider();
                return ListTile(
                  leading: Icon(item['icon'], color: item['color'] ?? Theme.of(context).iconTheme.color),
                  title: Text(item['title'], style: TextStyle(fontWeight: FontWeight.w500, color: item['color'] ?? Theme.of(context).textTheme.bodyLarge?.color)),
                  onTap: () => _navigate(context, item['title']),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(leading: const Icon(LucideIcons.settings), title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => _navigate(context, 'Settings')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> citizenMenuItems = [
  {'icon': LucideIcons.layoutDashboard, 'title': 'Dashboard'},
  {'icon': LucideIcons.alertTriangle, 'title': 'Report Issue', 'color': Colors.orange},
  {'icon': LucideIcons.map, 'title': 'Live Map'},
  {'icon': LucideIcons.messageSquare, 'title': 'Civic Feed'},
  {'icon': LucideIcons.fileText, 'title': 'My Complaints'},
  {'isDivider': true},
  {'icon': LucideIcons.award, 'title': 'Gamification & Badges', 'color': Colors.amber},
  {'icon': LucideIcons.bot, 'title': 'AI Chatbot', 'color': AppTheme.primaryTeal},
  {'isDivider': true},
  {'icon': LucideIcons.phoneCall, 'title': 'Helpline Numbers'},
  {'icon': LucideIcons.truck, 'title': 'Garbage Van Tracking'},
  {'icon': LucideIcons.user, 'title': 'Profile'},
  {'isDivider': true},
  {'icon': LucideIcons.logOut, 'title': 'Logout', 'color': Colors.red},
];

final List<Map<String, dynamic>> adminMenuItems = [
  {'icon': LucideIcons.layoutDashboard, 'title': 'Admin Dashboard'},
  {'icon': LucideIcons.clipboardList, 'title': 'Complaint Management'},
  {'icon': LucideIcons.clock, 'title': 'Pending Complaints', 'color': Colors.orange},
  {'icon': LucideIcons.checkSquare, 'title': 'Assigned Complaints', 'color': Colors.blue},
  {'icon': LucideIcons.map, 'title': 'Map View'},
  {'icon': LucideIcons.mapPin, 'title': 'Zone Management'},
  {'isDivider': true},
  {'icon': LucideIcons.hardHat, 'title': 'Contractor Management'},
  {'icon': LucideIcons.star, 'title': 'Top Contractors', 'color': Colors.amber},
  {'isDivider': true},
  {'icon': LucideIcons.mail, 'title': 'Received Complaints Email'},
  {'icon': LucideIcons.alertOctagon, 'title': 'Severity Control', 'color': Colors.red},
  {'icon': LucideIcons.copy, 'title': 'Duplicate Control'},
  {'icon': LucideIcons.barChart2, 'title': 'Analytics Panel', 'color': AppTheme.primaryTeal},
  {'icon': LucideIcons.sparkles, 'title': 'AI Insights'},
  {'isDivider': true},
  {'icon': LucideIcons.logOut, 'title': 'Logout', 'color': Colors.red},
];