import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/note.dart';
import '../../../providers/providers.dart';

class SessionCompleteSheet extends ConsumerStatefulWidget {
  final SessionType sessionType;
  final int durationMinutes;
  final String? taskTitle;
  final String? reflection;

  const SessionCompleteSheet({
    super.key,
    required this.sessionType,
    required this.durationMinutes,
    this.taskTitle,
    this.reflection,
  });

  @override
  ConsumerState<SessionCompleteSheet> createState() => _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends ConsumerState<SessionCompleteSheet> {
  final _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing reflection if available
    if (widget.reflection != null) {
      _reflectionController.text = widget.reflection!;
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppIcons.checkCircle,
              color: AppColors.success,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),

          // Task title if available
          if (widget.taskTitle != null) ...[
            Text(
              '"${widget.taskTitle}" complete!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          Text(
            'Session Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '${widget.durationMinutes} minutes of ${_getSessionLabel()}',
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Reflection input
          TextField(
            controller: _reflectionController,
            decoration: InputDecoration(
              labelText: 'Quick reflection (optional)',
              hintText: 'How did it go?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            maxLength: 280,
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  String _getSessionLabel() {
    switch (widget.sessionType) {
      case SessionType.open:
        return 'focused work';
      case SessionType.pomodoro:
        return 'pomodoro sessions';
      case SessionType.deep:
        return 'deep work';
    }
  }

  Future<void> _saveSession() async {
    final reflection = _reflectionController.text.trim();
    final sessionRepo = await ref.read(sessionRepositoryProvider.future);
    final sessions = sessionRepo.getAll();

    if (sessions.isNotEmpty) {
      // Get the most recently completed session and add reflection
      sessions.sort((a, b) => (b.completedAt ?? DateTime.now())
          .compareTo(a.completedAt ?? DateTime.now()));
      final recentSession = sessions.first;
      recentSession.reflection = reflection;
      await sessionRepo.save(recentSession);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session saved with reflection! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (reflection.isNotEmpty) {
      // No session found, but user entered a reflection - save as note
      final noteRepo = await ref.read(noteRepositoryProvider.future);
      final note = Note.create(
        content: 'Session reflection: $reflection',
        tags: ['reflection'],
      );
      await noteRepo.save(note);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reflection saved as a note 📝'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // No session and no reflection - just close
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}