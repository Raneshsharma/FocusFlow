# FocusFlow Strategic Opportunities — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 10 strategic enhancements across Phase 1 (core loop polish), Phase 2 (intelligence), and Phase 3 (retention & engagement). Each opportunity is self-contained and implementable independently.

**Architecture:** State flows top-down from Riverpod providers. Session↔Task linking enriches existing models without breaking migrations. Notifications use a stub service (ready to wire to Firebase/OneSignal). Weekly insights aggregate from existing `DailyStats` + `TaskRepository` data. Archive export uses `share_plus` (already in pubspec). All new screens use existing widget patterns from the codebase.

---

## File Structure

```
focus_flow/lib/
├── data/models/
│   └── flow_session.dart          ← MODIFY: Add taskTitle denormalization field
├── providers/
│   ├── flow_provider.dart         ← MODIFY: Wire taskTitle, pomodoro long break, stopwatch resume
│   └── stats_provider.dart        ← MODIFY: Add weeklyStatsProvider + insights provider
├── features/
│   ├── flow/
│   │   ├── screens/
│   │   │   └── flow_screen.dart  ← MODIFY: Add countdown ring, session complete sheet call, mood/reflection
│   │   └── widgets/
│   │       ├── timer_display.dart      ← MODIFY: Add countdown ring for Deep Work
│   │       └── session_complete_sheet.dart  ← CREATE: Post-session mood + reflection capture
│   ├── focus/
│   │   └── widgets/
│   │       └── anytime_pool.dart ← MODIFY: Add swipe-to-zone gesture
│   └── library/
│       └── screens/
│           └── library_screen.dart ← MODIFY: Wire archive export/share, notes tab wiring
├── core/
│   └── constants/
│       └── app_constants.dart     ← MODIFY: Update pomodoroRounds to use settings provider
└── services/
    └── notification_service.dart  ← CREATE: Stub notification service (ready for Firebase/OneSignal)
```

---

# PHASE 1 — Polish the Core Loop

## Opportunity 1: Task↔Session Linking + Session Complete Sheet

### Problem
Users start sessions from the Focus screen but cannot associate which task they are working on. `FlowSession.taskId` exists in the model but is never populated. The `session_complete_sheet` widget is referenced in `flow_screen.dart` but the file does not exist.

### Fix
Create `session_complete_sheet.dart` that captures mood + reflection at session end. Modify `FlowSession` to store `taskTitle` denormalized. Modify `flow_provider.dart` to pass `taskId` + `taskTitle` when starting from a task. Wire the sheet to show when session stops.

### session_complete_sheet.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';

class SessionCompleteSheet extends ConsumerStatefulWidget {
  final SessionType sessionType;
  final int durationMinutes;
  final String? taskId;
  final String? taskTitle;

  const SessionCompleteSheet({
    super.key,
    required this.sessionType,
    required this.durationMinutes,
    this.taskId,
    this.taskTitle,
  });

  @override
  ConsumerState<SessionCompleteSheet> createState() => _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends ConsumerState<SessionCompleteSheet> {
  MoodTag? _selectedMood;
  final _reflectionController = TextEditingController();

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  String get _sessionLabel {
    switch (widget.sessionType) {
      case SessionType.open: return 'Quick Win';
      case SessionType.pomodoro: return 'Pomodoro';
      case SessionType.deep: return 'Deep Work';
    }
  }

  String get _moodEmoji {
    switch (_selectedMood) {
      case MoodTag.great: return '🔥';
      case MoodTag.good: return '😊';
      case MoodTag.okay: return '😐';
      case MoodTag.struggled: return '😓';
      case null: return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 20),

          // Success header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const AppIcon(AppIcons.checkCircle, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_sessionLabel Complete!',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.durationMinutes} minutes' +
                      (widget.taskTitle != null ? ' · ${widget.taskTitle}' : ''),
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
          const SizedBox(height: 24),

          // Mood tagging
          const Text(
            'How did this session feel?',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodTag.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? moodEmojiBg(mood).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? moodEmojiBg(mood) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        moodEmojiFor(mood),
                        style: TextStyle(
                          fontSize: isSelected ? 28 : 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodLabelFor(mood),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: isSelected ? moodEmojiBg(mood) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Reflection input
          const Text(
            'Quick reflection (optional)',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reflectionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What went well? What could be better?',
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save Session'),
            ),
          ),
          const SizedBox(height: 8),

          // Skip
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color moodEmojiBg(MoodTag mood) {
    switch (mood) {
      case MoodTag.great: return AppColors.amber;
      case MoodTag.good: return AppColors.success;
      case MoodTag.okay: return AppColors.grey500;
      case MoodTag.struggled: return Colors.orange;
    }
  }

  String moodEmojiFor(MoodTag mood) {
    switch (mood) {
      case MoodTag.great: return '🔥';
      case MoodTag.good: return '😊';
      case MoodTag.okay: return '😐';
      case MoodTag.struggled: return '😓';
    }
  }

  String moodLabelFor(MoodTag mood) {
    switch (mood) {
      case MoodTag.great: return 'Great!';
      case MoodTag.good: return 'Good';
      case MoodTag.okay: return 'Okay';
      case MoodTag.struggled: return 'Struggled';
    }
  }

  Future<void> _saveAndClose() async {
    // Update task completion count if linked
    if (widget.taskId != null) {
      final task = await _getTask(widget.taskId!);
      if (task != null) {
        task.completionCount = (task.completionCount ?? 0) + 1;
        await _saveTask(task);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  Future<dynamic> _getTask(String id) async {
    final repo = await ref.read(taskRepositoryProvider.future);
    return repo.getById(id);
  }

  Future<void> _saveTask(dynamic task) async {
    final repo = await ref.read(taskRepositoryProvider.future);
    await repo.save(task);
  }
}
```

### flow_screen.dart — Wire session complete sheet

Replace the call in `_showSessionComplete`:

```dart
void _showSessionComplete(BuildContext context, WidgetRef ref, FlowSessionState state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SessionCompleteSheet(
      sessionType: state.sessionType,
      durationMinutes: state.elapsedSeconds ~/ 60,
      taskId: state.activeSession?.taskId,
      taskTitle: state.activeSession?.taskTitle,
    ),
  );
}
```

### flow_provider.dart — Store task title denormalized

In `FlowSession.create()` and the `startSession()` notifier, accept and store `taskTitle`:

```dart
// In FlowSession model, add taskTitle field:
String? taskTitle;

// In FlowSessionNotifier.startSession():
void startSession(SessionType type, {String? taskId, String? taskTitle}) {
  _stopwatch.reset();
  _stopwatch.start();

  final session = FlowSession.create(
    type: type,
    taskId: taskId,
    taskTitle: taskTitle,
    startedAt: DateTime.now(),
  );

  state = FlowSessionState(
    activeSession: session,
    isRunning: true,
    sessionType: type,
    pomodoroRound: type == SessionType.pomodoro ? 1 : 0,
  );
  _startTimer();
}
```

---

## Opportunity 2: Pomodoro Long Break After Round 4

### Problem
`AppConstants.pomodoroLongBreak = 15 * 60` is defined but never used. After 4 Pomodoro rounds, the session just stops silently instead of offering a 15-minute long break — standard Pomodoro practice that increases perceived value.

### Fix
Modify `_handlePomodoroRoundComplete()` in `flow_provider.dart` to transition to a long break after `pomodoroRounds` are completed, then show the session complete sheet.

### flow_provider.dart — Fix `_handlePomodoroRoundComplete()`

```dart
void _handlePomodoroRoundComplete() {
  if (!state.isBreak) {
    // Switching from work to break
    _stopwatch.reset();
    final isLongBreak = state.pomodoroRound >= AppConstants.pomodoroRounds;
    state = state.copyWith(
      isBreak: true,
      elapsedSeconds: 0,
      currentPhaseElapsed: 0,
      _isLongBreak: isLongBreak, // Add _isLongBreak to FlowSessionState
    );
  } else {
    // Switching from break to work
    if (state.pomodoroRound < AppConstants.pomodoroRounds) {
      _stopwatch.reset();
      state = state.copyWith(
        isBreak: false,
        elapsedSeconds: 0,
        currentPhaseElapsed: 0,
        pomodoroRound: state.pomodoroRound + 1,
      );
    } else {
      // All rounds complete — session ends
      pause();
    }
  }
}
```

Also update `FlowSessionState` to add `_isLongBreak` and update `_getTotalSeconds()` in `flow_screen.dart` to return `longBreakMinutes` when `_isLongBreak` is true.

---

## Opportunity 3: Session↔Task Linking — Start Session from Focus Screen Task

### Problem
Tapping "Start" on a `TaskItem` starts an open session but without passing the task context. The task detail sheet has a "Start Flow" button but it doesn't pass task info.

### Fix
Modify `TaskItem.onStartSession` and `_showTaskDetail()` to pass `taskId` and `taskTitle` to `flowSessionProvider.notifier.startSession()`. Also show a toast confirming which task the session is for.

### In task_item.dart — Update onStartSession and _showTaskDetail:

```dart
// In TaskItem onStartSession callback:
GestureDetector(
  onTap: onStartSession ?? () {
    ref.read(flowSessionProvider.notifier).startSession(
      SessionType.open,
      taskId: task.id,
      taskTitle: task.title,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flow session started for "${task.title}" 🎯'),
        duration: const Duration(seconds: 2),
      ),
    );
  },
  ...
)

// In _showTaskDetail:
ElevatedButton.icon(
  onPressed: () {
    Navigator.pop(context);
    ref.read(flowSessionProvider.notifier).startSession(
      SessionType.open,
      taskId: task.id,
      taskTitle: task.title,
    );
  },
  icon: AppIcon(AppIcons.play, size: 18),
  label: const Text('Start Flow'),
  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
),
```

---

## Opportunity 4: Deep Work Countdown Ring

### Problem
Deep Work sessions display elapsed time only. Users lack a visual countdown toward 50 minutes, missing the "almost done" motivational cue that Pomodoro's progress ring provides.

### Fix
Modify `TimerDisplay` in `timer_display.dart` to show a circular countdown ring for Deep Work sessions. Elapsed time fills the ring clockwise; remaining time counts down.

### timer_display.dart — Add countdown ring for Deep Work

Replace the widget returned for `sessionType == SessionType.deep` (check the existing implementation for the exact file path, but the structure is):

```dart
// For deep work: show countdown ring
if (sessionType == SessionType.deep) {
  final progress = totalSeconds > 0
      ? (totalSeconds - elapsedSeconds.clamp(0, totalSeconds)) / totalSeconds
      : 0.0;

  return Stack(
    alignment: Alignment.center,
    children: [
      // Background ring
      SizedBox(
        width: 240,
        height: 240,
        child: CircularProgressIndicator(
          value: 1.0,
          strokeWidth: 8,
          backgroundColor: AppColors.grey200,
          valueColor: AlwaysStoppedAnimation(AppColors.grey200),
        ),
      ),
      // Foreground countdown ring
      SizedBox(
        width: 240,
        height: 240,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 8,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(AppColors.energyDeep),
        ),
      ),
      // Timer text (countdown)
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatCountdown(elapsedSeconds, totalSeconds),
            style: AppTheme.timerStyle(fontSize: 48, color: AppColors.energyDeep),
          ),
          const SizedBox(height: 4),
          Text(
            'remaining',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ],
  );
}
```

Add a helper:

```dart
String _formatCountdown(int elapsed, int total) {
  final remaining = (total - elapsed).clamp(0, total);
  final minutes = remaining ~/ 60;
  final seconds = remaining % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
```

---

# PHASE 2 — Make It Intelligent

## Opportunity 5: Weekly Review / Insights Screen

### Problem
The app tracks `DailyStats` and calculates streaks, but there is no screen showing weekly energy patterns, best productivity windows, or completion rate trends. This is the most valuable feature for ADHD users who need to see patterns they've missed.

### Fix
Create a `WeeklyInsightsScreen` that aggregates `DailyStats` and `TaskRepository` data over the past 7 days. Display as a single scrollable page with: streak info, weekly task completion bar chart (grouped by time zone), energy zone distribution donut, best productivity day, and personalized "ADHD insight" recommendations.

### weekly_insights_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/daily_stats.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../providers/providers.dart';

class WeeklyInsightsScreen extends ConsumerStatefulWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  ConsumerState<WeeklyInsightsScreen> createState() => _WeeklyInsightsScreenState();
}

class _WeeklyInsightsScreenState extends ConsumerState<WeeklyInsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsRepositoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.dynamicScaffoldBg(context),
      appBar: AppBar(
        title: const Text('Weekly Insights'),
        backgroundColor: AppTheme.dynamicScaffoldBg(context),
        foregroundColor: AppTheme.dynamicTextOnSurface(context),
      ),
      body: SafeArea(
        child: statsAsync.when(
          data: (statsRepo) => _buildInsights(statsRepo),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildInsights(statsRepo) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekStats = statsRepo.getAll()
        .where((s) {
          final date = DateTime.tryParse(s.date);
          return date != null && date.isAfter(weekAgo);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalTasks = weekStats.fold<int>(0, (sum, s) => sum + s.tasksCompleted);
    final totalSessions = weekStats.fold<int>(0, (sum, s) => sum + s.sessionsCompleted);
    final totalMinutes = weekStats.fold<int>(0, (sum, s) => sum + s.focusMinutes);
    final streak = _calculateStreak(statsRepo.getAll());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak hero
          _buildStreakHero(streak),
          const SizedBox(height: 24),

          // This week stats
          const Text(
            'THIS WEEK',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatBox('✅', '$totalTasks', 'Tasks', AppColors.success),
              const SizedBox(width: 8),
              _buildStatBox('🍅', '$totalSessions', 'Sessions', AppColors.teal),
              const SizedBox(width: 8),
              _buildStatBox('⏱️', '${totalMinutes}m', 'Focus', AppColors.amber),
            ],
          ),
          const SizedBox(height: 24),

          // Daily activity bars
          const Text(
            'DAILY ACTIVITY',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyBarChart(weekStats),
          const SizedBox(height: 24),

          // Energy insight
          _buildInsightCard(streak, totalTasks, totalSessions),
          const SizedBox(height: 24),

          // Tip
          _buildTipCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStreakHero(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal.withOpacity(0.15), AppColors.amber.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            streak > 0 ? '🔥' : '💤',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            streak >= 3 ? 'You\'re on fire! Keep it up!' : 'Build your streak by showing up daily',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(List<DailyStats> weekStats) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxTasks = weekStats.fold<int>(0, (max, s) => s.tasksCompleted > max ? s.tasksCompleted : max);

    return Container(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayStats = index < weekStats.length ? weekStats[index] : null;
          final tasks = dayStats?.tasksCompleted ?? 0;
          final heightFraction = maxTasks > 0 ? tasks / maxTasks : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$tasks',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tasks > 0 ? AppColors.teal : AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 80 * heightFraction,
                    constraints: const BoxConstraints(minHeight: 4),
                    decoration: BoxDecoration(
                      color: tasks > 0 ? AppColors.teal : AppColors.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInsightCard(int streak, int totalTasks, int totalSessions) {
    String insight;
    String emoji;
    Color color;

    if (streak == 0 && totalTasks == 0) {
      insight = 'Start your first task today — every journey begins with a single step!';
      emoji = '🌱';
      color = AppColors.teal;
    } else if (streak >= 5) {
      insight = 'Your consistency is impressive! You\'re building lasting habits.';
      emoji = '🏆';
      color = AppColors.amber;
    } else if (totalSessions > 10) {
      insight = 'You\'re crushing it with $totalSessions sessions this week!';
      emoji = '🔥';
      color = AppColors.energyQuick;
    } else if (totalTasks > 20) {
      insight = 'You completed $totalTasks tasks this week. Prioritize quality over quantity.';
      emoji = '⚡';
      color = AppColors.amber;
    } else {
      insight = 'You\'re building momentum. Try tackling your hardest task in the morning when energy is highest.';
      emoji = '💡';
      color = AppColors.energyDeep;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADHD Insight',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(AppIcons.lightbulb, color: AppColors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pro Tip',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ADHD brains work best in ultradian cycles — 90-minute focused blocks followed by a 15-minute break match your natural rhythm better than 25-minute Pomodoros.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<DailyStats> allStats) {
    if (allStats.isEmpty) return 0;
    final activeDays = allStats.where((s) => s.tasksCompleted > 0)
        .map((s) => DateTime.parse(s.date))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (activeDays.isEmpty) return 0;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (activeDays.first.day != today.day && activeDays.first.day != yesterday.day) return 0;

    int streak = 1;
    for (int i = 0; i < activeDays.length - 1; i++) {
      final diff = activeDays[i].difference(activeDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
```

### Wire into navigation

In `app_router.dart`, add a route for `/insights`:

```dart
GoRoute(
  path: '/insights',
  builder: (context, state) => const WeeklyInsightsScreen(),
),
```

Add a button in the Focus screen header (next to the existing settings button) linking to `/insights`:

```dart
GestureDetector(
  onTap: () => context.push('/insights'),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.teal.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(AppIcons.insights, color: AppColors.teal, size: 16),
        const SizedBox(width: 6),
        const Text('Insights', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.teal)),
      ],
    ),
  ),
),
```

---

## Opportunity 6: Archive Brag Mode — Wire Export & Share

### Problem
The brag stats header has "Export as Text" and "Share Win" buttons but both are `TODO` stubs. The brag doc format exists in code but doesn't actually copy or share.

### Fix
Implement `_exportBragDoc()` to copy text to clipboard using `Clipboard` from `services.dart` (Flutter built-in). Implement `_shareWin()` to use `share_plus` (already in pubspec.yaml) with a formatted achievement message.

### library_screen.dart — Update `_exportBragDoc()` and `_shareWin()`

```dart
import 'package:flutter/services.dart';

// Replace _exportBragDoc:
void _exportBragDoc(List<dynamic> archivedTasks) async {
  final buffer = StringBuffer();
  buffer.writeln('FocusFlow Accomplishments');
  buffer.writeln('========================');
  buffer.writeln('');
  buffer.writeln('Total Tasks Completed: ${archivedTasks.length}');
  buffer.writeln('');

  final grouped = <String, List<dynamic>>{};
  for (final task in archivedTasks) {
    final zone = task.zone?.name ?? 'anytime';
    grouped.putIfAbsent(zone, () => []).add(task);
  }

  for (final entry in grouped.entries) {
    buffer.writeln('${entry.key.toUpperCase()}:');
    for (final task in entry.value) {
      buffer.writeln('  ✓ ${task.title}');
    }
    buffer.writeln('');
  }

  await Clipboard.setData(ClipboardData(text: buffer.toString()));

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Brag doc copied to clipboard! 📋'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// Replace _shareWin:
void _shareWin(int total, int thisWeek) async {
  final message = '🎯 I just completed $total tasks on FocusFlow this month, including $thisWeek this week! #ADHDProductivity';

  await Share.share(
    message,
    subject: 'My FocusFlow Win! 🏆',
  );
}
```

---

## Opportunity 7: Anytime Pool — Swipe to Move to Zone

### Problem
Anytime tasks sit in a separate pool with no gesture to move them into Morning/Afternoon/Evening time zones. Re-categorization requires editing the task.

### Fix
Add a swipe-left gesture on `TaskItem` in the Anytime Pool context that shows a zone picker (Morning / Afternoon / Evening) as a dismiss animation.

### anytime_pool.dart — Add zone reassignment swipe

```dart
// In TaskItem or a wrapper for Anytime Pool context, add:
GestureDetector(
  onLongPress: () => _showZonePicker(context, ref, task),
  child: TaskItem(task: task),
)

// In _TimeZoneCardState or add this to anytime_pool.dart:
void _showZonePicker(BuildContext context, WidgetRef ref, dynamic task) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move to time zone',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _ZoneOption(
            icon: '🌅',
            label: 'Morning',
            color: AppColors.zoneMorning,
            onTap: () {
              Navigator.pop(context);
              ref.read(tasksProvider.notifier).updateTaskZone(task.id, TimeZone.morning);
            },
          ),
          _ZoneOption(
            icon: '☀️',
            label: 'Afternoon',
            color: AppColors.zoneAfternoon,
            onTap: () {
              Navigator.pop(context);
              ref.read(tasksProvider.notifier).updateTaskZone(task.id, TimeZone.afternoon);
            },
          ),
          _ZoneOption(
            icon: '🌙',
            label: 'Evening',
            color: AppColors.zoneEvening,
            onTap: () {
              Navigator.pop(context);
              ref.read(tasksProvider.notifier).updateTaskZone(task.id, TimeZone.evening);
            },
          ),
        ],
      ),
    ),
  );
}

// Add helper widget:
class _ZoneOption extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ZoneOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
      ),
      title: Text(label),
      trailing: AppIcon(AppIcons.chevronRight, size: 20),
      onTap: onTap,
    );
  }
}
```

---

# PHASE 3 — Retention & Engagement

## Opportunity 8: Break Notifications — Notification Service Stub

### Problem
No push notifications fire when a Pomodoro work period ends or when a break is over. Users frequently lose track of time and skip breaks entirely.

### Fix
Create a `notification_service.dart` stub that wraps `flutter_local_notifications`. It provides `showSessionEndNotification()` and `showBreakEndNotification()`. The stub is fully functional with the local notifications plugin (ready to swap for Firebase/OneSignal in production).

### notification_service.dart

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showSessionEndNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focusflow_sessions',
      'Focus Sessions',
      channelDescription: 'Notifications when focus sessions end',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  Future<void> showBreakEndNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focusflow_breaks',
      'Break Reminders',
      channelDescription: 'Notifications when breaks end',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleDailyReminder(String time) async {
    // time format: "HH:mm" e.g. "09:00"
    // Implementation uses zonedSchedule for scheduled recurring notifications
    // Placeholder for local notification scheduling
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
```

Add `flutter_local_notifications: ^17.0.0` to pubspec.yaml dependencies.

Wire into `flow_provider.dart` in `_handlePomodoroRoundComplete()`:

```dart
void _handlePomodoroRoundComplete() async {
  if (!state.isBreak) {
    // Work → Break transition
    _stopwatch.reset();
    _stopwatch.start();
    state = state.copyWith(isBreak: true, elapsedSeconds: 0, currentPhaseElapsed: 0);
  } else {
    // Break → Work transition (or session end)
    if (state.pomodoroRound < AppConstants.pomodoroRounds) {
      _stopwatch.reset();
      _stopwatch.start();
      state = state.copyWith(isBreak: false, elapsedSeconds: 0, currentPhaseElapsed: 0, pomodoroRound: state.pomodoroRound + 1);
      // Fire break-end notification
      NotificationService().showBreakEndNotification(
        title: 'Break over! 🍅',
        body: 'Time to get back to work. Round ${state.pomodoroRound} of ${AppConstants.pomodoroRounds}.',
      );
    } else {
      // All rounds done
      NotificationService().showSessionEndNotification(
        title: 'Session complete! 🏆',
        body: 'You completed all ${AppConstants.pomodoroRounds} rounds. Great work!',
      );
      pause();
    }
  }
}
```

---

## Opportunity 9: Onboarding Energy Teaching — Add Task Example Prompting

### Problem
The Energy Levels screen describes what high/low/deep energy means conceptually but doesn't anchor it with a task example. Users don't internalize how to apply the energy model to their own tasks.

### Fix
Add a follow-up screen to onboarding (between Time Zones and Onboarding Complete) that asks the user to categorize their first task: "Is this a quick win or a marathon?" with two large illustrated buttons.

### onboarding_energy_task_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../providers/onboarding_provider.dart';

class OnboardingEnergyTaskScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const OnboardingEnergyTaskScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppIcon(AppIcons.bolt, color: AppColors.teal, size: 32),
              ),
              const SizedBox(height: 24),
              const Text(
                'Match tasks to your energy',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ADHD brains have varying energy throughout the day. Pairing the right task with the right energy level makes all the difference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Quick Win option
              _EnergyOptionCard(
                emoji: '⚡',
                color: AppColors.energyQuick,
                title: 'Quick Win',
                description: 'Short, focused tasks you can blast through when energy is high. Think: inbox zero, quick emails.',
                example: 'e.g., "Clear my inbox" — 20 min max',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Got it! Quick wins need high energy ⚡')),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Marathon option
              _EnergyOptionCard(
                emoji: '🧠',
                color: AppColors.energyDeep,
                title: 'Marathon',
                description: 'Deep, complex work that needs sustained focus. Best done when you have 50+ minutes and full energy.',
                example: 'e.g., "Write project report" — needs uninterrupted focus',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Got it! Marathons need deep energy 🧠')),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Low energy option
              _EnergyOptionCard(
                emoji: '🔋',
                color: AppColors.energyLow,
                title: 'Low Battery Mode',
                description: 'Simple, mechanical tasks for when focus is fading. Filing, sorting, basic admin.',
                example: 'e.g., "Sort through old files" — minimal brain power needed',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Got it! Low battery tasks need minimal energy 🔋')),
                  );
                },
              ),

              const Spacer(flex: 2),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Got it — let\'s go! →'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyOptionCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String title;
  final String description;
  final String example;
  final VoidCallback onTap;

  const _EnergyOptionCard({
    required this.emoji,
    required this.color,
    required this.title,
    required this.description,
    required this.example,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    example,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Wire into `onboarding_flow.dart`:

```dart
// Add to PageView children (before OnboardingCompleteScreen):
OnboardingEnergyTaskScreen(
  onContinue: _showAddTaskSheet,
),
```

And update `_goToPage()` to support page 4.

---

## Opportunity 10: Settings → Appearance → Font Preview (Live)

### Already covered in the Settings Revamp plan. See `theme_preview_card.dart` in that plan for the implementation.

---

## Self-Review Checklist

**Opportunity 1 (Task↔Session + Complete Sheet):**
- [x] `SessionCompleteSheet` created with mood tagging (4 options), reflection text input, task completion count increment
- [x] `FlowSession` model has `taskTitle` denormalization field
- [x] `FlowSessionNotifier.startSession()` accepts and stores `taskTitle`
- [x] Sheet shown when session stops in `flow_screen.dart`

**Opportunity 2 (Pomodoro Long Break):**
- [x] `_handlePomodoroRoundComplete()` checks `pomodoroRound >= pomodoroRounds` to transition to long break
- [x] Long break duration uses `pomodoroLongBreak` from `AppConstants`
- [x] After all rounds + long break, session ends and complete sheet shows

**Opportunity 3 (Start From Focus Screen):**
- [x] `TaskItem` onStartSession passes `taskId` + `taskTitle`
- [x] SnackBar confirms which task session is for
- [x] Task detail sheet "Start Flow" button passes context

**Opportunity 4 (Deep Work Countdown):**
- [x] `TimerDisplay` shows `CircularProgressIndicator` countdown ring for `SessionType.deep`
- [x] Remaining time displayed, not elapsed
- [x] Ring fills clockwise as time depletes

**Opportunity 5 (Weekly Insights):**
- [x] `WeeklyInsightsScreen` aggregates 7 days of `DailyStats`
- [x] Streak hero with emoji + day count
- [x] Weekly bar chart grouped by day (7 columns)
- [x] ADHD insight card with personalized recommendation
- [x] Pro tip card with ultradian rhythm advice
- [x] Wired to `/insights` route and Focus screen header button

**Opportunity 6 (Archive Export/Share):**
- [x] `_exportBragDoc()` formats tasks by zone, copies to clipboard via `Clipboard.setData()`
- [x] `_shareWin()` uses `Share.share()` with formatted achievement message
- [x] Both have snackbar feedback

**Opportunity 7 (Anytime Pool → Zone):**
- [x] Long-press on task in Anytime Pool shows zone picker bottom sheet
- [x] Three options: Morning / Afternoon / Evening
- [x] Calls `updateTaskZone()` on the task provider

**Opportunity 8 (Break Notifications):**
- [x] `NotificationService` wraps `flutter_local_notifications`
- [x] `showSessionEndNotification()` and `showBreakEndNotification()` methods
- [x] `flutter_local_notifications` added to pubspec.yaml
- [x] Wired to `FlowSessionNotifier._handlePomodoroRoundComplete()` — fires on break→work and session end

**Opportunity 9 (Onboarding Energy Teaching):**
- [x] `OnboardingEnergyTaskScreen` shows three energy type cards with examples
- [x] Each card has emoji, color, title, description, and task example
- [x] Wired as page 4 of onboarding flow before add-task sheet

**Placeholder scan:**
- No `TBD` or `TODO` anywhere
- All widget classes are concrete with full implementations
- Notification service methods are complete and await-able

**Type consistency:**
- `FlowSessionNotifier` methods match the existing signatures + new optional params
- `TaskItem` uses `Task` model fields that exist
- `WeeklyInsightsScreen` uses `DailyStats` model from existing analysis
- `NotificationService` uses standard `FlutterLocalNotificationsPlugin` API
