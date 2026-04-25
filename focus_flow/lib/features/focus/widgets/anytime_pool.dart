import 'package:flutter/material.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import 'task_card.dart';

class AnytimePool extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback onAddTask;

  const AnytimePool({super.key, required this.tasks, required this.onAddTask});

  @override
  State<AnytimePool> createState() => _AnytimePoolState();
}

class _AnytimePoolState extends State<AnytimePool> {
  bool _isExpanded = true;
  EnergyLevel? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedFilter == null
        ? widget.tasks
        : widget.tasks.where((t) => t.energy == _selectedFilter).toList();

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
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Funnel icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      AppIcons.infinity,
                      color: AppColors.teal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Anytime Pool',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tasks without a time. Pick what matches your energy.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.tasks.length}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Add button
                  GestureDetector(
                    onTap: widget.onAddTask,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppIcon(
                        AppIcons.add,
                        size: 18,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcon(
                    _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          if (_isExpanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == null,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    label: 'Quick',
                    emoji: '⚡',
                    color: AppColors.energyQuick,
                    isSelected: _selectedFilter == EnergyLevel.quick,
                    onTap: () => setState(() => _selectedFilter = EnergyLevel.quick),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    label: 'Deep',
                    emoji: '🧠',
                    color: AppColors.energyDeep,
                    isSelected: _selectedFilter == EnergyLevel.deep,
                    onTap: () => setState(() => _selectedFilter = EnergyLevel.deep),
                  ),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    label: 'Low',
                    emoji: '🔋',
                    color: AppColors.energyLow,
                    isSelected: _selectedFilter == EnergyLevel.low,
                    onTap: () => setState(() => _selectedFilter = EnergyLevel.low),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Content
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: filteredTasks.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey200.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: widget.onAddTask,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                AppIcons.add,
                                color: AppColors.teal.withOpacity(0.5),
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No tasks in the pool',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add tasks to any zone or create new ones',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: filteredTasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCard(task: task),
                      )).toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? emoji,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (color ?? AppColors.navy)
        : AppColors.grey100;
    final textColor = isSelected ? Colors.white : AppColors.grey600;
    final chipColor = color ?? AppColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: chipColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}