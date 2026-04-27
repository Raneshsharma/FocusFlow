import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/focus/screens/focus_screen.dart';
import '../../features/flow/screens/flow_screen.dart';
import '../../features/rest/screens/rest_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/library/screens/weekly_insights_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/onboarding/screens/onboarding_flow.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../widgets/main_shell.dart';

// Router state provider - tracks if onboarding is complete
final routerInitializedProvider = StateProvider<bool>((ref) => false);

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch onboarding state
  final onboardingState = ref.watch(onboardingProvider);

  // Mark as initialized once we've loaded state
  if (!ref.read(routerInitializedProvider) && onboardingState.hasCompletedOnboarding == false) {
    // Check if settings have been loaded (not just default)
    Future.microtask(() {
      ref.read(routerInitializedProvider.notifier).state = true;
    });
  }

  return GoRouter(
    initialLocation: onboardingState.hasCompletedOnboarding ? '/focus' : '/onboarding',
    redirect: (context, state) {
      // Handle redirect based on onboarding state
      final isOnboarding = state.uri.path == '/onboarding';

      // If onboarding not completed and we're not on onboarding page, redirect to onboarding
      if (!onboardingState.hasCompletedOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      // If onboarding completed and we're on onboarding page, redirect to focus
      if (onboardingState.hasCompletedOnboarding && isOnboarding) {
        return '/focus';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/focus',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FocusScreen(),
            ),
          ),
          GoRoute(
            path: '/flow',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FlowScreen(),
            ),
          ),
          GoRoute(
            path: '/rest',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RestScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/insights',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WeeklyInsightsScreen(),
        ),
      ),
    ],
  );
});