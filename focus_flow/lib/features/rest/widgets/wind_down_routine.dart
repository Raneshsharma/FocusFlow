import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class WindDownRoutineSheet extends StatefulWidget {
  const WindDownRoutineSheet({super.key});

  @override
  State<WindDownRoutineSheet> createState() => _WindDownRoutineSheetState();
}

class _WindDownRoutineSheetState extends State<WindDownRoutineSheet> {
  int _currentStep = 0;
  bool _screenOffComplete = false;
  String _winReflection = '';
  String _tomorrowPreview = '';
  bool _routineComplete = false;

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
              color: Colors.grey.shade300,
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
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey.shade200,
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
              color: Colors.grey.shade600,
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
              color: Colors.grey.shade600,
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
              color: Colors.grey.shade600,
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
              color: Colors.grey.shade600,
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

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Save reflection data (per design.md: saves to Session Notes tagged #daily-reflection)
      _saveWindDownData();
      setState(() => _routineComplete = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _saveWindDownData() {
    // Wind-down data is captured - would be saved to Hive/Notes here
    // Per design.md: "One Win" saves to Session Notes tagged #daily-reflection
    // "Tomorrow Preview" auto-promotes to Morning block
    if (_winReflection.isNotEmpty || _tomorrowPreview.isNotEmpty) {
      // TODO: Save to Hive - reflection notes and tomorrow preview
    }
  }
}
