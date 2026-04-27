import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models/resource.dart';
import '../../../data/models/note.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../data/models/template.dart';
import '../../../services/file_helper.dart';
import '../../../services/voice_transcription_service.dart';
import '../widgets/session_list_item.dart';
import '../widgets/template_card.dart';
import '../widgets/resource_tile.dart';
import '../../achievements/screens/achievement_gallery_screen.dart';

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
  MoodTag? _moodFilter; // Current mood filter (null = All)
  bool _favoritesSortDesc = true; // true = by frequency (most completed first)
  final Set<String> _selectedNoteTags = {}; // Selected note tags for filtering

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
            Tab(text: '🏆'),
          ],
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.grey500,
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
                  fillColor: AppColors.grey100,
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
                  _buildAchievementsTab(),
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
        final allSessions = repo.getAll();

        // Apply search filter
        final filteredBySearch = allSessions.where((s) =>
          _searchQuery.isEmpty ||
          s.type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.moodTag?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();

        // Apply mood filter
        final sessions = _moodFilter == null
            ? filteredBySearch
            : filteredBySearch.where((s) => s.moodTag == _moodFilter).toList();

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
            color: AppColors.grey600,
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

  String _getMostProductiveDay(List<FlowSession> sessions) {
    if (sessions.isEmpty) return '-';

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
          _buildFilterChip('All', _moodFilter == null, () {
            setState(() => _moodFilter = null);
          }),
          _buildFilterChip('Great 🔥', _moodFilter == MoodTag.great, () {
            setState(() => _moodFilter = MoodTag.great);
          }),
          _buildFilterChip('Good 😊', _moodFilter == MoodTag.good, () {
            setState(() => _moodFilter = MoodTag.good);
          }),
          _buildFilterChip('Okay 😐', _moodFilter == MoodTag.okay, () {
            setState(() => _moodFilter = MoodTag.okay);
          }),
          _buildFilterChip('Struggled 😓', _moodFilter == MoodTag.struggled, () {
            setState(() => _moodFilter = MoodTag.struggled);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.grey200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.grey700,
            fontSize: 12,
          ),
        ),
      ),
    );
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
                  color: AppColors.grey500,
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
              AppIcon(AppIcons.note, size: 14, color: AppColors.grey500),
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
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              Text(session.reflection!),
            ],
            const SizedBox(height: 24),
            // Mood tagging
            const Text(
              'How did this session feel?',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MoodTag.values.map((mood) =>
                GestureDetector(
                  onTap: () async {
                    session.moodTag = mood;
                    // Save to repository
                    final repo = await ref.read(sessionRepositoryProvider.future);
                    await repo.save(session);
                    if (mounted) Navigator.pop(context);
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
          Text(label, style: const TextStyle(color: AppColors.grey500)),
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
        final sortedTemplates = templates.toList()..sort((a, b) {
          if (a.streakCount != b.streakCount) {
            return b.streakCount.compareTo(a.streakCount);
          }
          final aLast = a.lastUsed ?? DateTime.now();
          final bLast = b.lastUsed ?? DateTime.now();
          return bLast.compareTo(aLast);
        });

        return Column(
          children: [
            // Quick actions header
            _buildTemplatesQuickActions(sortedTemplates),

            // Templates grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid based on screen width
                  final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
                  final aspectRatio = constraints.maxWidth >= 900 ? 1.4 : 1.2;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
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

  Widget _buildTemplatesQuickActions(List<Template> templates) {
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

  void _applyTemplate(Template template) {
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

  void _showTemplateOptions(Template template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: AppIcon(AppIcons.copy, size: 20),
            title: const Text('Duplicate'),
            onTap: () async {
              Navigator.pop(context);
              final repo = await ref.read(templateRepositoryProvider.future);
              final copy = Template(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: '${template.name} (Copy)',
                taskIds: List<String>.from(template.taskIds),
                zone: template.zone,
                usageCount: 0,
                streakCount: 0,
              );
              await repo.save(copy);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Template "${copy.name}" created'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.edit, size: 20),
            title: const Text('Rename'),
            onTap: () async {
              Navigator.pop(context);
              await _showRenameTemplateDialog(template);
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.delete, color: Colors.red, size: 20),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Template?'),
                  content: Text(
                    'Delete "${template.name}"? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final repo = await ref.read(templateRepositoryProvider.future);
                await repo.delete(template.id);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameTemplateDialog(dynamic template) async {
    final controller = TextEditingController(text: template.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Template name',
            hintText: 'e.g., Morning Routine',
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
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final repo = await ref.read(templateRepositoryProvider.future);
      template.name = controller.text.trim();
      await repo.save(template);
      setState(() {});
    }
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
    if (_favoritesSortDesc) {
      // Sort by frequency: most completed first
      filtered.sort((a, b) {
        final aCount = a.completionCount ?? 0;
        final bCount = b.completionCount ?? 0;
        if (aCount != bCount) return bCount.compareTo(aCount);
        // Secondary: by energy (high energy first)
        return a.energy.index.compareTo(b.energy.index);
      });
    } else {
      // Sort by energy priority first
      filtered.sort((a, b) {
        final aEnergy = a.energy.index;
        final bEnergy = b.energy.index;
        if (aEnergy != bEnergy) return aEnergy.compareTo(bEnergy);
        // Secondary: by frequency
        return (b.completionCount ?? 0).compareTo(a.completionCount ?? 0);
      });
    }

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
              setState(() {
                // Toggle sort order between "by energy" and "by frequency"
                _favoritesSortDesc = !_favoritesSortDesc;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _favoritesSortDesc ? 'Most Done ↓' : 'Energy ↑',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
                ),
              ],
            ),
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

  Widget _buildFavoriteItem(Task task, String energyType) {
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
                  color: AppColors.grey600,
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

  void _showTaskDetail(Task task) {
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
                      // Navigate to focus screen
                      context.go('/focus');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${task.title}" is in your Focus list'),
                          backgroundColor: AppColors.teal,
                        ),
                      );
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
                      ref.read(flowSessionProvider.notifier).startSession(
                        SessionType.open,
                        taskId: task.id,
                        taskTitle: task.title,
                      );
                      context.go('/flow');
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
    final notesAsync = ref.watch(noteRepositoryProvider);

    return notesAsync.when(
      data: (repo) {
        var notes = repo.getAll().where((n) =>
          _searchQuery.isEmpty ||
          n.content.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        // Apply tag filter
        if (_selectedNoteTags.isNotEmpty) {
          notes = notes.where((n) => n.tags.any((t) => _selectedNoteTags.contains(t))).toList();
        }

        return Column(
          children: [
            // Quick add button
            _buildNotesQuickAdd(),

            // Tags filter
            _buildTagsFilter(),

            // Notes list
            Expanded(
              child: notes.isEmpty
                  ? _buildEmptyState(
                      icon: AppIcons.note,
                      title: 'No notes yet',
                      subtitle: 'Tap below to capture a quick note',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _buildNoteCard(note);
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
            onPressed: () => _recordVoiceNote(),
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

  void _showQuickNoteDialog() async {
    final contentController = TextEditingController();
    final selectedTags = <String>{};

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Note',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: AppIcon(AppIcons.close, size: 24),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tags',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NoteTags.all.map((tag) =>
                  FilterChip(
                    label: Text(NoteTags.getLabel(tag)),
                    selected: selectedTags.contains(tag),
                    onSelected: (selected) {
                      setDialogState(() {
                        if (selected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && contentController.text.trim().isNotEmpty && mounted) {
      final repo = await ref.read(noteRepositoryProvider.future);
      final note = Note.create(
        content: contentController.text.trim(),
        tags: selectedTags.toList(),
      );
      await repo.save(note);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _recordVoiceNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoiceRecordSheet(
        onSaved: (transcription) async {
          final repo = await ref.read(noteRepositoryProvider.future);
          final note = Note.create(
            content: transcription,
            tags: [],
          );
          await repo.save(note);
          setState(() {});
        },
      ),
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
              selected: _selectedNoteTags.contains(tag),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedNoteTags.add(tag);
                  } else {
                    _selectedNoteTags.remove(tag);
                  }
                });
              },
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
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
                  utils.DateUtils.formatDisplayDate(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(width: 8),
                if (note.isVoiceNote)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.energyDeep.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(AppIcons.mic, size: 10, color: AppColors.energyDeep),
                        const SizedBox(width: 4),
                        const Text(
                          'Voice',
                          style: TextStyle(fontSize: 10, color: AppColors.energyDeep),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.content),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: note.tags.map((tag) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      NoteTags.getLabel(tag),
                      style: const TextStyle(fontSize: 10, color: AppColors.teal),
                    ),
                  ),
                ).toList(),
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

  Widget _buildBragStatsHeader(int total, int thisWeek, Map<String, int> byZone, List<Task> archivedTasks) {
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

  void _exportBragDoc(List<Task> tasks) async {
    final buffer = StringBuffer();
    buffer.writeln('FocusFlow Accomplishments');
    buffer.writeln('========================');
    buffer.writeln('');
    buffer.writeln('Total Tasks Completed: ${tasks.length}');
    buffer.writeln('');

    // Group by completion date
    final byDate = <String, List<dynamic>>{};
    for (final task in tasks) {
      final dateKey = task.completedAt != null
          ? utils.DateUtils.formatDisplayDate(task.completedAt!)
          : 'Unknown date';
      byDate.putIfAbsent(dateKey, () => []).add(task);
    }

    for (final entry in byDate.entries) {
      buffer.writeln('\n${entry.key}:');
      for (final task in entry.value) {
        buffer.writeln('  ✓ ${task.title}');
      }
    }

    // Copy to clipboard
    try {
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Brag doc copied! ${tasks.length} tasks exported.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareBragDoc(String content) async {
    try {
      await share_plus.Share.share(content, subject: 'FocusFlow Accomplishments');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _shareWin(int total, int thisWeek) async {
    final message = '🎉 I just completed $total tasks on FocusFlow this month, including $thisWeek this week! #ADHDProductivity';
    try {
      await share_plus.Share.share(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildArchiveItem(Task task) {
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
          _buildFilterChip('All', true, () {}),
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
          style: TextStyle(color: AppColors.grey600, fontSize: 12),
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
              onPressed: () async {
                final uri = Uri.tryParse(resource.url);
                if (uri == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid URL'), backgroundColor: AppColors.error),
                    );
                  }
                  return;
                }
                try {
                  final canLaunch = await canLaunchUrl(uri);
                  if (canLaunch) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open this link'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening link: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
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
        return AppColors.categoryPink;
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
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey500),
              ),
              const SizedBox(height: 8),
              Text(resource.notes!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                // Toggle read later
                TextButton.icon(
                  onPressed: () async {
                    resource.readLaterQueue = !resource.readLaterQueue;
                    // Save to repo
                    final repo = await ref.read(resourceRepositoryProvider.future);
                    await repo.save(resource);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(resource.readLaterQueue
                              ? '"${resource.title}" added to Read Later'
                              : '"${resource.title}" removed from Read Later'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
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
                onPressed: () async {
                  final uri = Uri.tryParse(resource.url);
                  if (uri == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid URL'), backgroundColor: AppColors.error),
                      );
                    }
                    return;
                  }
                  try {
                    final canLaunch = await canLaunchUrl(uri);
                    if (canLaunch) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                      Navigator.pop(context);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open this link'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  }
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
          AppIcon(icon, size: 64, color: AppColors.grey300),
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
            style: TextStyle(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACHIEVEMENTS TAB
  // ============================================
  Widget _buildAchievementsTab() {
    return const AchievementGalleryScreen();
  }
}

// Voice recording sheet widget with real-time speech recognition
class _VoiceRecordSheet extends StatefulWidget {
  final Function(String transcription) onSaved;

  const _VoiceRecordSheet({required this.onSaved});

  @override
  State<_VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<_VoiceRecordSheet> {
  final VoiceTranscriptionService _speechService = VoiceTranscriptionService.instance;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _hasPermission = false;
  bool _showPermissionDenied = false;
  String _transcription = '';
  String _partialResult = '';
  int _listeningSeconds = 0;
  DateTime? _listeningStartTime;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _speechService.cancelListening();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!mounted) return;

    setState(() {
      _hasPermission = status.isGranted;
      _showPermissionDenied = status.isDenied || status.isPermanentlyDenied;
    });

    if (_hasPermission) {
      await _initializeSpeechService();
    }
  }

  Future<void> _initializeSpeechService() async {
    final success = await _speechService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = success;
        if (!success) {
          _showPermissionDenied = true;
        }
      });
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeSpeechService();
      if (!_isInitialized) return;
    }

    if (_isListening) return;

    setState(() {
      _isListening = true;
      _listeningSeconds = 0;
      _listeningStartTime = DateTime.now();
      _partialResult = '';
    });

    final started = await _speechService.startListening(
      onResult: (String result) {
        if (mounted) {
          setState(() {
            _transcription = result;
            _partialResult = '';
          });
        }
      },
      onPartialResult: (String partial) {
        if (mounted) {
          setState(() {
            _partialResult = partial;
          });
        }
      },
      onListeningComplete: () {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );

    if (!started && mounted) {
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start speech recognition'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Update timer
    _updateTimer();

    // Auto-stop at 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      if (_isListening && mounted) {
        _stopListening();
      }
    });
  }

  void _updateTimer() {
    if (!_isListening) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isListening && mounted) {
        setState(() {
          _listeningSeconds = DateTime.now().difference(_listeningStartTime!).inSeconds;
        });
        _updateTimer();
      }
    });
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await _speechService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
        // Finalize partial result
        if (_partialResult.isNotEmpty && _transcription.isEmpty) {
          _transcription = _partialResult;
          _partialResult = '';
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Note',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: AppIcon(AppIcons.close, size: 24),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Permission denied view
          if (_showPermissionDenied) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.mic_off, size: 48, color: AppColors.error),
                  const SizedBox(height: 8),
                  const Text(
                    'Microphone permission required',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please grant microphone access to record voice notes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _openAppSettings,
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Listening button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : AppColors.energyDeep.withOpacity(0.2),
                ),
                child: Center(
                  child: _isListening
                      ? const Icon(Icons.stop, size: 48, color: Colors.white)
                      : AppIcon(AppIcons.mic, size: 48, color: AppColors.energyDeep),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Timer/status display
            Text(
              _isListening
                  ? '${_formatTime(_listeningSeconds)} / 01:00'
                  : 'Tap to speak',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
              ),
            ),
          ],
          // Live transcription preview
          if (_isListening && (_transcription.isNotEmpty || _partialResult.isNotEmpty)) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_transcription.isNotEmpty)
                    Text(
                      _transcription,
                      style: const TextStyle(fontSize: 14),
                    ),
                  if (_partialResult.isNotEmpty)
                    Text(
                      _partialResult,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Final transcription
          if (!_isListening && _transcription.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _transcription,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (_transcription.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _transcription = '';
                        _partialResult = '';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await widget.onSaved(_transcription);
                      if (mounted) Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Note'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}