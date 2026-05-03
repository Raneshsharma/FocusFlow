import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'welcome_screen.dart';
import 'energy_levels_screen.dart';
import 'time_zones_screen.dart';
import 'onboarding_energy_task_screen.dart';
import '../widgets/add_first_task_sheet.dart';
import '../providers/onboarding_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int _currentPage = 0;
  DateTime? _lastNavTime;
  static const _navCooldown = Duration(milliseconds: 500);

  void _goToPage(int page) {
    if (page < 0 || page > 3) return;

    // Debounce rapid taps
    final now = DateTime.now();
    if (_lastNavTime != null && now.difference(_lastNavTime!) < _navCooldown) {
      return;
    }
    _lastNavTime = now;

    setState(() {
      _currentPage = page;
    });
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddFirstTaskSheet(
          onComplete: () => _navigateToToday(),
          onSkip: () => _navigateToToday(),
        ),
      ),
    );
  }

  void _navigateToToday() {
    // Use context.go with replace to skip redirect checks
    context.go('/flow');
  }

  Future<void> _skipOnboarding() async {
    // Mark onboarding as complete in storage
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (!mounted) return;

    // Use pushReplacement to replace onboarding entirely
    // This avoids any redirect logic interference
    GoRouter.of(context).pushReplacement('/flow');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPage,
        children: [
          WelcomeScreen(
            onContinue: () => _goToPage(1),
            onSkip: _skipOnboarding,
          ),
          EnergyLevelsScreen(
            onContinue: () => _goToPage(2),
          ),
          TimeZonesScreen(
            onContinue: () => _goToPage(3),
          ),
          OnboardingEnergyTaskScreen(
            onContinue: _showAddTaskSheet,
          ),
        ],
      ),
    );
  }
}
