import 'package:flutter/material.dart';

/// Official Mentholatum Corporate Logo
///
/// Features:
/// - Crisp rendering from asset bundle
/// - Configurable height
/// - Semantic accessibility label
/// - Graceful fallback brandmark if asset is missing or loading in test environment
class MentholatumLogo extends StatelessWidget {
  final double height;
  final bool showTagline;

  const MentholatumLogo({
    super.key,
    this.height = 32.0,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mentholatum Logo',
      child: Image.asset(
        'assets/images/mentholatum_logo.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback vector brandmark: red dots cluster + bold Mentholatum typography
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: height * 0.75,
                height: height * 0.75,
                decoration: const BoxDecoration(
                  color: Color(0xFFE62134),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.bubble_chart,
                    size: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Mentholatum',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: height * 0.55,
                  color: const Color(0xFF005CA8),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
