import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import 'task_item.dart';

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
        border: Border(
          left: BorderSide(color: AppColors.teal, width: 4),
        ),
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
          // Header - fixed 64px height for consistency with TimeZoneCard
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Infinity icon - 44x44 container like zone cards
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('♾️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count - fixed size container
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
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
                  ),
                  const SizedBox(width: 8),
                  // Add button - identical size to zone cards (28x28)
                  GestureDetector(
                    onTap: widget.onAddTask,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
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

          // Filter chips and content
          if (_isExpanded) ...[
            // Filter row - 8px top padding
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == null,
                      onTap: () => setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Quick',
                      emoji: '⚡',
                      color: AppColors.energyQuick,
                      isSelected: _selectedFilter == EnergyLevel.quick,
                      onTap: () => setState(() => _selectedFilter = EnergyLevel.quick),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Deep',
                      emoji: '🧠',
                      color: AppColors.energyDeep,
                      isSelected: _selectedFilter == EnergyLevel.deep,
                      onTap: () => setState(() => _selectedFilter = EnergyLevel.deep),
                    ),
                    const SizedBox(width: 8),
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
            ),
            const SizedBox(height: 12),

            // Content
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: filteredTasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskItem(task: task),
                      )).toList(),
                    ),
            ),
          ],
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
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Plus button - centered
          GestureDetector(
            onTap: widget.onAddTask,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '+',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No tasks in the pool',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add tasks to any zone or create new ones',
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

  Widget _buildFilterChip({
    required String label,
    String? emoji,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (color ?? AppColors.teal)
        : AppColors.grey100;
    final textColor = isSelected ? Colors.white : AppColors.grey600;
    final chipColor = color ?? AppColors.teal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: chipColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
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
