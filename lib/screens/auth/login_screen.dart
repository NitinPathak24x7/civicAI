import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// --- FIREBASE IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../theme/app_theme.dart';
import '../../widgets/interactive_mascot.dart';
import '../citizen/citizen_main.dart';
import '../admin/admin_main.dart';
import '../../main.dart';
import '../chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  String selectedRole = 'Citizen';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // --- AUTH STATE VARIABLES ---
  bool _isLogin = true;
  bool _isLoading = false;

  final List<GlobalKey<InteractiveMascotState>> _mascotKeys = List.generate(8, (index) => GlobalKey<InteractiveMascotState>());
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // ==========================================
  // FIREBASE AUTHENTICATION LOGIC
  // ==========================================

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }

      if (mounted) _navigate();

    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed.");
    } catch (e) {
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Google Sign-In (UPDATED FOR google_sign_in 7.0.0+)
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // v7.0.0+ breaking change: Must use singleton and initialize it first
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // v7.0.0+ breaking change: signIn() was renamed to authenticate()
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // v7.0.0+ breaking change: accessToken is no longer attached to googleAuth.
      // Fortunately, Firebase only needs the idToken to securely log you in!
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) _navigate();

    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Google Sign-In failed.");
    } catch (e) {
      _showError("An unexpected error occurred with Google Sign-In.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // UI BUILDER
  // ==========================================

  @override
  Widget build(BuildContext context) {
    bool isDark = isDarkModeNotifier.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: AppTheme.backgroundLight),
            ),
          ),

          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(left: -(_bgController.value * 600), top: 120, child: Row(children: List.generate(30, (i) => _bgIcon(LucideIcons.building, 90, isDark)))),
                  Positioned(left: -(_bgController.value * 1000), top: 350, child: Row(children: List.generate(40, (i) => _bgIcon(LucideIcons.treePine, 70, isDark)))),
                ],
              );
            },
          ),

          InteractiveMascot(key: _mascotKeys[0], color: Colors.green, initialX: 320, initialY: 80, size: 45),
          InteractiveMascot(key: _mascotKeys[1], color: AppTheme.primaryTeal, initialX: 350, initialY: 250, size: 50),
          InteractiveMascot(key: _mascotKeys[2], color: Colors.blueAccent, initialX: 30, initialY: 720, size: 70),
          InteractiveMascot(key: _mascotKeys[3], color: Colors.greenAccent, initialX: 20, initialY: 400, size: 40),
          InteractiveMascot(key: _mascotKeys[4], color: Colors.teal, initialX: 120, initialY: 680, size: 35),
          InteractiveMascot(key: _mascotKeys[5], color: Colors.lightGreen, initialX: 80, initialY: 150, size: 40),
          InteractiveMascot(key: _mascotKeys[6], color: AppTheme.primaryTeal, initialX: 250, initialY: 650, size: 55),
          InteractiveMascot(key: _mascotKeys[7], color: Colors.green, initialX: 200, initialY: 300, size: 30),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 120, width: 120,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]
                          ),
                          child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(LucideIcons.landmark, size: 60, color: AppTheme.primaryTeal)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('CivicAI', style: GoogleFonts.poppins(fontSize: 46, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                    Text('Smart Governance, Better Cities.', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                    const SizedBox(height: 40),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: _roleChip("Citizen", isDark)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _roleChip("Admin", isDark)),
                                ],
                              ),
                              const SizedBox(height: 30),

                              _inputField("Email Address", LucideIcons.mail, _emailController, isDark),
                              const SizedBox(height: 16),
                              _inputField("Password", LucideIcons.lock, _passController, isDark, isPass: true),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity, height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleEmailAuth,
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                  child: _isLoading
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(_isLogin ? "Login to Continue" : "Create Account", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 15),

                              SizedBox(
                                width: double.infinity, height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                  icon: const Icon(LucideIcons.chrome, size: 20),
                                  label: Text("Sign in with Google", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(_isLogin ? "Sign Up" : "Login", style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgIcon(IconData icon, double size, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Icon(icon, size: size, color: isDark ? Colors.white.withOpacity(0.08) : AppTheme.primaryTeal.withOpacity(0.15))
    );
  }

  Widget _inputField(String hint, IconData icon, TextEditingController c, bool isDark, {bool isPass = false}) {
    return TextField(
      controller: c, obscureText: isPass,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
      ),
    );
  }

  Widget _roleChip(String role, bool isDark) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : (isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.5))
        ),
        child: Center(
          child: Text(role, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87))
        ),
      ),
    );
  }

  void _navigate() {
    if (selectedRole == 'Citizen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CitizenMainApp()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminMainApp()),
      );
    }
  }
}
