import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class InteractiveMascot extends StatefulWidget {
  final Color color;
  final double initialX;
  final double initialY;
  final double size;

  const InteractiveMascot({
    super.key, 
    required this.color, 
    required this.initialX, 
    required this.initialY, 
    required this.size
  });

  @override
  State<InteractiveMascot> createState() => InteractiveMascotState();
}

class InteractiveMascotState extends State<InteractiveMascot> {
  late double _currentX;
  late double _currentY;
  Timer? _timer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _currentX = widget.initialX;
    _currentY = widget.initialY;
    
    // Start wandering slightly after rendering
    Future.delayed(const Duration(milliseconds: 100), _startWandering);
  }

  void _startWandering() {
    // Pick a new random spot every 3 to 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          // Jump/Float randomly by up to 200 pixels in any direction
          double dx = (_random.nextDouble() - 0.5) * 300;
          double dy = (_random.nextDouble() - 0.5) * 300;
          
          // Clamp to keep them roughly on screen (0 to 400 wide, 0 to 900 high)
          _currentX = (_currentX + dx).clamp(-50.0, 400.0);
          _currentY = (_currentY + dy).clamp(-50.0, 900.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateEyes(Offset touchPosition) {
    // Optional: add touch interaction logic here if desired later
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOutSine, // Smooth, slow floating movement
      left: _currentX,
      top: _currentY,
      child: Container(
        width: widget.size, 
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2), 
          shape: BoxShape.circle, 
          border: Border.all(color: widget.color.withOpacity(0.5), width: 2)
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.eco, color: widget.color.withOpacity(0.8), size: widget.size * 0.5),
          ],
        ),
      ),
    );
  }
}