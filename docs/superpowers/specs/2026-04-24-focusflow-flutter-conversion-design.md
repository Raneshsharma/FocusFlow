# FocusFlow Flutter Conversion Design

**Date**: 2026-04-24
**Project**: Convert FocusFlow React web app to Flutter Android app
**Scope**: Full feature parity
**Platform**: Android only, mobile-first

---

## Overview

Converting the FocusFlow ADHD productivity web application to a native Android Flutter app. The Flutter version will maintain full feature parity while adapting to Material 3 design conventions and native Android patterns.

**Key Principles**:
- Clean Architecture with clear layer separation
- Feature-first folder organization
- Riverpod for state management (compile-safe, testable)
- Isar for local database persistence
- Material 3 with custom FocusFlow brand colors

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (Screens, Widgets, Riverpod Providers) │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│  (Models, Enums, Business Logic)        │
├─────────────────────────────────────────┤
│             Data Layer                  │
│  (Isar Collections, Repositories)       │
└─────────────────────────────────────────┘
```

### Folder Structure (Hybrid)

```
lib/
├── main.dart                           # App entry point
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 theme configuration
│   │   ├── app_colors.dart            # Brand color constants
│   │   └── app_typography.dart        # Text styles
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants
│   └── utils/
│       ├── date_utils.dart            # Date/time helpers
│       └── streak_calculator.dart     # Streak logic
├── data/
│   ├── models/
│   │   ├── task.dart                 # Isar collection
│   │   ├── flow_session.dart         # Isar collection
│   │   ├── template.dart              # Isar collection
│   │   ├── resource.dart              # Isar collection
│   │   ├── daily_stats.dart          # Isar collection
│   │   └── enums.dart                # Energy, Zone, Priority enums
│   └── repositories/
│       ├── task_repository.dart
│       ├── session_repository.dart
│       ├── template_repository.dart
│       ├── resource_repository.dart
│       └── stats_repository.dart
├── providers/
│   ├── task_provider.dart
│   ├── flow_provider.dart
│   ├── body_double_provider.dart
│   ├── stats_provider.dart
│   └── theme_provider.dart
└── features/
    ├── today/
    │   ├── screens/
    │   │   └── today_screen.dart
    │   └── widgets/
    │       ├── time_zone_section.dart
    │       ├── anytime_pool.dart
    │       ├── task_card.dart
    │       ├── add_task_dialog.dart
    │       ├── task_detail_sheet.dart
    │       ├── template_create_dialog.dart
    │       └── daily_summary.dart
    ├── flow/
    │   ├── screens/
    │   │   └── flow_screen.dart
    │   └── widgets/
    │       ├── timer_display.dart
    │       ├── session_complete_sheet.dart
    │       ├── break_timer.dart
    │       └── body_double_pill.dart
    ├── body_double/
    │   ├── screens/
    │   │   └── body_double_screen.dart
    │   └── widgets/
    │       └── body_double_status.dart
    ├── rest/
    │   ├── screens/
    │   │   └── rest_screen.dart
    │   └── widgets/
    │       ├── breathing_timer.dart
    │       ├── micro_break_card.dart
    │       └── wind_down_routine.dart
    ├── library/
    │   ├── screens/
    │   │   └── library_screen.dart
    │   └── widgets/
    │       ├── session_list_item.dart
    │       ├── template_card.dart
    │       └── resource_tile.dart
    └── settings/
        ├── screens/
        │   └── settings_screen.dart
        └── widgets/
            └── settings_tile.dart
```

---

## Data Models (Isar Collections)

### Task
```dart
@Collection()
class Task {
  Id id = Isar.autoIncrement;

  String title;
  @enumerated
  EnergyLevel energy;
  @enumerated
  TimeZone zone;
  @enumerated
  Priority priority;
  List<String> tags;
  int? estimatedMinutes;
  bool completed;
  DateTime? completedAt;
  bool isFavorite;
  String? notes;
  String? scheduledTime; // HH:mm format
  DateTime createdAt;
}
```

### FlowSession
```dart
@Collection()
class FlowSession {
  Id id = Isar.autoIncrement;

  int? taskId;
  @enumerated
  SessionType type;
  DateTime startedAt;
  int durationSeconds;
  DateTime? completedAt;
  String? reflection;
  @enumerated
  EnergyLevel? energyLevel;
}
```

### Template
```dart
@Collection()
class Template {
  Id id = Isar.autoIncrement;
  String name;
  List<int> taskIds;
  @enumerated
  TimeZone zone;
  DateTime createdAt;
  int usageCount;
}
```

### Resource
```dart
@Collection()
class Resource {
  Id id = Isar.autoIncrement;
  String title;
  String url;
  DateTime createdAt;
}
```

### DailyStats
```dart
@Collection()
class DailyStats {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String date; // yyyy-MM-dd format
  int tasksCompleted;
  int sessionsCompleted;
  int focusMinutes;
}
```

### AppSettings
```dart
@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;
  bool isDarkMode;
  bool soundEnabled;
  String? lastActiveDate;
}
```

### Enums
```dart
enum EnergyLevel { quick, deep, low, none }
enum TimeZone { morning, afternoon, evening, anytime, none }
enum Priority { high, medium, low }
enum SessionType { open, pomodoro, deep }
```

---

## Riverpod Providers

### Repository Providers
```dart
// Database instance
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

// Repositories
final taskRepositoryProvider = Provider<TaskRepository>((ref) => ...);
final sessionRepositoryProvider = Provider<SessionRepository>((ref) => ...);
final statsRepositoryProvider = Provider<StatsRepository>((ref) => ...);
```

### Task Providers
```dart
final tasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});

final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => !t.completed).toList();
});

final favoriteTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.isFavorite).toList();
});
```

### Flow Session Provider
```dart
final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>((ref) {
  return FlowSessionNotifier(ref);
});

class FlowSessionState {
  final FlowSession? activeSession;
  final int elapsedSeconds;
  final bool isRunning;
  final int pomodoroRound;
}

class FlowSessionNotifier extends StateNotifier<FlowSessionState> {
  // Timer logic with drift compensation using Stopwatch
}
```

### Stats Provider
```dart
final dailyStatsProvider = FutureProvider.family<DailyStats, String>((ref, date) {
  return ref.watch(statsRepositoryProvider).getByDate(date);
});

final streakProvider = Provider<StreakData>((ref) {
  return StreakCalculator.calculate(ref.watch(statsRepositoryProvider));
});
```

---

## Theme Configuration

### Brand Colors (from theme.css)
```dart
class AppColors {
  // Brand
  static const navy = Color(0xFF0B1E3D);
  static const teal = Color(0xFF0F969C);
  static const amber = Color(0xFFF5A623);

  // Energy levels
  static const energyQuick = Color(0xFF10B981);
  static const energyDeep = Color(0xFF8B5CF6);
  static const energyLow = Color(0xFF6366F1);

  // Zones
  static const zoneMorning = Color(0xFFF59E0B);
  static const zoneAfternoon = Color(0xFFF97316);
  static const zoneEvening = Color(0xFF6366F1);

  // Semantic
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}
```

### Material 3 Theme
```dart
ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      secondary: AppColors.amber,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal,
      foregroundColor: Colors.white,
    ),
  );
}
```

---

## Screen Specifications

### 1. TodayScreen
**Route**: `/today`
**Widgets**:
- `Scaffold` with `AppBar` (title: "Today", settings action)
- `SingleChildScrollView` containing:
  - `DailySummary` card at top
  - `TimeZoneSection` (morning) with `TaskCard` list
  - `TimeZoneSection` (afternoon) with `TaskCard` list
  - `TimeZoneSection` (evening) with `TaskCard` list
  - `AnytimePool` collapsible section
- `FloatingActionButton` for adding tasks
- `BottomNavigationBar` (4 items: Today, Flow, Rest, Library)

**Interactions**:
- Tap task card → open `TaskDetailSheet`
- Long press task card → show quick actions (complete, favorite, delete)
- Tap FAB → open `AddTaskDialog`
- Pull to refresh → reload tasks

### 2. FlowScreen
**Route**: `/flow`
**Widgets**:
- `Scaffold` with `AppBar` (title: "Flow Session")
- Session type selector (SegmentedButton: Open, Pomodoro, Deep Work)
- `TimerDisplay` with circular progress indicator
- Control buttons (Start, Pause, Resume, Stop)
- `BodyDoublePill` floating widget (when active)
- `BreakTimer` (shown after pomodoro round)

**Interactions**:
- Select session type → resets timer
- Tap Start → begins session
- Tap Pause → pauses timer
- Tap Resume → continues timer
- Timer completes → shows `SessionCompleteSheet`

### 3. RestScreen
**Route**: `/rest`
**Widgets**:
- Contextual greeting based on time of day
- `Card` with session count and encouragement
- `SectionHeader` "Take a Break"
- Horizontal scrollable list of `MicroBreakCard` (6 options)
- `BreathingTimerCard` → opens full `BreathingTimerSheet`
- `WindDownRoutineCard` → opens `WindDownRoutineSheet`
- Sound toggle switch

**BreathingTimer**:
- Pattern selector (Box, 4-7-8, Physiological Sigh)
- Duration selector (2, 5, 10 min)
- Animated breathing circle (expands on inhale, contracts on exhale)
- Phase label (Inhale, Hold, Exhale)
- Start/Stop controls

### 4. LibraryScreen
**Route**: `/library`
**Widgets**:
- `TabBar` with 6 tabs: Sessions, Templates, Favorites, Notes, Archive, Resources
- `TabBarView` containing respective lists
- Search bar at top
- Floating action button for adding resources

**Sessions Tab**: List of `SessionListItem` sorted by date
**Templates Tab**: Grid of `TemplateCard` with apply button
**Favorites Tab**: List of favorited `TaskCard` widgets
**Notes Tab**: List of sessions with reflections
**Archive Tab**: Stats summary + archived tasks
**Resources Tab**: List of saved `ResourceTile` with add button

### 5. SettingsScreen
**Route**: `/settings`
**Widgets**:
- `ListTile` for Export Data (downloads JSON)
- `ListTile` for Import Data (file picker)
- `ListTile` for Clear All Data (with confirmation dialog)
- `SwitchListTile` for Dark Mode
- `SwitchListTile` for Sound Effects
- `About` section with app version

---

## Navigation

Using GoRouter for declarative routing with bottom navigation shell.

```dart
final router = GoRouter(
  initialLocation: '/today',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
        GoRoute(path: '/flow', builder: (_, __) => const FlowScreen()),
        GoRoute(path: '/rest', builder: (_, __) => const RestScreen()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
      ],
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/body-double', builder: (_, __) => const BodyDoubleScreen()),
  ],
);
```

**MainShell** contains:
- `Scaffold` with `body` slot
- `BottomNavigationBar` synced to current route
- Settings accessible via `AppBar` action

---

## Implementation Phases

### Phase 1: Project Setup
1. Create Flutter project: `flutter create focus_flow --platforms=android`
2. Add dependencies to pubspec.yaml
3. Set up Isar database initialization
4. Create folder structure
5. Configure theme and colors

### Phase 2: Core Infrastructure
1. Implement Isar models and enums
2. Create repositories
3. Set up Riverpod providers
4. Configure GoRouter navigation
5. Build main shell with bottom nav

### Phase 3: Today Screen
1. Build TimeZoneSection widget
2. Build TaskCard widget
3. Build AddTaskDialog
4. Build TaskDetailSheet
5. Build AnytimePool
6. Wire up task providers

### Phase 4: Flow Screen
1. Build TimerDisplay widget
2. Implement FlowSessionNotifier with timer logic
3. Build SessionCompleteSheet
4. Implement pomodoro rounds logic
5. Add BodyDouble integration

### Phase 5: Rest Screen
1. Build BreathingTimer with animations
2. Build MicroBreakCard
3. Build WindDownRoutine
4. Integrate with stats provider

### Phase 6: Library Screen
1. Build tab structure
2. Implement Sessions tab
3. Implement Templates tab with apply functionality
4. Implement Favorites tab
5. Implement Resources tab

### Phase 7: Settings & Polish
1. Build SettingsScreen
2. Implement data export/import
3. Add dark mode support
4. Add sound notifications
5. Test and polish animations

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2

  # Navigation
  go_router: ^14.0.0

  # UI
  google_fonts: ^6.1.0
  flutter_animate: ^4.5.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  share_plus: ^7.2.1
  file_picker: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.0
  flutter_lints: ^3.0.1
```

---

## Testing Strategy

1. **Unit Tests**: Streak calculator, date utilities, repository methods
2. **Widget Tests**: Each screen and major widget
3. **Integration Tests**: Flow session lifecycle, task CRUD operations

---

## Success Criteria

- [ ] All React features implemented in Flutter
- [ ] Data persists across app restarts (Isar)
- [ ] Timer accuracy within 1 second drift per hour
- [ ] Dark mode fully functional
- [ ] Export/Import works correctly
- [ ] App builds successfully for Android
