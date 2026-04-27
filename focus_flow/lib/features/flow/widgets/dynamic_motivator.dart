import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class DynamicMotivator extends ConsumerStatefulWidget {
  const DynamicMotivator({super.key});

  @override
  ConsumerState<DynamicMotivator> createState() => _DynamicMotivatorState();
}

class _DynamicMotivatorState extends ConsumerState<DynamicMotivator> {
  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = _getTimeBasedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _currentMessage,
          key: ValueKey(_currentMessage),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  String _getTimeBasedMessage() {
    final hour = DateTime.now().hour;

    if (hour < 10) {
      return '☀️ Fresh morning — tackle your hardest task first!';
    } else if (hour < 14) {
      return '⚡ Peak hours — stay in the zone!';
    } else if (hour < 17) {
      return '🌤️ Afternoon push — keep the momentum!';
    } else if (hour < 20) {
      return '🌙 Evening wind-down — choose something light.';
    } else {
      return '🌛 Late night focus — one task at a time.';
    }
  }
}
