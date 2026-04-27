import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import 'task_card.dart';

class TimeZoneSection extends StatelessWidget {
  final String title;
  final Color color;
  final String timeRange;
  final List<Task> tasks;
  final TimeZone zone;

  const TimeZoneSection({
    super.key,
    required this.title,
    required this.color,
    required this.timeRange,
    required this.tasks,
    required this.zone,
  });

  bool _isCurrentBlock(int hour) {
    if (title == 'Morning') return hour >= 5 && hour < 12;
    if (title == 'Afternoon') return hour >= 12 && hour < 18;
    if (title == 'Evening') return hour >= 18 || hour < 5;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isCurrentBlock = _isCurrentBlock(hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeRange,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
            if (isCurrentBlock) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Text(
              '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                AppIcon(AppIcons.inbox, size: 20, color: AppColors.grey500),
                SizedBox(width: 8),
                Text(
                  'No tasks scheduled',
                  style: TextStyle(color: AppColors.grey500),
                ),
              ],
            ),
          )
        else
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TaskCard(task: task),
          )),
      ],
    );
  }
}
