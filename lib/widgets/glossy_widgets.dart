import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlossyCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlossyCard({super.key, required this.child, this.width, this.height, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width, height: height, padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    );
  }
}