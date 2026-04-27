import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';
import 'providers.dart';

final appSettingsProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(() {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    return repo.getSettings() ?? AppSettings();
  }

  Future<void> _save(AppSettings settings) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.saveSettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> setDarkMode(bool value) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(isDarkMode: value));
  }

  Future<void> setSoundEnabled(bool value) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(soundEnabled: value));
  }

  Future<void> updatePomodoro(PomodoroTimerSettings pomodoro) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(pomodoro: pomodoro));
  }

  Future<void> updateNotifications(NotificationSettings notifications) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(notifications: notifications));
  }

  Future<void> updateDisplay(DisplaySettings display) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(display: display));
  }

  Future<void> clearAllData() async {
    await _save(AppSettings());
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final current = state.valueOrNull ?? AppSettings();
    await _save(current.copyWith(hasCompletedOnboarding: value));
  }
}

final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.isDarkMode ?? false;
});

final soundEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.soundEnabled ?? true;
});

final pomodoroSettingsProvider = Provider<PomodoroTimerSettings>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.pomodoro
      ?? PomodoroTimerSettings();
});

final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.notifications
      ?? NotificationSettings();
});

final displaySettingsProvider = Provider<DisplaySettings>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.display
      ?? DisplaySettings();
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light;
});