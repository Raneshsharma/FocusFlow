export 'task_provider.dart' show tasksProvider, TasksNotifier;
export 'flow_provider.dart' show flowSessionProvider, FlowSessionNotifier;
export 'stats_provider.dart' show todayStatsProvider, getTodayStatsProvider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/task_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/template_repository.dart';
import '../data/repositories/resource_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/note_repository.dart';

// Repository providers (initialized async)
final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  return TaskRepository.create();
});

final sessionRepositoryProvider = FutureProvider<SessionRepository>((ref) async {
  return SessionRepository.create();
});

final statsRepositoryProvider = FutureProvider<StatsRepository>((ref) async {
  return StatsRepository.create();
});

final templateRepositoryProvider = FutureProvider<TemplateRepository>((ref) async {
  return TemplateRepository.create();
});

final resourceRepositoryProvider = FutureProvider<ResourceRepository>((ref) async {
  return ResourceRepository.create();
});

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  return SettingsRepository.create();
});

final noteRepositoryProvider = FutureProvider<NoteRepository>((ref) async {
  return NoteRepository.create();
});