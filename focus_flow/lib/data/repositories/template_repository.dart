import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/template.dart';

class TemplateRepository {
  static const String boxName = 'templates';
  final Box<String> _box;

  TemplateRepository(this._box);

  static Future<TemplateRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return TemplateRepository(box);
  }

  List<Template> getAll() {
    return _box.values.map((json) => Template.fromJson(jsonDecode(json))).toList();
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  Template? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Template.fromJson(jsonDecode(json));
  }

  Future<void> save(Template template) async {
    await _box.put(template.id, jsonEncode(template.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> incrementUsageCount(String id) async {
    final template = getById(id);
    if (template != null) {
      template.usageCount++;
      await save(template);
    }
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
