# FocusFlow Gamification — Implementation Document

**Date**: 2026-04-24
**Project**: FocusFlow Flutter App
**Purpose**: Gamification system design and implementation guide
**Scope**: Streak system, task celebrations, progress visualization, achievements

---

## 1. Design Philosophy

### ADHD-Friendly Gamification Principles

| Principle | Implementation |
|-----------|-----------------|
| **Immediate rewards** | Celebration triggers instantly on task completion, not delayed |
| **Visual progress** | Progress bars and streaks are visible at a glance, not hidden |
| **Easy wins count** | Any task completion maintains streak, no minimum threshold |
| **Positive framing** | Always celebrate progress, never mention "missed" or "failed" |
| **No punishment** | Broken streaks reset gracefully with encouraging message |
| **Dopamine hits** | Small animations throughout the day maintain engagement |
| **Consistency > Big wins** | Reward showing up, not just massive achievements |

---

## 2. Flutter Navigation Structure

| Index | Label | Icon | Route | Screen |
|-------|-------|------|-------|--------|
| 0 | Focus | `adjust` | `/focus` | FocusScreen |
| 1 | Flow | `play_circle` | `/flow` | FlowScreen |
| 2 | Library | `library_books` | `/library` | LibraryScreen |
| 3 | Rest | `self_improvement` | `/rest` | RestScreen |

Settings accessible via `/settings` route.

---

## 3. Gamification Screens Overview

```
┌─────────────────────────────────────────────────┐
│                   FOCUS SCREEN                    │
│                   Route: /focus                   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ DailyProgressCard                        │   │
│  │ ████████████░░░░░  6/10 tasks           │   │
│  │ 🔥 7 day streak  |  Best: 14 days       │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [Task zones with completion animations]        │
│                                                 │
│  [Checkmark tap → celebration]                  │
│                                                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                    REST SCREEN                   │
│                    Route: /rest                   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ Weekly Summary Card                      │   │
│  │                                         │   │
│  │ "You completed 23 tasks this week!"     │   │
│  │ That's 5 more than last week.          │   │
│  │                                         │   │
│  │ 🏆 Best: Wednesday                      │   │
│  │ ⏰ Most productive: Morning              │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [Encouragement message based on stats]          │
│                                                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                   LIBRARY SCREEN                  │
│                   Route: /library                  │
│                                                 │
│  ┌─────────┬─────────┬─────────┬─────────┐      │
│  │Sessions │Templates│Favorites│ Badges   │      │
│  └─────────┴─────────┴─────────┴─────────┘      │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ ACHIEVEMENTS                             │   │
│  │                                         │   │
│  │ 🏃 First Step        ✅ Earned!         │   │
│  │    Complete 1 task                      │   │
│  │                                         │   │
│  │ 🔥 On Fire           4/7 days           │   │
│  │    3 day streak      ████████░░          │   │
│  │                                         │   │
│  │ 📅 Week Warrior      0/7 days            │   │
│  │    7 day streak     ░░░░░░░░░░          │   │
│  │                                         │   │
│  │ ⚡ Quick Master       3/10              │   │
│  │    10 Quick tasks   ████████░░          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                   SETTINGS SCREEN                 │
│                   Route: /settings                │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ YOUR STATS                               │   │
│  │                                         │   │
│  │ Current Streak      🔥 7 days           │   │
│  │ Longest Streak      ⭐ 14 days           │   │
│  │ Total Tasks         ✅ 142 tasks         │   │
│  │ Total Sessions      🎯 28 sessions       │   │
│  │ Focus Time          ⏱️ 42 hours          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 3. Hive Data Models

### 3.1 DailyProgress

**File**: `lib/data/models/daily_progress.dart`

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

### 3.2 StreakData

**File**: `lib/data/models/streak_data.dart`

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

  // Calculate streak based on last completed date
  void updateStreak() {
    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (lastCompletedDate == today) {
      // Already completed today, no change
      return;
    } else if (lastCompletedDate == yesterday) {
      // Completed yesterday, continue streak
      currentStreak++;
      lastCompletedDate = today;
    } else if (lastCompletedDate == null) {
      // First ever completion
      currentStreak = 1;
      lastCompletedDate = today;
    } else {
      // Streak broken, start fresh
      currentStreak = 1;
      lastCompletedDate = today;
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 3.3 Achievement

**File**: `lib/data/models/achievement.dart`

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
  String icon;  // Emoji or icon name

  @HiveField(4)
  bool earned;

  @HiveField(5)
  DateTime? earnedAt;

  @HiveField(6)
  int currentProgress;

  @HiveField(7)
  int targetProgress;

  @HiveField(8)
  String category;  // 'streak', 'tasks', 'sessions', 'special'

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

// Predefined achievements
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

    // Zone achievements
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

### 3.4 Hive Box Initialization

**File**: `lib/data/hive_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'models/daily_progress.dart';
import 'models/streak_data.dart';
import 'models/achievement.dart';

class HiveService {
  static const String dailyProgressBox = 'daily_progress';
  static const String streakBox = 'streak_data';
  static const String achievementsBox = 'achievements';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(DailyProgressAdapter());
    Hive.registerAdapter(StreakDataAdapter());
    Hive.registerAdapter(AchievementAdapter());

    // Open boxes
    await Hive.openBox<DailyProgress>(dailyProgressBox);
    await Hive.openBox<StreakData>(streakBox);
    await Hive.openBox<Achievement>(achievementsBox);
  }

  static Box<DailyProgress> get dailyProgressBox =>
      Hive.box<DailyProgress>(dailyProgressBox);

  static Box<StreakData> get streakBox =>
      Hive.box<StreakData>(streakBox);

  static Box<Achievement> get achievementsBox =>
      Hive.box<Achievement>(achievementsBox);
}
```

---

## 4. Riverpod Providers

### 4.1 Gamification Provider

**File**: `lib/providers/gamification_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hive_service.dart';
import '../data/models/daily_progress.dart';
import '../data/models/streak_data.dart';
import '../data/models/achievement.dart';

final gamificationProvider = Provider<GamificationNotifier>((ref) {
  return GamificationNotifier();
});

class GamificationNotifier {
  // Today's progress
  DailyProgress getTodayProgress() {
    final today = _formatDate(DateTime.now());
    final box = HiveService.dailyProgressBox;

    var progress = box.get(today);
    if (progress == null) {
      progress = DailyProgress.forToday();
      box.put(today, progress);
    }
    return progress;
  }

  // Streak data
  StreakData getStreakData() {
    final box = HiveService.streakBox;
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

    // Update daily progress
    if (!progress.completedTaskIds.contains(taskId)) {
      progress.tasksCompleted++;
      progress.completedTaskIds.add(taskId);

      if (!progress.hadAnyCompletion) {
        progress.hadAnyCompletion = true;
        progress.firstTaskCompletedAt = DateTime.now();
      }

      await HiveService.dailyProgressBox.put(today, progress);

      // Update streak
      streak.totalTasksCompleted++;
      streak.updateStreak();
      await HiveService.streakBox.put('main', streak);
    }

    // Check achievements
    await _checkAchievements();
  }

  // On session completed
  Future<void> onSessionCompleted(String sessionId, int focusMinutes) async {
    final today = _formatDate(DateTime.now());
    final progress = getTodayProgress();
    final streak = getStreakData();

    // Update daily progress
    if (!progress.completedSessionIds.contains(sessionId)) {
      progress.sessionsCompleted++;
      progress.focusMinutes += focusMinutes;
      progress.completedSessionIds.add(sessionId);

      await HiveService.dailyProgressBox.put(today, progress);

      // Update streak
      streak.totalSessionsCompleted++;
      streak.totalFocusMinutes += focusMinutes;
      await HiveService.streakBox.put('main', streak);
    }

    // Check achievements
    await _checkAchievements();
  }

  // Check and award achievements
  Future<void> _checkAchievements() async {
    final box = HiveService.achievementsBox;
    final streak = getStreakData();
    final progress = getTodayProgress();

    // Initialize achievements if empty
    if (box.isEmpty) {
      for (final achievement in Achievements.getAll()) {
        await box.put(achievement.id, achievement);
      }
    }

    // Update progress for each achievement
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
          achievement.currentProgress = _countTasksByEnergy('quick');
          break;
        case 'deep_diver':
          achievement.currentProgress = _countTasksByEnergy('deep');
          break;
        case 'low_energy_hero':
          achievement.currentProgress = _countTasksByEnergy('low');
          break;
        case 'task_collector':
          achievement.currentProgress = streak.totalTasksCompleted;
          break;
        case 'hundred_club':
          achievement.currentProgress = streak.totalTasksCompleted;
          break;
        case 'first_flow':
        case 'flow_starter':
          achievement.currentProgress = streak.totalSessionsCompleted;
          break;
        case 'deep_worker':
          achievement.currentProgress = streak.totalSessionsCompleted;
          break;
        case 'pomodorist':
          achievement.currentProgress = streak.totalSessionsCompleted;
          break;
      }

      // Check if earned
      if (achievement.currentProgress >= achievement.targetProgress) {
        achievement.earned = true;
        achievement.earnedAt = DateTime.now();
        // Trigger celebration
        _triggerCelebration(achievement);
      }

      await box.put(achievement.id, achievement);
    }
  }

  int _countTasksByEnergy(String energy) {
    // This would query from task repository
    // For now, return 0 - implement based on your task storage
    return 0;
  }

  void _triggerCelebration(Achievement achievement) {
    // This will trigger a celebration animation/sound
    // Handled by celebration provider
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get weekly progress for past 7 days
  List<DailyProgress> getWeeklyProgress() {
    final box = HiveService.dailyProgressBox;
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
}
```

---

## 5. Screen Specifications

### 5.1 Today Screen — Daily Progress Card

**File**: `lib/features/today/widgets/daily_progress_card.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Card background | White, 12px radius, 2dp shadow |
| Progress bar | Teal fill on grey-100 track, 8px height, 4px radius |
| Progress text | "5/10 tasks" — 14px, Inter SemiBold, navy |
| Streak display | Fire emoji + number + "day streak" — 14px |
| Best streak | "Best: X days" — 12px, grey-500 |
| Card padding | 16px all sides |
| Card margin | 16px horizontal |

### Code

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              Text(
                '$completed/$totalTasks tasks',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          _ProgressBar(progress: progress, completed: completed),

          const SizedBox(height: 12),

          // Streak row
          Row(
            children: [
              _StreakBadge(streak: streakData.currentStreak),
              const SizedBox(width: 16),
              Text(
                'Best: ${streakData.longestStreak} days',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),

          // Encouragement message
          if (completed > 0) ...[
            const SizedBox(height: 8),
            Text(
              _getEncouragementMessage(completed, streakData.currentStreak),
              style: GoogleFonts.inter(
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
  final int completed;

  const _ProgressBar({
    required this.progress,
    required this.completed,
  });

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
            style: GoogleFonts.inter(
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
    if (streak >= 30) return const Color(0xFFEF4444);  // Red for 30+
    if (streak >= 7) return const Color(0xFFF97316);   // Orange for 7+
    if (streak >= 3) return const Color(0xFFF59E0B);   // Amber for 3+
    if (streak >= 1) return AppColors.teal;
    return AppColors.grey400;
  }
}
```

### 5.2 Task Completion Celebration

**File**: `lib/features/today/widgets/task_completion_celebration.dart`

### Celebration Triggers

| Trigger | Animation | Duration |
|---------|-----------|----------|
| Any task completed | Scale bounce + checkmark | 300ms |
| First daily task | "Nice start!" toast | 2s |
| 3rd task today | Small confetti | 1s |
| 5th task today | Big confetti | 2s |
| All zone tasks | Zone badge pop | 500ms |

### Code

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/gamification_provider.dart';

// Celebration types
enum CelebrationType {
  quick,      // Normal task completion
  firstDaily, // First task today
  milestone3, // 3rd task
  milestone5, // 5th task
  allZone,     // All tasks in zone completed
}

// Celebration overlay
class CelebrationOverlay extends ConsumerStatefulWidget {
  final CelebrationType type;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.onComplete,
  });

  @override
  ConsumerState<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case CelebrationType.quick:
        return _QuickCheckmark();
      case CelebrationType.firstDaily:
        return _ToastMessage(message: 'Nice start! 🎉');
      case CelebrationType.milestone3:
        return _SmallConfetti();
      case CelebrationType.milestone5:
        return _BigConfetti(message: 'You\'re on fire! 🔥');
      case CelebrationType.allZone:
        return _ZoneComplete();
    }
  }
}

class _QuickCheckmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _ToastMessage extends StatelessWidget {
  final String message;

  const _ToastMessage({required this.message});

  @override
  Widget build(BuildContext context) {
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
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SmallConfetti extends StatefulWidget {
  @override
  State<_SmallConfetti> createState() => _SmallConfettiState();
}

class _SmallConfettiState extends State<_SmallConfetti> {
  final _random = Random();
  final List<_ConfettiPiece> _pieces = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 20; i++) {
      _pieces.add(_ConfettiPiece(
        x: _random.nextDouble(),
        y: 0.5,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        size: 8 + _random.nextDouble() * 4,
        angle: _random.nextDouble() * pi * 2,
        speed: 0.5 + _random.nextDouble() * 0.5,
      ));
    }
  }

  static const _confettiColors = [
    AppColors.teal,
    AppColors.amber,
    AppColors.energyQuick,
    Color(0xFFF472B6),  // Pink
    Color(0xFF818CF8),  // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();  // Simplified - extend with AnimationController
  }
}

class _ConfettiPiece {
  double x;
  double y;
  final Color color;
  final double size;
  double angle;
  final double speed;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.angle,
    required this.speed,
  });
}

class _BigConfetti extends StatelessWidget {
  final String message;

  const _BigConfetti({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎉',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: GoogleFonts.montserrat(
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
}

class _ZoneComplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              style: GoogleFonts.montserrat(
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

// Celebration trigger helper
class CelebrationHelper {
  static CelebrationType getCelebrationType(int completedToday) {
    if (completedToday == 1) return CelebrationType.firstDaily;
    if (completedToday == 3) return CelebrationType.milestone3;
    if (completedToday == 5) return CelebrationType.milestone5;
    return CelebrationType.quick;
  }
}
```

### 5.3 Rest Screen — Weekly Summary Card

**File**: `lib/features/rest/widgets/weekly_summary_card.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Card background | White, 12px radius |
| Card header | "Weekly Summary" — 16px, Montserrat SemiBold |
| Stat row | Icon + label + value |
| Comparison text | "X more than last week" — green for positive |
| Best day highlight | Highlighted row with amber accent |
| Encouragement | Bottom text, italic, 13px |

### Code

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // Find best day
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
          // Header
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Weekly Summary',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats grid
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

          // Comparison with last week
          _ComparisonRow(
            thisWeek: totalTasks,
            label: 'tasks this week',
            isPositive: true,  // In real impl, compare with last week data
          ),

          const SizedBox(height: 16),

          // Best day highlight
          if (bestDayIndex >= 0) ...[
            _BestDayRow(
              dayName: _getDayName(bestDayIndex),
              taskCount: weeklyProgress[bestDayIndex].tasksCompleted,
            ),
          ],

          const SizedBox(height: 12),

          // Encouragement
          Text(
            _getEncouragementMessage(totalTasks, streakData.currentStreak),
            style: GoogleFonts.inter(
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
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final int thisWeek;
  final String label;
  final bool isPositive;

  const _ComparisonRow({
    required this.thisWeek,
    required this.label,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPositive
                ? AppColors.success.withOpacity(0.15)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? AppColors.success : AppColors.grey500,
              ),
              const SizedBox(width: 2),
              Text(
                '$thisWeek',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}

class _BestDayRow extends StatelessWidget {
  final String dayName;
  final int taskCount;

  const _BestDayRow({
    required this.dayName,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Best day: $dayName',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const Spacer(),
          Text(
            '$taskCount tasks',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.4 Library Screen — Achievements Tab

**File**: `lib/features/library/widgets/achievements_tab.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Achievement card | White, 12px radius, 8px margin |
| Icon | 40×40px, colored circle bg based on category |
| Progress bar | Colored fill based on category, 4px height |
| Earned badge | Checkmark overlay, full opacity |
| Unearned badge | Grey overlay, 60% opacity |
| Progress text | "X/Y" below progress bar |

### Code

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/achievement.dart';
import '../../../data/hive_service.dart';

class AchievementsTab extends ConsumerWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = HiveService.achievementsBox;
    final achievements = box.values.toList() as List<Achievement>;

    // Sort: earned first, then by progress
    achievements.sort((a, b) {
      if (a.earned && !b.earned) return -1;
      if (!a.earned && b.earned) return 1;
      return b.progressPercent.compareTo(a.progressPercent);
    });

    // Group by category
    final streakAchievements = achievements
        .where((a) => a.category == 'streak')
        .toList();
    final taskAchievements = achievements
        .where((a) => a.category == 'tasks')
        .toList();
    final sessionAchievements = achievements
        .where((a) => a.category == 'sessions')
        .toList();
    final specialAchievements = achievements
        .where((a) => a.category == 'special')
        .toList();

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

  const _CategoryHeader({
    required this.icon,
    required this.title,
  });

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
            style: GoogleFonts.montserrat(
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
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(achievement.category).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      if (isEarned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  if (!isEarned) ...[
                    const SizedBox(height: 8),
                    // Progress bar
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
          style: GoogleFonts.inter(
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

### 5.5 Settings Screen — Stats Section

**File**: `lib/features/settings/widgets/stats_section.dart`

### Code

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
            style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
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

---

## 6. Celebration Trigger Points

| Event | Trigger | Animation | Sound | Frequency |
|-------|---------|-----------|-------|-----------|
| Task completed | Tap checkmark | Scale bounce + checkmark | Soft "ding" | Every time |
| First daily task | After first completion | "Nice start!" toast | — | Once per day |
| 3rd task today | After 3rd completion | Small confetti | — | Once per day |
| 5th task today | After 5th completion | Big confetti + message | Chime | Once per day |
| All zone completed | After last zone task | Badge pop + glow | Success chime | Once per zone per day |
| Flow session done | Timer completes | Circle fill + pulse | Chime | Every session |
| Streak milestone | On app open (if milestone) | Fire grows animation | — | When milestone reached |
| New badge earned | When progress ≥ target | Full-screen badge reveal | Fanfare | When earned |
| All tasks done | After last task | Big celebration | Success fanfare | Once per day max |

---

## 7. Color System for Gamification

| Element | Color | Hex | Usage |
|--------|-------|-----|-------|
| Streak fire low | Amber | `#F59E0B` | 1-2 day streak |
| Streak fire mid | Orange | `#F97316` | 3-6 day streak |
| Streak fire high | Red | `#EF4444` | 7+ day streak |
| Success green | Green | `#10B981` | Checkmarks, earned badges |
| Progress bar | Teal | `#0F969C` | Progress fills |
| Confetti 1 | Teal | `#0F969C` | Celebration confetti |
| Confetti 2 | Amber | `#F5A623` | Celebration confetti |
| Confetti 3 | Green | `#10B981` | Celebration confetti |
| Confetti 4 | Pink | `#F472B6` | Celebration confetti |
| Confetti 5 | Indigo | `#818CF8` | Celebration confetti |
| Badge earned border | Teal | `#0F969C` | 30% opacity border |
| Badge unearned | Grey | `#9CA3AF` | 60% opacity |

---

## 8. Dependencies

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.5.4
  google_fonts: ^6.1.0
  confetti: ^0.7.0         # For confetti celebrations
  lottie: ^3.1.0          # For complex animations (optional)

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.1
```

---

## 9. Integration Checklist

| Item | File | Status |
|------|------|--------|
| Hive setup | `lib/data/hive_service.dart` | Create |
| DailyProgress model | `lib/data/models/daily_progress.dart` | Create |
| StreakData model | `lib/data/models/streak_data.dart` | Create |
| Achievement model | `lib/data/models/achievement.dart` | Create |
| Gamification provider | `lib/providers/gamification_provider.dart` | Create |
| DailyProgressCard widget | `lib/features/today/widgets/daily_progress_card.dart` | Create |
| Celebration widgets | `lib/features/today/widgets/task_completion_celebration.dart` | Create |
| WeeklySummaryCard | `lib/features/rest/widgets/weekly_summary_card.dart` | Create |
| AchievementsTab | `lib/features/library/widgets/achievements_tab.dart` | Create |
| StatsSection | `lib/features/settings/widgets/stats_section.dart` | Create |
| Run build_runner | Terminal | `flutter pub run build_runner build --delete-conflicting-outputs` |

---

## 10. Achievement List

### Streak Achievements (5)

| ID | Name | Icon | Target | Description |
|----|------|------|--------|-------------|
| first_step | First Step | 🏃 | 1 day | Complete first task |
| on_fire | On Fire | 🔥 | 3 days | 3-day streak |
| week_warrior | Week Warrior | 📅 | 7 days | 7-day streak |
| monthly_master | Monthly Master | 🌟 | 30 days | 30-day streak |
| century | Century | 💯 | 100 days | 100-day streak |

### Task Achievements (6)

| ID | Name | Icon | Target | Description |
|----|------|------|--------|-------------|
| task_opener | Task Opener | ✅ | 1 task | Complete first task ever |
| quick_master | Quick Master | ⚡ | 10 tasks | Complete 10 Quick tasks |
| deep_diver | Deep Diver | 🧠 | 5 tasks | Complete 5 Deep tasks |
| low_energy_hero | Low Energy Hero | 🔋 | 5 tasks | Complete 5 Low tasks |
| task_collector | Task Collector | 📋 | 50 tasks | Complete 50 tasks |
| hundred_club | Hundred Club | 💯 | 100 tasks | Complete 100 tasks |

### Session Achievements (4)

| ID | Name | Icon | Target | Description |
|----|------|------|--------|-------------|
| first_flow | First Flow | 🎯 | 1 session | Complete first session |
| flow_starter | Flow Starter | 🌊 | 5 sessions | Complete 5 sessions |
| deep_worker | Deep Worker | ⛏️ | 10 sessions | Complete 10 deep sessions |
| pomodorist | Pomodorist | 🍅 | 25 sessions | Complete 25 pomodoro sessions |

### Special Achievements (2)

| ID | Name | Icon | Target | Description |
|----|------|------|--------|-------------|
| morning_person | Morning Person | 🌅 | 5 days | Complete morning tasks 5 days |
| zone_crusher | Zone Crusher | 💪 | 1 day | Complete all zones in one day |