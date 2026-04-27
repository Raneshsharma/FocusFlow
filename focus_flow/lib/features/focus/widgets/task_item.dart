import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';
import '../../../providers/flow_provider.dart';
import 'task_detail_sheet.dart';

class TaskItem extends ConsumerWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onDeleted;
  final Function(Task task, TimeZone newZone)? onZoneChanged;

  const TaskItem({
    super.key,
    required this.task,
    this.onComplete,
    this.onDeleted,
    this.onZoneChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3,
        DismissDirection.startToEnd: 0.3,
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete task
          return await _confirmComplete(context);
        } else {
          // Delete task
          return await _confirmDelete(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _completeTask(context, ref);
        } else {
          _deleteTask(context, ref);
        }
      },
      background: _buildSwipeBackground(
        color: AppColors.success,
        icon: AppIcons.check,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.error,
        icon: AppIcons.delete,
        alignment: Alignment.centerRight,
      ),
      child: _buildTaskCard(context, ref),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required String icon,
    required Alignment alignment,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppIcon(
        icon,
        color: Colors.white,
        size: 28,
      ).animate().scale(
            begin: const Offset(0.5, 0.5),
            duration: 200.ms,
          ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        onLongPress: () => _showZonePicker(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => _completeTask(context, ref),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed ? AppColors.success : AppColors.grey500,
                      width: 2,
                    ),
                    color: task.completed ? AppColors.success : Colors.transparent,
                  ),
                  child: task.completed
                      ? AppIcon(AppIcons.check, size: 16, color: Colors.white)
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: task.priority == Priority.high ? FontWeight.bold : FontWeight.w500,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed ? AppColors.grey500 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task.energy != EnergyLevel.none) ...[
                          _buildChip(
                            label: _getEnergyLabel(task.energy),
                            color: _getEnergyColor(task.energy),
                          ),
                        ],
                        _buildChip(
                          label: _getZoneAbbrev(task.zone),
                          color: _getZoneChipColor(task.zone),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite star
              if (!task.completed)
                GestureDetector(
                  onTap: () => _toggleFavorite(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AppIcon(
                      task.isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
                      color: task.isFavorite ? AppColors.amber : AppColors.grey500,
                      size: 22,
                    ),
                  ),
                ),
              // Play button
              if (!task.completed)
                GestureDetector(
                  onTap: () => _startSession(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppIcon(
                      AppIcons.play,
                      color: AppColors.teal,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
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

  Future<bool> _confirmComplete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complete Task?'),
            content: Text('Mark "${task.title}" as complete?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: const Text('Complete'),
              ),
            ],
          ),
        ) ?? false;
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task?'),
            content: Text('Delete "${task.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
  }

  void _showZonePicker(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move to Zone',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(color: AppColors.grey600),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2,
              children: TimeZone.values.where((z) => z != TimeZone.none).map((zone) {
                final isSelected = task.zone == zone;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    if (!isSelected) {
                      await ref.read(tasksProvider.notifier).updateTaskZone(task.id, zone);
                      onZoneChanged?.call(task, zone);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Moved to ${_getZoneLabel(zone)}'),
                            backgroundColor: AppColors.teal,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getZoneColor(zone).withOpacity(0.2)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: _getZoneColor(zone), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getZoneEmoji(zone),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getZoneLabel(zone),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? _getZoneColor(zone) : AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getZoneEmoji(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return '🌅';
      case TimeZone.afternoon:
        return '☀️';
      case TimeZone.evening:
        return '🌙';
      case TimeZone.anytime:
        return '♾️';
      case TimeZone.none:
        return '';
    }
  }

  String _getZoneLabel(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return 'Morning';
      case TimeZone.afternoon:
        return 'Afternoon';
      case TimeZone.evening:
        return 'Evening';
      case TimeZone.anytime:
        return 'Anytime';
      case TimeZone.none:
        return '';
    }
  }

  Color _getZoneColor(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return AppColors.zoneMorning;
      case TimeZone.afternoon:
        return AppColors.zoneAfternoon;
      case TimeZone.evening:
        return AppColors.zoneEvening;
      case TimeZone.anytime:
        return AppColors.teal;
      case TimeZone.none:
        return AppColors.grey500;
    }
  }

  void _completeTask(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await ref.read(tasksProvider.notifier).completeTask(task.id);
    try {
      final repo = await ref.read(statsRepositoryProvider.future);
      await repo.incrementTasksCompleted(DateTime.now());
    } catch (_) {
      // Stats update is non-critical, continue silently
    }
    onComplete?.call();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${task.title}" completed!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(tasksProvider.notifier).deleteTask(task.id);
    onDeleted?.call();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${task.title}" deleted'),
          backgroundColor: AppColors.grey800,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.amber,
            onPressed: () {
              ref.read(tasksProvider.notifier).addTask(task);
            },
          ),
        ),
      );
    }
  }

  void _toggleFavorite(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    ref.read(tasksProvider.notifier).toggleFavorite(task.id);
  }

  void _startSession(BuildContext context, WidgetRef ref) {
    SessionType sessionType;
    switch (task.energy) {
      case EnergyLevel.deep:
        sessionType = SessionType.deep;
        break;
      case EnergyLevel.quick:
        sessionType = SessionType.open;
        break;
      default:
        sessionType = SessionType.pomodoro;
    }

    ref.read(flowSessionProvider.notifier).startSession(
          sessionType,
          taskId: task.id,
          taskTitle: task.title,
        );
    context.go('/flow');
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(task: task),
    );
  }

  String _getEnergyLabel(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick:
        return 'Quick';
      case EnergyLevel.deep:
        return 'Deep';
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.none:
        return '';
    }
  }

  Color _getEnergyColor(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick:
        return AppColors.energyQuick;
      case EnergyLevel.deep:
        return AppColors.energyDeep;
      case EnergyLevel.low:
        return AppColors.energyLow;
      case EnergyLevel.none:
        return AppColors.grey500;
    }
  }

  String _getZoneAbbrev(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return 'AM';
      case TimeZone.afternoon:
        return 'PM';
      case TimeZone.evening:
        return 'Eve';
      case TimeZone.anytime:
        return 'Any';
      case TimeZone.none:
        return '';
    }
  }

  Color _getZoneChipColor(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return AppColors.zoneMorning;
      case TimeZone.afternoon:
        return AppColors.zoneAfternoon;
      case TimeZone.evening:
        return AppColors.zoneEvening;
      case TimeZone.anytime:
        return AppColors.teal;
      case TimeZone.none:
        return AppColors.grey500;
    }
  }
}
