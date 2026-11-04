import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_companion/presentation/ai_companion_screen.dart';
import '../features/authentication/presentation/forgot_password_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/signup_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/health_timeline/presentation/health_timeline_screen.dart';
import '../features/medical_records/presentation/medical_records_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/permissions/presentation/permissions_screen.dart';
import '../features/profile/presentation/user_profile_setup_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/storage_selection/presentation/storage_selection_screen.dart';
import '../features/womens_health/presentation/womens_health_screen.dart';
import '../shared/widgets/main_shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    // Startup & Onboarding Flow
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Auth Flow
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Setup & Configuration Flow
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const UserProfileSetupScreen(),
    ),
    GoRoute(
      path: '/storage-selection',
      builder: (context, state) => const StorageSelectionScreen(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),

    // Women's Health Dedicated Route (Enabled for Females)
    GoRoute(
      path: '/womens-health',
      builder: (context, state) => const WomensHealthScreen(),
    ),

    // Dashboard alias redirect to Home tab
    GoRoute(
      path: '/dashboard',
      redirect: (context, state) => '/home',
    ),

    // Main App Shell with 5 Persistent Bottom Navigation Tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Tab 2: AI Companion
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai-companion',
              builder: (context, state) => const AiCompanionScreen(),
            ),
          ],
        ),

        // Tab 3: My Health (Health Timeline)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              builder: (context, state) => const HealthTimelineScreen(),
            ),
          ],
        ),

        // Tab 4: Medical Records
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/medical-records',
              builder: (context, state) => const MedicalRecordsScreen(),
            ),
          ],
        ),

        // Tab 5: Profile & Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

