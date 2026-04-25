import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/flow_provider.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../widgets/time_zone_card.dart';
import '../widgets/anytime_pool.dart';
import '../widgets/add_task_dialog.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final incomplete = tasks.where((t) => !t.completed).toList();
    final anytime = incomplete.where((t) => t.zone == TimeZone.anytime).toList();

    final hour = DateTime.now().hour;
    final currentZone = _getCurrentZone(hour);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TimeZoneCard(
                      icon: '🌅',
                      title: 'Morning',
                      timeRange: '5 AM – 11:59 AM',
                      color: AppColors.zoneMorning,
                      isCurrentZone: currentZone == TimeZone.morning,
                      tasks: incomplete.where((t) => t.zone == TimeZone.morning).toList(),
                      onAddTask: () => _showAddTaskDialog(context, TimeZone.morning),
                    ),
                    const SizedBox(height: 12),
                    TimeZoneCard(
                      icon: '☀️',
                      title: 'Afternoon',
                      timeRange: '12 PM – 5:59 PM',
                      color: AppColors.zoneAfternoon,
                      isCurrentZone: currentZone == TimeZone.afternoon,
                      tasks: incomplete.where((t) => t.zone == TimeZone.afternoon).toList(),
                      onAddTask: () => _showAddTaskDialog(context, TimeZone.afternoon),
                    ),
                    const SizedBox(height: 12),
                    TimeZoneCard(
                      icon: '🌙',
                      title: 'Evening',
                      timeRange: '6 PM – 12 AM',
                      color: AppColors.zoneEvening,
                      isCurrentZone: currentZone == TimeZone.evening,
                      tasks: incomplete.where((t) => t.zone == TimeZone.evening).toList(),
                      onAddTask: () => _showAddTaskDialog(context, TimeZone.evening),
                    ),
                    const SizedBox(height: 20),
                    AnytimePool(
                      tasks: anytime,
                      onAddTask: () => _showAddTaskDialog(context, TimeZone.anytime),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, null),
          backgroundColor: AppColors.amber,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: AppIcon(
              AppIcons.add,
              color: AppColors.deepSlate,
              size: 24,
            ),
        ),
      ),
    );
  }

  TimeZone? _getCurrentZone(int hour) {
    if (hour >= 5 && hour < 12) return TimeZone.morning;
    if (hour >= 12 && hour < 18) return TimeZone.afternoon;
    return TimeZone.evening;
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final displayDate = utils.DateUtils.formatDisplayDate(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Plan your energy, not just your time',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showFocusModeSheet(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.deepSlate,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(
                        AppIcons.gpsFixed,
                        color: AppColors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Focus mode',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showSettingsSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const AppIcon(
                    AppIcons.settingsOutline,
                    color: AppColors.grey600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TimeZone? preselectedZone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.08,
        ),
        child: AddTaskDialog(preselectedZone: preselectedZone),
      ),
    );
  }

  void _showFocusModeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Focus Mode',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Focus mode helps you concentrate on your current task by minimizing distractions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickStartCard(
                    icon: '⚡',
                    label: 'Quick Win',
                    color: AppColors.amber,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(flowSessionProvider.notifier).startSession(SessionType.open);
                      context.go('/flow');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStartCard(
                    icon: '🍅',
                    label: 'Pomodoro',
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(flowSessionProvider.notifier).startSession(SessionType.pomodoro);
                      context.go('/flow');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickStartCard(
                    icon: '🧠',
                    label: 'Deep Work',
                    color: const Color(0xFFEC4899),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(flowSessionProvider.notifier).startSession(SessionType.deep);
                      context.go('/flow');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),
            _SettingsItem(
              icon: '🎨',
              label: 'Appearance',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _SettingsItem(
              icon: '🔔',
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _SettingsItem(
              icon: '🌙',
              label: 'Do Not Disturb',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _SettingsItem(
              icon: '📊',
              label: 'Statistics',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _SettingsItem(
              icon: 'ℹ️',
              label: 'About',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ),
            AppIcon(
              AppIcons.chevronRight,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}