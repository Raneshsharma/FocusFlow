import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/enums.dart';
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
    // Get the repository asynchronously
    final repoAsync = ref.watch(taskRepositoryProvider);

    return repoAsync.when(
      data: (repo) {
        _repository = repo;
        return repo.getAll();
      },
      loading: () => [],
      error: (_, __) => [],
    );
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
        await _repository!.save(task);

        // Update stats and check achievements
        try {
          final statsRepo = await ref.read(statsRepositoryProvider.future);
          await statsRepo.incrementTasksCompleted(DateTime.now());
          final stats = await statsRepo.getStats();
          final streak = await statsRepo.getCurrentStreak();
          final newAchievement = await ref.read(achievementsProvider.notifier).checkAndUnlock(
            totalSessions: stats.totalSessions,
            totalTasks: stats.totalTasksCompleted,
            currentStreak: streak,
          );
          if (newAchievement != null) {
            // Use overlay service for showing achievement toast
            if (overlayService.isInitialized) {
              final defs = ref.read(achievementDefinitionsProvider);
              try {
                final def = defs.firstWhere((d) => d.id == newAchievement.definitionId);
                AchievementToast.showOverlay(overlayService, def);
              } catch (_) {}
            }
          }
        } catch (_) {}

        // Add XP for completing task
        await ref.read(gamificationProvider.notifier).addXpForTask();

        // Show celebration using overlay service
        if (overlayService.isInitialized) {
          TaskCompletionCelebration.showOverlay(
            overlayService,
            xpEarned: 10,
            taskTitle: task.title,
          );
        }

        ref.invalidateSelf();
      }
    }
  }

  Future<void> deleteTask(String id) async {
    if (_repository != null) {
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
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      return tasks.where((t) {
        if (t.completed) {
          return t.completedAt != null && t.completedAt!.isAfter(todayStart);
        }
        return t.createdAt.isAfter(todayStart) || t.createdAt.isAtSameMomentAs(todayStart);
      }).toList();
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
