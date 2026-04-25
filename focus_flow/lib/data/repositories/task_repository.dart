import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/enums.dart';

class TaskRepository {
  static const String boxName = 'tasks';
  final Box<String> _box;

  TaskRepository(this._box);

  static Future<TaskRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return TaskRepository(box);
  }

  List<Task> getAll() {
    return _box.values.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  List<Task> getByZone(TimeZone zone) {
    return getAll().where((t) => t.zone == zone).toList();
  }

  List<Task> getByZoneAndCompleted(TimeZone zone, bool completed) {
    return getAll().where((t) => t.zone == zone && t.completed == completed).toList();
  }

  List<Task> getFavorites() {
    return getAll().where((t) => t.isFavorite).toList();
  }

  List<Task> getCompleted() {
    return getAll().where((t) => t.completed).toList();
  }

  List<Task> getIncomplete() {
    return getAll().where((t) => !t.completed).toList();
  }

  Task? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Task.fromJson(jsonDecode(json));
  }

  Future<void> save(Task task) async {
    await _box.put(task.id, jsonEncode(task.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  int count() {
    return _box.length;
  }
}
