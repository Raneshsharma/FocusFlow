import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_settings.dart';
import '../../../providers/providers.dart';

class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;

  const OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final settingsRepo = await _ref.read(settingsRepositoryProvider.future);
    final settings = settingsRepo.getSettings();
    if (settings != null) {
      state = state.copyWith(
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
      );
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage() {
    if (state.currentPage < 3) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  Future<void> completeOnboarding() async {
    final settingsRepo = await _ref.read(settingsRepositoryProvider.future);
    final settings = settingsRepo.getSettings() ?? AppSettings();
    settings.hasCompletedOnboarding = true;
    await settingsRepo.saveSettings(settings);
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<void> resetOnboarding() async {
    final settingsRepo = await _ref.read(settingsRepositoryProvider.future);
    final settings = settingsRepo.getSettings() ?? AppSettings();
    settings.hasCompletedOnboarding = false;
    await settingsRepo.saveSettings(settings);
    state = state.copyWith(hasCompletedOnboarding: false, currentPage: 0);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});