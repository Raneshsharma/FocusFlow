import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/enums.dart';
import '../data/repositories/task_repository.dart';
import 'providers.dart';

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
        await _repository!.save(task);
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
