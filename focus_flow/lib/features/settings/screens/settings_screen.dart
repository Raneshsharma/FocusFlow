import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../providers/providers.dart';
import '../../../data/models/task.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/template.dart';
import '../../../data/models/resource.dart';
import '../../../data/models/daily_stats.dart';
import '../../../data/models/app_settings.dart';
import '../../onboarding/providers/onboarding_provider.dart';

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
      final settingsRepo = await ref.read(settingsRepositoryProvider.future);
      final settings = settingsRepo.getSettings();
      if (mounted && settings != null) {
        setState(() {
          _isDarkMode = settings.isDarkMode;
          _soundEnabled = settings.soundEnabled;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final settingsRepo = await ref.read(settingsRepositoryProvider.future);
    final settings = settingsRepo.getSettings() ?? AppSettings();
    settings.isDarkMode = _isDarkMode;
    settings.soundEnabled = _soundEnabled;
    await settingsRepo.saveSettings(settings);
  }

  Future<void> _loadStats() async {
    try {
      final taskRepo = await ref.read(taskRepositoryProvider.future);
      final sessionRepo = await ref.read(sessionRepositoryProvider.future);
      final statsRepo = await ref.read(statsRepositoryProvider.future);

      final tasks = taskRepo.getAll();
      final sessions = sessionRepo.getAll();
      final allStats = statsRepo.getAll();

      // Calculate totals
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Stats section
          _buildSectionHeader('YOUR STATS'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                _buildStatRow('🔥', 'Current Streak', '$_currentStreak days'),
                const Divider(height: 24),
                _buildStatRow('✅', 'Tasks Completed', '$_totalTasks tasks'),
                const Divider(height: 24),
                _buildStatRow('🎯', 'Sessions', '$_totalSessions sessions'),
                const Divider(height: 24),
                _buildStatRow('⏱️', 'Focus Time', '${(_totalFocusMinutes / 60).toStringAsFixed(1)} hours'),
              ],
            ),
          ),

          // Data section
          _buildSectionHeader('Data'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.download, color: Colors.blue),
            ),
            title: const Text('Export Data'),
            subtitle: const Text('Download all your data as JSON'),
            trailing: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : AppIcon(AppIcons.chevronRight),
            onTap: _isExporting ? null : _exportData,
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.upload, color: Colors.green),
            ),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a backup file'),
            trailing: _isImporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : AppIcon(AppIcons.chevronRight),
            onTap: _isImporting ? null : _importData,
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.deleteForever, color: Colors.red),
            ),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('This cannot be undone'),
            onTap: _showClearConfirmation,
          ),

          const Divider(),

          // Preferences section
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.darkMode, color: Colors.purple),
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _isDarkMode,
            onChanged: (value) async {
              setState(() => _isDarkMode = value);
              await _saveSettings();
            },
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.volumeUp, color: Colors.orange),
            ),
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds for timers'),
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() => _soundEnabled = value);
              await _saveSettings();
            },
          ),

          const Divider(),

          // Developer section
          _buildSectionHeader('Developer'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(AppIcons.refresh, color: Colors.purple),
            ),
            title: const Text('Reset Onboarding'),
            subtitle: const Text('Show onboarding screens again'),
            onTap: _showResetOnboardingConfirmation,
          ),

          const Divider(),

          // About section
          _buildSectionHeader('About'),
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.teal,
              child: AppIcon(AppIcons.check, color: Colors.white),
            ),
            title: Text('FocusFlow'),
            subtitle: Text('Version 1.0.0'),
          ),
          const ListTile(
            leading: AppIcon(AppIcons.heartAlt, color: Colors.pink),
            title: Text('Made for ADHD brains'),
            subtitle: Text('Designed to help you thrive'),
          ),
          const ListTile(
            leading: AppIcon(AppIcons.lock, color: Colors.grey),
            title: Text('Privacy'),
            subtitle: Text('All data stored locally on your device'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatRow(String icon, String label, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.teal,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
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

      await Share.share(
        jsonString,
        subject: 'FocusFlow Export ${DateTime.now().toIso8601String().split('T')[0]}',
      );

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
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
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

      if (!data.containsKey('version')) {
        throw Exception('Invalid backup file');
      }

      final taskCount = (data['tasks'] as List?)?.length ?? 0;
      final sessionCount = (data['sessions'] as List?)?.length ?? 0;
      final templateCount = (data['templates'] as List?)?.length ?? 0;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: Text(
            'This will replace all existing data with:\n'
            '- $taskCount tasks\n'
            '- $sessionCount sessions\n'
            '- $templateCount templates\n\n'
            'Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
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

      // Clear existing data
      await taskRepo.deleteAll();
      await sessionRepo.deleteAll();
      await templateRepo.deleteAll();
      await resourceRepo.deleteAll();
      await statsRepo.deleteAll();

      // Import tasks
      final tasksList = data['tasks'] as List?;
      if (tasksList != null) {
        for (final taskJson in tasksList) {
          final task = Task.fromJson(taskJson as Map<String, dynamic>);
          await taskRepo.save(task);
        }
      }

      // Import sessions
      final sessionsList = data['sessions'] as List?;
      if (sessionsList != null) {
        for (final sessionJson in sessionsList) {
          final session = FlowSession.fromJson(sessionJson as Map<String, dynamic>);
          await sessionRepo.save(session);
        }
      }

      // Import templates
      final templatesList = data['templates'] as List?;
      if (templatesList != null) {
        for (final templateJson in templatesList) {
          final template = Template.fromJson(templateJson as Map<String, dynamic>);
          await templateRepo.save(template);
        }
      }

      // Import resources
      final resourcesList = data['resources'] as List?;
      if (resourcesList != null) {
        for (final resourceJson in resourcesList) {
          final resource = Resource.fromJson(resourceJson as Map<String, dynamic>);
          await resourceRepo.save(resource);
        }
      }

      // Import stats
      final statsList = data['stats'] as List?;
      if (statsList != null) {
        for (final statJson in statsList) {
          final stat = DailyStats.fromJson(statJson as Map<String, dynamic>);
          await statsRepo.addStat(stat);
        }
      }

      // Refresh stats display
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
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your:\n'
          '- Tasks\n'
          '- Sessions\n'
          '- Templates\n'
          '- Resources\n'
          '- Stats\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetOnboardingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Onboarding?'),
        content: const Text(
          'This will show the onboarding screens again when you restart the app.\n\n'
          'Your tasks and data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(onboardingProvider.notifier).resetOnboarding();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Onboarding will show again on next launch'),
                    backgroundColor: AppColors.teal,
                  ),
                );
              }
            },
            child: const Text('Reset'),
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

      // Refresh stats display
      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}