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
    with TickerProviderStateMixin {
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
              color: AppColors.grey300,
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
                  icon: const Icon(Icons.close, size: 24),
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
          ListenableBuilder(
            listenable: _breathAnimation,
            builder: (context, child) {
              double scale = _breathAnimation.value;
              // Adjust scale based on phase
              if (_currentPhase.contains('Out')) {
                scale = 1.6 - (0.6 * _breathAnimation.value);
              } else if (_currentPhase == 'Hold') {
                scale = 1.0;
              } else if (_currentPhase.contains('In')) {
                scale = 0.6 + (0.4 * _breathAnimation.value);
              }
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withOpacity(0.3),
                    border: Border.all(
                      color: AppColors.teal,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPhase,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal,
                          ),
                        ),
                        if (_selectedPattern == BreathingPattern.physiologicalSigh &&
                            (_currentPhase == 'Inhale 1' || _currentPhase == 'Inhale 2'))
                          const Text(
                            '(double inhale)',
                            style: TextStyle(fontSize: 12, color: AppColors.teal),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Timer
          Text(
            _formatTime((_selectedMinutes * 60 - _elapsedSeconds).clamp(0, 9999)),
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
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

  String _formatTime(int seconds) {
    if (seconds < 0) seconds = 0;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
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

  Future<void> _runBreathingCycle() async {
    if (!mounted || !_isRunning) return;

    switch (_selectedPattern) {
      case BreathingPattern.box:
        await _runBoxBreathing();
        break;
      case BreathingPattern.fourSevenEight:
        await _run478Breathing();
        break;
      case BreathingPattern.physiologicalSigh:
        await _runPhysiologicalSigh();
        break;
    }
  }

  Future<void> _runBoxBreathing() async {
    if (!mounted || !_isRunning) return;
    // Box breathing: 4s inhale, 4s hold, 4s exhale, 4s hold = 16s total
    if (mounted) setState(() => _currentPhase = 'Inhale');
    _breathController.duration = const Duration(seconds: 4);
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted || !_isRunning) return;
    if (mounted) setState(() => _currentPhase = 'Hold');
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted || !_isRunning) return;
    if (mounted) setState(() => _currentPhase = 'Exhale');
    _breathController.duration = const Duration(seconds: 4);
    _breathController.reverse(from: 1);
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted || !_isRunning) return;
    if (mounted) setState(() => _currentPhase = 'Hold');
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) _updateElapsed(16);
  }

  Future<void> _run478Breathing() async {
    if (!mounted || !_isRunning) return;
    // 4-7-8: 4s inhale, 7s hold, 8s exhale = 19s total
    if (mounted) setState(() => _currentPhase = 'Inhale');
    _breathController.duration = const Duration(seconds: 4);
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted || !_isRunning) return;
    if (mounted) setState(() => _currentPhase = 'Hold');
    await Future.delayed(const Duration(seconds: 7));

    if (!mounted || !_isRunning) return;
    if (mounted) setState(() => _currentPhase = 'Exhale');
    _breathController.duration = const Duration(seconds: 8);
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 8));

    if (mounted) _updateElapsed(19);
  }

  Future<void> _runPhysiologicalSigh() async {
    if (!mounted || !_isRunning) return;
    setState(() => _currentPhase = 'Inhale 1');
    _breathController.duration = const Duration(seconds: 3);
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));

    if (!_isRunning) return;

    // Second inhale
    setState(() => _currentPhase = 'Inhale 2');
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));

    if (!_isRunning) return;

    // Long exhale
    if (mounted) setState(() => _currentPhase = 'Exhale');
    _breathController.duration = const Duration(seconds: 6);
    _breathController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 6));

    if (mounted) _updateElapsed(12);
  }

  void _updateElapsed(int seconds) {
    if (!mounted) return;
    setState(() {
      _elapsedSeconds += seconds;
      if (_elapsedSeconds >= _selectedMinutes * 60) {
        _isRunning = false;
        _currentPhase = 'Complete!';
      }
    });

    // Continue cycling if still running
    if (_isRunning && mounted) {
      _runBreathingCycle();
    }
  }
}
