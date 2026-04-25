import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'welcome_screen.dart';
import 'energy_levels_screen.dart';
import 'time_zones_screen.dart';
import '../widgets/add_first_task_sheet.dart';
import '../providers/onboarding_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
    context.go('/focus');
  }

  Future<void> _skipOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      _navigateToToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          WelcomeScreen(
            onContinue: () => _goToPage(1),
            onSkip: _skipOnboarding,
          ),
          EnergyLevelsScreen(
            onContinue: () => _goToPage(2),
          ),
          TimeZonesScreen(
            onContinue: _showAddTaskSheet,
          ),
        ],
      ),
    );
  }
}