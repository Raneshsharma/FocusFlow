import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/enums.dart';
import '../data/models/archive_item.dart';
import '../data/repositories/task_repository.dart';
import '../features/achievements/widgets/achievement_toast.dart';
import '../features/focus/widgets/task_completion_celebration.dart';
import '../services/overlay_service.dart';
import 'providers.dart';
import 'achievement_provider.dart';
import 'flow_provider.dart';
import 'gamification_provider.dart';

// Provider for tasks list - watches repo for async completion
final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(() {
  return TasksNotifier();
});

class TasksNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository? _repository;

  @override
  Future<List<Task>> build() async {
    // Use read instead of watch for one-time access during initialization
    // Watching inside async build causes unnecessary rebuilds
    try {
      _repository = await ref.read(taskRepositoryProvider.future);
      return _repository!.getAll();
    } catch (e, st) {
      debugPrint('TasksNotifier.build: Error loading repository: $e\n$st');
      return [];
    }
  }

  Future<void> addTask(Task task) async {
    if (_repository != null) {
      await _repository!.save(task);
      ref.invalidateSelf();
    }
  }

  Future<void> updateTask(Task task) async {
    if (_repository != null) {
      await _repository!.save(task);
      ref.invalidateSelf();
    }
  }

  Future<void> completeTask(String id) async {
    if (_repository != null) {
      final task = _repository!.getById(id);
      if (task != null) {
        task.completed = true;
        task.completedAt = DateTime.now();
        task.completionCount = (task.completionCount ?? 0) + 1;

        // Archive the task before marking complete
        try {
          final archiveRepo = await ref.read(archiveRepositoryProvider.future);
          await archiveRepo.archive(
            ArchiveItemType.task,
            task.id,
            task.toJson(),
            ArchiveReason.completed,
            title: task.title,
          );
        } catch (e, st) {
          debugPrint('completeTask: Error archiving task: $e\n$st');
        }

        try {
          await _repository!.save(task);
        } catch (e, st) {
          debugPrint('completeTask: Error saving task: $e\n$st');
          return;
        }

        // Update stats and check achievements
        try {
          final statsRepo = await ref.read(statsRepositoryProvider.future);
          await statsRepo.incrementTasksCompleted(DateTime.now());
          // Refresh today stats so weekly chart shows updated data
          ref.invalidate(todayStatsProvider);
          // Check for new achievements using the full stats provider
          final newAchievement = await ref.read(achievementsProvider.notifier).checkAndUnlock();
          if (newAchievement != null) {
            // Use overlay service for showing achievement toast
            if (overlayService.isInitialized) {
              final defs = ref.read(achievementDefinitionsProvider);
              try {
                final def = defs.firstWhere((d) => d.id == newAchievement.definitionId);
                AchievementToast.showOverlay(overlayService, def);
              } catch (e) {
                debugPrint('completeTask: Achievement definition not found: $e');
              }
            }
          }
        } catch (e, st) {
          debugPrint('completeTask: Error updating stats/achievements: $e\n$st');
        }

        // Add XP for completing task
        try {
          await ref.read(gamificationProvider.notifier).addXpForTask();
        } catch (e, st) {
          debugPrint('completeTask: Error adding XP: $e\n$st');
        }

        // Show celebration using overlay service
        if (overlayService.isInitialized) {
          try {
            TaskCompletionCelebration.showOverlay(
              overlayService,
              xpEarned: 10,
              taskTitle: task.title,
            );
          } catch (e, st) {
            debugPrint('completeTask: Error showing celebration: $e\n$st');
          }
        }

        ref.invalidateSelf();
      } else {
        debugPrint('completeTask: Task with id $id not found');
      }
    }
  }

  Future<void> deleteTask(String id) async {
    if (_repository != null) {
      final task = _repository!.getById(id);
      if (task != null) {
        // Archive the task before deleting
        try {
          final archiveRepo = await ref.read(archiveRepositoryProvider.future);
          await archiveRepo.archive(
            ArchiveItemType.task,
            task.id,
            task.toJson(),
            ArchiveReason.deleted,
            title: task.title,
          );
        } catch (e, st) {
          debugPrint('deleteTask: Error archiving task: $e\n$st');
        }
      }
      await _repository!.delete(id);
      ref.invalidateSelf();
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (_repository != null) {
      final task = _repository!.getById(id);
      if (task != null) {
        task.isFavorite = !task.isFavorite;
        await _repository!.save(task);
        ref.invalidateSelf();
      }
    }
  }

  Future<void> updateTaskZone(String id, TimeZone zone) async {
    if (_repository != null) {
      final task = _repository!.getById(id);
      if (task != null) {
        task.zone = zone;
        await _repository!.save(task);
        ref.invalidateSelf();
      }
    }
  }
}

// Filtered providers - handle async tasks provider
final incompleteTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) {
      // Only show incomplete tasks (completed tasks go to archive)
      return tasks.where((t) => !t.completed).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final allIncompleteTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((t) => !t.completed).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((t) => t.completed).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final favoriteTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((t) => t.isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final morningTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(incompleteTasksProvider).where((t) => t.zone == TimeZone.morning).toList();
});

final afternoonTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(incompleteTasksProvider).where((t) => t.zone == TimeZone.afternoon).toList();
});

final eveningTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(incompleteTasksProvider).where((t) => t.zone == TimeZone.evening).toList();
});

final anytimeTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(incompleteTasksProvider).where((t) => t.zone == TimeZone.anytime).toList();
});
