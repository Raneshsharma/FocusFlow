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
import '../../providers/providers.dart';
import '../widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/focus',
    redirect: (context, state) async {
      // IMPORTANT: Wait for onboarding state to be initialized before making redirect decisions
      // This prevents the app from always showing onboarding on restart
      await ref.read(onboardingProvider.notifier).ensureInitialized();
      final onboardingState = ref.read(onboardingProvider);

      // Don't redirect while still loading (prevents flash of onboarding on every app start)
      if (onboardingState.isLoading) {
        return null;
      }

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
      GoRoute(
        path: '/404',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Page not found'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/focus'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/focus'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});