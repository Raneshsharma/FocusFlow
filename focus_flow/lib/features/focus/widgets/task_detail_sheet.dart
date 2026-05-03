import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late EnergyLevel _selectedEnergy;
  late TimeZone _selectedZone;
  late Priority _selectedPriority;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _selectedEnergy = widget.task.energy;
    _selectedZone = widget.task.zone;
    _selectedPriority = widget.task.priority;
    _isFavorite = widget.task.isFavorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Task Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24, color: AppColors.grey600),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task',
                labelStyle: const TextStyle(color: AppColors.grey600, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal, width: 2),
                ),
                filled: true,
                fillColor: AppColors.grey50,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
              maxLines: 2,
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 20),

            // Energy Level
            const Text(
              'Energy Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: EnergyLevel.values.where((e) => e != EnergyLevel.none).map((energy) {
                final isSelected = _selectedEnergy == energy;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEnergy = energy);
                    _saveChanges();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _getEnergyColor(energy) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _getEnergyColor(energy) : AppColors.grey300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: _getEnergyColor(energy).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Text(
                      _getEnergyLabel(energy),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : _getEnergyColor(energy),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Time Zone
            const Text(
              'Time Zone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: TimeZone.values.where((z) => z != TimeZone.none).map((zone) {
                final isSelected = _selectedZone == zone;
                final zoneColor = _getZoneColor(zone);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedZone = zone);
                    _saveChanges();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? zoneColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? zoneColor : AppColors.grey300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: zoneColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Text(
                      _getZoneLabel(zone),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : zoneColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Favorite toggle
            SwitchListTile(
              title: const Text(
                'Favorite',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              secondary: AppIcon(
                _isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
                color: _isFavorite ? AppColors.amber : AppColors.grey500,
                size: 24,
              ),
              value: _isFavorite,
              onChanged: (value) {
                setState(() => _isFavorite = value);
                _saveChanges();
              },
              activeColor: AppColors.amber,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                labelStyle: const TextStyle(color: AppColors.grey600, fontWeight: FontWeight.w500),
                hintText: 'Add any additional notes...',
                hintStyle: const TextStyle(color: AppColors.grey400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal, width: 2),
                ),
                filled: true,
                fillColor: AppColors.grey50,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.navy,
              ),
              maxLines: 3,
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                if (!widget.task.completed)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _completeTask,
                      icon: AppIcon(AppIcons.check, size: 20, color: Colors.white),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (!widget.task.completed) const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteTask,
                    icon: AppIcon(AppIcons.delete, size: 20, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  void _saveChanges() {
    widget.task.title = _titleController.text;
    widget.task.energy = _selectedEnergy;
    widget.task.zone = _selectedZone;
    widget.task.priority = _selectedPriority;
    widget.task.isFavorite = _isFavorite;
    widget.task.notes = _notesController.text.isEmpty ? null : _notesController.text;
    ref.read(tasksProvider.notifier).updateTask(widget.task);
  }

  void _completeTask() {
    ref.read(tasksProvider.notifier).completeTask(widget.task.id);
    // Note: completeTask already increments stats internally
    if (mounted) Navigator.pop(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(widget.task.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}