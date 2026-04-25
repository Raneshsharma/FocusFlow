import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/resource.dart';

class ResourceRepository {
  static const String boxName = 'resources';
  final Box<String> _box;

  ResourceRepository(this._box);

  static Future<ResourceRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return ResourceRepository(box);
  }

  List<Resource> getAll() {
    return _box.values.map((json) => Resource.fromJson(jsonDecode(json))).toList();
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  Resource? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Resource.fromJson(jsonDecode(json));
  }

  Future<void> save(Resource resource) async {
    await _box.put(resource.id, jsonEncode(resource.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
