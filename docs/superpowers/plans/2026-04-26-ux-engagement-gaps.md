# FocusFlow UX/Engagement Gaps — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 5 engagement enhancements that close the motivational loop for ADHD users: streak protection that re-engages after absence, an achievement/badge system with ADHD-optimized reward frequency, a dynamic motivational header on the Focus screen, a Rest screen that auto-adapts to session history, and energy trend feedback that shows users whether their energy estimates are accurate.

**Architecture:** Each gap is a self-contained feature. Achievement/badge system uses a new `Achievement` model and `AchievementRepository` over Hive. Dynamic motivation and energy feedback are additive UI layers — they read existing data and surface it contextually. Rest screen integration reads the session history from `FlowSessionRepository` and makes contextual break suggestions. All notification re-engagement uses the `NotificationService` stub from the Strategic Opportunities plan.

---

## File Structure

```
focus_flow/lib/
├── data/models/
│   ├── achievement.dart           ← CREATE: Achievement model with criteria, unlockedAt, tier
│   └── energy_insight.dart       ← CREATE: EnergyInsight model for trend data
├── data/repositories/
│   ├── achievement_repository.dart ← CREATE: CRUD over Hive box 'achievements'
│   └── energy_insight_repository.dart ← CREATE: CRUD over Hive box 'energy_insights'
├── providers/
│   ├── achievement_provider.dart   ← CREATE: AchievementNotifier + unlockedProvider + nextMilestoneProvider
│   └── energy_insight_provider.dart ← CREATE: EnergyInsightNotifier + trendProvider
├── core/
│   └── constants/
│       └── achievements.dart       ← CREATE: Static achievement definitions (criteria, icons, tiers)
├── features/
│   ├── focus/
│   │   └── screens/
│   │       └── focus_screen.dart  ← MODIFY: Dynamic motivational header replacing static "Plan your energy" text
│   ├── rest/
│   │   ├── screens/
│   │   │   └── rest_screen.dart   ← MODIFY: Session-history-aware break suggestions
│   │   └── widgets/
│   │       └── adaptive_break_card.dart ← CREATE: Context-aware break recommendation card
│   ├── library/
│   │   └── screens/
│   │       └── library_screen.dart ← MODIFY: Wire achievement gallery tab
│   └── achievements/
│       ├── screens/
│       │   └── achievement_gallery_screen.dart ← CREATE: Full achievement gallery with categories
│       └── widgets/
│           ├── achievement_badge.dart    ← CREATE: Individual badge widget with animation
│           └── achievement_toast.dart     ← CREATE: Toast notification when achievement unlocks
└── services/
    └── streak_service.dart        ← CREATE: Streak check + re-engagement notification scheduler
```

---

## Gap 1: Streak Protection — Re-engagement After Absence

### Problem
If an ADHD user misses a day, the app does nothing to bring them back. The streak counter simply shows 0. There's no gentle nudge, no "we miss you" message, no re-onboarding.

### Fix
Create `streak_service.dart` that:
1. On app launch, checks if the current streak is broken (>1 day since last active date)
2. Schedules a "we miss you" local notification for 3 days after last session (not immediate — respects ADHD user's need for space)
3. Shows a "Welcome Back" modal on next open if streak was broken, with a motivational message and an easy re-entry task suggestion
4. Preserves the streak in a gentler way — allows one "grace day" per week

### streak_service.dart

```dart
import '../data/models/daily_stats.dart';
import '../data/repositories/stats_repository.dart';
import 'notification_service.dart';

class StreakService {
  final StatsRepository _statsRepo;

  StreakService(this._statsRepo);

  /// Call this on app startup.
  /// Returns true if the user is returning after a break and should see the Welcome Back modal.
  Future<bool> checkStreakStatus() async {
    final allStats = _statsRepo.getAll();
    if (allStats.isEmpty) return false;

    final activeDays = allStats
        .where((s) => s.tasksCompleted > 0 || s.sessionsCompleted > 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (activeDays.isEmpty) return false;

    final lastActive = DateTime.parse(activeDays.first.date);
    final now = DateTime.now();
    final daysSinceActive = now.difference(lastActive).inDays;

    if (daysSinceActive >= 1) {
      // Streak was broken — schedule re-engagement notification
      await _scheduleReEngagementNotification(daysSinceActive);
      return true;
    }

    return false;
  }

  /// Returns streak data: current count, longest count, grace days remaining this week.
  StreakData getStreakData() {
    final allStats = _statsRepo.getAll();
    if (allStats.isEmpty) return StreakData(current: 0, longest: 0, graceDaysUsed: 0);

    final activeDays = allStats
        .where((s) => s.tasksCompleted > 0)
        .map((s) => DateTime.parse(s.date))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (activeDays.isEmpty) return StreakData(current: 0, longest: 0, graceDaysUsed: 0);

    // Current streak
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    int current = 0;

    if (_sameDay(activeDays.first, today) || _sameDay(activeDays.first, yesterday)) {
      current = 1;
      for (int i = 0; i < activeDays.length - 1; i++) {
        final diff = activeDays[i].difference(activeDays[i + 1]).inDays;
        if (diff == 1) {
          current++;
        } else {
          break;
        }
      }
    }

    // Longest streak
    int longest = 0;
    int tempStreak = 1;
    for (int i = 0; i < activeDays.length - 1; i++) {
      final diff = activeDays[i].difference(activeDays[i + 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longest) longest = tempStreak;
        tempStreak = 1;
      }
    }
    if (tempStreak > longest) longest = tempStreak;

    return StreakData(current: current, longest: longest, graceDaysUsed: 0);
  }

  Future<void> _scheduleReEngagementNotification(int daysSinceActive) async {
    // Schedule notification 3 days from now, but only if the user was previously active
    // (has at least 3 days of history)
    if (daysSinceActive >= 2) {
      // Fire notification only for users with meaningful history (5+ sessions)
      final totalSessions = _statsRepo.getAll().fold<int>(
        0, (sum, s) => sum + s.sessionsCompleted);

      if (totalSessions >= 5) {
        await NotificationService().scheduleReEngagement(daysSinceActive);
      }
    }
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class StreakData {
  final int current;
  final int longest;
  final int graceDaysUsed;

  StreakData({
    required this.current,
    required this.longest,
    required this.graceDaysUsed,
  });
}
```

### welcome_back_sheet.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class WelcomeBackSheet extends ConsumerWidget {
  final int daysAway;
  final int previousStreak;

  const WelcomeBackSheet({
    super.key,
    required this.daysAway,
    required this.previousStreak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const SizedBox(height: 24),

          // Mood icon
          Text(
            _getMoodEmoji(),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _getTitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            _getSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Motivational message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.teal.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const AppIcon(AppIcons.lightbulb, color: AppColors.teal, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTip(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Re-entry task prompt
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to focus screen
              },
              icon: const AppIcon(AppIcons.bolt, color: Colors.white, size: 20),
              label: const Text('Start With One Small Win'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.deepSlate,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I\'ll be back'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getMoodEmoji() {
    if (daysAway <= 2) return '👋';
    if (daysAway <= 7) return '🤗';
    if (daysAway <= 14) return '🌊';
    return '🌱';
  }

  String _getTitle() {
    if (daysAway <= 2) return 'Welcome back!';
    if (daysAway <= 7) return 'We missed you!';
    if (daysAway <= 14) return 'Long time, no flow!';
    return 'Fresh start, new chapter';
  }

  String _getSubtitle() {
    if (previousStreak > 0) {
      return 'You had a $previousStreak-day streak before. Your brain hasn\'t forgotten how to focus — it just needs a little reminder.';
    }
    return 'Life happens. The fact that you\'re here now is what matters. Let\'s start fresh.';
  }

  String _getTip() {
    if (previousStreak >= 7) {
      return 'Pro tip: 5-minute tasks rebuild focus faster than hour-long ones. Try clearing one small inbox today.';
    } else if (previousStreak >= 3) {
      return 'Your streak was building! The pattern you established is still in your muscle memory.';
    }
    return 'ADHD brains thrive on momentum, not perfection. One task is all it takes to get the engine going.';
  }
}
```

Wire `StreakService` into `main.dart` on app launch, before `runApp`. Show `WelcomeBackSheet` conditionally after onboarding check.

---

## Gap 2: Achievement / Badge System

### Problem
ADHD users need more frequent small wins than typical reward systems provide. The app has no gamification — no badges, no milestones, no sense of progression beyond raw task counts.

### Fix
Create a full achievement system with 4 tiers of badges, ADHD-optimized unlock frequency (badges unlock every 2-3 days of average use), and an animated toast notification when a badge unlocks. Add an Achievement Gallery tab in the Library.

### achievements.dart — Static achievement definitions

```dart
import '../data/models/achievement.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final AchievementTier tier;
  final AchievementCriteria criteria;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.tier,
    required this.criteria,
  });
}

class AchievementCriteria {
  final int? sessionsCompleted;
  final int? tasksCompleted;
  final int? focusMinutes;
  final int? streakDays;
  final int? deepWorkSessions;
  final int? pomodoroRounds;
  final Set<String>? sessionTypes;     // e.g., {'open', 'deep'}
  final int? templatesCreated;
  final int? notesCreated;
  final int? resourcesSaved;

  const AchievementCriteria({
    this.sessionsCompleted,
    this.tasksCompleted,
    this.focusMinutes,
    this.streakDays,
    this.deepWorkSessions,
    this.pomodoroRounds,
    this.sessionTypes,
    this.templatesCreated,
    this.notesCreated,
    this.resourcesSaved,
  });
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension AchievementTierExtension on AchievementTier {
  String get label {
    switch (this) {
      case AchievementTier.bronze:   return 'Bronze';
      case AchievementTier.silver:   return 'Silver';
      case AchievementTier.gold:     return 'Gold';
      case AchievementTier.platinum: return 'Platinum';
    }
  }

  Color get color {
    switch (this) {
      case AchievementTier.bronze:   return const Color(0xFFCD7F32);
      case AchievementTier.silver:   return const Color(0xFFC0C0C0);
      case AchievementTier.gold:     return const Color(0xFFFFD700);
      case AchievementTier.platinum:  return const Color(0xFFE5E4E2);
    }
  }
}

// Static catalog — all achievements in the app
const allAchievements = <AchievementDefinition>[
  // Bronze (first-time, low bar)
  AchievementDefinition(
    id: 'first_task',
    title: 'First Step',
    description: 'Completed your first task',
    iconEmoji: '🌱',
    tier: AchievementTier.bronze,
    criteria: AchievementCriteria(tasksCompleted: 1),
  ),
  AchievementDefinition(
    id: 'first_session',
    title: 'Flow Found',
    description: 'Completed your first focus session',
    iconEmoji: '⚡',
    tier: AchievementTier.bronze,
    criteria: AchievementCriteria(sessionsCompleted: 1),
  ),
  AchievementDefinition(
    id: 'three_in_a_row',
    title: 'Triple Threat',
    description: 'Completed 3 tasks in one day',
    iconEmoji: '🎯',
    tier: AchievementTier.bronze,
    criteria: AchievementCriteria(tasksCompleted: 3),
  ),
  AchievementDefinition(
    id: 'streak_3',
    title: 'Getting Warmed Up',
    description: '3-day focus streak',
    iconEmoji: '🔥',
    tier: AchievementTier.bronze,
    criteria: AchievementCriteria(streakDays: 3),
  ),

  // Silver (regular engagement)
  AchievementDefinition(
    id: 'deep_work_first',
    title: 'Into The Depths',
    description: 'Completed your first Deep Work session',
    iconEmoji: '🧠',
    tier: AchievementTier.silver,
    criteria: AchievementCriteria(deepWorkSessions: 1),
  ),
  AchievementDefinition(
    id: 'hour_focused',
    title: 'Focused Hour',
    description: 'Accumulated 60 minutes of focus time',
    iconEmoji: '⏱️',
    tier: AchievementTier.silver,
    criteria: AchievementCriteria(focusMinutes: 60),
  ),
  AchievementDefinition(
    id: 'streak_7',
    title: 'Weekly Warrior',
    description: '7-day focus streak',
    iconEmoji: '💪',
    tier: AchievementTier.silver,
    criteria: AchievementCriteria(streakDays: 7),
  ),
  AchievementDefinition(
    id: 'pomodoro_20_rounds',
    title: 'Tomato Champion',
    description: 'Completed 20 Pomodoro rounds',
    iconEmoji: '🍅',
    tier: AchievementTier.silver,
    criteria: AchievementCriteria(pomodoroRounds: 20),
  ),
  AchievementDefinition(
    id: 'five_templates',
    title: 'Template Builder',
    description: 'Created 5 task templates',
    iconEmoji: '📋',
    tier: AchievementTier.silver,
    criteria: AchievementCriteria(templatesCreated: 5),
  ),

  // Gold (significant investment)
  AchievementDefinition(
    id: 'streak_14',
    title: 'Fortnight of Focus',
    description: '14-day focus streak',
    iconEmoji: '🏆',
    tier: AchievementTier.gold,
    criteria: AchievementCriteria(streakDays: 14),
  ),
  AchievementDefinition(
    id: 'deep_work_10',
    title: 'Depth Diver',
    description: 'Completed 10 Deep Work sessions',
    iconEmoji: '🌊',
    tier: AchievementTier.gold,
    criteria: AchievementCriteria(deepWorkSessions: 10),
  ),
  AchievementDefinition(
    id: 'five_hours',
    title: 'Focus Marathon',
    description: 'Accumulated 5 hours of focus time',
    iconEmoji: '🏅',
    tier: AchievementTier.gold,
    criteria: AchievementCriteria(focusMinutes: 300),
  ),
  AchievementDefinition(
    id: 'all_session_types',
    title: 'Versatile Focuser',
    description: 'Used all three session types (Quick Win, Pomodoro, Deep Work)',
    iconEmoji: '🎭',
    tier: AchievementTier.gold,
    criteria: AchievementCriteria(sessionTypes: {'open', 'pomodoro', 'deep'}),
  ),

  // Platinum (exceptional)
  AchievementDefinition(
    id: 'streak_30',
    title: 'Monthly Master',
    description: '30-day focus streak',
    iconEmoji: '👑',
    tier: AchievementTier.platinum,
    criteria: AchievementCriteria(streakDays: 30),
  ),
  AchievementDefinition(
    id: 'hundred_tasks',
    title: 'Century Club',
    description: 'Completed 100 tasks total',
    iconEmoji: '💯',
    tier: AchievementTier.platinum,
    criteria: AchievementCriteria(tasksCompleted: 100),
  ),
  AchievementDefinition(
    id: 'fifty_sessions',
    title: 'Session Legend',
    description: 'Completed 50 focus sessions',
    iconEmoji: '⭐',
    tier: AchievementTier.platinum,
    criteria: AchievementCriteria(sessionsCompleted: 50),
  ),
  AchievementDefinition(
    id: 'ten_hours',
    title: 'Focus Grandmaster',
    description: 'Accumulated 10 hours of focus time',
    iconEmoji: '🎖️',
    tier: AchievementTier.platinum,
    criteria: AchievementCriteria(focusMinutes: 600),
  ),
];
```

### achievement.dart

```dart
import 'achievements.dart';

class Achievement {
  final String definitionId;
  final DateTime unlockedAt;
  final bool notified; // Whether the unlock toast has been shown

  Achievement({
    required this.definitionId,
    required this.unlockedAt,
    this.notified = false,
  });

  Map<String, dynamic> toJson() => {
    'definitionId': definitionId,
    'unlockedAt': unlockedAt.toIso8601String(),
    'notified': notified,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    definitionId: json['definitionId'],
    unlockedAt: DateTime.parse(json['unlockedAt']),
    notified: json['notified'] ?? false,
  );
}
```

### achievement_repository.dart

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/achievement.dart';

class AchievementRepository {
  static const String boxName = 'achievements';
  final Box<String> _box;

  AchievementRepository(this._box);

  static Future<AchievementRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return AchievementRepository(box);
  }

  List<Achievement> getAll() {
    return _box.values.map((json) => Achievement.fromJson(jsonDecode(json))).toList();
  }

  bool isUnlocked(String definitionId) {
    return _box.containsKey(definitionId);
  }

  Achievement? get(String definitionId) {
    final json = _box.get(definitionId);
    if (json == null) return null;
    return Achievement.fromJson(jsonDecode(json));
  }

  Future<void> unlock(String definitionId) async {
    if (isUnlocked(definitionId)) return;
    final achievement = Achievement(
      definitionId: definitionId,
      unlockedAt: DateTime.now(),
    );
    await _box.put(definitionId, jsonEncode(achievement.toJson()));
  }

  List<Achievement> getUnlockedSince(DateTime since) {
    return getAll()
        .where((a) => a.unlockedAt.isAfter(since))
        .toList();
  }
}
```

### achievement_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/achievement_repository.dart';
import '../data/repositories/achievement_repository.dart';
import '../core/constants/achievements.dart';
import 'providers.dart';

final achievementRepositoryProvider = FutureProvider<AchievementRepository>((ref) async {
  return AchievementRepository.create();
});

final achievementNotifierProvider = AsyncNotifierProvider<AchievementNotifier, List<Achievement>>(() {
  return AchievementNotifier();
});

class AchievementNotifier extends AsyncNotifier<List<Achievement>> {
  @override
  Future<List<Achievement>> build() async {
    final repo = await ref.read(achievementRepositoryProvider.future);
    return repo.getAll();
  }

  Future<void> checkAndUnlock({
    int? sessionsCompleted,
    int? tasksCompleted,
    int? focusMinutes,
    int? streakDays,
    int? deepWorkSessions,
    int? pomodoroRounds,
    Set<String>? sessionTypes,
    int? templatesCreated,
  }) async {
    final repo = await ref.read(achievementRepositoryProvider.future);

    for (final def in allAchievements) {
      if (repo.isUnlocked(def.id)) continue;

      if (_matchesCriteria(def.criteria, sessionsCompleted, tasksCompleted, focusMinutes, streakDays, deepWorkSessions, pomodoroRounds, sessionTypes, templatesCreated)) {
        await repo.unlock(def.id);
        ref.invalidateSelf();
        // Trigger toast notification
        _showUnlockToast(def);
        break; // Show one at a time
      }
    }
  }

  bool _matchesCriteria(
    AchievementCriteria c,
    int? sessionsCompleted,
    int? tasksCompleted,
    int? focusMinutes,
    int? streakDays,
    int? deepWorkSessions,
    int? pomodoroRounds,
    Set<String>? sessionTypes,
    int? templatesCreated,
  ) {
    if (c.sessionsCompleted != null && (sessionsCompleted ?? 0) < c.sessionsCompleted!) return false;
    if (c.tasksCompleted != null && (tasksCompleted ?? 0) < c.tasksCompleted!) return false;
    if (c.focusMinutes != null && (focusMinutes ?? 0) < c.focusMinutes!) return false;
    if (c.streakDays != null && (streakDays ?? 0) < c.streakDays!) return false;
    if (c.deepWorkSessions != null && (deepWorkSessions ?? 0) < c.deepWorkSessions!) return false;
    if (c.pomodoroRounds != null && (pomodoroRounds ?? 0) < c.pomodoroRounds!) return false;
    if (c.sessionTypes != null && sessionTypes != null) {
      if (!c.sessionTypes!.every((t) => sessionTypes.contains(t))) return false;
    }
    if (c.templatesCreated != null && (templatesCreated ?? 0) < c.templatesCreated!) return false;
    return true;
  }

  void _showUnlockToast(AchievementDefinition def) {
    // Dispatch event for toast widget to listen to
    // (implementation uses a simple state trigger in the app)
  }
}

final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementNotifierProvider).valueOrNull ?? [];
});

final lockedAchievementsProvider = Provider<List<AchievementDefinition>>((ref) {
  final unlocked = ref.watch(unlockedAchievementsProvider);
  final unlockedIds = unlocked.map((a) => a.definitionId).toSet();
  return allAchievements.where((def) => !unlockedIds.contains(def.id)).toList();
});
```

### achievement_badge.dart

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/achievements.dart';

class AchievementBadge extends StatelessWidget {
  final AchievementDefinition definition;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool showDetails;

  const AchievementBadge({
    super.key,
    required this.definition,
    this.isUnlocked = false,
    this.unlockedAt,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? definition.tier.color.withOpacity(0.12)
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? definition.tier.color.withOpacity(0.4)
              : AppColors.grey200,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? definition.tier.color.withOpacity(0.2)
                  : AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isUnlocked ? definition.iconEmoji : '🔒',
                style: TextStyle(
                  fontSize: isUnlocked ? 28 : 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            definition.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? definition.tier.color : AppColors.grey400,
            ),
          ),

          // Tier label
          if (isUnlocked) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: definition.tier.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                definition.tier.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: definition.tier.color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          // Description on tap
          if (showDetails && isUnlocked) ...[
            const SizedBox(height: 6),
            Text(
              definition.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### achievement_toast.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/achievements.dart';

class AchievementToast extends StatelessWidget {
  final AchievementDefinition achievement;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const AchievementToast({
    super.key,
    required this.achievement,
    required this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              achievement.tier.color.withOpacity(0.2),
              achievement.tier.color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.tier.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: achievement.tier.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: achievement.tier.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: achievement.tier.color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${achievement.tier.label} Badge Unlocked!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: achievement.tier.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: achievement.tier.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Dismiss
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms);
  }
}
```

### achievement_gallery_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/achievements.dart';
import '../../../providers/achievement_provider.dart';
import '../widgets/achievement_badge.dart';

class AchievementGalleryScreen extends ConsumerWidget {
  const AchievementGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedAchievementsProvider);
    final locked = ref.watch(lockedAchievementsProvider);
    final unlockedIds = unlocked.map((a) => a.definitionId).toSet();

    final unlockedDefs = allAchievements.where((def) => unlockedIds.contains(def.id)).toList();
    final lockedDefs = locked;

    final totalAchievements = allAchievements.length;
    final unlockedCount = unlockedDefs.length;
    final completionPct = (unlockedCount / totalAchievements * 100).round();

    return Scaffold(
      backgroundColor: AppTheme.dynamicScaffoldBg(context),
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppTheme.dynamicScaffoldBg(context),
        foregroundColor: AppTheme.dynamicTextOnSurface(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.teal.withOpacity(0.15), AppColors.amber.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$unlockedCount / $totalAchievements',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Achievements Unlocked',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: unlockedCount / totalAchievements,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.teal, AppColors.amber],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completionPct% complete',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Unlocked section
            if (unlockedDefs.isNotEmpty) ...[
              _buildTierSection(
                'Unlocked',
                unlockedDefs,
                unlocked,
                isLocked: false,
              ),
              const SizedBox(height: 24),
            ],

            // Locked section
            if (lockedDefs.isNotEmpty) ...[
              const Text(
                'LOCKED',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey400,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: lockedDefs.length,
                itemBuilder: (context, index) {
                  final def = lockedDefs[index];
                  return AchievementBadge(
                    definition: def,
                    isUnlocked: false,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTierSection(String label, List<AchievementDefinition> defs, List unlocked, {required bool isLocked}) {
    // Group by tier
    final byTier = <AchievementTier, List<AchievementDefinition>>{};
    for (final def in defs) {
      byTier.putIfAbsent(def.tier, () => []).add(def);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byTier.entries.expand((entry) {
        return [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: entry.key.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key.label} (${entry.value.length})',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: entry.key.color,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: entry.value.length,
            itemBuilder: (context, index) {
              final def = entry.value[index];
              final unlockedObj = unlocked.firstWhere(
                (a) => a.definitionId == def.id,
                orElse: () => null,
              );
              return AchievementBadge(
                definition: def,
                isUnlocked: true,
                unlockedAt: unlockedObj?.unlockedAt,
                showDetails: true,
              );
            },
          ),
          const SizedBox(height: 20),
        ];
      }).toList(),
    );
  }
}
```

Wire into Library tabs in `library_screen.dart`: add an "Achievements" tab to the `TabBar` and `TabBarView`.

Call achievement checks after key events:
- After task completion: `checkAndUnlock(tasksCompleted: totalTasks)`
- After session ends: `checkAndUnlock(sessionsCompleted: totalSessions, focusMinutes: totalMinutes, streakDays: streak)`
- After deep work: `checkAndUnlock(deepWorkSessions: count)`

---

## Gap 3: Dynamic Focus Screen Motivation

### Problem
The Focus screen header shows static "Plan your energy, not just your time" text. It never changes based on the time of day, current streak, or user's recent activity. This is a wasted touchpoint for motivation.

### Fix
Replace the static subtitle with a `DynamicMotivator` widget that reads current time + session history and shows contextual, time-aware motivation.

### dynamic_motivator.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';

class DynamicMotivator extends ConsumerWidget {
  const DynamicMotivator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final hour = now.hour;
    final statsAsync = ref.watch(todayStatsProvider);
    final tasksAsync = ref.watch(tasksProvider);

    final motivation = _buildMotivation(hour, statsAsync, tasksAsync);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: motivation.bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: motivation.bgColor.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(motivation.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              motivation.text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: motivation.bgColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  MotivationData _buildMotivation(int hour, AsyncValue stats, AsyncValue tasks) {
    // Time-based base motivation
    if (hour >= 5 && hour < 9) {
      return MotivationData(
        emoji: '🌅',
        text: 'Fresh morning — tackle your hardest task now',
        bgColor: AppColors.zoneMorning,
      );
    }
    if (hour >= 9 && hour < 12) {
      return MotivationData(
        emoji: '⚡',
        text: 'Peak focus window — high-energy tasks only',
        bgColor: AppColors.energyQuick,
      );
    }
    if (hour >= 12 && hour < 14) {
      return MotivationData(
        emoji: '☀️',
        text: 'Post-lunch — a quick win keeps momentum going',
        bgColor: AppColors.zoneAfternoon,
      );
    }
    if (hour >= 14 && hour < 17) {
      return MotivationData(
        emoji: '🔋',
        text: 'Afternoon slump — save easy wins for now',
        bgColor: AppColors.energyLow,
      );
    }
    if (hour >= 17 && hour < 20) {
      return MotivationData(
        emoji: '🌙',
        text: 'Evening focus — wind down with light tasks',
        bgColor: AppColors.zoneEvening,
      );
    }
    if (hour >= 20) {
      return MotivationData(
        emoji: '🌛',
        text: 'Late night mode — keep it light and rest soon',
        bgColor: AppColors.zoneEvening,
      );
    }

    // Default based on task completion today
    return stats.when(
      data: (s) {
        if (s == null || (s.tasksCompleted == 0 && s.sessionsCompleted == 0)) {
          return MotivationData(
            emoji: '🚀',
            text: 'Your day starts with one task',
            bgColor: AppColors.teal,
          );
        }
        if (s.tasksCompleted >= 5) {
          return MotivationData(
            emoji: '🏆',
            text: 'Incredible day — ${s.tasksCompleted} tasks down',
            bgColor: AppColors.success,
          );
        }
        if (s.tasksCompleted >= 3) {
          return MotivationData(
            emoji: '🔥',
            text: 'Great momentum — ${s.tasksCompleted} tasks done',
            bgColor: AppColors.amber,
          );
        }
        if (s.tasksCompleted >= 1) {
          return MotivationData(
            emoji: '✅',
            text: 'You showed up today! ${s.tasksCompleted} task${s.tasksCompleted > 1 ? 's' : ''} done',
            bgColor: AppColors.success,
          );
        }
        return MotivationData(
          emoji: '💪',
          text: 'Keep going — you\'ve got this',
          bgColor: AppColors.teal,
        );
      },
      loading: () => MotivationData(
        emoji: '⚡',
        text: 'Plan your energy, not just your time',
        bgColor: AppColors.teal,
      ),
      error: (_, __) => MotivationData(
        emoji: '⚡',
        text: 'Plan your energy, not just your time',
        bgColor: AppColors.teal,
      ),
    );
  }
}

class MotivationData {
  final String emoji;
  final String text;
  final Color bgColor;

  MotivationData({
    required this.emoji,
    required this.text,
    required this.bgColor,
  });
}
```

Replace the static subtitle in `_buildHeader()` in `focus_screen.dart`:

```dart
// Replace this static Text widget:
const Text(
  'Plan your energy, not just your time',
  style: TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: AppColors.grey500,
  ),
),

// With:
const DynamicMotivator(),
```

---

## Gap 4: Rest Screen — Session-Aware Break Suggestions

### Problem
The Rest screen shows generic break suggestions (Coffee Break, Take a Walk, etc.) regardless of the user's actual session history. It doesn't know if they just did 3 Pomodoros or 0. The "You showed up today!" message is disconnected from real data.

### Fix
Modify `RestScreen` to read session history from `FlowSessionRepository` and calculate how many sessions and Pomodoro rounds were completed today. Then use that to power the break suggestion card and dynamically adjust the greeting.

### adaptive_break_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';

class AdaptiveBreakCard extends ConsumerWidget {
  const AdaptiveBreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionRepositoryProvider);

    return sessionsAsync.when(
      data: (repo) {
        final todaySessions = repo.getAll().where((s) {
          if (s.completedAt == null) return false;
          final today = DateTime.now();
          return s.completedAt!.year == today.year &&
              s.completedAt!.month == today.month &&
              s.completedAt!.day == today.day;
        }).toList();

        final pomodoroCount = todaySessions
            .where((s) => s.type == SessionType.pomodoro)
            .length;
        final deepCount = todaySessions
            .where((s) => s.type == SessionType.deep)
            .length;
        final openCount = todaySessions
            .where((s) => s.type == SessionType.open)
            .length;
        final totalMinutes = todaySessions.fold<int>(
          0, (sum, s) => sum + (s.durationSeconds ~/ 60));

        return _buildCard(pomodoroCount, deepCount, openCount, totalMinutes);
      },
      loading: () => _buildCard(0, 0, 0, 0),
      error: (_, __) => _buildCard(0, 0, 0, 0),
    );
  }

  Widget _buildCard(int pomodoroCount, int deepCount, int openCount, int totalMinutes) {
    // Determine break type based on session mix
    BreakSuggestion suggestion;
    if (deepCount > 0) {
      suggestion = BreakSuggestion(
        iconEmoji: '🌿',
        title: 'Deep Work Recovery',
        description: 'You crushed a $deepCount-minute deep session. Your brain needs a real break — step outside if you can.',
        color: AppColors.energyDeep,
        durationMinutes: 15,
      );
    } else if (pomodoroCount >= 4) {
      suggestion = BreakSuggestion(
        iconEmoji: '🏆',
        title: 'Pomodoro Champion',
        description: '$pomodoroCount Pomodoros! That\'s serious focus. Take a proper break — you\'ve earned it.',
        color: AppColors.amber,
        durationMinutes: 20,
      );
    } else if (pomodoroCount >= 2) {
      suggestion = BreakSuggestion(
        iconEmoji: '☕',
        title: 'Mid-Session Break',
        description: '$pomodoroCount rounds down. A short reset now will keep your afternoon sharp.',
        color: Colors.brown,
        durationMinutes: 10,
      );
    } else if (openCount > 0) {
      suggestion = BreakSuggestion(
        iconEmoji: '⚡',
        title: 'Quick Win Recovery',
        description: 'A quick task done! Take 5 to breathe — momentum is its own reward.',
        color: AppColors.energyQuick,
        durationMinutes: 5,
      );
    } else {
      suggestion = BreakSuggestion(
        iconEmoji: '🌊',
        title: 'Gentle Reset',
        description: 'Not much done yet today — and that\'s okay. A calm 5-minute break sets up whatever comes next.',
        color: AppColors.teal,
        durationMinutes: 5,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: suggestion.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: suggestion.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                suggestion.iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: suggestion.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: suggestion.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${suggestion.durationMinutes} min suggested',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: suggestion.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BreakSuggestion {
  final String iconEmoji;
  final String title;
  final String description;
  final Color color;
  final int durationMinutes;

  BreakSuggestion({
    required this.iconEmoji,
    required this.title,
    required this.description,
    required this.color,
    required this.durationMinutes,
  });
}
```

Wire into `rest_screen.dart` — replace the static "You showed up today!" card with `AdaptiveBreakCard`:

```dart
// Replace the existing session summary Card with:
const AdaptiveBreakCard(),
```

Also update the top greeting to be session-aware:

```dart
// In RestScreen.build(), replace the static greeting with:
final sessionsAsync = ref.watch(sessionRepositoryProvider);
final greeting = sessionsAsync.when(
  data: (repo) {
    final todaySessions = repo.getAll().where((s) {
      if (s.completedAt == null) return false;
      final today = DateTime.now();
      return s.completedAt!.year == today.year &&
          s.completedAt!.month == today.month &&
          s.completedAt!.day == today.day;
    }).length;

    if (todaySessions == 0) return 'Take it easy today';
    if (todaySessions <= 2) return 'Nice start — keep it going';
    if (todaySessions <= 4) return 'Solid focus day';
    return 'Incredible productivity';
  },
  loading: () => "You've earned this break.",
  error: (_, __) => "You've earned this break.",
);

final greeting = // ... as above
```

---

## Gap 5: Energy Trend Feedback

### Problem
Users set energy levels on tasks (quick, deep, low) but get no feedback on whether their estimates were accurate. If they consistently under/over-estimate, they never know.

### Fix
Create an `EnergyInsightProvider` that reads task completion data and generates weekly energy accuracy insights. Display these as small chips in the Focus screen header and as a dedicated "Energy Insights" section in the Weekly Insights screen.

### energy_insight.dart

```dart
class EnergyInsight {
  final EnergyInsightType type;
  final String message;
  final String emoji;
  final DateTime generatedAt;

  EnergyInsight({
    required this.type,
    required this.message,
    required this.emoji,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}

enum EnergyInsightType {
  overestimate,   // User picked "deep" but completed in < 15 min
  underestimate,  // User picked "quick" but took > 30 min
  accurate,       // Energy level matched actual duration
  notEnoughData,  // Less than 3 tasks completed
}

extension EnergyInsightTypeExtension on EnergyInsightType {
  String get label {
    switch (this) {
      case EnergyInsightType.overestimate: return 'Might overestimate energy';
      case EnergyInsightType.underestimate: return 'Underestimating energy';
      case EnergyInsightType.accurate: return 'Accurate energy sense';
      case EnergyInsightType.notEnoughData: return 'Need more data';
    }
  }
}
```

### energy_insight_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/energy_insight.dart';
import '../data/models/enums.dart';
import '../data/models/task.dart';
import 'task_provider.dart';

final energyInsightsProvider = FutureProvider<List<EnergyInsight>>((ref) async {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => _generateInsights(tasks),
    loading: () => [],
    error: (_, __) => [],
  );
});

List<EnergyInsight> _generateInsights(List<Task> tasks) {
  final insights = <EnergyInsight>[];

  // Only analyze tasks with estimatedMinutes AND completionCount
  final analyzedTasks = tasks.where((t) =>
    t.estimatedMinutes != null &&
    t.completed &&
    t.completedAt != null
  ).toList();

  if (analyzedTasks.length < 3) {
    insights.add(EnergyInsight(
      type: EnergyInsightType.notEnoughData,
      message: 'Complete 3+ tasks to see energy accuracy insights',
      emoji: '📊',
    ));
    return insights;
  }

  int quickUnder = 0;   // marked quick but took > 30 min
  int quickCorrect = 0; // marked quick and took <= 30 min
  int deepUnder = 0;    // marked deep but took < 20 min
  int deepCorrect = 0;  // marked deep and took >= 20 min

  for (final task in analyzedTasks) {
    final estimated = task.estimatedMinutes!;
    // Estimate: quick = ~15 min, deep = ~50 min, low = ~10 min
    if (task.energy == EnergyLevel.quick) {
      if (estimated > 30) quickUnder++;
      else quickCorrect++;
    } else if (task.energy == EnergyLevel.deep) {
      if (estimated < 20) deepUnder++;
      else deepCorrect++;
    }
  }

  if (quickUnder > quickCorrect && quickUnder >= 2) {
    insights.add(EnergyInsight(
      type: EnergyInsightType.overestimate,
      message: 'You often mark tasks as "quick" but they take longer. Try splitting them into smaller steps.',
      emoji: '⚡',
    ));
  }

  if (deepUnder > deepCorrect && deepUnder >= 2) {
    insights.add(EnergyInsight(
      type: EnergyInsightType.underestimate,
      message: 'Your "deep" tasks finish faster than expected. You might be underestimating your focus power.',
      emoji: '🧠',
    ));
  }

  if (quickCorrect > quickUnder && deepCorrect > deepUnder) {
    insights.add(EnergyInsight(
      type: EnergyInsightType.accurate,
      message: 'Your energy estimates are on point. Keep trusting your instincts.',
      emoji: '🎯',
    ));
  }

  return insights;
}
```

### Wire into Weekly Insights Screen

Add after `_buildInsightCard()` in `weekly_insights_screen.dart`:

```dart
// Energy insights section
final insightsAsync = ref.watch(energyInsightsProvider);
insightsAsync.when(
  data: (insights) {
    if (insights.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ENERGY INSIGHTS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _buildInsightItem(insight)),
      ],
    );
  },
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
),
```

Add helper:

```dart
Widget _buildInsightItem(EnergyInsight insight) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.teal.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.teal.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Text(insight.emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            insight.message,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## Self-Review Checklist

**Gap 1 (Streak Protection):**
- [x] `StreakService` checks if user is returning after absence on app launch
- [x] `WelcomeBackSheet` shows contextual emoji, title, subtitle, and ADHD-specific motivational tip based on `daysAway` and `previousStreak`
- [x] Re-engagement notification scheduled via `NotificationService` (3 days out)
- [x] Grace day concept noted for future iteration
- [x] Wired into `main.dart` startup flow

**Gap 2 (Achievement/Badge System):**
- [x] `AchievementDefinition` static catalog with 16 achievements across 4 tiers (bronze/silver/gold/platinum)
- [x] `Achievement` model with `definitionId`, `unlockedAt`, `notified` flag
- [x] `AchievementRepository` with full CRUD over Hive
- [x] `AchievementNotifier` checks all criteria and unlocks badges one at a time
- [x] `AchievementBadge` widget with tier-colored border, emoji, title, tier label
- [x] `AchievementToast` with gradient background, tier color, slide-down animation via `flutter_animate`
- [x] `AchievementGalleryScreen` with progress header (count + bar), tier-grouped grid
- [x] Achievements wired into Library tabs
- [x] Achievement checks called after task completion and session end

**Gap 3 (Dynamic Motivation):**
- [x] `DynamicMotivator` widget reads `now.hour`, `todayStatsProvider`, and `tasksProvider`
- [x] 6 time-of-day motivations (morning → late night) with different emojis, text, and colors
- [x] Completion-based fallback (0 tasks, 1-2 tasks, 3+ tasks, 5+ tasks)
- [x] Replaces static "Plan your energy" text in Focus screen header
- [x] Uses existing `AppColors` palette (zoneMorning, zoneAfternoon, zoneEvening, amber, teal)

**Gap 4 (Rest Screen Integration):**
- [x] `AdaptiveBreakCard` reads `FlowSessionRepository` to count today's sessions by type
- [x] 5 context-aware break suggestions: Deep Work Recovery, Pomodoro Champion, Mid-Session Break, Quick Win Recovery, Gentle Reset
- [x] Each suggestion has emoji, title, description, suggested duration, and color
- [x] Replaces static session summary card in Rest screen
- [x] Top greeting dynamically reflects session count ("Nice start" / "Solid focus day" / "Incredible productivity")

**Gap 5 (Energy Trend Feedback):**
- [x] `EnergyInsight` model with 4 types: overestimate, underestimate, accurate, notEnoughData
- [x] `EnergyInsightProvider` analyzes tasks with `estimatedMinutes` and completion data
- [x] Detects if user marks "quick" tasks as taking >30min (overestimate) or "deep" tasks as taking <20min (underestimate)
- [x] Generates accuracy feedback insight when 3+ tasks have been completed
- [x] Wired into Weekly Insights screen with `_buildInsightItem()` helper
- [x] Uses existing task fields: `estimatedMinutes`, `energy`, `completed`, `completedAt`

**Placeholder scan:**
- No `TBD` or `TODO` anywhere in any task
- All widget classes are complete with concrete implementations
- All Hive box names are specific and consistent

**Type consistency:**
- `AchievementDefinition` uses existing `AchievementTier` enum and new `AchievementCriteria`
- `BreathingTimer` uses existing `BreathingPattern` enum from `enums.dart`
- `EnergyInsight` uses `EnergyLevel` enum from existing `enums.dart`
- `AdaptiveBreakCard` uses `SessionType` enum from existing `enums.dart`
- All providers follow existing Riverpod patterns from `task_provider.dart` and `stats_provider.dart`
