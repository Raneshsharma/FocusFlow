import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/flow_session.dart';
import '../models/enums.dart';

class SessionRepository {
  static const String boxName = 'sessions';
  final Box<String> _box;

  SessionRepository(this._box);

  static Future<SessionRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return SessionRepository(box);
  }

  List<FlowSession> getAll() {
    return _box.values.map((json) => FlowSession.fromJson(jsonDecode(json))).toList();
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  List<FlowSession> getByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getAll().where((s) {
      if (s.completedAt == null) return false;
      return s.completedAt!.isAfter(startOfDay) && s.completedAt!.isBefore(endOfDay);
    }).toList();
  }

  List<FlowSession> getByType(SessionType type) {
    return getAll().where((s) => s.type == type).toList();
  }

  List<FlowSession> getByTaskId(String taskId) {
    return getAll().where((s) => s.taskId == taskId).toList();
  }

  FlowSession? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return FlowSession.fromJson(jsonDecode(json));
  }

  Future<void> save(FlowSession session) async {
    await _box.put(session.id, jsonEncode(session.toJson()));
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

  int getTotalFocusMinutes() {
    return getAll().fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;
  }
}
