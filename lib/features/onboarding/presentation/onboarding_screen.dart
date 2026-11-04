import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Your Health Timeline',
      description:
          'Organize all lab reports, biometric feeds, and clinical visits into a unified, chronological history.',
      icon: Icons.timeline_rounded,
      accentColor: AppColors.secondary,
    ),
    _OnboardingData(
      title: 'Clinical Consultation',
      description:
          'Clarify diagnostic findings and prepare structured questions for your next doctor appointment.',
      icon: Icons.forum_outlined,
      accentColor: AppColors.primary,
    ),
    _OnboardingData(
      title: 'Private by Design',
      description:
          'Client-side zero-knowledge encryption ensures your health records remain completely under your control.',
      icon: Icons.shield_outlined,
      accentColor: AppColors.accentEmerald,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _onSkip,
              child: Text(
                'Skip',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: page.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                page.icon,
                                size: 36,
                                color: page.accentColor,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: AppTypography.displayMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators & Next Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      PrimaryButton(
                        label: isLastPage ? 'Get Started' : 'Continue',
                        onPressed: _onNext,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
