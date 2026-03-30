import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

import '../../theme/app_theme.dart';
import '../common/detailed_dummy_pages.dart' hide HelplineScreen, SettingsScreen;
import '../common/settings_screen.dart';
import 'report_issue_screen.dart';
import 'live_map_screen.dart';
import 'leaderboard_screen.dart';
import '../chat_screen.dart';
import 'my_region_screen.dart'; 
import 'helpline_screen.dart';
import 'van_tracking_screen.dart';
import 'auto_email_screen.dart';
import '../auth/login_screen.dart'; 

class CitizenMainApp extends StatefulWidget {
  const CitizenMainApp({super.key});
  @override
  State<CitizenMainApp> createState() => _CitizenMainAppState();
}

class _CitizenMainAppState extends State<CitizenMainApp> {
  int _currentIndex = 0;
  String _currentTemp = "--°C";
  String _currentAQI = "AQI: --";

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final weatherRes = await http.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=28.6139&longitude=77.2090&current_weather=true'));
      if (weatherRes.statusCode == 200) {
        final weatherData = jsonDecode(weatherRes.body);
        setState(() => _currentTemp = "${weatherData['current_weather']['temperature'].round()}°C");
      }

      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        final aqiRes = await http.post(
          Uri.parse('https://airquality.googleapis.com/v1/currentConditions:lookup?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"location": {"latitude": 28.6139, "longitude": 77.2090}}),
        );
        if (aqiRes.statusCode == 200) {
          final aqiData = jsonDecode(aqiRes.body);
          setState(() => _currentAQI = "AQI: ${aqiData['indexes'][0]['aqi']}");
        }
      }
    } catch (e) {
      debugPrint("Weather Fetch Error: $e");
    }
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
      const CitizenHomeTab(), 
      const LiveMapScreen(isAdmin: false), 
      const ReportIssueScreen(), 
      const LeaderboardScreen(), 
      const CitizenProfileScreen() 
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
              decoration: const BoxDecoration(color: AppTheme.primaryTeal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(LucideIcons.user, size: 40, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text('Nitin Pathak', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Citizen Account', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(leading: const Icon(LucideIcons.layoutDashboard), title: const Text('Dashboard'), onTap: () { setState(() => _currentIndex = 0); Navigator.pop(context); }),
            ListTile(leading: const Icon(LucideIcons.alertTriangle, color: Colors.orange), title: const Text('Report Issue', style: TextStyle(color: Colors.orange)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen()))),
            ListTile(leading: const Icon(LucideIcons.map), title: const Text('Live Map'), onTap: () { setState(() => _currentIndex = 1); Navigator.pop(context); }),
            ListTile(leading: const Icon(LucideIcons.messageSquare), title: const Text('Civic Feed'), onTap: () { setState(() => _currentIndex = 3); Navigator.pop(context); }),
            ListTile(leading: const Icon(LucideIcons.fileText), title: const Text('My Complaints'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyComplaintsScreen()))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.award, color: Colors.amber), title: const Text('Gamification & Badges', style: TextStyle(color: Colors.amber)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen()))),
            ListTile(leading: const Icon(LucideIcons.bot, color: AppTheme.primaryTeal), title: const Text('AI Chatbot', style: TextStyle(color: AppTheme.primaryTeal)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen(role: 'Citizen')))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.phoneCall), title: const Text('Helpline Numbers'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelplineScreen()))),
            ListTile(leading: const Icon(LucideIcons.truck), title: const Text('Garbage Van Tracking'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VanTrackingScreen()))),
            ListTile(leading: const Icon(LucideIcons.mail), title: const Text('Auto Write Email'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoEmailScreen()))),
            const Divider(),
            ListTile(leading: const Icon(LucideIcons.settings), title: const Text('Settings'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            ListTile(leading: const Icon(LucideIcons.logOut, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: _handleLogout),
          ],
        ),
      ),
      
      appBar: AppBar(
        titleSpacing: 0, toolbarHeight: 80, 
        backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', height: 40, width: 40, errorBuilder: (c,e,s) => const Icon(LucideIcons.landmark, size: 40, color: AppTheme.primaryTeal)),
            const SizedBox(width: 8),
            const Text('CivicAI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)), 
          ],
        ),
        actions: [
          // FIXED: Weather and AQI are now non-clickable
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(children: [const Icon(LucideIcons.cloudSun, size: 14, color: Colors.blueGrey), const SizedBox(width: 4), Text(_currentTemp, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 11))]),
              Row(children: [const Icon(LucideIcons.wind, size: 14, color: Colors.green), const SizedBox(width: 4), Text(_currentAQI, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 11))]),
            ],
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRegionScreen())),
            icon: const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.primaryTeal),
            label: const Text('Region', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: const Icon(LucideIcons.bell, size: 22, color: Colors.black), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())))
        ],
      ), 
      
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),
          
          Positioned(
            bottom: 110, right: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen(role: 'Citizen'))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryTeal, Colors.tealAccent]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))], border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)),
                    child: const Icon(LucideIcons.messageCircle, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navItem(LucideIcons.home, 0), _navItem(LucideIcons.map, 1),
                  GestureDetector(onTap: () => setState(() => _currentIndex = 2), child: Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle), child: const Icon(LucideIcons.plus, color: Colors.white))),
                  _navItem(LucideIcons.award, 3), _navItem(LucideIcons.user, 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Icon(icon, color: isSelected ? AppTheme.primaryTeal : Colors.white54, size: 28), 
          if (isSelected) Container(margin: const EdgeInsets.only(top: 4), height: 5, width: 5, decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle))
        ]
      ),
    );
  }
}

class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 30),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryTeal,
                child: const Icon(LucideIcons.user, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
            
            _buildTextField("Full Name", "Nitin Pathak"),
            const SizedBox(height: 20),
            _buildTextField("Email", "nitin@civicai.in"),
            const SizedBox(height: 20),
            _buildTextField("Zone", "Ghaziabad, Zone 4"),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully!'))),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3E5F5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Save Changes', style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2)),
      ),
    );
  }
}

class CitizenHomeTab extends StatefulWidget {
  const CitizenHomeTab({super.key});
  @override
  State<CitizenHomeTab> createState() => _CitizenHomeTabState();
}

class _CitizenHomeTabState extends State<CitizenHomeTab> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  static const List<String> _searchOptions = ['Report Issue', 'Live Map', 'Garbage Dump', 'Potholes', 'My Score', 'Leaderboard', 'Water Leak', 'Traffic Issue'];

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
  void dispose() { _timer?.cancel(); _pageController.dispose(); super.dispose(); }

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
                  hintText: 'Search areas, issues, features...',
                  prefixIcon: const Icon(LucideIcons.search, color: AppTheme.primaryTeal),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5)),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Area Cleanliness Stats"))),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.darkTeal]), borderRadius: BorderRadius.circular(30)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(LucideIcons.leaf, color: Colors.white, size: 28), SizedBox(height: 10), Text('86%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text('Area Cleanliness', style: TextStyle(color: Colors.white70, fontSize: 12))]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(30)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(LucideIcons.award, color: Colors.white, size: 28), SizedBox(height: 10), Text('Nitin', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text('Top Citizen', style: TextStyle(color: Colors.white70, fontSize: 12))]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text('Critical Alerts 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    return _criticalAlertCard(context, doc['title'], doc['category'], [const Color(0xFFD32F2F), const Color(0xFF9A0007)]);
                  },
                );
              },
            )
          ),
          const SizedBox(height: 30),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Community Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyComplaintsScreen())), child: const Text('My Reports', style: TextStyle(color: AppTheme.primaryTeal)))]),
          const SizedBox(height: 10),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No reports submitted yet. Be the first!"));

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

  Widget _criticalAlertCard(BuildContext context, String title, String cat, List<Color> gradientColors) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenericDummyScreen(title: title))),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: const Text('CRITICAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [const Icon(LucideIcons.tag, size: 12, color: Colors.white70), const SizedBox(width: 4), Text(cat, style: const TextStyle(color: Colors.white70, fontSize: 12))])
            ],
          ),
        ),
      ),
    );
  }
}

class FeedPostWidget extends StatefulWidget {
  final QueryDocumentSnapshot document;
  const FeedPostWidget({super.key, required this.document});

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget> {
  void _upvote() {
    FirebaseFirestore.instance.collection('reports').doc(widget.document.id).update({'upvotes': FieldValue.increment(1)});
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.document.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'] ?? '';
    final upvotes = data['upvotes'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Image Viewer"))),
              child: Container(
                height: 150, width: double.infinity, 
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20), image: imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null), 
                child: imageUrl.isEmpty ? const Icon(LucideIcons.image, size: 50, color: Colors.grey) : null
              ),
            ),
            const SizedBox(height: 16),
            Text(data['title'] ?? 'No Title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(data['description'] ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  IconButton(icon: const Icon(LucideIcons.thumbsUp, color: AppTheme.primaryTeal), onPressed: _upvote), 
                  Text('$upvotes', style: const TextStyle(fontWeight: FontWeight.bold)), 
                  const SizedBox(width: 16), 
                  IconButton(icon: const Icon(LucideIcons.messageSquare, color: Colors.blueAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GenericDummyScreen(title: "Comments Section")))), 
                  const Text('0', style: TextStyle(fontWeight: FontWeight.bold))
                ]),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reported to Admins!'))),
                      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))), child: const Icon(LucideIcons.flag, size: 20, color: Colors.red)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}