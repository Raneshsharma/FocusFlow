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
import '../../../providers/providers.dart';

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
    final settingsAsync = ref.watch(appSettingsProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final displaySettings = ref.watch(displaySettingsProvider);
    final pomSettings = ref.watch(pomodoroSettingsProvider);
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

              // STATS SECTION
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

              // TIMER SETTINGS SECTION
              SettingsSection(label: 'Timer'),
              SettingsCard(
                child: SettingsActionTile(
                  iconEmoji: '🍅',
                  iconColor: const Color(0xFFEF4444),
                  title: 'Pomodoro Settings',
                  subtitle: 'Work: ${pomSettings.workMinutes}min · '
                      'Break: ${pomSettings.shortBreakMinutes}min · '
                      'Long: ${pomSettings.longBreakMinutes}min',
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

              // APPEARANCE SECTION
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

              // NOTIFICATIONS SECTION
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

              // DATA SECTION
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
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              // DEVELOPER SECTION
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

              // ABOUT SECTION
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