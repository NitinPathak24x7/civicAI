import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import '../../theme/app_theme.dart';
import '../chat_screen.dart'; 
import '../citizen/live_map_screen.dart'; 
import '../citizen/citizen_main.dart'; 
import '../citizen/my_region_screen.dart';
import '../common/detailed_dummy_pages.dart' hide SettingsScreen;
import '../common/settings_screen.dart';
import '../auth/login_screen.dart';

class AdminMainApp extends StatefulWidget {
  const AdminMainApp({super.key});

  @override
  State<AdminMainApp> createState() => _AdminMainAppState();
}

class _AdminMainAppState extends State<AdminMainApp> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
    Navigator.pop(context); 
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AdminHomeTab(), 
      const LiveMapScreen(isAdmin: true), 
      const GenericDummyScreen(title: "Issue Management Hub"), 
      const ContractorManagementScreen(), // FIXED: Actual Rich Dummy Screen
      const SettingsScreen()
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F9),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
              decoration: const BoxDecoration(color: Color(0xFF2C3E50)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(LucideIcons.user, size: 40, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text('Admin Officer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Authority Panel', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(leading: const Icon(LucideIcons.layoutDashboard, color: Colors.black87), title: const Text('Admin Dashboard'), onTap: () => _navigateToTab(0)),
            ListTile(leading: const Icon(LucideIcons.clipboardList, color: Colors.black87), title: const Text('Complaint Management'), onTap: () => _navigateToTab(2)),
            ListTile(leading: const Icon(LucideIcons.clock, color: Colors.orange), title: const Text('Pending Complaints', style: TextStyle(color: Colors.orange)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Pending Tickets")))),
            ListTile(leading: const Icon(LucideIcons.checkSquare, color: Colors.blue), title: const Text('Assigned Complaints', style: TextStyle(color: Colors.blue)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Assigned Tasks")))),
            ListTile(leading: const Icon(LucideIcons.map, color: Colors.black87), title: const Text('Map View'), onTap: () => _navigateToTab(1)),
            // FIXED: Wired to Zone Distribution Screen
            ListTile(leading: const Icon(LucideIcons.mapPin, color: Colors.black87), title: const Text('Zone Management'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoneDistributionScreen()))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.hardHat, color: Colors.black87), title: const Text('Contractor Management'), onTap: () => _navigateToTab(3)),
            ListTile(leading: const Icon(LucideIcons.star, color: Colors.amber), title: const Text('Top Contractors', style: TextStyle(color: Colors.amber)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorManagementScreen()))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.mail, color: Colors.black87), title: const Text('Received Complaints Email'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Email Inbox Integration")))),
            ListTile(leading: const Icon(LucideIcons.alertCircle, color: Colors.red), title: const Text('Severity Control', style: TextStyle(color: Colors.red)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Severity Moderation")))),
            ListTile(leading: const Icon(LucideIcons.copy, color: Colors.black87), title: const Text('Duplicate Control'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Merge Duplicate Reports")))),
            // FIXED: Wired to AI Analytics Hub
            ListTile(leading: const Icon(LucideIcons.barChart2, color: AppTheme.primaryTeal), title: const Text('Analytics Panel', style: TextStyle(color: AppTheme.primaryTeal)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAnalyticsHubScreen()))),
            ListTile(leading: const Icon(LucideIcons.sparkles, color: Colors.black87), title: const Text('AI Insights'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAnalyticsHubScreen()))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.settings, color: Colors.black87), title: const Text('Settings'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            ListTile(leading: const Icon(LucideIcons.logOut, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: _handleLogout),
          ],
        ),
      ),

      appBar: AppBar(
        titleSpacing: 0, toolbarHeight: 80, backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset('assets/icon/icon.png', height: 40, width: 40, errorBuilder: (c, e, s) => const Icon(LucideIcons.landmark, size: 40, color: Color(0xFF2C3E50))),
            const SizedBox(width: 8),
            const Text('Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegionScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3E50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12)),
              icon: const Icon(LucideIcons.mapPin, size: 14, color: Colors.white),
              label: const Text('Region', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          // FIXED: Wired Notification Bell
          IconButton(icon: const Icon(LucideIcons.bellRing, size: 28, color: Colors.redAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        ],
      ),

      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),

          Positioned(
            bottom: 30, left: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen(role: 'Admin'))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.black, AppTheme.darkTeal]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30, right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'chat_admin_insights',
              backgroundColor: AppTheme.textDark,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAnalyticsHubScreen())),
              icon: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
              label: const Text("AI Insights Analysis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});
  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const List<String> _searchOptions = ['Manage Issues', 'Contractors', 'Analytics', 'Settings', 'Users', 'Zone Health'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) { 
      if (!mounted) return; 
      if (_currentPage < 4) { _currentPage++; } else { _currentPage = 0; }
      if (_pageController.hasClients) { _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }
    });
  }

  @override
  void dispose() { 
    _timer?.cancel(); 
    _pageController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') return const Iterable<String>.empty();
              return _searchOptions.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller, focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search complaints, IDs, zones...',
                  prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF2C3E50)),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          const Text('Live Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (context, snapshot) {
              int pending = 0, resolved = 0, active = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  String status = doc['status'] ?? 'Pending';
                  if (status == 'Pending') pending++;
                  else if (status == 'Resolved') resolved++;
                  else active++;
                }
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _statBox(context, 'Pending', '$pending', Colors.red)),
                      const SizedBox(width: 16),
                      Expanded(child: _statBox(context, 'Resolved', '$resolved', Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _statBox(context, 'Active Issues', '$active', Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _statBox(context, 'Zone Health', '82%', Colors.orange)),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 30),
          const Text('Urgent Attention 🔥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          SizedBox(
            height: 160,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).limit(5).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No critical alerts right now."));

                return PageView.builder(
                  controller: _pageController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return _adminActionCard(context, doc['title'], doc['category']);
                  },
                );
              },
            )
          ),
          const SizedBox(height: 30),
          const Text('Live Civic Feed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No reports available."));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  return FeedPostWidget(document: doc); 
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _statBox(BuildContext context, String title, String count, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAnalyticsHubScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.3), width: 1.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _adminActionCard(BuildContext context, String title, String loc) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.shade200, width: 2), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10)]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: const Text("CRITICAL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
            ],
          ),
          Row(children: [const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(loc, style: const TextStyle(color: Colors.grey))]),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textDark, padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorManagementScreen())),
                  child: const Text("Assign", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Issue Image Details"))),
                  child: const Text("View Image"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}