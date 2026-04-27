import 'package:hive/hive.dart';
import '../models/achievement.dart';

class AchievementRepository {
  static const String _boxName = 'achievements';
  static const String _unlockedKey = 'unlocked';

  Future<Box> get _box async => Hive.openBox(_boxName);

  Future<List<Achievement>> getUnlockedAchievements() async {
    final box = await _box;
    final List<dynamic>? data = box.get(_unlockedKey);
    if (data == null) return [];
    return data.map((e) => Achievement.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> unlockAchievement(String definitionId) async {
    final box = await _box;
    final existing = await getUnlockedAchievements();

    // Already unlocked
    if (existing.any((a) => a.definitionId == definitionId)) return;

    final achievement = Achievement(
      definitionId: definitionId,
      unlockedAt: DateTime.now(),
    );

    existing.add(achievement);
    await box.put(_unlockedKey, existing.map((a) => a.toJson()).toList());
  }

  Future<bool> isUnlocked(String definitionId) async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.any((a) => a.definitionId == definitionId);
  }

  Future<void> clearAll() async {
    final box = await _box;
    await box.delete(_unlockedKey);
  }
}