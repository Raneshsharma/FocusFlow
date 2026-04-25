import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../providers/task_provider.dart';
import '../providers/onboarding_provider.dart';

class AddFirstTaskSheet extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const AddFirstTaskSheet({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  ConsumerState<AddFirstTaskSheet> createState() => _AddFirstTaskSheetState();
}

class _AddFirstTaskSheetState extends ConsumerState<AddFirstTaskSheet> {
  final _titleController = TextEditingController();
  TimeZone _selectedZone = TimeZone.anytime;
  EnergyLevel? _selectedEnergy;
  Priority _selectedPriority = Priority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final task = Task.create(
      title: _titleController.text.trim(),
      zone: _selectedZone,
      energy: _selectedEnergy ?? EnergyLevel.none,
      priority: _selectedPriority,
    );

    await ref.read(tasksProvider.notifier).addTask(task);
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              AppIcon(AppIcons.checkCircle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Task added! You\'re ready to flow.',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Let\'s add your first task',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pick something small to start.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title input
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppColors.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What do you want to do?',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: AppColors.grey400,
                        ),
                        filled: true,
                        fillColor: AppColors.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.grey200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.teal),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Time Zone selector
                    const _SectionLabel(text: 'When?'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ZoneChip(
                          label: 'Morning',
                          zone: TimeZone.morning,
                          selected: _selectedZone,
                          onSelected: (z) => setState(() => _selectedZone = z),
                        ),
                        _ZoneChip(
                          label: 'Afternoon',
                          zone: TimeZone.afternoon,
                          selected: _selectedZone,
                          onSelected: (z) => setState(() => _selectedZone = z),
                        ),
                        _ZoneChip(
                          label: 'Evening',
                          zone: TimeZone.evening,
                          selected: _selectedZone,
                          onSelected: (z) => setState(() => _selectedZone = z),
                        ),
                        _ZoneChip(
                          label: 'Anytime',
                          zone: TimeZone.anytime,
                          selected: _selectedZone,
                          onSelected: (z) => setState(() => _selectedZone = z),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Energy selector
                    const _SectionLabel(text: 'Energy needed?'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _EnergyButton(
                          icon: '⚡',
                          energy: EnergyLevel.quick,
                          selected: _selectedEnergy,
                          onSelected: (e) => setState(() => _selectedEnergy = e),
                        ),
                        const SizedBox(width: 12),
                        _EnergyButton(
                          icon: '🧠',
                          energy: EnergyLevel.deep,
                          selected: _selectedEnergy,
                          onSelected: (e) => setState(() => _selectedEnergy = e),
                        ),
                        const SizedBox(width: 12),
                        _EnergyButton(
                          icon: '🔋',
                          energy: EnergyLevel.low,
                          selected: _selectedEnergy,
                          onSelected: (e) => setState(() => _selectedEnergy = e),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Priority selector
                    const _SectionLabel(text: 'Priority'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PriorityPill(
                          label: 'Low',
                          priority: Priority.low,
                          selected: _selectedPriority,
                          onSelected: (p) => setState(() => _selectedPriority = p),
                        ),
                        const SizedBox(width: 8),
                        _PriorityPill(
                          label: 'Medium',
                          priority: Priority.medium,
                          selected: _selectedPriority,
                          onSelected: (p) => setState(() => _selectedPriority = p),
                        ),
                        const SizedBox(width: 8),
                        _PriorityPill(
                          label: 'High',
                          priority: Priority.high,
                          selected: _selectedPriority,
                          onSelected: (p) => setState(() => _selectedPriority = p),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canSubmit ? AppColors.teal : AppColors.grey200,
                          foregroundColor: _canSubmit ? Colors.white : AppColors.grey400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Add Task'),
                      ),
                    ),

                    // Skip link
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await ref.read(onboardingProvider.notifier).completeOnboarding();
                          if (mounted) {
                            Navigator.of(context).pop();
                            widget.onSkip();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.grey500,
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        child: const Text("I'll do this later"),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.grey600,
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String label;
  final TimeZone zone;
  final TimeZone selected;
  final ValueChanged<TimeZone> onSelected;

  const _ZoneChip({
    required this.label,
    required this.zone,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = zone == selected;
    final colors = _zoneColors(zone);

    return GestureDetector(
      onTap: () => onSelected(zone),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.bgColor : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: colors.borderColor, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? colors.textColor : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  _ZoneChipColors _zoneColors(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return _ZoneChipColors(
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
          borderColor: const Color(0xFFF59E0B),
        );
      case TimeZone.afternoon:
        return _ZoneChipColors(
          bgColor: const Color(0xFFFFEDD5),
          textColor: const Color(0xFFC2410C),
          borderColor: const Color(0xFFF97316),
        );
      case TimeZone.evening:
        return _ZoneChipColors(
          bgColor: const Color(0xFFE0E7FF),
          textColor: const Color(0xFF3730A3),
          borderColor: const Color(0xFF6366F1),
        );
      case TimeZone.anytime:
        return _ZoneChipColors(
          bgColor: const Color(0xFFCCFBF1),
          textColor: const Color(0xFF0F766E),
          borderColor: AppColors.teal,
        );
      case TimeZone.none:
        return _ZoneChipColors(
          bgColor: AppColors.grey100,
          textColor: AppColors.grey600,
          borderColor: Colors.transparent,
        );
    }
  }
}

class _ZoneChipColors {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  _ZoneChipColors({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });
}

class _EnergyButton extends StatelessWidget {
  final String icon;
  final EnergyLevel energy;
  final EnergyLevel? selected;
  final ValueChanged<EnergyLevel?> onSelected;

  const _EnergyButton({
    required this.icon,
    required this.energy,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = energy == selected;
    final color = _energyColor(energy);

    return GestureDetector(
      onTap: () => onSelected(isSelected ? null : energy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  Color _energyColor(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick:
        return AppColors.energyQuick;
      case EnergyLevel.deep:
        return AppColors.energyDeep;
      case EnergyLevel.low:
        return AppColors.energyLow;
      case EnergyLevel.none:
        return AppColors.grey400;
    }
  }
}

class _PriorityPill extends StatelessWidget {
  final String label;
  final Priority priority;
  final Priority selected;
  final ValueChanged<Priority> onSelected;

  const _PriorityPill({
    required this.label,
    required this.priority,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = priority == selected;
    final colors = _priorityColors(priority, isSelected);

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colors.bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: colors.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _PriorityColors _priorityColors(Priority priority, bool isSelected) {
    if (!isSelected) {
      return _PriorityColors(
        bgColor: AppColors.grey100,
        textColor: AppColors.grey600,
      );
    }
    switch (priority) {
      case Priority.low:
        return _PriorityColors(
          bgColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1D4ED8),
        );
      case Priority.medium:
        return _PriorityColors(
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
        );
      case Priority.high:
        return _PriorityColors(
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFB91C1C),
        );
    }
  }
}

class _PriorityColors {
  final Color bgColor;
  final Color textColor;
  _PriorityColors({required this.bgColor, required this.textColor});
}