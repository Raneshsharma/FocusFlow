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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    ),
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 16),

            // Energy Level
            Text('Energy Level', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EnergyLevel.values.where((e) => e != EnergyLevel.none).map((energy) {
                return ChoiceChip(
                  label: Text(_getEnergyLabel(energy)),
                  selected: _selectedEnergy == energy,
                  selectedColor: _getEnergyColor(energy).withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedEnergy = energy);
                      _saveChanges();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Time Zone
            Text('Time Zone', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TimeZone.values.where((z) => z != TimeZone.none).map((zone) {
                return ChoiceChip(
                  label: Text(_getZoneLabel(zone)),
                  selected: _selectedZone == zone,
                  selectedColor: AppColors.teal.withOpacity(0.3),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedZone = zone);
                      _saveChanges();
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Favorite toggle
            SwitchListTile(
              title: const Text('Favorite'),
              secondary: AppIcon(
                _isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
                color: _isFavorite ? AppColors.amber : Colors.grey,
                size: 24,
              ),
              value: _isFavorite,
              onChanged: (value) {
                setState(() => _isFavorite = value);
                _saveChanges();
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        return Colors.grey;
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

  void _saveChanges() {
    widget.task.title = _titleController.text;
    widget.task.energy = _selectedEnergy;
    widget.task.zone = _selectedZone;
    widget.task.priority = _selectedPriority;
    widget.task.isFavorite = _isFavorite;
    widget.task.notes = _notesController.text.isEmpty ? null : _notesController.text;
    ref.read(tasksProvider.notifier).updateTask(widget.task);
  }

  void _completeTask() async {
    ref.read(tasksProvider.notifier).completeTask(widget.task.id);
    final statsRepo = await ref.read(statsRepositoryProvider.future);
    await statsRepo.incrementTasksCompleted(DateTime.now());
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