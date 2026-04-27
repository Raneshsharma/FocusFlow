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
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tasks) {
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // Morning card
                        TimeZoneCard(
                          icon: '🌅',
                          title: 'Morning',
                          timeRange: '5 AM – 11:59 AM',
                          color: AppColors.zoneMorning,
                          isCurrentZone: currentZone == TimeZone.morning,
                          tasks: incomplete.where((t) => t.zone == TimeZone.morning).toList(),
                          onAddTask: () => _showAddTaskDialog(context, TimeZone.morning),
                        ),
                        // Fixed 12px spacing
                        const SizedBox(height: 12),
                        // Afternoon card
                        TimeZoneCard(
                          icon: '☀️',
                          title: 'Afternoon',
                          timeRange: '12 PM – 5:59 PM',
                          color: AppColors.zoneAfternoon,
                          isCurrentZone: currentZone == TimeZone.afternoon,
                          tasks: incomplete.where((t) => t.zone == TimeZone.afternoon).toList(),
                          onAddTask: () => _showAddTaskDialog(context, TimeZone.afternoon),
                        ),
                        // Fixed 12px spacing
                        const SizedBox(height: 12),
                        // Evening card
                        TimeZoneCard(
                          icon: '🌙',
                          title: 'Evening',
                          timeRange: '6 PM – 12 AM',
                          color: AppColors.zoneEvening,
                          isCurrentZone: currentZone == TimeZone.evening,
                          tasks: incomplete.where((t) => t.zone == TimeZone.evening).toList(),
                          onAddTask: () => _showAddTaskDialog(context, TimeZone.evening),
                        ),
                        // 16px before Anytime Pool (slightly more breathing room)
                        const SizedBox(height: 16),
                        // Anytime Pool
                        AnytimePool(
                          tasks: anytime,
                          onAddTask: () => _showAddTaskDialog(context, TimeZone.anytime),
                        ),
                        // Bottom padding to prevent overflow
                        const SizedBox(height: 100),
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.deepSlate,
                size: 26,
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Date and tagline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Plan your energy, not just your time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - Action buttons row
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Focus mode button
                  GestureDetector(
                    onTap: () => _showFocusModeSheet(context, ref),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.deepSlate,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.gps_fixed,
                            color: AppColors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Focus mode',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Insights button
                  GestureDetector(
                    onTap: () => context.go('/insights'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('📊', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings button
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('⚙️', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ],
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
      builder: (context) => AddTaskDialog(preselectedZone: preselectedZone),
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
            // Handle bar
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
            const SizedBox(height: 12),
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
                    color: AppColors.sessionPomodoro,
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
                    color: AppColors.sessionDeep,
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(flowSessionProvider.notifier).startSession(SessionType.deep);
                      context.go('/flow');
                    },
                  ),
                ),
              ],
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
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
