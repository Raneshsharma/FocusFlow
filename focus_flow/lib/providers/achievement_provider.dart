import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../core/constants/achievements.dart';
import '../providers/stats_provider.dart';

final achievementRepositoryProvider = Provider((ref) => AchievementRepository());

final achievementsProvider = AsyncNotifierProvider<AchievementsNotifier, List<Achievement>>(
  AchievementsNotifier.new,
);

class AchievementsNotifier extends AsyncNotifier<List<Achievement>> {
  AchievementRepository get _repo => ref.read(achievementRepositoryProvider);

  @override
  Future<List<Achievement>> build() async {
    return _repo.getUnlockedAchievements();
  }

  Future<Achievement?> checkAndUnlock({
    required int totalSessions,
    required int totalTasks,
    required int currentStreak,
  }) async {
    final unlockedIds = (await state.value ?? []).map((a) => a.definitionId).toSet();

    for (final def in achievementsCatalog) {
      if (!unlockedIds.contains(def.id) && def.isUnlocked(totalSessions, totalTasks, currentStreak)) {
        await _repo.unlockAchievement(def.id);
        ref.invalidateSelf();
        final all = await _repo.getUnlockedAchievements();
        state = AsyncValue.data(all);
        return all.last;
      }
    }
    return null;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final achievementDefinitionsProvider = Provider<List<AchievementDefinition>>((ref) {
  return achievementsCatalog;
});