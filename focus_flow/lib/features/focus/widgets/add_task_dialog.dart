import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final TimeZone? preselectedZone;

  const AddTaskDialog({super.key, this.preselectedZone});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  EnergyLevel _selectedEnergy = EnergyLevel.none;
  late TimeZone _selectedZone;
  Priority _selectedPriority = Priority.medium;
  int? _estimatedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedZone = widget.preselectedZone ?? TimeZone.anytime;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) return;
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepOne(),
                  _buildStepTwo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentStep == 0 ? 'Add New Task' : 'Task Details',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppIcon(
                    AppIcons.close,
                    size: 18,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Step dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            const SizedBox(width: 8),
            _buildDot(1),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentStep;
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.teal : AppColors.grey200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildStepOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want to accomplish?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),
          // Title input field
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200, width: 1.5),
            ),
            child: TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., Finish project proposal',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.grey400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Next button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _titleController,
            builder: (context, value, child) {
              final isEnabled = value.text.trim().isNotEmpty;
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.teal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: isEnabled ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.grey200,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.grey500,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      AppIcon(
                        AppIcons.chevronRight,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Energy Level Section
          const Text(
            'Energy Needed',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _EnergyChip(
                  label: 'Quick',
                  emoji: '⚡',
                  color: AppColors.energyQuick,
                  isSelected: _selectedEnergy == EnergyLevel.quick,
                  onTap: () => setState(() => _selectedEnergy = EnergyLevel.quick),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnergyChip(
                  label: 'Deep',
                  emoji: '🧠',
                  color: AppColors.energyDeep,
                  isSelected: _selectedEnergy == EnergyLevel.deep,
                  onTap: () => setState(() => _selectedEnergy = EnergyLevel.deep),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnergyChip(
                  label: 'Low',
                  emoji: '🔋',
                  color: AppColors.energyLow,
                  isSelected: _selectedEnergy == EnergyLevel.low,
                  onTap: () => setState(() => _selectedEnergy = EnergyLevel.low),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time Zone Section
          const Text(
            'Schedule For',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ZoneChip(
                label: 'Morning',
                emoji: '🌅',
                color: AppColors.zoneMorning,
                isSelected: _selectedZone == TimeZone.morning,
                onTap: () => setState(() => _selectedZone = TimeZone.morning),
              ),
              _ZoneChip(
                label: 'Afternoon',
                emoji: '☀️',
                color: AppColors.zoneAfternoon,
                isSelected: _selectedZone == TimeZone.afternoon,
                onTap: () => setState(() => _selectedZone = TimeZone.afternoon),
              ),
              _ZoneChip(
                label: 'Evening',
                emoji: '🌙',
                color: AppColors.zoneEvening,
                isSelected: _selectedZone == TimeZone.evening,
                onTap: () => setState(() => _selectedZone = TimeZone.evening),
              ),
              _ZoneChip(
                label: 'Anytime',
                emoji: '⏰',
                color: AppColors.teal,
                isSelected: _selectedZone == TimeZone.anytime,
                onTap: () => setState(() => _selectedZone = TimeZone.anytime),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time estimate
          Row(
            children: [
              const Text(
                'Est. Time',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(width: 12),
              _TimeChip(
                label: '15 min',
                isSelected: _estimatedMinutes == 15,
                onTap: () => setState(() => _estimatedMinutes = 15),
              ),
              const SizedBox(width: 8),
              _TimeChip(
                label: '30 min',
                isSelected: _estimatedMinutes == 30,
                onTap: () => setState(() => _estimatedMinutes = 30),
              ),
              const SizedBox(width: 8),
              _TimeChip(
                label: '1 hr',
                isSelected: _estimatedMinutes == 60,
                onTap: () => setState(() => _estimatedMinutes = 60),
              ),
              const SizedBox(width: 8),
              _TimeChip(
                label: '2 hrs',
                isSelected: _estimatedMinutes == 120,
                onTap: () => setState(() => _estimatedMinutes = 120),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tags input
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200, width: 1),
            ),
            child: TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Add tags (work, urgent...)',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.grey400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _currentStep = 0);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.grey300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Task',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task.create(
      title: _titleController.text.trim(),
      energy: _selectedEnergy,
      zone: _selectedZone,
      priority: _selectedPriority,
      tags: _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      estimatedMinutes: _estimatedMinutes,
    );

    ref.read(tasksProvider.notifier).addTask(task);
    Navigator.pop(context);
  }
}

class _EnergyChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnergyChip({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepSlate : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.deepSlate : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}