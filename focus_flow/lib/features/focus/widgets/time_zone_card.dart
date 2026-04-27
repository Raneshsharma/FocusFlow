import 'package:flutter/material.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import 'task_item.dart';

class TimeZoneCard extends StatefulWidget {
  final String icon;
  final String title;
  final String timeRange;
  final Color color;
  final bool isCurrentZone;
  final List<Task> tasks;
  final VoidCallback onAddTask;

  const TimeZoneCard({
    super.key,
    required this.icon,
    required this.title,
    required this.timeRange,
    required this.color,
    this.isCurrentZone = false,
    required this.tasks,
    required this.onAddTask,
  });

  @override
  State<TimeZoneCard> createState() => _TimeZoneCardState();
}

class _TimeZoneCardState extends State<TimeZoneCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final hasTasks = widget.tasks.isNotEmpty;
    final taskCount = widget.tasks.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - fixed 48px height for consistency
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  left: BorderSide(color: widget.color, width: 4),
                ),
              ),
              child: Row(
                children: [
                  // Zone icon - perfectly centered 44x44 container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and time - aligned
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: widget.color,
                              ),
                            ),
                            if (widget.isCurrentZone) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Now',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: widget.color,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.timeRange,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count badge - fixed size container
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '📋',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add button - identical size across all cards
                  GestureDetector(
                    onTap: widget.onAddTask,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Expand arrow
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 22,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ),
          ),

          // Content - tasks or empty state
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: hasTasks
                  ? Column(
                      children: widget.tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TaskItem(task: task),
                      )).toList(),
                    )
                  : _buildEmptyState(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Plus button - perfectly centered
          GestureDetector(
            onTap: widget.onAddTask,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.color.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No tasks scheduled',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap + to add tasks to this zone',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}