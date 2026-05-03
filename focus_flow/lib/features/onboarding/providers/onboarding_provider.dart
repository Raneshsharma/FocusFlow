import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_settings.dart';
import '../../../providers/providers.dart';

class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;
  final bool isLoading;

  const OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
    this.isLoading = true, // Start with loading = true
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;
  bool _initialized = false;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final settingsRepo = await _ref.read(settingsRepositoryProvider.future);
      final settings = settingsRepo.getSettings();
      state = state.copyWith(
        hasCompletedOnboarding: settings?.hasCompletedOnboarding ?? false,
        isLoading: false,
      );
    } catch (e) {
      // If settings can't be loaded, assume not completed (safer default)
      state = state.copyWith(
        hasCompletedOnboarding: false,
        isLoading: false,
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