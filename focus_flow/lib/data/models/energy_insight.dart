enum InsightType {
  peakTime,
  energyPattern,
  tip,
}

class EnergyInsight {
  final String title;
  final String body;
  final InsightType type;

  const EnergyInsight({
    required this.title,
    required this.body,
    required this.type,
  });

  static List<EnergyInsight> generate(List<dynamic> sessions) {
    final insights = <EnergyInsight>[];

    if (sessions.isEmpty) {
      insights.add(const EnergyInsight(
        title: 'Start tracking',
        body: 'Complete focus sessions to discover your energy patterns.',
        type: InsightType.tip,
      ));
      return insights;
    }

    // Analyze: what time of day gets the longest sessions?
    final byHour = <int, List<dynamic>>{};
    for (final session in sessions) {
      if (session.startedAt != null) {
        final hour = session.startedAt!.hour;
        byHour.putIfAbsent(hour, () => []).add(session);
      }
    }

    if (byHour.isNotEmpty) {
      final peakHourEntry = byHour.entries.reduce((a, b) =>
        a.value.length > b.value.length ? a : b);

      final peakHour = peakHourEntry.key;
      final peakLabel = _formatHour(peakHour);
      insights.add(EnergyInsight(
        title: '⚡ Your peak hour',
        body: "You're most productive around $peakLabel.",
        type: InsightType.peakTime,
      ));
    }

    // Energy pattern insights
    final energyCounts = <String, int>{};
    for (final session in sessions) {
      final energyName = session.energyLevel?.name ?? 'none';
      energyCounts[energyName] = (energyCounts[energyName] ?? 0) + 1;
    }

    if (energyCounts.isNotEmpty) {
      final mostCommon = energyCounts.entries.reduce((a, b) =>
        a.value > b.value ? a : b).key;

      if (mostCommon != 'none') {
        insights.add(EnergyInsight(
          title: '🔋 Most used energy',
          body: "You've been doing mostly ${mostCommon.toLowerCase()} energy tasks.",
          type: InsightType.energyPattern,
        ));
      }
    }

    // General tip
    insights.add(const EnergyInsight(
      title: '💡 Pro tip',
      body: 'Break complex tasks into smaller pieces to match your energy levels.',
      type: InsightType.tip,
    ));

    return insights;
  }

  static String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
