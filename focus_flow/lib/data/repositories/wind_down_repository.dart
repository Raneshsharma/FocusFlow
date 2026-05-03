import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/wind_down_entry.dart';
import '../../core/utils/date_helpers.dart';

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
    final dateKey = formatDateKey(date);
    final json = _box.get(dateKey);
    if (json == null) return null;
    return WindDownEntry.fromJson(jsonDecode(json));
  }

  Future<void> save(WindDownEntry entry) async {
    final dateKey = formatDateKey(entry.date);
    await _box.put(dateKey, jsonEncode(entry.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}