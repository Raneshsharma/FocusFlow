# FocusFlow Gamification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add streak tracking, achievements, task celebrations, and progress stats to the Flutter app

The app uses **Focus** (not "Today") as the primary screen name - this is the screen where users manage daily tasks organized by time zones (Morning, Afternoon, Evening, Anytime).

**Architecture:** Gamification uses Hive for local persistence (matching existing app patterns). Data models extend HiveObject for reactive updates. Riverpod providers bridge data layer to UI. Celebrations triggered on task/session completion events.

**Tech Stack:** Flutter, Hive, Riverpod, Confetti package (for celebrations)

**Navigation Structure:**
| Index | Label | Icon | Route | Screen |
|-------|-------|------|-------|--------|
| 0 | Focus | `adjust` | `/focus` | FocusScreen |
| 1 | Flow | `play_circle` | `/flow` | FlowScreen |
| 2 | Library | `library_books` | `/library` | LibraryScreen |
| 3 | Rest | `self_improvement` | `/rest` | RestScreen |

---

## File Structure

```
focus_flow/lib/
├── data/
│   └── models/
│       ├── daily_progress.dart       # NEW - tracks daily task/session counts
│       ├── streak_data.dart          # NEW - tracks streak state
│       └── achievement.dart          # NEW - achievement definitions
├── providers/
│   └── gamification_provider.dart   # NEW - main gamification logic
├── features/
│   ├── focus/                       # Route: /focus
│   │   └── widgets/
│   │       ├── daily_progress_card.dart     # Add to focus_screen.dart
│   │       └── task_completion_celebration.dart  # NEW - celebration overlays
│   ├── rest/                        # Route: /rest
│   │   └── widgets/
│   │       └── weekly_summary_card.dart     # NEW - weekly stats
│   ├── library/                     # Route: /library
│   │   └── widgets/
│   │       └── achievements_tab.dart        # NEW - achievements view
│   └── settings/                     # Route: /settings
│       └── widgets/
│           └── stats_section.dart           # NEW - stats display
```

---

## Task 1: Hive Data Models

**Files:**
- Create: `focus_flow/lib/data/models/daily_progress.dart`
- Create: `focus_flow/lib/data/models/streak_data.dart`
- Create: `focus_flow/lib/data/models/achievement.dart`
- Modify: `focus_flow/lib/main.dart` (add Hive initialization)

- [ ] **Step 1: Create daily_progress.dart**

```dart
import 'package:hive/hive.dart';

part 'daily_progress.g.dart';

@HiveType(typeId: 0)
class DailyProgress extends HiveObject {
  @HiveField(0)
  String date;  // Format: yyyy-MM-dd

  @HiveField(1)
  int tasksCompleted;

  @HiveField(2)
  int tasksAdded;

  @HiveField(3)
  int sessionsCompleted;

  @HiveField(4)
  int focusMinutes;

  @HiveField(5)
  DateTime? firstTaskCompletedAt;

  @HiveField(6)
  bool hadAnyCompletion;

  @HiveField(7)
  List<String> completedTaskIds;

  @HiveField(8)
  List<String> completedSessionIds;

  DailyProgress({
    required this.date,
    this.tasksCompleted = 0,
    this.tasksAdded = 0,
    this.sessionsCompleted = 0,
    this.focusMinutes = 0,
    this.firstTaskCompletedAt,
    this.hadAnyCompletion = false,
    List<String>? completedTaskIds,
    List<String>? completedSessionIds,
  })  : completedTaskIds = completedTaskIds ?? [],
        completedSessionIds = completedSessionIds ?? [];

  factory DailyProgress.forToday() {
    return DailyProgress(
      date: _formatDate(DateTime.now()),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool get isToday {
    return date == _formatDate(DateTime.now());
  }
}
```

- [ ] **Step 2: Create streak_data.dart**

```dart
import 'package:hive/hive.dart';

part 'streak_data.g.dart';

@HiveType(typeId: 1)
class StreakData extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  String? lastCompletedDate;  // Format: yyyy-MM-dd

  @HiveField(3)
  int totalTasksCompleted;

  @HiveField(4)
  int totalSessionsCompleted;

  @HiveField(5)
  int totalFocusMinutes;

  @HiveField(6)
  Map<String, int> weeklyTaskCounts;  // date -> count

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.totalTasksCompleted = 0,
    this.totalSessionsCompleted = 0,
    this.totalFocusMinutes = 0,
    Map<String, int>? weeklyTaskCounts,
  }) : weeklyTaskCounts = weeklyTaskCounts ?? {};

  void updateStreak() {
    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (lastCompletedDate == today) {
      return;
    } else if (lastCompletedDate == yesterday) {
      currentStreak++;
      lastCompletedDate = today;
    } else if (lastCompletedDate == null) {
      currentStreak = 1;
      lastCompletedDate = today;
    } else {
      currentStreak = 1;
      lastCompletedDate = today;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 3: Create achievement.dart**

```dart
import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 2)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  bool earned;

  @HiveField(5)
  DateTime? earnedAt;

  @HiveField(6)
  int currentProgress;

  @HiveField(7)
  int targetProgress;

  @HiveField(8)
  String category;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.earned = false,
    this.earnedAt,
    this.currentProgress = 0,
    required this.targetProgress,
    required this.category,
  });

  double get progressPercent =>
      (currentProgress / targetProgress).clamp(0.0, 1.0);
}

class Achievements {
  static List<Achievement> getAll() => [
    // Streak achievements
    Achievement(
      id: 'first_step',
      name: 'First Step',
      description: 'Complete your first task',
      icon: '🏃',
      targetProgress: 1,
      category: 'streak',
    ),
    Achievement(
      id: 'on_fire',
      name: 'On Fire',
      description: 'Maintain a 3-day streak',
      icon: '🔥',
      targetProgress: 3,
      category: 'streak',
    ),
    Achievement(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '📅',
      targetProgress: 7,
      category: 'streak',
    ),
    Achievement(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      icon: '🌟',
      targetProgress: 30,
      category: 'streak',
    ),
    Achievement(
      id: 'century',
      name: 'Century',
      description: 'Maintain a 100-day streak',
      icon: '💯',
      targetProgress: 100,
      category: 'streak',
    ),
    // Task achievements
    Achievement(
      id: 'task_opener',
      name: 'Task Opener',
      description: 'Complete your first task ever',
      icon: '✅',
      targetProgress: 1,
      category: 'tasks',
    ),
    Achievement(
      id: 'quick_master',
      name: 'Quick Master',
      description: 'Complete 10 Quick Energy tasks',
      icon: '⚡',
      targetProgress: 10,
      category: 'tasks',
    ),
    Achievement(
      id: 'deep_diver',
      name: 'Deep Diver',
      description: 'Complete 5 Deep Energy tasks',
      icon: '🧠',
      targetProgress: 5,
      category: 'tasks',
    ),
    Achievement(
      id: 'low_energy_hero',
      name: 'Low Energy Hero',
      description: 'Complete 5 Low Energy tasks',
      icon: '🔋',
      targetProgress: 5,
      category: 'tasks',
    ),
    Achievement(
      id: 'task_collector',
      name: 'Task Collector',
      description: 'Complete 50 tasks total',
      icon: '📋',
      targetProgress: 50,
      category: 'tasks',
    ),
    Achievement(
      id: 'hundred_club',
      name: 'Hundred Club',
      description: 'Complete 100 tasks total',
      icon: '💯',
      targetProgress: 100,
      category: 'tasks',
    ),
    // Session achievements
    Achievement(
      id: 'first_flow',
      name: 'First Flow',
      description: 'Complete your first focus session',
      icon: '🎯',
      targetProgress: 1,
      category: 'sessions',
    ),
    Achievement(
      id: 'flow_starter',
      name: 'Flow Starter',
      description: 'Complete 5 focus sessions',
      icon: '🌊',
      targetProgress: 5,
      category: 'sessions',
    ),
    Achievement(
      id: 'deep_worker',
      name: 'Deep Worker',
      description: 'Complete 10 deep work sessions',
      icon: '⛏️',
      targetProgress: 10,
      category: 'sessions',
    ),
    Achievement(
      id: 'pomodorist',
      name: 'Pomodorist',
      description: 'Complete 25 pomodoro sessions',
      icon: '🍅',
      targetProgress: 25,
      category: 'sessions',
    ),
    // Special achievements
    Achievement(
      id: 'morning_person',
      name: 'Morning Person',
      description: 'Complete morning tasks 5 days',
      icon: '🌅',
      targetProgress: 5,
      category: 'special',
    ),
    Achievement(
      id: 'zone_crusher',
      name: 'Zone Crusher',
      description: 'Complete all zones in one day',
      icon: '💪',
      targetProgress: 1,
      category: 'special',
    ),
  ];
}
```

- [ ] **Step 4: Update pubspec.yaml to add dependencies**

Add to dependencies section:
```yaml
hive: ^2.2.3
hive_flutter: ^1.5.4
confetti: ^0.7.0
```

Add to dev_dependencies:
```yaml
hive_generator: ^2.0.1
build_runner: ^2.4.8
```

Run: `cd focus_flow && flutter pub add hive hive_flutter confetti && flutter pub add --dev hive_generator build_runner`

- [ ] **Step 5: Run build_runner to generate adapters**

Run: `cd focus_flow && flutter pub run build_runner build --delete-conflicting-outputs`

Expected: Creates `.g.dart` files for each model

- [ ] **Step 6: Update main.dart to initialize Hive**

Find the `main()` function in `focus_flow/lib/main.dart` and add:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/daily_progress.dart';
import 'data/models/streak_data.dart';
import 'data/models/achievement.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DailyProgressAdapter());
  Hive.registerAdapter(StreakDataAdapter());
  Hive.registerAdapter(AchievementAdapter());
  await Hive.openBox<DailyProgress>('daily_progress');
  await Hive.openBox<StreakData>('streak_data');
  await Hive.openBox<Achievement>('achievements');

  runApp(ProviderScope(child: FocusFlowApp()));
}
```

- [ ] **Step 7: Commit**

```bash
cd focus_flow
git add lib/data/models/daily_progress.dart lib/data/models/streak_data.dart lib/data/models/achievement.dart pubspec.yaml lib/main.dart
git commit -m "feat: add Hive models for gamification (daily_progress, streak_data, achievement)"
```

---

## Task 2: Gamification Provider

**Files:**
- Create: `focus_flow/lib/providers/gamification_provider.dart`

- [ ] **Step 1: Create gamification_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_progress.dart';
import '../data/models/streak_data.dart';
import '../data/models/achievement.dart';

final gamificationProvider = Provider<GamificationNotifier>((ref) {
  return GamificationNotifier();
});

class GamificationNotifier {
  static const String _dailyProgressBox = 'daily_progress';
  static const String _streakBox = 'streak_data';
  static const String _achievementsBox = 'achievements';

  // Today's progress
  DailyProgress getTodayProgress() {
    final today = _formatDate(DateTime.now());
    final box = _getBox<DailyProgress>(_dailyProgressBox);

    var progress = box.get(today);
    if (progress == null) {
      progress = DailyProgress.forToday();
      box.put(today, progress);
    }
    return progress;
  }

  // Streak data
  StreakData getStreakData() {
    final box = _getBox<StreakData>(_streakBox);
    var data = box.get('main');
    if (data == null) {
      data = StreakData();
      box.put('main', data);
    }
    return data;
  }

  // On task completed
  Future<void> onTaskCompleted(String taskId) async {
    final today = _formatDate(DateTime.now());
    final progress = getTodayProgress();
    final streak = getStreakData();

    if (!progress.completedTaskIds.contains(taskId)) {
      progress.tasksCompleted++;
      progress.completedTaskIds.add(taskId);

      if (!progress.hadAnyCompletion) {
        progress.hadAnyCompletion = true;
        progress.firstTaskCompletedAt = DateTime.now();
      }

      await progress.save();

      streak.totalTasksCompleted++;
      streak.updateStreak();
      await streak.save();
    }

    await _checkAchievements();
  }

  // On session completed
  Future<void> onSessionCompleted(String sessionId, int focusMinutes) async {
    final today = _formatDate(DateTime.now());
    final progress = getTodayProgress();
    final streak = getStreakData();

    if (!progress.completedSessionIds.contains(sessionId)) {
      progress.sessionsCompleted++;
      progress.focusMinutes += focusMinutes;
      progress.completedSessionIds.add(sessionId);

      await progress.save();

      streak.totalSessionsCompleted++;
      streak.totalFocusMinutes += focusMinutes;
      await streak.save();
    }

    await _checkAchievements();
  }

  // Check and award achievements
  Future<void> _checkAchievements() async {
    final box = _getBox<Achievement>(_achievementsBox);
    final streak = getStreakData();
    final progress = getTodayProgress();

    if (box.isEmpty) {
      for (final achievement in Achievements.getAll()) {
        await box.put(achievement.id, achievement);
      }
    }

    for (final achievement in box.values) {
      if (achievement.earned) continue;

      switch (achievement.id) {
        case 'first_step':
        case 'task_opener':
          achievement.currentProgress = streak.totalTasksCompleted >= 1 ? 1 : 0;
          break;
        case 'on_fire':
          achievement.currentProgress = streak.currentStreak;
          break;
        case 'week_warrior':
          achievement.currentProgress = streak.longestStreak >= 7 ? streak.currentStreak : 0;
          break;
        case 'monthly_master':
          achievement.currentProgress = streak.longestStreak >= 30 ? streak.currentStreak : 0;
          break;
        case 'century':
          achievement.currentProgress = streak.longestStreak >= 100 ? streak.currentStreak : 0;
          break;
        case 'quick_master':
        case 'deep_diver':
        case 'low_energy_hero':
          achievement.currentProgress = 0; // TODO: wire up to task energy tracking
          break;
        case 'task_collector':
        case 'hundred_club':
          achievement.currentProgress = streak.totalTasksCompleted;
          break;
        case 'first_flow':
        case 'flow_starter':
        case 'deep_worker':
        case 'pomodorist':
          achievement.currentProgress = streak.totalSessionsCompleted;
          break;
      }

      if (achievement.currentProgress >= achievement.targetProgress) {
        achievement.earned = true;
        achievement.earnedAt = DateTime.now();
      }

      await achievement.save();
    }
  }

  // Get weekly progress
  List<DailyProgress> getWeeklyProgress() {
    final box = _getBox<DailyProgress>(_dailyProgressBox);
    final now = DateTime.now();
    final result = <DailyProgress>[];

    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final progress = box.get(dateStr);
      if (progress != null) {
        result.add(progress);
      } else {
        result.add(DailyProgress(date: dateStr));
      }
    }

    return result;
  }

  // Get all achievements
  List<Achievement> getAchievements() {
    final box = _getBox<Achievement>(_achievementsBox);
    if (box.isEmpty) {
      for (final achievement in Achievements.getAll()) {
        box.put(achievement.id, achievement);
      }
    }
    return box.values.toList();
  }

  T _getBox<T>(String name) {
    return _boxes[name] as T;
  }

  static final Map<String, dynamic> _boxes = {};

  static void registerBox(String name, dynamic box) {
    _boxes[name] = box;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: Update main.dart to register Hive boxes with provider**

After opening Hive boxes in main.dart, add:

```dart
GamificationNotifier.registerBox('daily_progress', Hive.box<DailyProgress>('daily_progress'));
GamificationNotifier.registerBox('streak_data', Hive.box<StreakData>('streak_data'));
GamificationNotifier.registerBox('achievements', Hive.box<Achievement>('achievements'));
```

- [ ] **Step 3: Commit**

```bash
git add lib/providers/gamification_provider.dart lib/main.dart
git commit -m "feat: add gamification provider with streak and achievement tracking"
```

---

## Task 3: Daily Progress Card Widget

**Files:**
- Create: `focus_flow/lib/features/focus/widgets/daily_progress_card.dart`
- Modify: `focus_flow/lib/features/focus/screens/focus_screen.dart`

- [ ] **Step 1: Create daily_progress_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/gamification_provider.dart';

class DailyProgressCard extends ConsumerWidget {
  final int totalTasks;

  const DailyProgressCard({
    super.key,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final todayProgress = gamification.getTodayProgress();
    final streakData = gamification.getStreakData();

    final completed = todayProgress.tasksCompleted;
    final progress = totalTasks > 0 ? completed / totalTasks : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              Text(
                '$completed/$totalTasks tasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(progress: progress),
          const SizedBox(height: 12),
          Row(
            children: [
              _StreakBadge(streak: streakData.currentStreak),
              const SizedBox(width: 16),
              Text(
                'Best: ${streakData.longestStreak} days',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          if (completed > 0) ...[
            const SizedBox(height: 8),
            Text(
              _getEncouragementMessage(completed, streakData.currentStreak),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getEncouragementMessage(int completed, int streak) {
    if (streak >= 7) return 'You\'re on fire! Keep the streak alive!';
    if (streak >= 3) return 'Nice streak! You\'re building momentum.';
    if (completed >= 5) return 'Amazing day so far!';
    if (completed >= 3) return 'Great progress!';
    if (completed >= 1) return 'Nice start!';
    return '';
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final fireEmoji = _getFireEmoji(streak);
    final fireColor = _getFireColor(streak);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(fireEmoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: fireColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fireColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getFireEmoji(int streak) {
    if (streak >= 30) return '🔥🔥🔥';
    if (streak >= 7) return '🔥🔥';
    if (streak >= 1) return '🔥';
    return '💤';
  }

  Color _getFireColor(int streak) {
    if (streak >= 30) return const Color(0xFFEF4444);
    if (streak >= 7) return const Color(0xFFF97316);
    if (streak >= 3) return const Color(0xFFF59E0B);
    if (streak >= 1) return AppColors.teal;
    return AppColors.grey400;
  }
}
```

- [ ] **Step 2: Add to FocusScreen**

In `focus_flow/lib/features/focus/screens/focus_screen.dart`, import and add the card to the top of the screen layout.

- [ ] **Step 3: Commit**

```bash
git add lib/features/focus/widgets/daily_progress_card.dart
git add lib/features/focus/screens/focus_screen.dart  # modified
git commit -m "feat: add DailyProgressCard to FocusScreen"
```

---

## Task 4: Task Completion Celebrations

**Files:**
- Create: `focus_flow/lib/features/focus/widgets/task_completion_celebration.dart`

- [ ] **Step 1: Create task_completion_celebration.dart**

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_colors.dart';

enum CelebrationType {
  quick,
  firstDaily,
  milestone3,
  milestone5,
  allZone,
}

class CelebrationOverlay extends StatefulWidget {
  final CelebrationType type;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  ConfettiController? _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.type == CelebrationType.milestone3 ||
        widget.type == CelebrationType.milestone5) {
      _confettiController = ConfettiController(duration: const Duration(seconds: 1));
      _confettiController?.play();
    }

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildContent(),
              ),
            ),
            if (_confettiController != null)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController!,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    AppColors.teal,
                    AppColors.amber,
                    AppColors.energyQuick,
                    Color(0xFFF472B6),
                    Color(0xFF818CF8),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case CelebrationType.quick:
        return _buildCheckmark();
      case CelebrationType.firstDaily:
        return _buildToast('Nice start! 🎉');
      case CelebrationType.milestone3:
        return _buildToast('Getting momentum! 💪');
      case CelebrationType.milestone5:
        return _buildBigCelebration();
      case CelebrationType.allZone:
        return _buildZoneComplete();
    }
  }

  Widget _buildCheckmark() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildToast(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBigCelebration() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You\'re on fire! 🔥',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneComplete() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              'Zone Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

CelebrationType getCelebrationType(int completedToday) {
  if (completedToday == 1) return CelebrationType.firstDaily;
  if (completedToday == 3) return CelebrationType.milestone3;
  if (completedToday == 5) return CelebrationType.milestone5;
  return CelebrationType.quick;
}
```

- [ ] **Step 2: Integrate into task completion flow**

In the task completion handler in FocusScreen (where tasks are marked complete), wrap the completion with celebration overlay.

- [ ] **Step 3: Commit**

```bash
git add lib/features/focus/widgets/task_completion_celebration.dart
git commit -m "feat: add task completion celebration animations"
```

---

## Task 5: Weekly Summary Card

**Files:**
- Create: `focus_flow/lib/features/rest/widgets/weekly_summary_card.dart`
- Modify: `focus_flow/lib/features/rest/screens/rest_screen.dart`

- [ ] **Step 1: Create weekly_summary_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/gamification_provider.dart';

class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final weeklyProgress = gamification.getWeeklyProgress();
    final streakData = gamification.getStreakData();

    final totalTasks = weeklyProgress.fold<int>(
      0,
      (sum, p) => sum + p.tasksCompleted,
    );
    final totalSessions = weeklyProgress.fold<int>(
      0,
      (sum, p) => sum + p.sessionsCompleted,
    );
    final totalMinutes = weeklyProgress.fold<int>(
      0,
      (sum, p) => sum + p.focusMinutes,
    );

    final bestDayIndex = _findBestDay(weeklyProgress);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Weekly Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(
                icon: '✅',
                label: 'Tasks',
                value: '$totalTasks',
              ),
              _StatItem(
                icon: '🎯',
                label: 'Sessions',
                value: '$totalSessions',
              ),
              _StatItem(
                icon: '⏱️',
                label: 'Focus',
                value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward, size: 12, color: AppColors.success),
                const SizedBox(width: 2),
                Text(
                  '+$totalTasks',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'tasks this week',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          if (bestDayIndex >= 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Best day: ${_getDayName(bestDayIndex)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${weeklyProgress[bestDayIndex].tasksCompleted} tasks',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _getEncouragementMessage(totalTasks, streakData.currentStreak),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  int _findBestDay(List<dynamic> weeklyProgress) {
    var bestIndex = -1;
    var bestCount = 0;
    for (var i = 0; i < weeklyProgress.length; i++) {
      final count = weeklyProgress[i].tasksCompleted as int;
      if (count > bestCount) {
        bestCount = count;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  String _getDayName(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayIndex = (DateTime.now().weekday - 7 + index) % 7;
    return days[dayIndex];
  }

  String _getEncouragementMessage(int tasks, int streak) {
    if (tasks >= 30) return 'Incredible week! You\'re unstoppable!';
    if (tasks >= 20) return 'Solid week! You\'re building great habits.';
    if (tasks >= 10) return 'Nice work this week! Every task counts.';
    if (streak >= 3) return 'Your streak is building momentum!';
    if (tasks > 0) return 'You showed up! That\'s what matters.';
    return 'Ready to get started this week?';
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add to RestScreen**

In `focus_flow/lib/features/rest/screens/rest_screen.dart`, add the WeeklySummaryCard.

- [ ] **Step 3: Commit**

```bash
git add lib/features/rest/widgets/weekly_summary_card.dart
git add lib/features/rest/screens/rest_screen.dart  # modified
git commit -m "feat: add WeeklySummaryCard to RestScreen"
```

---

## Task 6: Achievements Tab

**Files:**
- Create: `focus_flow/lib/features/library/widgets/achievements_tab.dart`
- Modify: `focus_flow/lib/features/library/screens/library_screen.dart`

- [ ] **Step 1: Create achievements_tab.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/achievement.dart';
import '../../../providers/gamification_provider.dart';

class AchievementsTab extends ConsumerWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final achievements = gamification.getAchievements();

    achievements.sort((a, b) {
      if (a.earned && !b.earned) return -1;
      if (!a.earned && b.earned) return 1;
      return b.progressPercent.compareTo(a.progressPercent);
    });

    final streakAchievements = achievements.where((a) => a.category == 'streak').toList();
    final taskAchievements = achievements.where((a) => a.category == 'tasks').toList();
    final sessionAchievements = achievements.where((a) => a.category == 'sessions').toList();
    final specialAchievements = achievements.where((a) => a.category == 'special').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (streakAchievements.isNotEmpty) ...[
          _CategoryHeader(icon: '🔥', title: 'Streaks'),
          ...streakAchievements.map((a) => _AchievementCard(achievement: a)),
          const SizedBox(height: 16),
        ],
        if (taskAchievements.isNotEmpty) ...[
          _CategoryHeader(icon: '✅', title: 'Tasks'),
          ...taskAchievements.map((a) => _AchievementCard(achievement: a)),
          const SizedBox(height: 16),
        ],
        if (sessionAchievements.isNotEmpty) ...[
          _CategoryHeader(icon: '🎯', title: 'Sessions'),
          ...sessionAchievements.map((a) => _AchievementCard(achievement: a)),
          const SizedBox(height: 16),
        ],
        if (specialAchievements.isNotEmpty) ...[
          _CategoryHeader(icon: '⭐', title: 'Special'),
          ...specialAchievements.map((a) => _AchievementCard(achievement: a)),
        ],
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String icon;
  final String title;

  const _CategoryHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isEarned = achievement.earned;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEarned ? AppColors.white : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: isEarned
            ? Border.all(color: AppColors.teal.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Opacity(
        opacity: isEarned ? 1.0 : 0.6,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(achievement.category).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      if (isEarned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  if (!isEarned) ...[
                    const SizedBox(height: 8),
                    _AchievementProgressBar(achievement: achievement),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'streak':
        return AppColors.amber;
      case 'tasks':
        return AppColors.energyQuick;
      case 'sessions':
        return AppColors.teal;
      case 'special':
        return AppColors.energyDeep;
      default:
        return AppColors.grey500;
    }
  }
}

class _AchievementProgressBar extends StatelessWidget {
  final Achievement achievement;

  const _AchievementProgressBar({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final progress = achievement.progressPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(achievement.category),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.currentProgress}/${achievement.targetProgress}',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'streak':
        return AppColors.amber;
      case 'tasks':
        return AppColors.energyQuick;
      case 'sessions':
        return AppColors.teal;
      case 'special':
        return AppColors.energyDeep;
      default:
        return AppColors.grey500;
    }
  }
}
```

- [ ] **Step 2: Add tab to LibraryScreen**

In `focus_flow/lib/features/library/screens/library_screen.dart`, add a new tab for achievements that uses this widget.

- [ ] **Step 3: Commit**

```bash
git add lib/features/library/widgets/achievements_tab.dart
git add lib/features/library/screens/library_screen.dart  # modified
git commit -m "feat: add AchievementsTab to LibraryScreen"
```

---

## Task 7: Stats Section (Settings)

**Files:**
- Create: `focus_flow/lib/features/settings/widgets/stats_section.dart`
- Modify: `focus_flow/lib/features/settings/screens/settings_screen.dart`

- [ ] **Step 1: Create stats_section.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/gamification_provider.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final streakData = gamification.getStreakData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR STATS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.teal,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: '🔥',
            iconColor: AppColors.amber,
            label: 'Current Streak',
            value: '${streakData.currentStreak} ${streakData.currentStreak == 1 ? 'day' : 'days'}',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: '⭐',
            iconColor: AppColors.amber,
            label: 'Longest Streak',
            value: '${streakData.longestStreak} ${streakData.longestStreak == 1 ? 'day' : 'days'}',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: '✅',
            iconColor: AppColors.energyQuick,
            label: 'Total Tasks',
            value: '${streakData.totalTasksCompleted} tasks',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: '🎯',
            iconColor: AppColors.teal,
            label: 'Total Sessions',
            value: '${streakData.totalSessionsCompleted} sessions',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: '⏱️',
            iconColor: AppColors.energyDeep,
            label: 'Focus Time',
            value: '${(streakData.totalFocusMinutes / 60).toStringAsFixed(1)} hours',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Add to SettingsScreen**

In `focus_flow/lib/features/settings/screens/settings_screen.dart`, add the StatsSection.

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/widgets/stats_section.dart
git add lib/features/settings/screens/settings_screen.dart  # modified
git commit -m "feat: add StatsSection to SettingsScreen"
```

---

## Integration Checklist

After implementing all tasks:

- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Hive adapters
- [ ] Build the app: `flutter build`
- [ ] Test task completion celebrations on FocusScreen
- [ ] Test streak increments after completing tasks on consecutive days
- [ ] Verify achievement progress updates correctly
- [ ] Check weekly summary displays on RestScreen
- [ ] Verify achievements tab in LibraryScreen
- [ ] Check stats section in SettingsScreen
