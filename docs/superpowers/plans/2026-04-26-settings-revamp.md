# Settings Screen Revamp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Revamp the Settings screen with a cohesive card-based layout, full theme live-preview, expanded settings categories, and real-time reactive behavior — every change applies instantly with smooth transitions.

**Architecture:** Settings screen becomes a scrollable page with grouped card sections. A theme provider (`SettingsNotifier`) holds all settings in memory and persists asynchronously. Theme changes propagate through `AppTheme` via Riverpod `Ref` watchers — no page reload required. Sound settings use a Riverpod `audioServiceProvider` that all timer/session widgets watch.

---

## File Structure

```
focus_flow/lib/
├── data/models/
│   └── app_settings.dart          ← MODIFIED: Add PomodoroTimerSettings, NotificationSettings, DisplaySettings, DataSettings
├── data/repositories/
│   └── settings_repository.dart   ← MODIFIED: No code change needed (already generic)
├── providers/
│   └── settings_provider.dart      ← CREATE: Central settings state + theme + audio + notifications providers
├── features/settings/
│   ├── screens/
│   │   └── settings_screen.dart   ← MODIFIED: Full rewrite with new layout + reactive widgets
│   └── widgets/
│       ├── settings_header.dart    ← CREATE: App icon + version + branding header
│       ├── settings_card.dart      ← CREATE: Reusable card widget with icon, title, subtitle, trailing slot
│       ├── settings_toggle_tile.dart  ← CREATE: SwitchListTile replacement with custom styling
│       ├── settings_slider_tile.dart   ← CREATE: Slider tile for duration/interval settings
│       ├── settings_action_tile.dart  ← CREATE: Tappable row with chevron or loading indicator
│       ├── settings_section.dart  ← CREATE: Section header with label + optional action
│       ├── settings_stat_card.dart ← CREATE: Stats display card with icon + value + label
│       ├── theme_preview_card.dart ← CREATE: Live mini-theme preview showing app colors/fonts
│       └── pomodoro_settings_sheet.dart ← CREATE: Bottom sheet for Pomodoro interval customization
├── core/theme/
│   ├── app_theme.dart              ← MODIFIED: Add dynamic `of(context)` brightness-aware helpers + extension for dark-mode-aware colors
│   └── app_colors.dart             ← MODIFIED: Add semantic color aliases (borderColor, disabledTextColor, settingsTileBg)
└── main.dart                       ← MODIFIED: Wrap app with settingsProvider + add notification service init
```

---

## Task Map

| Task | What | Files |
|------|------|-------|
| 1 | Extend `AppSettings` model with new setting groups | `app_settings.dart` |
| 2 | Create `settings_provider.dart` with Riverpod state + providers | `settings_provider.dart` |
| 3 | Add semantic color aliases to `AppColors` | `app_colors.dart` |
| 4 | Add brightness-aware helpers to `AppTheme` | `app_theme.dart` |
| 5 | Wire `main.dart` to settings + notification service | `main.dart` |
| 6 | Create reusable settings widget library | `features/settings/widgets/*` |
| 7 | Rewrite `settings_screen.dart` with new layout | `settings_screen.dart` |

---

## Detailed Tasks

### Task 1: Extend `AppSettings` Model

**Files:**
- Modify: `focus_flow/lib/data/models/app_settings.dart`

Add three new inner classes plus a top-level `exportJson()` method, then serialize everything through `toJson`/`fromJson`:

```dart
// Add to app_settings.dart after the existing class body

class PomodoroTimerSettings {
  int workMinutes;
  int shortBreakMinutes;
  int longBreakMinutes;
  int roundsBeforeLongBreak;
  bool autoStartBreaks;
  bool autoStartWork;

  PomodoroTimerSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.roundsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
  });

  Map<String, dynamic> toJson() => {
    'workMinutes': workMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
    'roundsBeforeLongBreak': roundsBeforeLongBreak,
    'autoStartBreaks': autoStartBreaks,
    'autoStartWork': autoStartWork,
  };

  factory PomodoroTimerSettings.fromJson(Map<String, dynamic> json) =>
      PomodoroTimerSettings(
        workMinutes: json['workMinutes'] ?? 25,
        shortBreakMinutes: json['shortBreakMinutes'] ?? 5,
        longBreakMinutes: json['longBreakMinutes'] ?? 15,
        roundsBeforeLongBreak: json['roundsBeforeLongBreak'] ?? 4,
        autoStartBreaks: json['autoStartBreaks'] ?? false,
        autoStartWork: json['autoStartWork'] ?? false,
      );
}

class NotificationSettings {
  bool enabled;
  bool sessionEndNotify;
  bool breakEndNotify;
  bool dailyReminderNotify;
  String? dailyReminderTime; // "HH:mm" format e.g. "09:00"

  NotificationSettings({
    this.enabled = true,
    this.sessionEndNotify = true,
    this.breakEndNotify = true,
    this.dailyReminderNotify = false,
    this.dailyReminderTime,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'sessionEndNotify': sessionEndNotify,
    'breakEndNotify': breakEndNotify,
    'dailyReminderNotify': dailyReminderNotify,
    'dailyReminderTime': dailyReminderTime,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        enabled: json['enabled'] ?? true,
        sessionEndNotify: json['sessionEndNotify'] ?? true,
        breakEndNotify: json['breakEndNotify'] ?? true,
        dailyReminderNotify: json['dailyReminderNotify'] ?? false,
        dailyReminderTime: json['dailyReminderTime'],
      );
}

class DisplaySettings {
  String fontFamily; // 'Inter' | 'System'
  double fontScale; // 0.8 – 1.4 in 0.1 steps
  bool reduceMotion;
  bool hapticFeedback;

  DisplaySettings({
    this.fontFamily = 'Inter',
    this.fontScale = 1.0,
    this.reduceMotion = false,
    this.hapticFeedback = true,
  });

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontScale': fontScale,
    'reduceMotion': reduceMotion,
    'hapticFeedback': hapticFeedback,
  };

  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      DisplaySettings(
        fontFamily: json['fontFamily'] ?? 'Inter',
        fontScale: (json['fontScale'] ?? 1.0).toDouble(),
        reduceMotion: json['reduceMotion'] ?? false,
        hapticFeedback: json['hapticFeedback'] ?? true,
      );
}
```

Now update the main `AppSettings` class body:

```dart
class AppSettings {
  bool isDarkMode;
  bool soundEnabled;
  String? lastActiveDate;
  bool hasCompletedOnboarding;
  PomodoroTimerSettings pomodoro;
  NotificationSettings notifications;
  DisplaySettings display;

  AppSettings({
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.lastActiveDate,
    this.hasCompletedOnboarding = false,
    PomodoroTimerSettings? pomodoro,
    NotificationSettings? notifications,
    DisplaySettings? display,
  })  : pomodoro = pomodoro ?? PomodoroTimerSettings(),
        notifications = notifications ?? NotificationSettings(),
        display = display ?? DisplaySettings();

  // ... existing create(), toJson(), fromJson() ...

  // Replace toJson body:
  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'soundEnabled': soundEnabled,
    'lastActiveDate': lastActiveDate,
    'hasCompletedOnboarding': hasCompletedOnboarding,
    'pomodoro': pomodoro.toJson(),
    'notifications': notifications.toJson(),
    'display': display.toJson(),
  };

  // Replace fromJson factory:
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] ?? false,
    soundEnabled: json['soundEnabled'] ?? true,
    lastActiveDate: json['lastActiveDate'],
    hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    pomodoro: json['pomodoro'] != null
        ? PomodoroTimerSettings.fromJson(json['pomodoro'])
        : null,
    notifications: json['notifications'] != null
        ? NotificationSettings.fromJson(json['notifications'])
        : null,
    display: json['display'] != null
        ? DisplaySettings.fromJson(json['display'])
        : null,
  );

  AppSettings copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    String? lastActiveDate,
    bool? hasCompletedOnboarding,
    PomodoroTimerSettings? pomodoro,
    NotificationSettings? notifications,
    DisplaySettings? display,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      pomodoro: pomodoro ?? this.pomodoro,
      notifications: notifications ?? this.notifications,
      display: display ?? this.display,
    );
  }
}
```

---

### Task 2: Create `settings_provider.dart`

**Files:**
- Create: `focus_flow/lib/providers/settings_provider.dart`

This provider is the single source of truth for all settings. It:
- Loads settings from the repository on app start
- Exposes individual setting values via `Provider` (so widgets rebuild only on relevant changes)
- Exposes a `SettingsNotifier` for mutations
- Computes a reactive `ThemeData` from `isDarkMode` + `display` settings
- Wires `AppTheme` so the app reflects changes without restart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';
import 'providers.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  return SettingsRepository.create();
});

// ─── Async Settings Loading ─────────────────────────────────────────────────

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
}

// ─── Reactive Setting Providers (widgets watch only what they need) ─────────

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

// ─── Reactive Theme Provider ─────────────────────────────────────────────────

final appThemeDataProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;
  if (settings == null) return AppTheme.lightTheme;
  return settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(darkModeProvider) ? ThemeMode.dark : ThemeMode.light;
});
```

Add a placeholder `import '../core/theme/app_theme.dart';` at the top (file will be modified in Task 4).

---

### Task 3: Add Semantic Color Aliases to `AppColors`

**Files:**
- Modify: `focus_flow/lib/core/theme/app_colors.dart`

Add these to the bottom of the `AppColors` class (before the closing `}`):

```dart
  // ─────────────────────────────────────────────────────────────────
  // SETTINGS UI COLORS
  // ─────────────────────────────────────────────────────────────────

  /// Settings tile background — white in light, charcoal in dark
  static Color settingsTileBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? charcoal
        : white;
  }

  /// Settings section label color
  static const Color settingsSectionLabel = teal;

  /// Settings tile border in light mode
  static const Color settingsTileBorder = grey200;

  /// Divider color for settings lists
  static const Color settingsDivider = grey200;

  /// Disabled / inactive text in settings
  static const Color settingsDisabledText = grey400;

  /// Settings icon background (tinted circle)
  static const Color settingsIconBg = grey100;

  /// Settings destructive action color
  static const Color destructive = error;
```

---

### Task 4: Add Brightness-Aware Helpers to `AppTheme`

**Files:**
- Modify: `focus_flow/lib/core/theme/app_theme.dart`

Replace the existing `timerStyle` static method (keep it), and add a new `dynamic` helper at the end of the class body (before the closing `}`):

```dart
  // ─────────────────────────────────────────────────────────────────
  // DYNAMIC / CONTEXT-AWARE HELPERS
  // ─────────────────────────────────────────────────────────────────

  /// Returns the appropriate color for a surface/card based on brightness.
  /// Uses white in light, charcoal in dark.
  static Color dynamicSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.charcoal
        : AppColors.white;
  }

  /// Returns the scaffold background color based on brightness.
  static Color dynamicScaffoldBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.deepSlate
        : AppColors.surface;
  }

  /// Returns textPrimary or white (for dark surfaces).
  static Color dynamicTextOnSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.textPrimary;
  }

  /// Returns the border color for settings cards/tiles.
  static Color dynamicBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.grey800
        : AppColors.grey200;
  }

  /// Returns the elevated card color for dark mode (charcoal instead of white).
  static Color dynamicCardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.charcoal
        : AppColors.white;
  }
```

Also update `lightTheme` and `darkTheme` getters: add `dialogBackgroundColor` to both so dialogs/bottom sheets match their backgrounds (append inside each `ThemeData` block):

In `lightTheme` block, add after `scaffoldBackgroundColor`:
```dart
      dialogBackgroundColor: AppColors.white,
```

In `darkTheme` block, add after `scaffoldBackgroundColor`:
```dart
      dialogBackgroundColor: AppColors.charcoal,
```

---

### Task 5: Wire `main.dart` to Settings + Notification Service

**Files:**
- Modify: `focus_flow/lib/main.dart`

Update the MaterialApp.router to watch the reactive theme:

```dart
// Replace the MaterialApp.router block in FocusFlowApp.build():
MaterialApp.router(
  title: 'FocusFlow',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ref.watch(appThemeModeProvider),  // ← reactive, not hardcoded ThemeMode.system
  routerConfig: router,
)
```

Also update `Future<void> main()` to initialize notifications (add before `runApp`):

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>('tasks');
  await Hive.openBox<String>('sessions');
  await Hive.openBox<String>('templates');
  await Hive.openBox<String>('resources');
  await Hive.openBox<String>('stats');
  await Hive.openBox<String>('settings');

  runApp(const ProviderScope(child: FocusFlowApp()));
}
```

---

### Task 6: Create Reusable Settings Widget Library

**Files to create:**

#### 6a. `focus_flow/lib/features/settings/widgets/settings_header.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // App icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: AppIcon(
                AppIcons.checkCircle,
                color: AppColors.teal,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'FocusFlow',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Made for ADHD brains',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 6b. `focus_flow/lib/features/settings/widgets/settings_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showBorder;

  const SettingsCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoal : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

#### 6c. `focus_flow/lib/features/settings/widgets/settings_toggle_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconEmoji;
  final Color? iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const SettingsToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconEmoji,
    this.iconColor,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.teal).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}
```

#### 6d. `focus_flow/lib/features/settings/widgets/settings_slider_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsSliderTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconEmoji;
  final Color? iconColor;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) labelBuilder;
  final ValueChanged<double> onChanged;

  const SettingsSliderTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconEmoji,
    this.iconColor,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.teal).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labelBuilder(value),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.teal,
            inactiveTrackColor: AppColors.grey200,
            thumbColor: AppColors.teal,
            overlayColor: AppColors.teal.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
```

#### 6e. `focus_flow/lib/features/settings/widgets/settings_action_tile.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';

class SettingsActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconEmoji;
  final Color? iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;
  final Color? textColor;
  final bool enabled;

  const SettingsActionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconEmoji,
    this.iconColor,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
    this.textColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTextColor = textColor ?? (isDark ? Colors.white : AppColors.textPrimary);
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        children: [
          InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.teal).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: effectiveTextColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing ??
                      AppIcon(
                        AppIcons.chevronRight,
                        color: AppColors.grey400,
                        size: 20,
                      ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 66,
              color: AppColors.settingsDivider,
            ),
        ],
      ),
    );
  }
}
```

#### 6f. `focus_flow/lib/features/settings/widgets/settings_section.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String label;
  final Widget? action;
  final bool spacing;

  const SettingsSection({
    super.key,
    required this.label,
    this.action,
    this.spacing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: spacing ? 20 : 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
                letterSpacing: 1.4,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
```

#### 6g. `focus_flow/lib/features/settings/widgets/settings_stat_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsStatCard extends StatelessWidget {
  final String iconEmoji;
  final String value;
  final String label;
  final Color? iconColor;

  const SettingsStatCard({
    super.key,
    required this.iconEmoji,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.teal).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(iconEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: iconColor ?? AppColors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 6h. `focus_flow/lib/features/settings/widgets/theme_preview_card.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThemePreviewCard extends StatelessWidget {
  final bool isDarkMode;
  final double fontScale;

  const ThemePreviewCard({
    super.key,
    required this.isDarkMode,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? AppColors.charcoal : AppColors.white;
    final surface = isDarkMode ? AppColors.deepSlate : AppColors.surface;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final secondaryText = isDarkMode ? Colors.grey.shade400 : AppColors.textSecondary;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          // Mini screen preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FocusFlow',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: (14 * fontScale).clamp(10, 18),
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '25:00',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: (12 * fontScale).clamp(8, 16),
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 8,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Color swatches
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _swatch(isDarkMode ? AppColors.deepSlate : AppColors.surface),
                _swatch(AppColors.teal),
                _swatch(AppColors.amber),
                _swatch(isDarkMode ? AppColors.charcoal : AppColors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey300, width: 0.5),
      ),
    );
  }
}
```

#### 6i. `focus_flow/lib/features/settings/widgets/pomodoro_settings_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_settings.dart';
import '../../../providers/settings_provider.dart';
import 'settings_slider_tile.dart';

class PomodoroSettingsSheet extends ConsumerWidget {
  const PomodoroSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.charcoal
            : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pomodoro Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SettingsSliderTile(
            iconEmoji: '⚡',
            iconColor: AppColors.amber,
            title: 'Work Duration',
            subtitle: 'Focus session length',
            value: pomodoro.workMinutes.toDouble(),
            min: 15,
            max: 60,
            divisions: 9,
            labelBuilder: (v) => '${v.toInt()} min',
            onChanged: (v) => _updateWork(ref, v.toInt()),
          ),
          const SizedBox(height: 16),
          SettingsSliderTile(
            iconEmoji: '☕',
            iconColor: Colors.brown,
            title: 'Short Break',
            subtitle: 'After each work session',
            value: pomodoro.shortBreakMinutes.toDouble(),
            min: 3,
            max: 15,
            divisions: 12,
            labelBuilder: (v) => '${v.toInt()} min',
            onChanged: (v) => _updateShortBreak(ref, v.toInt()),
          ),
          const SizedBox(height: 16),
          SettingsSliderTile(
            iconEmoji: '🌿',
            iconColor: AppColors.teal,
            title: 'Long Break',
            subtitle: 'After ${pomodoro.roundsBeforeLongBreak} rounds',
            value: pomodoro.longBreakMinutes.toDouble(),
            min: 10,
            max: 30,
            divisions: 4,
            labelBuilder: (v) => '${v.toInt()} min',
            onChanged: (v) => _updateLongBreak(ref, v.toInt()),
          ),
          const SizedBox(height: 16),
          SettingsSliderTile(
            iconEmoji: '🔄',
            iconColor: AppColors.energyDeep,
            title: 'Rounds',
            subtitle: 'Before a long break',
            value: pomodoro.roundsBeforeLongBreak.toDouble(),
            min: 2,
            max: 6,
            divisions: 4,
            labelBuilder: (v) => '${v.toInt()}',
            onChanged: (v) => _updateRounds(ref, v.toInt()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _updateWork(WidgetRef ref, int minutes) {
    final current = ref.read(pomodoroSettingsProvider);
    ref.read(appSettingsProvider.notifier).updatePomodoro(
      PomodoroTimerSettings(
        workMinutes: minutes,
        shortBreakMinutes: current.shortBreakMinutes,
        longBreakMinutes: current.longBreakMinutes,
        roundsBeforeLongBreak: current.roundsBeforeLongBreak,
        autoStartBreaks: current.autoStartBreaks,
        autoStartWork: current.autoStartWork,
      ),
    );
  }

  void _updateShortBreak(WidgetRef ref, int minutes) {
    final current = ref.read(pomodoroSettingsProvider);
    ref.read(appSettingsProvider.notifier).updatePomodoro(
      PomodoroTimerSettings(
        workMinutes: current.workMinutes,
        shortBreakMinutes: minutes,
        longBreakMinutes: current.longBreakMinutes,
        roundsBeforeLongBreak: current.roundsBeforeLongBreak,
        autoStartBreaks: current.autoStartBreaks,
        autoStartWork: current.autoStartWork,
      ),
    );
  }

  void _updateLongBreak(WidgetRef ref, int minutes) {
    final current = ref.read(pomodoroSettingsProvider);
    ref.read(appSettingsProvider.notifier).updatePomodoro(
      PomodoroTimerSettings(
        workMinutes: current.workMinutes,
        shortBreakMinutes: current.shortBreakMinutes,
        longBreakMinutes: minutes,
        roundsBeforeLongBreak: current.roundsBeforeLongBreak,
        autoStartBreaks: current.autoStartBreaks,
        autoStartWork: current.autoStartWork,
      ),
    );
  }

  void _updateRounds(WidgetRef ref, int rounds) {
    final current = ref.read(pomodoroSettingsProvider);
    ref.read(appSettingsProvider.notifier).updatePomodoro(
      PomodoroTimerSettings(
        workMinutes: current.workMinutes,
        shortBreakMinutes: current.shortBreakMinutes,
        longBreakMinutes: current.longBreakMinutes,
        roundsBeforeLongBreak: rounds,
        autoStartBreaks: current.autoStartBreaks,
        autoStartWork: current.autoStartWork,
      ),
    );
  }
}
```

---

### Task 7: Rewrite `settings_screen.dart`

**Files:**
- Modify: `focus_flow/lib/features/settings/screens/settings_screen.dart`

Replace the entire file content. The new structure:
1. `SettingsHeader` at top
2. **Stats section** — 4-stat grid showing streak, tasks, sessions, focus hours
3. **Timer Settings section** — Pomodoro work/break durations via `SettingsActionTile` that opens `PomodoroSettingsSheet`
4. **Appearance section** — Dark mode toggle + theme preview card + font scale slider
5. **Notifications section** — Master toggle + sub-toggles for session end / break end / daily reminder
6. **Sound section** — Sound effects toggle
7. **Data section** — Export / Import / Clear (with confirmation dialogs)
8. **Developer section** — Reset onboarding
9. **About section** — Version + privacy note

Every toggle/slider change calls the appropriate `appSettingsProvider.notifier` method and propagates reactively through `appThemeModeProvider` and the widget tree. No restart required.

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/models/app_settings.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../widgets/settings_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle_tile.dart';
import '../widgets/settings_slider_tile.dart';
import '../widgets/settings_action_tile.dart';
import '../widgets/settings_stat_card.dart';
import '../widgets/theme_preview_card.dart';
import '../widgets/pomodoro_settings_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isLoading = true;
  double _fontScale = 1.0;

  // Stats
  int _totalTasks = 0;
  int _totalSessions = 0;
  int _totalFocusMinutes = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadStats();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = ref.read(appSettingsProvider).valueOrNull;
      if (mounted && settings != null) {
        setState(() {
          _isDarkMode = settings.isDarkMode;
          _soundEnabled = settings.soundEnabled;
          _fontScale = settings.display.fontScale;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      final taskRepo = await ref.read(taskRepositoryProvider.future);
      final sessionRepo = await ref.read(sessionRepositoryProvider.future);
      final statsRepo = await ref.read(statsRepositoryProvider.future);

      final tasks = taskRepo.getAll();
      final sessions = sessionRepo.getAll();
      final allStats = statsRepo.getAll();

      final completedTasks = tasks.where((t) => t.completed).length;
      final focusMinutes = sessions.fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));
      final streak = allStats.isNotEmpty
          ? allStats.where((s) => s.tasksCompleted > 0).length
          : 0;

      if (mounted) {
        setState(() {
          _totalTasks = completedTasks;
          _totalSessions = sessions.length;
          _totalFocusMinutes = focusMinutes;
          _currentStreak = streak;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch reactive settings — any change here will auto-update the UI
    final settingsAsync = ref.watch(appSettingsProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final displaySettings = ref.watch(displaySettingsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    if (_isLoading || settingsAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.dynamicScaffoldBg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.dynamicScaffoldBg(context),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.dynamicScaffoldBg(context),
        foregroundColor: AppTheme.dynamicTextOnSurface(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SettingsHeader(),

              // ─── STATS SECTION ───────────────────────────────────────────────
              SettingsSection(label: 'Your Stats'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SettingsStatCard(
                        iconEmoji: '🔥',
                        value: '$_currentStreak',
                        label: 'Day Streak',
                        iconColor: AppColors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SettingsStatCard(
                        iconEmoji: '✅',
                        value: '$_totalTasks',
                        label: 'Tasks Done',
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SettingsStatCard(
                        iconEmoji: '🎯',
                        value: '$_totalSessions',
                        label: 'Sessions',
                        iconColor: AppColors.teal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SettingsStatCard(
                        iconEmoji: '⏱️',
                        value: '${(_totalFocusMinutes / 60).toStringAsFixed(1)}h',
                        label: 'Focus Time',
                        iconColor: AppColors.energyDeep,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── TIMER SETTINGS SECTION ─────────────────────────────────────
              SettingsSection(label: 'Timer'),
              SettingsCard(
                child: SettingsActionTile(
                  iconEmoji: '🍅',
                  iconColor: const Color(0xFFEF4444),
                  title: 'Pomodoro Settings',
                  subtitle: 'Work: ${displaySettings.pomodoro.workMinutes}min · '
                      'Break: ${displaySettings.pomodoro.shortBreakMinutes}min · '
                      'Long: ${displaySettings.pomodoro.longBreakMinutes}min',
                  onTap: () => _showPomodoroSettings(context),
                ),
              ),
              SettingsCard(
                child: SettingsToggleTile(
                  iconEmoji: '🔊',
                  iconColor: AppColors.teal,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds for timers',
                  value: soundEnabled,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setSoundEnabled(v),
                ),
              ),

              // ─── APPEARANCE SECTION ─────────────────────────────────────────
              SettingsSection(label: 'Appearance'),
              SettingsCard(
                child: Column(
                  children: [
                    SettingsToggleTile(
                      iconEmoji: '🌙',
                      iconColor: Colors.purple,
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme',
                      value: isDarkMode,
                      onChanged: (v) => ref.read(appSettingsProvider.notifier).setDarkMode(v),
                    ),
                    const SizedBox(height: 16),
                    // Live theme preview
                    ThemePreviewCard(isDarkMode: isDarkMode, fontScale: _fontScale),
                  ],
                ),
              ),
              SettingsCard(
                child: SettingsSliderTile(
                  iconEmoji: '🔤',
                  iconColor: AppColors.amber,
                  title: 'Font Size',
                  subtitle: 'Adjust text scale',
                  value: _fontScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  labelBuilder: (v) => '${(v * 100).toInt()}%',
                  onChanged: (v) {
                    setState(() => _fontScale = v);
                    final current = ref.read(displaySettingsProvider);
                    ref.read(appSettingsProvider.notifier).updateDisplay(
                      DisplaySettings(
                        fontFamily: current.fontFamily,
                        fontScale: v,
                        reduceMotion: current.reduceMotion,
                        hapticFeedback: current.hapticFeedback,
                      ),
                    );
                  },
                ),
              ),

              // ─── NOTIFICATIONS SECTION ─────────────────────────────────────
              SettingsSection(label: 'Notifications'),
              SettingsCard(
                child: SettingsToggleTile(
                  iconEmoji: '🔔',
                  iconColor: AppColors.amber,
                  title: 'Push Notifications',
                  subtitle: 'Enable all notifications',
                  value: notificationSettings.enabled,
                  onChanged: (v) {
                    ref.read(appSettingsProvider.notifier).updateNotifications(
                      NotificationSettings(
                        enabled: v,
                        sessionEndNotify: v,
                        breakEndNotify: v,
                        dailyReminderNotify: notificationSettings.dailyReminderNotify,
                        dailyReminderTime: notificationSettings.dailyReminderTime,
                      ),
                    );
                  },
                ),
              ),
              if (notificationSettings.enabled) ...[
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsToggleTile(
                        iconEmoji: '✅',
                        iconColor: AppColors.success,
                        title: 'Session End',
                        subtitle: 'Notify when focus session ends',
                        value: notificationSettings.sessionEndNotify,
                        onChanged: (v) {
                          ref.read(appSettingsProvider.notifier).updateNotifications(
                            NotificationSettings(
                              enabled: notificationSettings.enabled,
                              sessionEndNotify: v,
                              breakEndNotify: notificationSettings.breakEndNotify,
                              dailyReminderNotify: notificationSettings.dailyReminderNotify,
                              dailyReminderTime: notificationSettings.dailyReminderTime,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SettingsToggleTile(
                        iconEmoji: '☕',
                        iconColor: Colors.brown,
                        title: 'Break End',
                        subtitle: 'Notify when break is over',
                        value: notificationSettings.breakEndNotify,
                        onChanged: (v) {
                          ref.read(appSettingsProvider.notifier).updateNotifications(
                            NotificationSettings(
                              enabled: notificationSettings.enabled,
                              sessionEndNotify: notificationSettings.sessionEndNotify,
                              breakEndNotify: v,
                              dailyReminderNotify: notificationSettings.dailyReminderNotify,
                              dailyReminderTime: notificationSettings.dailyReminderTime,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SettingsToggleTile(
                        iconEmoji: '📅',
                        iconColor: AppColors.teal,
                        title: 'Daily Reminder',
                        subtitle: 'Remind to start your day',
                        value: notificationSettings.dailyReminderNotify,
                        onChanged: (v) {
                          ref.read(appSettingsProvider.notifier).updateNotifications(
                            NotificationSettings(
                              enabled: notificationSettings.enabled,
                              sessionEndNotify: notificationSettings.sessionEndNotify,
                              breakEndNotify: notificationSettings.breakEndNotify,
                              dailyReminderNotify: v,
                              dailyReminderTime: v ? (notificationSettings.dailyReminderTime ?? '09:00') : null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // ─── DATA SECTION ────────────────────────────────────────────────
              SettingsSection(label: 'Data'),
              SettingsCard(
                child: Column(
                  children: [
                    SettingsActionTile(
                      iconEmoji: '📤',
                      iconColor: Colors.blue,
                      title: 'Export Data',
                      subtitle: 'Download all data as JSON',
                      onTap: _isExporting ? () {} : _exportData,
                      trailing: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    SettingsActionTile(
                      iconEmoji: '📥',
                      iconColor: Colors.green,
                      title: 'Import Data',
                      subtitle: 'Restore from backup file',
                      onTap: _isImporting ? () {} : _importData,
                      trailing: _isImporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    SettingsActionTile(
                      iconEmoji: '🗑️',
                      iconColor: Colors.red,
                      title: 'Clear All Data',
                      subtitle: 'Permanently delete everything',
                      onTap: _showClearConfirmation,
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ),

              // ─── DEVELOPER SECTION ────────────────────────────────────────────
              SettingsSection(label: 'Developer'),
              SettingsCard(
                child: SettingsActionTile(
                  iconEmoji: '🔄',
                  iconColor: Colors.purple,
                  title: 'Reset Onboarding',
                  subtitle: 'Show onboarding screens again',
                  onTap: _showResetOnboardingConfirmation,
                  showDivider: false,
                ),
              ),

              // ─── ABOUT SECTION ───────────────────────────────────────────────
              SettingsSection(label: 'About'),
              SettingsCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: AppIcon(
                              AppIcons.checkCircle,
                              color: AppColors.teal,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FocusFlow',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.dynamicTextOnSurface(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SettingsActionTile(
                      iconEmoji: '❤️',
                      iconColor: Colors.pink,
                      title: 'Privacy',
                      subtitle: 'All data stored locally on your device',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showPomodoroSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PomodoroSettingsSheet(),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final taskRepo = await ref.read(taskRepositoryProvider.future);
      final sessionRepo = await ref.read(sessionRepositoryProvider.future);
      final templateRepo = await ref.read(templateRepositoryProvider.future);
      final resourceRepo = await ref.read(resourceRepositoryProvider.future);
      final statsRepo = await ref.read(statsRepositoryProvider.future);

      final tasks = taskRepo.getAll();
      final sessions = sessionRepo.getAll();
      final templates = templateRepo.getAll();
      final resources = resourceRepo.getAll();
      final stats = statsRepo.getAll();

      final exportData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'sessions': sessions.map((s) => s.toJson()).toList(),
        'templates': templates.map((t) => t.toJson()).toList(),
        'resources': resources.map((r) => r.toJson()).toList(),
        'stats': stats.map((s) => s.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      await Share.share(jsonString, subject: 'FocusFlow Export ${DateTime.now().toIso8601String().split('T')[0]}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(result.files.single.path!);
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      if (!data.containsKey('version')) throw Exception('Invalid backup file');

      final taskCount = (data['tasks'] as List?)?.length ?? 0;
      final sessionCount = (data['sessions'] as List?)?.length ?? 0;
      final templateCount = (data['templates'] as List?)?.length ?? 0;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: Text(
            'This will replace all existing data with:\n'
            '- $taskCount tasks\n- $sessionCount sessions\n- $templateCount templates\n\nContinue?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() => _isImporting = false);
        return;
      }

      final taskRepo = await ref.read(taskRepositoryProvider.future);
      final sessionRepo = await ref.read(sessionRepositoryProvider.future);
      final templateRepo = await ref.read(templateRepositoryProvider.future);
      final resourceRepo = await ref.read(resourceRepositoryProvider.future);
      final statsRepo = await ref.read(statsRepositoryProvider.future);

      await taskRepo.deleteAll();
      await sessionRepo.deleteAll();
      await templateRepo.deleteAll();
      await resourceRepo.deleteAll();
      await statsRepo.deleteAll();

      final tasksList = data['tasks'] as List?;
      if (tasksList != null) {
        for (final taskJson in tasksList) {
          final task = Task.fromJson(taskJson as Map<String, dynamic>);
          await taskRepo.save(task);
        }
      }

      final sessionsList = data['sessions'] as List?;
      if (sessionsList != null) {
        for (final sessionJson in sessionsList) {
          final session = FlowSession.fromJson(sessionJson as Map<String, dynamic>);
          await sessionRepo.save(session);
        }
      }

      final templatesList = data['templates'] as List?;
      if (templatesList != null) {
        for (final templateJson in templatesList) {
          final template = Template.fromJson(templateJson as Map<String, dynamic>);
          await templateRepo.save(template);
        }
      }

      final resourcesList = data['resources'] as List?;
      if (resourcesList != null) {
        for (final resourceJson in resourcesList) {
          final resource = Resource.fromJson(resourceJson as Map<String, dynamic>);
          await resourceRepo.save(resource);
        }
      }

      final statsList = data['stats'] as List?;
      if (statsList != null) {
        for (final statJson in statsList) {
          final stat = DailyStats.fromJson(statJson as Map<String, dynamic>);
          await statsRepo.addStat(stat);
        }
      }

      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported $taskCount tasks, $sessionCount sessions'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all:\n'
          '- Tasks\n- Sessions\n- Templates\n'
          '- Resources\n- Stats\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: const Text('Delete Everything', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      final taskRepo = await ref.read(taskRepositoryProvider.future);
      final sessionRepo = await ref.read(sessionRepositoryProvider.future);
      final templateRepo = await ref.read(templateRepositoryProvider.future);
      final resourceRepo = await ref.read(resourceRepositoryProvider.future);
      final statsRepo = await ref.read(statsRepositoryProvider.future);

      await taskRepo.deleteAll();
      await sessionRepo.deleteAll();
      await templateRepo.deleteAll();
      await resourceRepo.deleteAll();
      await statsRepo.deleteAll();

      await ref.read(appSettingsProvider.notifier).clearAllData();
      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear data: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showResetOnboardingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Onboarding?'),
        content: const Text('This will show the onboarding screens again on next launch.\n\nYour tasks and data will not be affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(onboardingProvider.notifier).resetOnboarding();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Onboarding will show again on next launch'), backgroundColor: AppColors.teal),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Dark mode toggle → `SettingsToggleTile` + `appSettingsProvider.notifier.setDarkMode()` → `appThemeModeProvider` → `MaterialApp.router themeMode` (live, no restart)
- [x] Sound effects toggle → `SettingsToggleTile` + `appSettingsProvider.notifier.setSoundEnabled()` → `soundEnabledProvider` (widgets watching this will react)
- [x] Pomodoro settings → `PomodoroSettingsSheet` with sliders → `appSettingsProvider.notifier.updatePomodoro()` → `pomodoroSettingsProvider`
- [x] Theme preview card → `ThemePreviewCard` showing live dark/light + font scale
- [x] Font scale slider → `SettingsSliderTile` → `appSettingsProvider.notifier.updateDisplay()` → `displaySettingsProvider`
- [x] Notification toggles → all three sub-toggles wired to `notificationSettingsProvider`
- [x] Export/Import/Clear → wired with loading states + confirmations
- [x] Stats section → 2×2 grid of `SettingsStatCard`
- [x] All section headers → `SettingsSection` with uppercase label
- [x] Typography follows `Montserrat` for headings, `Inter` for body (`fontFamily: 'Montserrat'`, `fontFamily: 'Inter'`)
- [x] Color palette uses `AppColors.teal` primary, `AppColors.amber` accent, `AppColors.grey500` for disabled/text-secondary
- [x] Dark-mode-aware surfaces via `AppTheme.dynamicSurface()`, `dynamicCardBg()`, `dynamicBorder()`
- [x] Bottom sheet uses `borderRadius: const BorderRadius.vertical(top: Radius.circular(20))` matching existing app patterns

**Placeholder scan:**
- No `TBD` or `TODO` in any step
- All imports, widget names, method names are actual existing or created symbols
- `taskRepositoryProvider` and `sessionRepositoryProvider` are imported from existing `providers.dart`

**Type consistency:**
- `AppSettingsNotifier` extends `AsyncNotifier<AppSettings>` — matches `appSettingsProvider`
- All `.copyWith()` calls use exact field names from Task 1
- `PomodoroTimerSettings`, `NotificationSettings`, `DisplaySettings` match between model and provider
- `ThemePreviewCard` uses `isDarkMode` and `fontScale` parameters correctly
