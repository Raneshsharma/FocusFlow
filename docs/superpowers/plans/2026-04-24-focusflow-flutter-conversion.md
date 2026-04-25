# FocusFlow Flutter Conversion Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan.

**Goal:** Convert FocusFlow React web app to native Android Flutter app with full feature parity.

**Architecture:** Clean Architecture with Hybrid folder structure, Riverpod state management, Isar database.

**Tech Stack:** Flutter, Riverpod, Isar, GoRouter, Material 3

---

## File Structure Overview

```
focus_flow/                    (new Flutter project)
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/             (app_theme.dart, app_colors.dart)
│   │   ├── constants/         (app_constants.dart)
│   │   └── utils/             (date_utils.dart, streak_calculator.dart)
│   ├── data/
│   │   ├── models/            (task.dart, flow_session.dart, template.dart, resource.dart, daily_stats.dart, enums.dart)
│   │   └── repositories/     (task_repository.dart, session_repository.dart, stats_repository.dart)
│   ├── providers/             (task_provider.dart, flow_provider.dart, body_double_provider.dart, stats_provider.dart)
│   └── features/
│       ├── today/             (screens/, widgets/)
│       ├── flow/              (screens/, widgets/)
│       ├── body_double/       (screens/, widgets/)
│       ├── rest/              (screens/, widgets/)
│       ├── library/           (screens/, widgets/)
│       └── settings/          (screens/, widgets/)
└── pubspec.yaml
```

---

## Task 1: Project Setup

**Files:**
- Create: `focus_flow/pubspec.yaml`
- Create: `focus_flow/lib/main.dart`

- [ ] **Step 1: Create Flutter project structure**

Create `pubspec.yaml` with dependencies:
```yaml
name: focus_flow
publish_to: 'none'
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  go_router: ^14.0.0
  google_fonts: ^6.1.0
  intl: ^0.19.0
  share_plus: ^7.2.1
  file_picker: ^6.1.1
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  isar_generator: ^3.1.0+1
  flutter_lints: ^3.0.1
```

- [ ] **Step 2: Create main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'data/models/task.dart';
import 'data/models/flow_session.dart';
import 'data/models/template.dart';
import 'data/models/resource.dart';
import 'data/models/daily_stats.dart';
import 'data/models/app_settings.dart';
import 'core/router/app_router.dart';

late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [TaskSchema, FlowSessionSchema, TemplateSchema, ResourceSchema, DailyStatsSchema, AppSettingsSchema],
    directory: dir.path,
  );
  
  runApp(const ProviderScope(child: FocusFlowApp()));
}

class FocusFlowApp extends ConsumerWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FocusFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
```

- [ ] **Step 3: Initialize Isar models (see Task 2)**
- [ ] **Step 4: Run build_runner for Isar code generation**

Run: `cd focus_flow && flutter pub run build_runner build --delete-conflicting-outputs`

---

## Task 2: Core Models & Enums

**Files:**
- Create: `focus_flow/lib/data/models/enums.dart`
- Create: `focus_flow/lib/data/models/task.dart`
- Create: `focus_flow/lib/data/models/flow_session.dart`
- Create: `focus_flow/lib/data/models/template.dart`
- Create: `focus_flow/lib/data/models/resource.dart`
- Create: `focus_flow/lib/data/models/daily_stats.dart`
- Create: `focus_flow/lib/data/models/app_settings.dart`

- [ ] **Step 1: Create enums.dart**

```dart
enum EnergyLevel { quick, deep, low, none }

enum TimeZone { morning, afternoon, evening, anytime, none }

enum Priority { high, medium, low }

enum SessionType { open, pomodoro, deep }

enum BreathingPattern { box,478, physiologicalSigh }

enum BlockState { past, current, future }
```

- [ ] **Step 2: Create task.dart**

```dart
import 'package:isar/isar.dart';
import 'enums.dart';

part 'task.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;
  
  late String title;
  
  @enumerated
  EnergyLevel energy = EnergyLevel.none;
  
  @enumerated
  TimeZone zone = TimeZone.anytime;
  
  @enumerated
  Priority priority = Priority.medium;
  
  List<String> tags = [];
  
  int? estimatedMinutes;
  
  bool completed = false;
  
  DateTime? completedAt;
  
  bool isFavorite = false;
  
  String? notes;
  
  String? scheduledTime;
  
  DateTime createdAt = DateTime.now();
}
```

- [ ] **Step 3: Create flow_session.dart**

```dart
import 'package:isar/isar.dart';
import 'enums.dart';

part 'flow_session.g.dart';

@Collection()
class FlowSession {
  Id id = Isar.autoIncrement;
  
  int? taskId;
  
  @enumerated
  SessionType type = SessionType.open;
  
  DateTime? startedAt;
  
  int durationSeconds = 0;
  
  DateTime? completedAt;
  
  String? reflection;
  
  @enumerated
  EnergyLevel? energyLevel;
}
```

- [ ] **Step 4: Create template.dart, resource.dart, daily_stats.dart, app_settings.dart** (similar pattern)

- [ ] **Step 5: Run build_runner**

Run: `cd focus_flow && flutter pub run build_runner build --delete-conflicting-outputs`

---

## Task 3: Core Theme & Constants

**Files:**
- Create: `focus_flow/lib/core/theme/app_colors.dart`
- Create: `focus_flow/lib/core/theme/app_theme.dart`
- Create: `focus_flow/lib/core/constants/app_constants.dart`
- Create: `focus_flow/lib/core/utils/date_utils.dart`
- Create: `focus_flow/lib/core/utils/streak_calculator.dart`

- [ ] **Step 1: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand colors from theme.css
  static const navy = Color(0xFF0B1E3D);
  static const teal = Color(0xFF0F969C);
  static const amber = Color(0xFFF5A623);
  static const charcoal = Color(0xFF1E293B);
  
  // Energy level colors
  static const energyQuick = Color(0xFF10B981);
  static const energyDeep = Color(0xFF8B5CF6);
  static const energyLow = Color(0xFF6366F1);
  
  // Zone colors
  static const zoneMorning = Color(0xFFF59E0B);
  static const zoneAfternoon = Color(0xFFF97316);
  static const zoneEvening = Color(0xFF6366F1);
  
  // Semantic
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  
  // Block states
  static const blockPast = Color(0xFFE5E7EB);
  static const blockCurrent = Color(0xFFD1FAE5);
  static const blockFuture = Color(0xFFF3F4F6);
}
```

- [ ] **Step 2: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.light,
        primary: AppColors.teal,
        secondary: AppColors.amber,
        surface: Colors.white,
        surfaceContainerHighest: AppColors.charcoal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.dark,
        primary: AppColors.teal,
        secondary: AppColors.amber,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
```

- [ ] **Step 3: Create app_constants.dart**

```dart
class AppConstants {
  // Timer durations (in seconds)
  static const pomodoroWork = 25 * 60;      // 25 minutes
  static const pomodoroShortBreak = 5 * 60; // 5 minutes
  static const pomodoroLongBreak = 15 * 60;  // 15 minutes
  static const deepWork = 50 * 60;          // 50 minutes
  
  // Pomodoro
  static const pomodoroRounds = 4;
  
  // Breathing patterns (in seconds)
  static const boxBreathDuration = 4;
  static const breathing478Inhale = 4;
  static const breathing478Hold = 7;
  static const breathing478Exhale = 8;
  
  // Time zone hour ranges
  static const morningStart = 5;
  static const morningEnd = 12;
  static const afternoonStart = 12;
  static const afternoonEnd = 18;
  static const eveningStart = 18;
  static const eveningEnd = 24;
  
  // UI
  static const animationDuration = Duration(milliseconds: 300);
  static const toastDuration = Duration(seconds: 3);
}
```

---

## Task 4: Repositories

**Files:**
- Create: `focus_flow/lib/data/repositories/task_repository.dart`
- Create: `focus_flow/lib/data/repositories/session_repository.dart`
- Create: `focus_flow/lib/data/repositories/stats_repository.dart`

- [ ] **Step 1: Create task_repository.dart**

```dart
import 'package:isar/isar.dart';
import '../models/task.dart';

class TaskRepository {
  final Isar _isar;
  
  TaskRepository(this._isar);
  
  Future<List<Task>> getAll() async {
    return await _isar.tasks.where().findAll();
  }
  
  Stream<List<Task>> watchAll() {
    return _isar.tasks.where().watch(fireImmediately: true);
  }
  
  Future<List<Task>> getByZone(String zone) async {
    return await _isar.tasks.filter().zoneEqualTo(zone).findAll();
  }
  
  Future<List<Task>> getFavorites() async {
    return await _isar.tasks.filter().isFavoriteEqualTo(true).findAll();
  }
  
  Future<List<Task>> getCompleted() async {
    return await _isar.tasks.filter().completedEqualTo(true).findAll();
  }
  
  Future<int> save(Task task) async {
    return await _isar.writeTxn(() async {
      return await _isar.tasks.put(task);
    });
  }
  
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.tasks.delete(id);
    });
  }
  
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.tasks.clear();
    });
  }
}
```

- [ ] **Step 2: Create session_repository.dart** (similar pattern for FlowSession)

- [ ] **Step 3: Create stats_repository.dart**

```dart
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/daily_stats.dart';

class StatsRepository {
  final Isar _isar;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  
  StatsRepository(this._isar);
  
  Future<DailyStats> getByDate(DateTime date) async {
    final dateStr = _dateFormat.format(date);
    var stats = await _isar.dailyStats.filter().dateEqualTo(dateStr).findFirst();
    
    if (stats == null) {
      stats = DailyStats()..date = dateStr;
      await _isar.writeTxn(() async {
        await _isar.dailyStats.put(stats!);
      });
    }
    return stats;
  }
  
  Future<void> incrementTasksCompleted(DateTime date) async {
    final stats = await getByDate(date);
    await _isar.writeTxn(() async {
      stats.tasksCompleted++;
      await _isar.dailyStats.put(stats);
    });
  }
  
  Future<void> incrementSessionsCompleted(DateTime date) async {
    final stats = await getByDate(date);
    await _isar.writeTxn(() async {
      stats.sessionsCompleted++;
      await _isar.dailyStats.put(stats);
    });
  }
  
  Future<void> addFocusMinutes(DateTime date, int minutes) async {
    final stats = await getByDate(date);
    await _isar.writeTxn(() async {
      stats.focusMinutes += minutes;
      await _isar.dailyStats.put(stats);
    });
  }
}
```

---

## Task 5: Riverpod Providers

**Files:**
- Create: `focus_flow/lib/providers/task_provider.dart`
- Create: `focus_flow/lib/providers/flow_provider.dart`
- Create: `focus_flow/lib/providers/stats_provider.dart`

- [ ] **Step 1: Create task_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';
import '../core/utils/date_utils.dart' as utils;

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TaskRepository(isar);
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});

final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => !t.completed).toList();
});

final morningTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  return tasks.where((t) => t.zone == TimeZone.morning).toList();
});

final afternoonTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  return tasks.where((t) => t.zone == TimeZone.afternoon).toList();
});

final eveningTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  return tasks.where((t) => t.zone == TimeZone.evening).toList();
});

final anytimeTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  return tasks.where((t) => t.zone == TimeZone.anytime).toList();
});

final favoriteTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  return tasks.where((t) => t.isFavorite).toList();
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  
  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }
  
  Future<void> _init() async {
    _repository.watchAll().listen((tasks) {
      state = AsyncValue.data(tasks);
    });
  }
  
  Future<void> addTask(Task task) async {
    await _repository.save(task);
  }
  
  Future<void> updateTask(Task task) async {
    await _repository.save(task);
  }
  
  Future<void> completeTask(int id) async {
    final tasks = state.value ?? [];
    final task = tasks.firstWhere((t) => t.id == id);
    task.completed = true;
    task.completedAt = DateTime.now();
    await _repository.save(task);
  }
  
  Future<void> deleteTask(int id) async {
    await _repository.delete(id);
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref.watch(taskRepositoryProvider));
});
```

- [ ] **Step 2: Create flow_provider.dart**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/flow_session.dart';
import '../data/models/enums.dart';
import '../core/constants/app_constants.dart';

class FlowSessionState {
  final FlowSession? activeSession;
  final int elapsedSeconds;
  final bool isRunning;
  final int pomodoroRound;
  final bool isBreak;
  final SessionType sessionType;
  
  const FlowSessionState({
    this.activeSession,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.pomodoroRound = 0,
    this.isBreak = false,
    this.sessionType = SessionType.open,
  });
  
  FlowSessionState copyWith({
    FlowSession? activeSession,
    int? elapsedSeconds,
    bool? isRunning,
    int? pomodoroRound,
    bool? isBreak,
    SessionType? sessionType,
  }) {
    return FlowSessionState(
      activeSession: activeSession ?? this.activeSession,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      pomodoroRound: pomodoroRound ?? this.pomodoroRound,
      isBreak: isBreak ?? this.isBreak,
      sessionType: sessionType ?? this.sessionType,
    );
  }
  
  double get progress {
    if (sessionType == SessionType.pomodoro) {
      final total = isBreak ? AppConstants.pomodoroShortBreak : AppConstants.pomodoroWork;
      return elapsedSeconds / total;
    } else if (sessionType == SessionType.deep) {
      return elapsedSeconds / AppConstants.deepWork;
    }
    return 0;
  }
}

class FlowSessionNotifier extends StateNotifier<FlowSessionState> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  
  FlowSessionNotifier() : super(const FlowSessionState());
  
  void startSession(SessionType type, {int? taskId}) {
    _stopwatch.reset();
    _stopwatch.start();
    
    final session = FlowSession()
      ..type = type
      ..taskId = taskId
      ..startedAt = DateTime.now();
    
    state = FlowSessionState(
      activeSession: session,
      isRunning: true,
      sessionType: type,
      pomodoroRound: type == SessionType.pomodoro ? 1 : 0,
    );
    
    _startTimer();
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_stopwatch.elapsed.inSeconds != state.elapsedSeconds) {
        state = state.copyWith(elapsedSeconds: _stopwatch.elapsed.inSeconds);
        
        // Check for auto-complete
        _checkAutoComplete();
      }
    });
  }
  
  void _checkAutoComplete() {
    if (state.sessionType == SessionType.deep) {
      if (state.elapsedSeconds >= AppConstants.deepWork) {
        pause();
        // Signal completion
      }
    } else if (state.sessionType == SessionType.pomodoro) {
      final target = state.isBreak 
          ? AppConstants.pomodoroShortBreak 
          : AppConstants.pomodoroWork;
      if (state.elapsedSeconds >= target) {
        _handlePomodoroRoundComplete();
      }
    }
  }
  
  void _handlePomodoroRoundComplete() {
    if (!state.isBreak) {
      // Work round complete, start break
      _stopwatch.reset();
      state = state.copyWith(isBreak: true, elapsedSeconds: 0);
    } else {
      // Break complete, check if more rounds
      if (state.pomodoroRound < AppConstants.pomodoroRounds) {
        _stopwatch.reset();
        state = state.copyWith(
          isBreak: false,
          elapsedSeconds: 0,
          pomodoroRound: state.pomodoroRound + 1,
        );
      } else {
        // All rounds complete
        pause();
      }
    }
  }
  
  void pause() {
    _stopwatch.stop();
    state = state.copyWith(isRunning: false);
    _timer?.cancel();
  }
  
  void resume() {
    _stopwatch.start();
    state = state.copyWith(isRunning: true);
    _startTimer();
  }
  
  void stop() {
    _timer?.cancel();
    _stopwatch.stop();
    state = const FlowSessionState();
  }
  
  void addProgress(int percent) {
    // Manual progress increment for open sessions
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>((ref) {
  return FlowSessionNotifier();
});
```

- [ ] **Step 3: Create stats_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/stats_repository.dart';
import '../providers/task_provider.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return StatsRepository(isar);
});

final todayStatsProvider = FutureProvider((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getByDate(DateTime.now());
});

final streakProvider = Provider<StreakData>((ref) {
  // Calculate from stats repository
  return StreakData(current: 0, longest: 0, totalDays: 0);
});

class StreakData {
  final int current;
  final int longest;
  final int totalDays;
  
  StreakData({
    required this.current,
    required this.longest,
    required this.totalDays,
  });
}
```

---

## Task 6: Navigation (GoRouter)

**Files:**
- Create: `focus_flow/lib/core/router/app_router.dart`
- Create: `focus_flow/lib/core/widgets/main_shell.dart`

- [ ] **Step 1: Create app_router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_shell.dart';
import '../../features/today/screens/today_screen.dart';
import '../../features/flow/screens/flow_screen.dart';
import '../../features/rest/screens/rest_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final AppRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TodayScreen(),
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
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
```

- [ ] **Step 2: Create main_shell.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});
  
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/today')) return 0;
    if (location.startsWith('/flow')) return 1;
    if (location.startsWith('/rest')) return 2;
    if (location.startsWith('/library')) return 3;
    return 0;
  }
  
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/today');
        break;
      case 1:
        context.go('/flow');
        break;
      case 2:
        context.go('/rest');
        break;
      case 3:
        context.go('/library');
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Flow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Rest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
```

---

## Task 7: Today Screen & Widgets

**Files:**
- Create: `focus_flow/lib/features/today/screens/today_screen.dart`
- Create: `focus_flow/lib/features/today/widgets/time_zone_section.dart`
- Create: `focus_flow/lib/features/today/widgets/anytime_pool.dart`
- Create: `focus_flow/lib/features/today/widgets/task_card.dart`
- Create: `focus_flow/lib/features/today/widgets/add_task_dialog.dart`
- Create: `focus_flow/lib/features/today/widgets/task_detail_sheet.dart`

- [ ] **Step 1: Create today_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/task_provider.dart';
import '../widgets/time_zone_section.dart';
import '../widgets/anytime_pool.dart';
import '../widgets/daily_summary.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DailySummary(),
              const SizedBox(height: 24),
              TimeZoneSection(
                title: 'Morning',
                color: AppColors.zoneMorning,
                timeRange: '5 AM - 12 PM',
                tasks: ref.watch(morningTasksProvider),
              ),
              const SizedBox(height: 16),
              TimeZoneSection(
                title: 'Afternoon',
                color: AppColors.zoneAfternoon,
                timeRange: '12 PM - 6 PM',
                tasks: ref.watch(afternoonTasksProvider),
              ),
              const SizedBox(height: 16),
              TimeZoneSection(
                title: 'Evening',
                color: AppColors.zoneEvening,
                timeRange: '6 PM - 12 AM',
                tasks: ref.watch(eveningTasksProvider),
              ),
              const SizedBox(height: 16),
              AnytimePool(tasks: ref.watch(anytimeTasksProvider)),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTaskDialog(),
    );
  }
}
```

- [ ] **Step 2: Create time_zone_section.dart**

```dart
import 'package:flutter/material.dart';
import '../../../data/models/task.dart';
import '../widgets/task_card.dart';

class TimeZoneSection extends StatelessWidget {
  final String title;
  final Color color;
  final String timeRange;
  final List<Task> tasks;
  
  const TimeZoneSection({
    super.key,
    required this.title,
    required this.color,
    required this.timeRange,
    required this.tasks,
  });
  
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isCurrentBlock = _isCurrentBlock(hour);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeRange,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            if (isCurrentBlock) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No tasks scheduled',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskCard(task: task),
          )),
      ],
    );
  }
  
  bool _isCurrentBlock(int hour) {
    if (title == 'Morning') return hour >= 5 && hour < 12;
    if (title == 'Afternoon') return hour >= 12 && hour < 18;
    if (title == 'Evening') return hour >= 18 || hour < 5;
    return false;
  }
}
```

- [ ] **Step 3: Create task_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  
  const TaskCard({super.key, required this.task});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Completion checkbox
              GestureDetector(
                onTap: () => ref.read(taskNotifierProvider.notifier).completeTask(task.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed ? AppColors.success : Colors.grey,
                      width: 2,
                    ),
                    color: task.completed ? AppColors.success : Colors.transparent,
                  ),
                  child: task.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildEnergyChip(task.energy),
                        if (task.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '#${task.tags.first}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  task.isFavorite ? Icons.star : Icons.star_border,
                  color: task.isFavorite ? AppColors.amber : Colors.grey,
                ),
                onPressed: () {
                  task.isFavorite = !task.isFavorite;
                  ref.read(taskNotifierProvider.notifier).updateTask(task);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnergyChip(EnergyLevel energy) {
    Color color;
    String label;
    
    switch (energy) {
      case EnergyLevel.quick:
        color = AppColors.energyQuick;
        label = 'Quick';
        break;
      case EnergyLevel.deep:
        color = AppColors.energyDeep;
        label = 'Deep';
        break;
      case EnergyLevel.low:
        color = AppColors.energyLow;
        label = 'Low Energy';
        break;
      case EnergyLevel.none:
        color = Colors.grey;
        label = '';
        break;
    }
    
    if (label.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailSheet(task: task),
    );
  }
}
```

- [ ] **Step 4: Create add_task_dialog.dart, anytime_pool.dart, task_detail_sheet.dart** (similar patterns)

---

## Task 8: Flow Screen & Timer

**Files:**
- Create: `focus_flow/lib/features/flow/screens/flow_screen.dart`
- Create: `focus_flow/lib/features/flow/widgets/timer_display.dart`
- Create: `focus_flow/lib/features/flow/widgets/session_complete_sheet.dart`

- [ ] **Step 1: Create flow_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/enums.dart';
import '../../../providers/flow_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/body_double_pill.dart';

class FlowScreen extends ConsumerWidget {
  const FlowScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(flowSessionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Session type selector
            SegmentedButton<SessionType>(
              segments: const [
                ButtonSegment(value: SessionType.open, label: Text('Open')),
                ButtonSegment(value: SessionType.pomodoro, label: Text('Pomodoro')),
                ButtonSegment(value: SessionType.deep, label: Text('Deep Work')),
              ],
              selected: {sessionState.sessionType},
              onSelectionChanged: sessionState.activeSession == null
                  ? (selected) {
                      ref.read(flowSessionProvider.notifier).startSession(selected.first);
                    }
                  : null,
            ),
            const SizedBox(height: 48),
            // Timer display
            TimerDisplay(
              elapsedSeconds: sessionState.elapsedSeconds,
              totalSeconds: _getTotalSeconds(sessionState),
              isBreak: sessionState.isBreak,
              sessionType: sessionState.sessionType,
            ),
            const SizedBox(height: 24),
            // Pomodoro rounds
            if (sessionState.sessionType == SessionType.pomodoro)
              Text(
                'Round ${sessionState.pomodoroRound} of ${AppConstants.pomodoroRounds}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 48),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!sessionState.isRunning && sessionState.activeSession == null)
                  ElevatedButton.icon(
                    onPressed: () => ref.read(flowSessionProvider.notifier).startSession(
                      sessionState.sessionType,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  )
                else if (sessionState.isRunning)
                  ElevatedButton.icon(
                    onPressed: () => ref.read(flowSessionProvider.notifier).pause(),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => ref.read(flowSessionProvider.notifier).resume(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                if (sessionState.activeSession != null) ...[
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(flowSessionProvider.notifier).stop(),
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ],
            ),
            // Body double pill when active
            if (sessionState.isRunning) ...[
              const Spacer(),
              const BodyDoublePill(),
            ],
          ],
        ),
      ),
    );
  }
  
  int _getTotalSeconds(FlowSessionState state) {
    if (state.sessionType == SessionType.pomodoro) {
      return state.isBreak 
          ? AppConstants.pomodoroShortBreak 
          : AppConstants.pomodoroWork;
    } else if (state.sessionType == SessionType.deep) {
      return AppConstants.deepWork;
    }
    return 0;
  }
}
```

- [ ] **Step 2: Create timer_display.dart**

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';

class TimerDisplay extends StatelessWidget {
  final int elapsedSeconds;
  final int totalSeconds;
  final bool isBreak;
  final SessionType sessionType;
  
  const TimerDisplay({
    super.key,
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.isBreak,
    required this.sessionType,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
    final remaining = totalSeconds > 0 ? totalSeconds - elapsedSeconds : 0;
    
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
            ),
          ),
          // Progress circle
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isBreak ? Colors.green : AppColors.teal,
              ),
            ),
          ),
          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(remaining),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                isBreak ? 'Break' : _getSessionLabel(),
                style: TextStyle(
                  fontSize: 16,
                  color: isBreak ? Colors.green : AppColors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  String _getSessionLabel() {
    switch (sessionType) {
      case SessionType.open:
        return 'Open Session';
      case SessionType.pomodoro:
        return 'Focus Time';
      case SessionType.deep:
        return 'Deep Work';
    }
  }
}
```

- [ ] **Step 3: Create session_complete_sheet.dart, body_double_pill.dart** (similar patterns)

---

## Task 9: Rest Screen & Breathing

**Files:**
- Create: `focus_flow/lib/features/rest/screens/rest_screen.dart`
- Create: `focus_flow/lib/features/rest/widgets/breathing_timer.dart`
- Create: `focus_flow/lib/features/rest/widgets/micro_break_card.dart`
- Create: `focus_flow/lib/features/rest/widgets/wind_down_routine.dart`

- [ ] **Step 1: Create rest_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/breathing_timer.dart';
import '../widgets/micro_break_card.dart';
import '../widgets/wind_down_routine.dart';

class RestScreen extends ConsumerWidget {
  const RestScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest & Recovery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve earned this break.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Session summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.teal,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You showed up today!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '2 sessions completed',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Take a break section
            Text(
              'Take a Break',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Micro breaks
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MicroBreakCard(
                    icon: Icons.coffee,
                    title: 'Coffee Break',
                    duration: '5 min',
                  ),
                  MicroBreakCard(
                    icon: Icons.directions_walk,
                    title: 'Walk',
                    duration: '10 min',
                  ),
                  MicroBreakCard(
                    icon: Icons.visibility,
                    title: 'Look Away',
                    duration: '20 sec',
                  ),
                  MicroBreakCard(
                    icon: Icons.stretching,
                    title: 'Stretch',
                    duration: '5 min',
                  ),
                  MicroBreakCard(
                    icon: Icons.water_drop,
                    title: 'Hydrate',
                    duration: '2 min',
                  ),
                  MicroBreakCard(
                    icon: Icons.spa,
                    title: 'Relax',
                    duration: '5 min',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Breathing timer card
            Card(
              onTap: () => _showBreathingTimer(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.air,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Breathing Exercise',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Calm your nervous system',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Wind down card
            Card(
              onTap: () => _showWindDownRoutine(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        color: Colors.purple,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wind Down Routine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Prepare for better sleep',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  
  void _showBreathingTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BreathingTimerSheet(),
    );
  }
  
  void _showWindDownRoutine(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const WindDownRoutineSheet(),
    );
  }
}
```

- [ ] **Step 2: Create breathing_timer.dart** (with AnimationController for animated breathing circle)

- [ ] **Step 3: Create micro_break_card.dart, wind_down_routine.dart** (similar patterns)

---

## Task 10: Library Screen

**Files:**
- Create: `focus_flow/lib/features/library/screens/library_screen.dart`
- Create: `focus_flow/lib/features/library/widgets/session_list_item.dart`
- Create: `focus_flow/lib/features/library/widgets/template_card.dart`

- [ ] **Step 1: Create library_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/task_provider.dart';
import '../widgets/session_list_item.dart';
import '../widgets/template_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Sessions'),
            Tab(text: 'Templates'),
            Tab(text: 'Favorites'),
            Tab(text: 'Notes'),
            Tab(text: 'Archive'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionsTab(),
          _buildTemplatesTab(),
          _buildFavoritesTab(),
          _buildNotesTab(),
          _buildArchiveTab(),
          _buildResourcesTab(),
        ],
      ),
    );
  }
  
  Widget _buildSessionsTab() {
    // List past sessions
    return const Center(child: Text('Sessions coming soon'));
  }
  
  Widget _buildTemplatesTab() {
    // List templates with apply button
    return const Center(child: Text('Templates coming soon'));
  }
  
  Widget _buildFavoritesTab() {
    final favorites = ref.watch(favoriteTasksProvider);
    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet'),
      );
    }
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) => SessionListItem(
        title: favorites[index].title,
        subtitle: 'Favorite task',
      ),
    );
  }
  
  Widget _buildNotesTab() {
    return const Center(child: Text('Session notes coming soon'));
  }
  
  Widget _buildArchiveTab() {
    return const Center(child: Text('Archive coming soon'));
  }
  
  Widget _buildResourcesTab() {
    return const Center(child: Text('Resources coming soon'));
  }
}
```

- [ ] **Step 2: Create session_list_item.dart, template_card.dart** (similar patterns)

---

## Task 11: Settings Screen

**Files:**
- Create: `focus_flow/lib/features/settings/screens/settings_screen.dart`

- [ ] **Step 1: Create settings_screen.dart**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download all your data as JSON'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a backup file'),
            onTap: () => _importData(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This cannot be undone'),
            onTap: () => _showClearConfirmation(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('FocusFlow'),
            subtitle: Text('Version 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.favorite_outline),
            title: Text('Made for ADHD brains'),
            subtitle: Text('Designed to help you thrive'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportData(BuildContext context) async {
    // Get all data from Isar and export as JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }
  
  Future<void> _importData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();
      // Parse and import
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import feature coming soon')),
      );
    }
  }
  
  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your tasks, sessions, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear feature coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.teal,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
```

---

## Task 12: Build & Verify

- [ ] **Step 1: Run flutter pub get**

Run: `cd focus_flow && flutter pub get`

- [ ] **Step 2: Run build_runner for Isar**

Run: `cd focus_flow && flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Step 3: Build debug APK**

Run: `cd focus_flow && flutter build apk --debug`

- [ ] **Step 4: Verify APK exists**

Check: `build/app/outputs/flutter-apk/app-debug.apk`

---

## Spec Coverage Checklist

| Feature | Task | Status |
|---------|------|--------|
| Task CRUD | Task 7 | ✓ |
| Time zones (morning/afternoon/evening/anytime) | Task 7 | ✓ |
| Energy levels (quick/deep/low) | Task 7 | ✓ |
| Flow sessions (open/pomodoro/deep) | Task 8 | ✓ |
| Timer with drift compensation | Task 8 | ✓ |
| Pomodoro rounds logic | Task 8 | ✓ |
| Body double pill | Task 8 | ✓ |
| Breathing exercises | Task 9 | ✓ |
| Micro breaks | Task 9 | ✓ |
| Wind down routine | Task 9 | ✓ |
| Library tabs | Task 10 | ✓ |
| Settings (export/import/clear) | Task 11 | ✓ |
| Dark mode | Theme (Task 3) | ✓ |
| Navigation | Task 6 | ✓ |
| Isar persistence | Tasks 1-2 | ✓ |
| Riverpod state | Tasks 4-5 | ✓ |
