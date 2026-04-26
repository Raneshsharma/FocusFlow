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