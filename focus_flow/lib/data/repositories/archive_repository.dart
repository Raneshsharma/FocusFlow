import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/archive_item.dart';

class ArchiveRepository {
  static const String boxName = 'archive';
  final Box<String> _box;

  ArchiveRepository(this._box);

  static Future<ArchiveRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return ArchiveRepository(box);
  }

  List<ArchiveItem> getAll() {
    return _box.values.map((json) => ArchiveItem.fromJson(jsonDecode(json))).toList();
  }

  List<ArchiveItem> getByType(ArchiveItemType type) {
    return getAll().where((item) => item.originalType == type).toList();
  }

  ArchiveItem? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return ArchiveItem.fromJson(jsonDecode(json));
  }

  ArchiveItem? getByOriginalId(String originalId) {
    try {
      return getAll().firstWhere((item) => item.originalId == originalId);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ArchiveItem item) async {
    await _box.put(item.id, jsonEncode(item.toJson()));
  }

  Future<void> archive(ArchiveItemType type, String originalId, Map<String, dynamic> data, ArchiveReason reason, {String? title}) async {
    final item = ArchiveItem.create(
      originalId: originalId,
      originalType: type,
      originalData: data,
      reason: reason,
      title: title,
    );
    await save(item);
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

  int countByType(ArchiveItemType type) {
    return getAll().where((item) => item.originalType == type).length;
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }
}