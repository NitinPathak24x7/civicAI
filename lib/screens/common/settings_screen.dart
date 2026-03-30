import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import 'detailed_dummy_pages.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    bool isDark = isDarkModeNotifier.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryTeal)),
          const SizedBox(height: 10),
          
          // FIXED: WORKING DARK MODE TOGGLE
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Toggle app visual theme'),
            secondary: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.moon, color: isDark ? Colors.white : Colors.black)),
            value: isDark,
            activeColor: AppTheme.primaryTeal,
            onChanged: (bool value) {
              setState(() {
                isDarkModeNotifier.value = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Receive critical civic alerts'),
            secondary: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.bell, color: Colors.blue)),
            value: _notifications,
            activeColor: AppTheme.primaryTeal,
            onChanged: (bool value) => setState(() => _notifications = value),
          ),

          _buildSettingsTile(context, LucideIcons.languages, 'Language', 'English (US)', Colors.purple),
          const Divider(height: 40),
          
          const Text('Support & Help', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryTeal)),
          const SizedBox(height: 10),
          _buildSettingsTile(context, LucideIcons.helpCircle, 'Help Centre', 'Get assistance with the app', Colors.orange),
          _buildSettingsTile(context, LucideIcons.messageSquare, 'FAQ', 'Frequently asked questions', Colors.green),
          _buildSettingsTile(context, LucideIcons.shieldCheck, 'Privacy Policy', 'Data handling and security', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenericDummyScreen(title: title))),
    );
  }
}