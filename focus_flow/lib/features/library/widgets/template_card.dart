import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class TemplateCard extends StatelessWidget {
  final String name;
  final int taskCount;
  final int usageCount;
  final int streakCount;
  final TimeOfDay? bestTime;
  final bool isHot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TemplateCard({
    super.key,
    required this.name,
    required this.taskCount,
    required this.usageCount,
    this.streakCount = 0,
    this.bestTime,
    this.isHot = false,
    this.onTap,
    this.onLongPress,
  });

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isHot
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.amber, width: 2),
                )
              : null,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isHot
                          ? AppColors.amber.withOpacity(0.2)
                          : AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppIcon(
                      AppIcons.copy,
                      color: isHot ? AppColors.amber : AppColors.teal,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  // Streak badge
                  if (streakCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 2),
                          Text(
                            '$streakCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (isHot)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    '🔥 HOT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$taskCount task${taskCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (bestTime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppIcon(AppIcons.schedule, size: 10, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeOfDay(bestTime!),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
