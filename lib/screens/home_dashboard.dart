import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120), // Kept space so content doesn't hide behind nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Updated Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'CivicAI', // Updated Text
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                        // Custom Logo inserted here
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(height: 48, width: 48, color: Colors.grey.shade300, child: const Icon(Icons.error)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        _buildTab('Nearby', true),
                        const SizedBox(width: 24),
                        _buildTab('Urgent', false),
                        const SizedBox(width: 24),
                        _buildTab('Resolved', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Cards
                  SizedBox(
                    height: 400,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildLargeIssueCard('Open Pothole', 'High Severity', 'Raj Nagar, Sector 4', LucideIcons.alertOctagon),
                        const SizedBox(width: 20),
                        _buildLargeIssueCard('Garbage Dump', 'Medium Severity', 'Indirapuram', LucideIcons.trash2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Fixed Bottom Navigation (Lowered to sit just above system nav)
            Positioned(
              bottom: 12, // Reduced from 24 to sit lower
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem('Home', LucideIcons.home, true),
                    _buildNavItem('Map', LucideIcons.map, false),
                    // Floating Action Button integrated into Nav
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.plus, color: Colors.white),
                    ),
                    _buildNavItem('Feed', LucideIcons.layoutList, false),
                    _buildNavItem('Profile', LucideIcons.user, false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(height: 6, width: 6, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
        ]
      ],
    );
  }

  Widget _buildLargeIssueCard(String title, String subtitle, String location, IconData icon) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                const SizedBox(height: 8),
                Text(location, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textDark,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppTheme.primaryTeal : Colors.grey.shade400, size: 24),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(height: 4, width: 4, decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}