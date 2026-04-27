import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/energy_insight.dart';
import '../data/repositories/session_repository.dart';
import 'providers.dart';

final energyInsightProvider = FutureProvider<List<EnergyInsight>>((ref) async {
  final sessionsRepoAsync = ref.watch(sessionRepositoryProvider);

  return sessionsRepoAsync.when(
    data: (repo) {
      final sessions = repo.getAll();
      return EnergyInsight.generate(sessions);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
