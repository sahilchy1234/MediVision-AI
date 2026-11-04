import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _skipSplash() {
    _timer?.cancel();
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: InkWell(
        onTap: _skipSplash,
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Minimal clinical brand mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shield_outlined,
                        size: 38,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Brand name with editorial typography
                  Text(
                    'MediVision AI',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Clinical Tagline
                  Text(
                    'Intelligent Medical History & Clinical Companion',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondarySage,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Privacy standard tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Zero-Knowledge On-Device Encryption',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
