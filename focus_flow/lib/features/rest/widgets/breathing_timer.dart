import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';

class BreathingTimerSheet extends ConsumerStatefulWidget {
  const BreathingTimerSheet({super.key});

  @override
  ConsumerState<BreathingTimerSheet> createState() => _BreathingTimerSheetState();
}

class _BreathingTimerSheetState extends ConsumerState<BreathingTimerSheet>
    with SingleTickerProviderStateMixin {
  BreathingPattern _selectedPattern = BreathingPattern.box;
  int _selectedMinutes = 2;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  String _currentPhase = 'Ready';

  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Breathing Exercise',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pattern selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pattern',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SegmentedButton<BreathingPattern>(
                  segments: const [
                    ButtonSegment(value: BreathingPattern.box, label: Text('Box')),
                    ButtonSegment(value: BreathingPattern.fourSevenEight, label: Text('4-7-8')),
                    ButtonSegment(value: BreathingPattern.physiologicalSigh, label: Text('Physio')),
                  ],
                  selected: {_selectedPattern},
                  onSelectionChanged: _isRunning
                      ? null
                      : (selected) {
                          setState(() => _selectedPattern = selected.first);
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Duration selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2 min')),
                    ButtonSegment(value: 5, label: Text('5 min')),
                    ButtonSegment(value: 10, label: Text('10 min')),
                  ],
                  selected: {_selectedMinutes},
                  onSelectionChanged: _isRunning
                      ? null
                      : (selected) {
                          setState(() => _selectedMinutes = selected.first);
                        },
                ),
              ],
            ),
          ),
          const Spacer(),

          // Breathing circle animation
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Container(
                width: 200 * _breathAnimation.value,
                height: 200 * _breathAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal.withOpacity(0.3),
                  border: Border.all(
                    color: AppColors.teal,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _currentPhase,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Timer
          Builder(
            builder: (context) {
              final remainingMinutes = (_selectedMinutes - (_elapsedSeconds ~/ 60)).clamp(0, 999);
              final remainingSeconds = ((_selectedMinutes * 60 - _elapsedSeconds) % 60).abs();
              return Text(
                '$remainingMinutes:${remainingSeconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const Spacer(),

          // Start/Stop button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRunning ? _stop : _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(_isRunning ? 'Stop' : 'Start'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0;
    });
    _runBreathingCycle();
  }

  void _stop() {
    setState(() {
      _isRunning = false;
      _currentPhase = 'Ready';
    });
    _breathController.stop();
    _breathController.reset();
  }

  void _runBreathingCycle() async {
    if (!_isRunning) return;

    final cycleDuration = _getPatternDuration();
    _breathController.duration = Duration(milliseconds: cycleDuration);

    // Inhale
    setState(() => _currentPhase = 'Inhale');
    await _breathController.forward();

    if (!_isRunning) return;

    // Hold (if pattern has it)
    if (_selectedPattern == BreathingPattern.fourSevenEight) {
      setState(() => _currentPhase = 'Hold');
      await Future.delayed(const Duration(seconds: 7));
    }

    if (!_isRunning) return;

    // Exhale
    setState(() => _currentPhase = 'Exhale');
    await _breathController.reverse();

    // Update elapsed
    setState(() {
      _elapsedSeconds += (cycleDuration ~/ 1000) * 2 + (_selectedPattern == BreathingPattern.fourSevenEight ? 7 : 0);
      if (_elapsedSeconds >= _selectedMinutes * 60) {
        _isRunning = false;
        _currentPhase = 'Complete!';
      }
    });

    // Loop
    if (_isRunning) {
      _runBreathingCycle();
    }
  }

  int _getPatternDuration() {
    switch (_selectedPattern) {
      case BreathingPattern.box:
        return 4000;
      case BreathingPattern.fourSevenEight:
        return 4000;
      case BreathingPattern.physiologicalSigh:
        return 3000;
    }
  }
}
