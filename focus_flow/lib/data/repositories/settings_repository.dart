import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  static const String boxName = 'settings';
  final Box<String> _box;

  SettingsRepository(this._box);

  static Future<SettingsRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return SettingsRepository(box);
  }

  AppSettings? getSettings() {
    final json = _box.get('app_settings');
    if (json == null) return null;
    return AppSettings.fromJson(jsonDecode(json));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put('app_settings', jsonEncode(settings.toJson()));
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}