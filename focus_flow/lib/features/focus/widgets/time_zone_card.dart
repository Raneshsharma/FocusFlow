import 'package:flutter/material.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import 'task_card.dart';

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
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  left: BorderSide(color: widget.color, width: 4),
                ),
              ),
              child: Row(
                children: [
                  // Zone icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(widget.icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: widget.color,
                              ),
                            ),
                            if (widget.isCurrentZone) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
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
                        const SizedBox(height: 3),
                        Text(
                          widget.timeRange,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.inbox,
                          size: 14,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Add button
                  GestureDetector(
                    onTap: widget.onAddTask,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppIcon(
                        AppIcons.add,
                        size: 18,
                        color: widget.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcon(
                    _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                    color: AppColors.grey400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Content - tasks or empty state
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: hasTasks
                  ? Column(
                      children: widget.tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TaskCard(task: task),
                      )).toList(),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey200.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: widget.onAddTask,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: AppIcon(
                                    AppIcons.add,
                                    color: widget.color.withOpacity(0.5),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No tasks scheduled',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add tasks to this zone',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}