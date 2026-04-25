import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/enums.dart';
import '../data/repositories/task_repository.dart';
import 'providers.dart';

// Simple provider for tasks list
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final repoAsync = ref.watch(taskRepositoryProvider);
  return repoAsync.when(
    data: (repo) => TasksNotifier(repo),
    loading: () => TasksNotifier._loading(),
    error: (_, __) => TasksNotifier._error(),
  );
});

class TasksNotifier extends StateNotifier<List<Task>> {
  final TaskRepository? _repository;

  TasksNotifier(this._repository) : super([]) {
    if (_repository != null) {
      state = _repository!.getAll();
    }
  }

  TasksNotifier._loading() : _repository = null, super([]);

  TasksNotifier._error() : _repository = null, super([]);

  void refresh() {
    if (_repository != null) {
      state = _repository!.getAll();
    }
  }

  Future<void> addTask(Task task) async {
    await _repository?.save(task);
    refresh();
  }

  Future<void> updateTask(Task task) async {
    await _repository?.save(task);
    refresh();
  }

  Future<void> completeTask(String id) async {
    final task = _repository?.getById(id);
    if (task != null) {
      task.completed = true;
      task.completedAt = DateTime.now();
      await _repository?.save(task);
      refresh();
    }
  }

  Future<void> deleteTask(String id) async {
    await _repository?.delete(id);
    refresh();
  }

  Future<void> toggleFavorite(String id) async {
    final task = _repository?.getById(id);
    if (task != null) {
      task.isFavorite = !task.isFavorite;
      await _repository?.save(task);
      refresh();
    }
  }

  Future<void> updateTaskZone(String id, TimeZone zone) async {
    final task = _repository?.getById(id);
    if (task != null) {
      task.zone = zone;
      await _repository?.save(task);
      refresh();
    }
  }
}

// Filtered providers
final incompleteTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => !t.completed).toList();
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.completed).toList();
});

final favoriteTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.isFavorite).toList();
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
