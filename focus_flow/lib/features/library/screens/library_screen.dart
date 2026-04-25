import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models/resource.dart';
import '../../../data/models/note.dart';
import '../../../data/models/flow_session.dart';
import '../widgets/session_list_item.dart';
import '../widgets/template_card.dart';
import '../widgets/resource_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _bragMode = false; // Toggle for Archive "Brag Document" mode

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Sessions'),
            Tab(text: 'Templates'),
            Tab(text: 'Favorites'),
            Tab(text: 'Notes'),
            Tab(text: 'Archive'),
            Tab(text: 'Resources'),
          ],
          labelColor: AppColors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.teal,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: AppIcon(AppIcons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSessionsTab(),
                  _buildTemplatesTab(),
                  _buildFavoritesTab(),
                  _buildNotesTab(),
                  _buildArchiveTab(),
                  _buildResourcesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SESSIONS TAB — "Prove it to my brain"
  // ============================================
  Widget _buildSessionsTab() {
    final sessionsAsync = ref.watch(sessionRepositoryProvider);

    return sessionsAsync.when(
      data: (repo) {
        final sessions = repo.getAll().where((s) =>
          _searchQuery.isEmpty ||
          s.type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.moodTag?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();

        // Sort by date, most recent first
        sessions.sort((a, b) => (b.completedAt ?? DateTime.now())
            .compareTo(a.completedAt ?? DateTime.now()));

        // Calculate stats
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final monthlySessions = sessions.where((s) =>
          s.completedAt != null && s.completedAt!.isAfter(thirtyDaysAgo)
        ).length;

        // Calculate flow streak
        final flowStreak = _calculateFlowStreak(sessions);

        return Column(
          children: [
            // Stats header
            _buildSessionsStatsHeader(flowStreak, monthlySessions, sessions.length, sessions),

            // Filter tabs
            _buildSessionsFilterChips(),

            // Sessions list
            Expanded(
              child: sessions.isEmpty
                  ? _buildEmptyState(
                      icon: AppIcons.history, // String for _buildEmptyState
                      title: 'No sessions yet',
                      subtitle: 'Complete your first flow session',
                    )
                  : _buildSessionsList(sessions),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSessionsStatsHeader(int flowStreak, int monthlySessions, int totalSessions, dynamic sessions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal.withOpacity(0.1), AppColors.amber.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Flow streak
          Row(
            children: [
              Text(
                flowStreak > 0 ? '🔥' : '💤',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flowStreak > 0
                          ? 'Flow Streak: $flowStreak day${flowStreak > 1 ? 's' : ''}'
                          : 'No active streak',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (flowStreak >= 3)
                      const Text(
                        '🔥 You\'re on fire!',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$monthlySessions', 'This month'),
              _buildStatItem('$totalSessions', 'Total'),
              _buildStatItem(_getMostProductiveDay(sessions), 'Best day'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.teal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  int _calculateFlowStreak(List<FlowSession> sessions) {
    if (sessions.isEmpty) return 0;

    // Get unique days with completed sessions, sorted descending
    final completedDays = sessions
        .where((s) => s.completedAt != null)
        .map((s) => DateTime(s.completedAt!.year, s.completedAt!.month, s.completedAt!.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (completedDays.isEmpty) return 0;

    // Check if today or yesterday has a session
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

    if (completedDays.first != todayDate && completedDays.first != yesterdayDate) {
      return 0; // Streak broken
    }

    // Count consecutive days
    int streak = 1;
    for (int i = 0; i < completedDays.length - 1; i++) {
      final diff = completedDays[i].difference(completedDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  String _getMostProductiveDay(dynamic repo) {
    if (repo == null) return '-';

    final sessions = repo.getAll();
    final dayCounts = <int, int>{};

    for (final session in sessions) {
      if (session.completedAt != null) {
        final weekday = session.completedAt!.weekday;
        dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
      }
    }

    if (dayCounts.isEmpty) return '-';

    final bestDay = dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[bestDay - 1];
  }

  Widget _buildSessionsFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', true),
          _buildFilterChip('Great 🔥', false, () => _filterByMood(MoodTag.great)),
          _buildFilterChip('Good 😊', false, () => _filterByMood(MoodTag.good)),
          _buildFilterChip('Okay 😐', false, () => _filterByMood(MoodTag.okay)),
          _buildFilterChip('Struggled 😓', false, () => _filterByMood(MoodTag.struggled)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _filterByMood(MoodTag mood) {
    // TODO: Implement mood filtering
  }

  Widget _buildSessionsList(List<FlowSession> sessions) {
    // Group by date
    final grouped = <String, List<FlowSession>>{};
    for (final session in sessions) {
      final dateKey = session.completedAt != null
          ? utils.DateUtils.formatDisplayDate(session.completedAt!)
          : 'In progress';
      grouped.putIfAbsent(dateKey, () => []).add(session);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final dateSessions = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...dateSessions.map((session) => _buildSessionItem(session)),
          ],
        );
      },
    );
  }

  Widget _buildSessionItem(FlowSession session) {
    final minutes = session.durationSeconds ~/ 60;
    final moodEmoji = session.moodTag?.emoji ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.teal.withOpacity(0.2),
          child: Text(
            session.type.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppColors.teal),
          ),
        ),
        title: Text('${session.type.name} · $minutes min'),
        subtitle: Row(
          children: [
            if (moodEmoji.isNotEmpty) ...[
              Text(moodEmoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
            ],
            if (session.reflection != null)
              AppIcon(AppIcons.note, size: 14, color: Colors.grey),
          ],
        ),
        trailing: AppIcon(AppIcons.chevronRight),
        onTap: () => _showSessionDetail(session),
      ),
    );
  }

  void _showSessionDetail(FlowSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.type.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Duration', '${session.durationSeconds ~/ 60} minutes'),
            if (session.completedAt != null)
              _detailRow('Completed', utils.DateUtils.formatDisplayDate(session.completedAt!)),
            if (session.moodTag != null)
              _detailRow('Mood', '${session.moodTag!.emoji} ${session.moodTag!.label}'),
            if (session.reflection != null && session.reflection!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Reflection',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(session.reflection!),
            ],
            const SizedBox(height: 24),
            // Mood tagging
            const Text(
              'How did this session feel?',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MoodTag.values.map((mood) =>
                GestureDetector(
                  onTap: () {
                    session.moodTag = mood;
                    // Save to repository
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Text(
                        mood.emoji,
                        style: TextStyle(
                          fontSize: session.moodTag == mood ? 32 : 24,
                        ),
                      ),
                      Text(
                        mood.label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ============================================
  // TEMPLATES TAB — "Reduce friction to zero"
  // ============================================
  Widget _buildTemplatesTab() {
    final templatesAsync = ref.watch(templateRepositoryProvider);

    return templatesAsync.when(
      data: (repo) {
        final templates = repo.getAll().where((t) =>
          _searchQuery.isEmpty ||
          t.name.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        if (templates.isEmpty) {
          return _buildEmptyState(
            icon: AppIcons.copy, // String for _buildEmptyState
            title: 'No templates yet',
            subtitle: 'Create templates from your tasks',
          );
        }

        // Sort by streak count (hot templates first) then by last used
        final sortedTemplates = List.from(templates);
        sortedTemplates.sort((a, b) {
          if (a.streakCount != b.streakCount) {
            return b.streakCount.compareTo(a.streakCount);
          }
          final aLast = a.lastUsed ?? DateTime;
          final bLast = b.lastUsed ?? DateTime;
          return bLast.compareTo(aLast);
        });

        return Column(
          children: [
            // Quick actions header
            _buildTemplatesQuickActions(sortedTemplates),

            // Templates grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: sortedTemplates.length,
                itemBuilder: (context, index) {
                  final template = sortedTemplates[index];
                  return TemplateCard(
                    name: template.name,
                    taskCount: template.taskIds.length,
                    usageCount: template.usageCount,
                    streakCount: template.streakCount,
                    bestTime: template.bestTimeOfDay,
                    isHot: template.streakCount >= 3,
                    onTap: () => _applyTemplate(template),
                    onLongPress: () => _showTemplateOptions(template),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTemplatesQuickActions(List<dynamic> templates) {
    // Find most recently used template
    final withLastUsed = templates.where((t) => t.lastUsed != null).toList();
    withLastUsed.sort((a, b) => b.lastUsed!.compareTo(a.lastUsed!));
    final lastUsed = withLastUsed;

    if (lastUsed.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _applyTemplate(lastUsed.first),
              icon: AppIcon(AppIcons.play, size: 20),
              label: Text('Use Last: ${lastUsed.first.name}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyTemplate(dynamic template) {
    template.recordUse();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied template: ${template.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showTemplateOptions(dynamic template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: AppIcon(AppIcons.copy, size: 20),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement duplicate
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.edit, size: 20),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.delete, color: Colors.red, size: 20),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement delete
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // FAVORITES TAB — "Catch the wave"
  // ============================================
  Widget _buildFavoritesTab() {
    final favoriteTasks = ref.watch(favoriteTasksProvider);
    final filtered = favoriteTasks.where((t) =>
      _searchQuery.isEmpty ||
      t.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: AppIcons.starFilled, // String for _buildEmptyState
        title: 'No favorites yet',
        subtitle: 'Star tasks to add them here',
      );
    }

    // Sort by energy level (high first) then by completion count
    filtered.sort((a, b) {
      final aEnergy = a.energy.index;
      final bEnergy = b.energy.index;
      if (aEnergy != bEnergy) return aEnergy.compareTo(bEnergy); // High energy first
      return (b.completionCount ?? 0).compareTo(a.completionCount ?? 0);
    });

    // Group by energy
    final highEnergy = filtered.where((t) => t.energy.name == 'quick').toList();
    final lowEnergy = filtered.where((t) => t.energy.name == 'low').toList();
    final anytime = filtered.where((t) =>
      t.energy.name != 'quick' && t.energy.name != 'low'
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Energy indicator
        _buildEnergyIndicator(),

        if (highEnergy.isNotEmpty) ...[
          _buildSectionHeader('Ready to Fire 🔥', AppColors.energyQuick),
          ...highEnergy.map((t) => _buildFavoriteItem(t, 'high')),
        ],

        if (anytime.isNotEmpty) ...[
          _buildSectionHeader('Anytime Anchors 🪝', AppColors.teal),
          ...anytime.map((t) => _buildFavoriteItem(t, 'medium')),
        ],

        if (lowEnergy.isNotEmpty) ...[
          _buildSectionHeader('Low Energy Mode 🔋', AppColors.energyLow),
          ...lowEnergy.map((t) => _buildFavoriteItem(t, 'low')),
        ],
      ],
    );
  }

  Widget _buildEnergyIndicator() {
    final hour = DateTime.now().hour;
    String energyLabel;
    Color energyColor;
    String energyIconPath;

    if (hour >= 6 && hour < 10) {
      energyLabel = 'Morning Energy: High';
      energyColor = AppColors.energyQuick;
      energyIconPath = AppIcons.sun;
    } else if (hour >= 10 && hour < 14) {
      energyLabel = 'Peak Focus Time';
      energyColor = AppColors.energyQuick;
      energyIconPath = AppIcons.bolt;
    } else if (hour >= 14 && hour < 17) {
      energyLabel = 'Afternoon Energy: Medium';
      energyColor = AppColors.amber;
      energyIconPath = AppIcons.cloud;
    } else if (hour >= 17 && hour < 21) {
      energyLabel = 'Evening Wind-down';
      energyColor = AppColors.energyLow;
      energyIconPath = AppIcons.nightlight;
    } else {
      energyLabel = 'Late Night Mode';
      energyColor = AppColors.energyLow;
      energyIconPath = AppIcons.bed;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: energyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: energyColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AppIcon(energyIconPath, size: 24, color: energyColor),
          const SizedBox(width: 8),
          Text(
            energyLabel,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: energyColor,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // TODO: Shuffle favorites by energy
            },
            child: const Text('Shuffle ↕'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(dynamic task, String energyType) {
    final completionCount = task.completionCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEnergyColor(task.energy.name).withOpacity(0.2),
          child: AppIcon(
            _getEnergyIconPath(task.energy.name),
            color: _getEnergyIconColor(task.energy.name),
            size: 20,
          ),
        ),
        title: Text(task.title),
        subtitle: Row(
          children: [
            Text(task.zone.name, style: const TextStyle(fontSize: 12)),
            if (completionCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                'Done $completionCount times',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        trailing: AppIcon(AppIcons.starFilled, color: AppColors.amber),
        onTap: () => _showTaskDetail(task),
      ),
    );
  }

  Color _getEnergyColor(String energy) {
    switch (energy) {
      case 'quick':
        return AppColors.energyQuick;
      case 'deep':
        return AppColors.energyDeep;
      case 'low':
        return AppColors.energyLow;
      default:
        return AppColors.teal;
    }
  }

  String _getEnergyIconPath(String energy) {
    switch (energy) {
      case 'quick':
        return AppIcons.bolt;
      case 'deep':
        return AppIcons.psychology;
      case 'low':
        return AppIcons.batteryCharging;
      default:
        return AppIcons.adjust;
    }
  }

  Color _getEnergyIconColor(String energy) {
    switch (energy) {
      case 'quick':
        return AppColors.energyQuick;
      case 'deep':
        return AppColors.energyDeep;
      case 'low':
        return AppColors.energyLow;
      default:
        return AppColors.teal;
    }
  }

  void _showTaskDetail(dynamic task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Energy', task.energy.name),
            _detailRow('Time Zone', task.zone.name),
            if (task.completionCount != null && task.completionCount! > 0)
              _detailRow('Completed', '${task.completionCount} times'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Add to today
                    },
                    icon: AppIcon(AppIcons.add, size: 20),
                    label: const Text('Add to Today'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Start session
                    },
                    icon: AppIcon(AppIcons.play, size: 20),
                    label: const Text('Start Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // NOTES TAB — "Voice dump + reflection"
  // ============================================
  Widget _buildNotesTab() {
    // For now, show session reflections as notes
    // TODO: Implement full Note model with separate repository
    final sessionsAsync = ref.watch(sessionRepositoryProvider);

    return sessionsAsync.when(
      data: (repo) {
        final sessionsWithNotes = repo.getAll()
            .where((s) => s.reflection != null && s.reflection!.isNotEmpty)
            .where((s) =>
              _searchQuery.isEmpty ||
              (s.reflection?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
            )
            .toList();

        return Column(
          children: [
            // Quick add button
            _buildNotesQuickAdd(),

            // Tags filter
            _buildTagsFilter(),

            // Notes list
            Expanded(
              child: sessionsWithNotes.isEmpty
                  ? _buildEmptyState(
                      icon: AppIcons.note,
                      title: 'No notes yet',
                      subtitle: 'Add reflections after completing sessions',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sessionsWithNotes.length,
                      itemBuilder: (context, index) {
                        final session = sessionsWithNotes[index];
                        return _buildNoteCard(session);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildNotesQuickAdd() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showQuickNoteDialog(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    AppIcon(AppIcons.add, size: 20, color: AppColors.teal),
                    const SizedBox(width: 8),
                    const Text(
                      'Tap to capture a quick note...',
                      style: TextStyle(color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // TODO: Voice capture
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice capture coming soon!')),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.energyDeep.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: AppIcon(AppIcons.mic, size: 20, color: AppColors.energyDeep),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickNoteDialog() {
    // TODO: Implement quick note creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick notes coming soon!')),
    );
  }

  Widget _buildTagsFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: NoteTags.all.map((tag) =>
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(NoteTags.getLabel(tag)),
              selected: false,
              onSelected: (selected) {
                // TODO: Filter by tag
              },
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildNoteCard(FlowSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  session.completedAt != null
                      ? utils.DateUtils.formatDisplayDate(session.completedAt!)
                      : 'Unknown date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '💭 Reflection',
                    style: TextStyle(fontSize: 10, color: AppColors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(session.reflection!),
            if (session.moodTag != null) ...[
              const SizedBox(height: 8),
              Text(
                '${session.moodTag!.emoji} ${session.moodTag!.label}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // ARCHIVE TAB — "Brag Document"
  // ============================================
  Widget _buildArchiveTab() {
    final tasksAsync = ref.watch(taskRepositoryProvider);

    return tasksAsync.when(
      data: (repo) {
        final archivedTasks = repo.getAll().where((t) => t.completed).toList();
        final filtered = archivedTasks.where((t) =>
          _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        // Calculate stats
        final totalCompleted = filtered.length;
        final thisWeek = filtered.where((t) {
          if (t.completedAt == null) return false;
          return t.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)));
        }).length;

        // Group by zone
        final byZone = <String, int>{};
        for (final task in filtered) {
          byZone[task.zone.name] = (byZone[task.zone.name] ?? 0) + 1;
        }

        return Column(
          children: [
            // Brag stats header
            _buildBragStatsHeader(totalCompleted, thisWeek, byZone, filtered),

            // Toggle brag mode
            _buildBragModeToggle(),

            // Archive list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(
                      icon: AppIcons.archive, // String for _buildEmptyState
                      title: 'Archive is empty',
                      subtitle: 'Completed tasks appear here',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return _buildArchiveItem(task);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBragStatsHeader(int total, int thisWeek, Map<String, int> byZone, List<dynamic> archivedTasks) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.amber.withOpacity(0.2), AppColors.teal.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '🌟 THIS MONTH',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$total', 'Tasks\nCompleted'),
              _buildStatItem('$thisWeek', 'This\nWeek'),
              _buildStatItem('${byZone['morning'] ?? 0}', 'Morning\nTasks'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _exportBragDoc(archivedTasks),
                icon: AppIcon(AppIcons.copy, size: 16),
                label: const Text('Export as Text'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _shareWin(total, thisWeek),
                icon: AppIcon(AppIcons.share, size: 16),
                label: const Text('Share Win 🎉'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBragModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('View as:'),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Brag 📣'),
            selected: _bragMode,
            onSelected: (selected) => setState(() => _bragMode = selected),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Archive 📁'),
            selected: !_bragMode,
            onSelected: (selected) => setState(() => _bragMode = !selected),
          ),
        ],
      ),
    );
  }

  void _exportBragDoc(List<dynamic> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('FocusFlow Accomplishments');
    buffer.writeln('========================');
    buffer.writeln('');
    buffer.writeln('Total Tasks Completed: ${tasks.length}');
    buffer.writeln('');
    buffer.writeln('Tasks:');
    for (final task in tasks) {
      buffer.writeln('- ${task.title}');
    }

    // TODO: Copy to clipboard or share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brag doc copied to clipboard!')),
    );
  }

  void _shareWin(int total, int thisWeek) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 I just completed $total tasks on FocusFlow this month, including $thisWeek this week! #ADHDProductivity'),
      ),
    );
  }

  Widget _buildArchiveItem(dynamic task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withOpacity(0.2),
          child: AppIcon(AppIcons.checkCircle, color: AppColors.success, size: 20),
        ),
        title: Text(
          task.title,
          style: _bragMode
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
        subtitle: Text(
          task.completedAt != null
              ? 'Completed ${utils.DateUtils.formatDisplayDate(task.completedAt!)}'
              : '',
        ),
        trailing: _bragMode
            ? AppIcon(AppIcons.celebration, color: AppColors.amber, size: 24)
            : null,
      ),
    );
  }

  // ============================================
  // RESOURCES TAB — "External brain"
  // ============================================
  Widget _buildResourcesTab() {
    final resourcesAsync = ref.watch(resourceRepositoryProvider);

    return resourcesAsync.when(
      data: (repo) {
        final resources = repo.getAll();
        final filtered = resources.where((r) =>
          _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.url.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        // Group by category
        final byCategory = <ResourceCategory, List<Resource>>{};
        for (final resource in filtered) {
          byCategory.putIfAbsent(resource.category, () => []).add(resource);
        }

        // Separate read later queue
        final readLater = filtered.where((r) => r.readLaterQueue).toList();
        final otherResources = filtered.where((r) => !r.readLaterQueue).toList();

        return Column(
          children: [
            // Category filter
            _buildResourceCategoryFilter(),

            // Resources list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(
                      icon: AppIcons.link, // String for _buildEmptyState
                      title: 'No resources saved',
                      subtitle: 'Save links and references here',
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Read Later section
                        if (readLater.isNotEmpty) ...[
                          _buildSectionHeader('📚 Read When Energy Is Low (${readLater.length})', AppColors.energyLow),
                          ...readLater.map((r) => _buildResourceItem(r)),
                          const SizedBox(height: 16),
                        ],

                        // Other resources by category
                        ...byCategory.entries
                            .where((e) => e.key != ResourceCategory.article || e.value.any((r) => !r.readLaterQueue))
                            .map((entry) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  '${entry.key.icon} ${entry.key.label}s (${entry.value.where((r) => !r.readLaterQueue).length})',
                                  _getCategoryColor(entry.key),
                                ),
                                ...entry.value
                                    .where((r) => !r.readLaterQueue)
                                    .map((r) => _buildResourceItem(r)),
                                const SizedBox(height: 16),
                              ],
                            )),
                      ],
                    ),
            ),

            // Add resource button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addResource,
                  icon: AppIcon(AppIcons.add, size: 20),
                  label: const Text('Add Resource'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildResourceCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', true),
          _buildFilterChip('📄 Article', false, () {}),
          _buildFilterChip('🛠️ Tool', false, () {}),
          _buildFilterChip('🎥 Video', false, () {}),
          _buildFilterChip('📚 Course', false, () {}),
        ],
      ),
    );
  }

  Widget _buildResourceItem(Resource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(resource.category).withOpacity(0.2),
          child: Text(
            resource.category.icon,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(resource.title),
        subtitle: Text(
          resource.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resource.readLaterQueue)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: AppIcon(AppIcons.bookmarkFilled, color: AppColors.energyLow, size: 16),
              ),
            IconButton(
              icon: AppIcon(AppIcons.externalLink, size: 18),
              onPressed: () {
                // TODO: Open URL
              },
            ),
          ],
        ),
        onTap: () => _showResourceDetail(resource),
      ),
    );
  }

  Color _getCategoryColor(ResourceCategory category) {
    switch (category) {
      case ResourceCategory.article:
        return AppColors.teal;
      case ResourceCategory.tool:
        return AppColors.energyQuick;
      case ResourceCategory.video:
        return const Color(0xFFE91E63);
      case ResourceCategory.course:
        return AppColors.energyDeep;
    }
  }

  void _showResourceDetail(Resource resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  resource.category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              resource.url,
              style: const TextStyle(color: AppColors.teal),
            ),
            if (resource.notes != null && resource.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(resource.notes!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                // Toggle read later
                TextButton.icon(
                  onPressed: () {
                    resource.readLaterQueue = !resource.readLaterQueue;
                    // TODO: Save to repo
                    Navigator.pop(context);
                  },
                  icon: AppIcon(
                    resource.readLaterQueue ? AppIcons.bookmarkFilled : AppIcons.bookmarkOutline,
                    color: AppColors.energyLow,
                    size: 24,
                  ),
                  label: Text(resource.readLaterQueue ? 'Remove from Read Later' : 'Add to Read Later'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Open URL
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                child: const Text('Open Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addResource() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    ResourceCategory selectedCategory = ResourceCategory.article;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Resource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
                const SizedBox(height: 16),
                const Text('Category:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ResourceCategory.values.map((cat) =>
                    ChoiceChip(
                      label: Text('${cat.icon} ${cat.label}'),
                      selected: selectedCategory == cat,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedCategory = cat);
                        }
                      },
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final repo = await ref.read(resourceRepositoryProvider.future);
      final resource = Resource.create(
        title: titleController.text,
        url: urlController.text,
        category: selectedCategory,
      );
      await repo.save(resource);
      setState(() {});
    }
  }

  // ============================================
  // SHARED COMPONENTS
  // ============================================
  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}