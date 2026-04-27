import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/wind_down_entry.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/wind_down_repository.dart';
import '../../../providers/providers.dart';

class WindDownRoutineSheet extends ConsumerStatefulWidget {
  const WindDownRoutineSheet({super.key});

  @override
  ConsumerState<WindDownRoutineSheet> createState() => _WindDownRoutineSheetState();
}

class _WindDownRoutineSheetState extends ConsumerState<WindDownRoutineSheet> {
  int _currentStep = 0;
  bool _screenOffComplete = false;
  String _winReflection = '';
  String _tomorrowPreview = '';
  bool _routineComplete = false;
  int _windDownMinutes = 0;
  WindDownRepository? _repository;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    _repository = await WindDownRepository.create();
    // Load today's entry if it exists
    final today = _repository!.getByDate(DateTime.now());
    if (today != null && mounted) {
      setState(() {
        _winReflection = today.winReflection ?? '';
        _tomorrowPreview = today.tomorrowPreview ?? '';
        _windDownMinutes = today.windDownMinutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Wind Down Routine',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentStep + 1}/3',
                  style: const TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
            ),
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: _routineComplete
                ? _buildCompleteView()
                : _buildStepContent(),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0 && !_routineComplete)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_currentStep == 2 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildScreenOffStep();
      case 1:
        return _buildWinReflectionStep();
      case 2:
        return _buildTomorrowPreviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildScreenOffStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.phone,
              size: 64,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Step 1: Screen Off',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turn off all screens for 5 minutes.\nLet your mind unwind.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => setState(() => _screenOffComplete = true),
            icon: AppIcon(
              _screenOffComplete ? AppIcons.checkCircle : AppIcons.timer,
              size: 24,
            ),
            label: Text(_screenOffComplete ? 'Done!' : 'Start 5 min Timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _screenOffComplete ? Colors.green : Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinReflectionStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.trophy,
              size: 64,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Step 2: Your Win',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "What's one thing you accomplished today?",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            onChanged: (value) => setState(() => _winReflection = value),
            decoration: InputDecoration(
              hintText: "I finished...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowPreviewStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.sun,
              size: 64,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Step 3: Tomorrow Preview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What\'s one thing you want to tackle tomorrow?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            onChanged: (value) => setState(() => _tomorrowPreview = value),
            decoration: InputDecoration(
              hintText: "Tomorrow, I'll...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.checkCircle,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Routine Complete!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sweet dreams. See you tomorrow.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _screenOffComplete;
      case 1:
        return true; // Win reflection is optional
      case 2:
        return true; // Tomorrow preview is optional
      default:
        return false;
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      setState(() => _routineComplete = true);
      await _saveWindDownData();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _saveWindDownData() async {
    if (_winReflection.isEmpty && _tomorrowPreview.isEmpty) return;

    final entry = WindDownEntry.create(
      winReflection: _winReflection.isNotEmpty ? _winReflection : null,
      tomorrowPreview: _tomorrowPreview.isNotEmpty ? _tomorrowPreview : null,
      windDownMinutes: _windDownMinutes,
    );

    await _repository?.save(entry);

    // If tomorrow preview exists, promote to a Morning task for tomorrow
    if (_tomorrowPreview.isNotEmpty) {
      await _createTomorrowMorningTask(_tomorrowPreview);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wind-down saved! 🌙'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _createTomorrowMorningTask(String preview) async {
    try {
      final repo = await ref.read(taskRepositoryProvider.future);
      final task = Task.create(
        title: '📋 Tomorrow: $preview',
        zone: TimeZone.morning,
        notes: 'Auto-created from wind-down preview',
      );
      await repo.save(task);
    } catch (e) {
      // If repository isn't available, skip creating the task
      debugPrint('Failed to create tomorrow task: $e');
    }
  }
}
