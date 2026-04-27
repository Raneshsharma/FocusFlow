import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/wind_down_entry.dart';

class WindDownRepository {
  static const String boxName = 'wind_down';
  final Box<String> _box;

  WindDownRepository(this._box);

  static Future<WindDownRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return WindDownRepository(box);
  }

  List<WindDownEntry> getAll() {
    return _box.values.map((json) => WindDownEntry.fromJson(jsonDecode(json))).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest first
  }

  WindDownEntry? getByDate(DateTime date) {
    final dateKey = _dateKey(date);
    final json = _box.get(dateKey);
    if (json == null) return null;
    return WindDownEntry.fromJson(jsonDecode(json));
  }

  Future<void> save(WindDownEntry entry) async {
    final dateKey = _dateKey(entry.date);
    await _box.put(dateKey, jsonEncode(entry.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}