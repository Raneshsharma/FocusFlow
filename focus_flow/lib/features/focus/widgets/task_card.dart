import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';
import '../../../providers/flow_provider.dart';
import 'task_detail_sheet.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

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

  String _getEnergyLabel(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick:
        return 'Quick';
      case EnergyLevel.deep:
        return 'Deep';
      case EnergyLevel.low:
        return 'Low Energy';
      case EnergyLevel.none:
        return '';
    }
  }

  void _startFocusMode(BuildContext context, WidgetRef ref) {
    // Determine session type based on energy level
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

    // Start the flow session
    ref.read(flowSessionProvider.notifier).startSession(sessionType);

    // Navigate to Flow screen
    context.go('/flow');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _showTaskDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (!task.completed) {
                    try {
                      final tasksNotifier = ref.read(tasksProvider.notifier);
                      await tasksNotifier.completeTask(task.id);
                    } catch (e) {
                      debugPrint('TaskCard: Error completing task: $e');
                    }
                  }
                },
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
                        fontWeight: FontWeight.w500,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed ? AppColors.grey500 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task.energy != EnergyLevel.none) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getEnergyColor(task.energy).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _getEnergyLabel(task.energy),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getEnergyColor(task.energy),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (task.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '#${task.tags.first}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions menu
              if (!task.completed)
                PopupMenuButton<String>(
                  icon: AppIcon(
                    AppIcons.moreHoriz,
                    color: AppColors.grey500,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) => _handleAction(context, ref, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'focus',
                      child: Row(
                        children: [
                          AppIcon(AppIcons.trackChanges, color: AppColors.navy, size: 18),
                          const SizedBox(width: 12),
                          Text('Start Focus', style: TextStyle(color: AppColors.navy)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'snooze',
                      child: Row(
                        children: [
                          AppIcon(AppIcons.inbox, color: AppColors.teal, size: 18),
                          const SizedBox(width: 12),
                          Text('Snooze to Anytime', style: TextStyle(color: AppColors.teal)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          AppIcon(
                            task.isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
                            color: task.isFavorite ? AppColors.amber : AppColors.grey500,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(task.isFavorite ? 'Unfavorite' : 'Favorite', style: TextStyle(color: AppColors.navy)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          AppIcon(AppIcons.delete, color: AppColors.error, size: 18),
                          const SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(task: task),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'focus':
        _startFocusMode(context, ref);
        break;
      case 'snooze':
        ref.read(tasksProvider.notifier).updateTaskZone(task.id, TimeZone.anytime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Snoozed to Anytime'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.teal,
          ),
        );
        break;
      case 'favorite':
        ref.read(tasksProvider.notifier).toggleFavorite(task.id);
        break;
      case 'delete':
        _deleteTaskWithUndo(context, ref);
        break;
    }
  }

  void _deleteTaskWithUndo(BuildContext context, WidgetRef ref) {
    final taskProvider = ref.read(tasksProvider.notifier);
    final deletedTask = task;
    taskProvider.deleteTask(task.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted'),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.grey800,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.amber,
          onPressed: () {
            ref.read(tasksProvider.notifier).addTask(deletedTask);
          },
        ),
      ),
    );
  }
}