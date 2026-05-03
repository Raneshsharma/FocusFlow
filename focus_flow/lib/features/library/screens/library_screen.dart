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
import '../../../core/constants/achievements.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models/resource.dart';
import '../../../data/models/note.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/archive_item.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/task.dart';
import '../../../data/models/template.dart';
import '../../../services/file_helper.dart';
import '../../../services/voice_transcription_service.dart';
import '../widgets/session_list_item.dart';
import '../widgets/template_card.dart';
import '../widgets/resource_tile.dart';
import '../../achievements/screens/achievement_gallery_screen.dart';
import '../../achievements/widgets/achievement_badge.dart';

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
  ArchiveItemType? _archiveTypeFilter; // Filter for archive tab (null = All)

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

            // Achievements preview section
            _buildAchievementsPreview(),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSessionsTab(),
                  _buildTemplatesTab(),
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
          s.type.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.type.shortName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.taskTitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (s.reflection?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (s.moodTag?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();

        // Apply mood filter
        List<FlowSession> filteredSessions;
        if (_showFavoritesOnly) {
          filteredSessions = filteredBySearch.where((s) => s.isFavorite).toList();
        } else if (_moodFilter != null) {
          filteredSessions = filteredBySearch.where((s) => s.moodTag == _moodFilter).toList();
        } else {
          filteredSessions = filteredBySearch;
        }

        // Sort by date, most recent first
        filteredSessions.sort((a, b) => (b.completedAt ?? DateTime.now())
            .compareTo(a.completedAt ?? DateTime.now()));

        // Calculate stats
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final monthlySessions = filteredSessions.where((s) =>
          s.completedAt != null && s.completedAt!.isAfter(thirtyDaysAgo)
        ).length;

        // Calculate flow streak
        final flowStreak = _calculateFlowStreak(filteredSessions);

        // Calculate total minutes this month
        final monthlyMinutes = filteredSessions
            .where((s) => s.completedAt != null && s.completedAt!.isAfter(thirtyDaysAgo))
            .fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;

        return Column(
          children: [
            // Stats header
            _buildSessionsStatsHeader(flowStreak, monthlySessions, monthlyMinutes, filteredSessions.length, filteredSessions),

            // Filter tabs
            _buildSessionsFilterChips(),

            // Sessions list
            Expanded(
              child: filteredSessions.isEmpty
                  ? _buildSessionsEmptyState()
                  : _buildSessionsList(filteredSessions, repo),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSessionsStatsHeader(int flowStreak, int monthlySessions, int monthlyMinutes, int totalSessions, dynamic sessions) {
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
              _buildStatItem('$monthlySessions', 'Sessions\nthis month'),
              _buildStatItem('$monthlyMinutes', 'Minutes\nthis month'),
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

  bool _showFavoritesOnly = false; // Filter for favorites only

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
          _buildFilterChip('All', _moodFilter == null && !_showFavoritesOnly, () {
            setState(() {
              _moodFilter = null;
              _showFavoritesOnly = false;
            });
          }),
          _buildFilterChip('⭐ Favorites', _showFavoritesOnly, () {
            setState(() {
              _moodFilter = null;
              _showFavoritesOnly = !_showFavoritesOnly;
            });
          }),
          _buildFilterChip('Great 🔥', _moodFilter == MoodTag.great, () {
            setState(() {
              _moodFilter = MoodTag.great;
              _showFavoritesOnly = false;
            });
          }),
          _buildFilterChip('Good 😊', _moodFilter == MoodTag.good, () {
            setState(() {
              _moodFilter = MoodTag.good;
              _showFavoritesOnly = false;
            });
          }),
          _buildFilterChip('Okay 😐', _moodFilter == MoodTag.okay, () {
            setState(() {
              _moodFilter = MoodTag.okay;
              _showFavoritesOnly = false;
            });
          }),
          _buildFilterChip('Struggled 😓', _moodFilter == MoodTag.struggled, () {
            setState(() {
              _moodFilter = MoodTag.struggled;
              _showFavoritesOnly = false;
            });
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

  Widget _buildSessionsList(List<FlowSession> sessions, dynamic repo) {
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
            ...dateSessions.map((session) => _buildSessionItem(session, repo)),
          ],
        );
      },
    );
  }

  Widget _buildSessionItem(FlowSession session, dynamic repo) {
    final minutes = session.durationSeconds ~/ 60;
    final timeStr = session.completedAt != null
        ? _formatTime(session.completedAt!)
        : '';

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Session?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        final sessionRepo = await ref.read(sessionRepositoryProvider.future);
        await sessionRepo.delete(session.id);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session deleted')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _showSessionDetail(session, repo),
          onLongPress: () => _showSessionContextMenu(session, repo),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Session type icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getSessionTypeColor(session.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      session.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            session.type.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSessionTypeColor(session.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$minutes min',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _getSessionTypeColor(session.type),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (timeStr.isNotEmpty) ...[
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                            if (session.taskTitle != null) ...[
                              const Text(' · ', style: TextStyle(color: AppColors.grey500)),
                              Flexible(
                                child: Text(
                                  session.taskTitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                      if (session.moodTag != null) ...[
                        const SizedBox(height: 4),
                        _buildMoodChip(session.moodTag!),
                      ],
                    ],
                  ),
                ),

                // Favorite toggle
                IconButton(
                  onPressed: () async {
                    session.isFavorite = !session.isFavorite;
                    await repo.save(session);
                    setState(() {});
                  },
                  icon: Icon(
                    session.isFavorite ? Icons.star : Icons.star_border,
                    color: session.isFavorite ? AppColors.amber : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSessionTypeColor(SessionType type) {
    switch (type) {
      case SessionType.open:
        return AppColors.amber;
      case SessionType.pomodoro:
        return AppColors.sessionPomodoro;
      case SessionType.deep:
        return AppColors.sessionDeep;
      case SessionType.custom:
        return AppColors.teal;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildMoodChip(MoodTag mood) {
    Color chipColor;
    switch (mood) {
      case MoodTag.great:
        chipColor = Colors.green;
        break;
      case MoodTag.good:
        chipColor = Colors.blue;
        break;
      case MoodTag.okay:
        chipColor = Colors.amber;
        break;
      case MoodTag.struggled:
        chipColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            mood.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionContextMenu(FlowSession session, dynamic repo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              session.isFavorite ? Icons.star : Icons.star_border,
              color: AppColors.amber,
            ),
            title: Text(session.isFavorite ? 'Remove from favorites' : 'Add to favorites'),
            onTap: () async {
              Navigator.pop(context);
              session.isFavorite = !session.isFavorite;
              await repo.save(session);
              setState(() {});
            },
          ),
          if (session.moodTag == null)
            ListTile(
              leading: const Text('😀', style: TextStyle(fontSize: 20)),
              title: const Text('Add mood tag'),
              onTap: () async {
                Navigator.pop(context);
                session.moodTag = MoodTag.good;
                await repo.save(session);
                setState(() {});
              },
            ),
          ListTile(
            leading: AppIcon(AppIcons.edit, size: 20),
            title: const Text('Add/edit note'),
            onTap: () {
              Navigator.pop(context);
              _showSessionDetail(session, repo);
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.delete, color: Colors.red, size: 20),
            title: const Text('Delete session', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Session?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await repo.delete(session.id);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(FlowSession session, dynamic repo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionDetailSheet(
        session: session,
        onUpdate: () async {
          await repo.save(session);
          if (mounted) setState(() {});
        },
        onDelete: () async {
          await repo.delete(session.id);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _buildSessionsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📭',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'No sessions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first focus session in the Flow tab',
            style: TextStyle(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/flow'),
            icon: AppIcon(AppIcons.play, size: 20, color: Colors.white),
            label: const Text('Start a Flow'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
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

    // Group by energy using type-safe enum comparisons
    final highEnergy = filtered.where((t) => t.energy == EnergyLevel.quick).toList();
    final lowEnergy = filtered.where((t) => t.energy == EnergyLevel.low).toList();
    final anytime = filtered.where((t) =>
      t.energy != EnergyLevel.quick && t.energy != EnergyLevel.low
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
        // Get non-archived notes only
        var notes = repo.getAll()
            .where((n) => !n.isArchived)
            .toList();

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          notes = notes.where((n) =>
            n.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            n.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
          ).toList();
        }

        // Apply category filter (OR logic - show notes matching ANY selected category)
        if (_selectedNoteTags.isNotEmpty) {
          notes = notes.where((n) => n.tags.any((t) => _selectedNoteTags.contains(t))).toList();
        }

        // Sort by date, newest first
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            // Quick add button
            _buildNotesQuickAdd(),

            // Category filter chips
            _buildCategoryFilterChips(),

            // Notes list
            Expanded(
              child: notes.isEmpty
                  ? _buildNotesEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _buildNoteCard(note, repo);
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
              onTap: () => _showNoteEditor(null),
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

  void _showNoteEditor(Note? note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteEditorSheet(
        note: note,
        onSaved: (updatedNote) async {
          final repo = await ref.read(noteRepositoryProvider.future);
          await repo.save(updatedNote);
          setState(() {});
        },
        onDeleted: note != null ? () async {
          note.isArchived = true;
          final repo = await ref.read(noteRepositoryProvider.future);
          await repo.save(note);
          setState(() {});
        } : null,
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // "All" chip when no filters selected
          if (_selectedNoteTags.isEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _selectedNoteTags.clear()),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.grey700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ...NoteTags.all.map((tag) => _buildCategoryChip(tag)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String tag) {
    final isSelected = _selectedNoteTags.contains(tag);
    final color = _getNoteTagColor(tag);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedNoteTags.remove(tag);
          } else {
            _selectedNoteTags.add(tag);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(NoteTags.getEmoji(tag), style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              NoteTags.getLabel(tag),
              style: TextStyle(
                color: isSelected ? color : AppColors.grey700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNoteTagColor(String tag) {
    switch (tag) {
      case 'idea':
        return Colors.amber;
      case 'todo':
        return Colors.blue;
      case 'remember':
        return Colors.orange;
      case 'later':
        return Colors.purple;
      case 'reflection':
        return Colors.green;
      default:
        return AppColors.teal;
    }
  }

  Widget _buildNotesEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No notes yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap below to capture a quick note',
            style: TextStyle(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  String _formatNoteTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  Widget _buildNoteCard(Note note, dynamic repo) {
    final primaryTag = note.tags.isNotEmpty ? note.tags.first : 'note';

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Archive Note?'),
            content: const Text('This note will be moved to Archive.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Archive'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        note.isArchived = true;
        final noteRepo = await ref.read(noteRepositoryProvider.future);
        await noteRepo.save(note);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note archived')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showNoteEditor(note),
          onLongPress: () => _showNoteContextMenu(note, repo),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: category chip + time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getNoteTagColor(primaryTag).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(NoteTags.getEmoji(primaryTag), style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            NoteTags.getLabel(primaryTag),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getNoteTagColor(primaryTag),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (note.isVoiceNote)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
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
                    Text(
                      _formatNoteTime(note.createdAt),
                      style: TextStyle(fontSize: 11, color: AppColors.grey500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Content preview (max 2 lines)
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),

                // Additional tags (if any)
                if (note.tags.length > 1) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.tags.skip(1).map((tag) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          NoteTags.getLabel(tag),
                          style: TextStyle(fontSize: 10, color: AppColors.grey600),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteContextMenu(Note note, dynamic repo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: AppIcon(AppIcons.edit, size: 20),
            title: const Text('Edit note'),
            onTap: () {
              Navigator.pop(context);
              _showNoteEditor(note);
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.copy, size: 20),
            title: const Text('Copy text'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: note.content));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          ListTile(
            leading: AppIcon(AppIcons.archive, size: 20),
            title: const Text('Archive'),
            onTap: () async {
              Navigator.pop(context);
              note.isArchived = true;
              await repo.save(note);
              setState(() {});
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
                  title: const Text('Delete Note?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await repo.delete(note.id);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
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

  // ============================================
  // ARCHIVE TAB — "Recycle Bin"
  // ============================================
  Widget _buildArchiveTab() {
    final archiveAsync = ref.watch(archiveRepositoryProvider);
    final taskRepoAsync = ref.watch(taskRepositoryProvider);

    return archiveAsync.when(
      data: (archiveRepo) {
        return taskRepoAsync.when(
          data: (taskRepo) => _buildArchiveContent(archiveRepo, taskRepo),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildArchiveContent(dynamic archiveRepo, dynamic taskRepo) {
    var allItems = archiveRepo.getAll() as List<ArchiveItem>;

    // Calculate stats
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));

    final thisMonthCount = allItems.where((ArchiveItem item) =>
      item.archivedAt.isAfter(thisMonth)
    ).length;

    final thisWeekCount = allItems.where((ArchiveItem item) =>
      item.archivedAt.isAfter(thisWeekStart)
    ).length;

    // Filter by type if selected
    final filteredItems = _archiveTypeFilter == null
        ? allItems
        : allItems.where((ArchiveItem item) => item.originalType == _archiveTypeFilter).toList();

    // Apply search filter
    final searchFiltered = filteredItems.where((ArchiveItem item) =>
      _searchQuery.isEmpty ||
      item.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item.preview.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    // Sort by archived date, newest first
    searchFiltered.sort((a, b) => b.archivedAt.compareTo(a.archivedAt));

    return Column(
      children: [
        // Stats header
        _buildArchiveStatsHeader(thisMonthCount, thisWeekCount, allItems.length),

        // Filter chips
        _buildArchiveFilterChips(allItems.length),

        // Archive list
        Expanded(
          child: searchFiltered.isEmpty
              ? _buildArchiveEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: searchFiltered.length,
                  itemBuilder: (context, index) {
                    final item = searchFiltered[index];
                    return _buildArchiveItemCard(item, archiveRepo, taskRepo);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildArchiveStatsHeader(int thisMonth, int thisWeek, int total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.amber.withOpacity(0.15), AppColors.teal.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '🗄️ ARCHIVE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$thisMonth', 'This\nMonth'),
              _buildStatItem('$thisWeek', 'This\nWeek'),
              _buildStatItem('$total', 'Total\nItems'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _exportArchive(),
                icon: AppIcon(AppIcons.copy, size: 16),
                label: const Text('Export'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _shareWin(thisMonth, thisWeek),
                icon: AppIcon(AppIcons.share, size: 16),
                label: const Text('Share 🎉'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveFilterChips(int totalCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildArchiveFilterChip('All ($totalCount)', _archiveTypeFilter == null, () {
            setState(() => _archiveTypeFilter = null);
          }),
          _buildArchiveFilterChip('✅ Tasks', _archiveTypeFilter == ArchiveItemType.task, () {
            setState(() => _archiveTypeFilter = ArchiveItemType.task);
          }),
          _buildArchiveFilterChip('🎯 Sessions', _archiveTypeFilter == ArchiveItemType.session, () {
            setState(() => _archiveTypeFilter = ArchiveItemType.session);
          }),
          _buildArchiveFilterChip('📝 Notes', _archiveTypeFilter == ArchiveItemType.note, () {
            setState(() => _archiveTypeFilter = ArchiveItemType.note);
          }),
          _buildArchiveFilterChip('🧩 Templates', _archiveTypeFilter == ArchiveItemType.template, () {
            setState(() => _archiveTypeFilter = ArchiveItemType.template);
          }),
        ],
      ),
    );
  }

  Widget _buildArchiveFilterChip(String label, bool selected, VoidCallback onTap) {
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

  Widget _buildArchiveEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🗄️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Archive is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed tasks and deleted items appear here',
            style: TextStyle(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatArchivedDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Archived ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildArchiveItemCard(ArchiveItem item, dynamic archiveRepo, dynamic taskRepo) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Permanently?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Forever'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await archiveRepo.delete(item.id);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.displayTitle} permanently deleted')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => _showArchiveItemOptions(item, archiveRepo, taskRepo),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getArchiveTypeColor(item.originalType).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      item.originalType.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.preview,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatArchivedDate(item.archivedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Restore button
                IconButton(
                  onPressed: () => _restoreItem(item, archiveRepo, taskRepo),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(AppIcons.refresh, size: 16, color: AppColors.success),
                  ),
                  tooltip: 'Restore',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getArchiveTypeColor(ArchiveItemType type) {
    switch (type) {
      case ArchiveItemType.task:
        return Colors.green;
      case ArchiveItemType.session:
        return AppColors.teal;
      case ArchiveItemType.note:
        return Colors.amber;
      case ArchiveItemType.template:
        return Colors.purple;
    }
  }

  Future<void> _restoreItem(ArchiveItem item, dynamic archiveRepo, dynamic taskRepo) async {
    try {
      switch (item.originalType) {
        case ArchiveItemType.task:
          // Restore task
          final task = taskRepo.getById(item.originalId);
          if (task != null) {
            task.completed = false;
            task.completedAt = null;
            await taskRepo.save(task);
          }
          break;
        case ArchiveItemType.session:
          // Sessions can't really be restored to active state
          break;
        case ArchiveItemType.note:
          // Notes would need noteRepo - simplified for now
          break;
        case ArchiveItemType.template:
          // Templates would need templateRepo
          break;
      }

      await archiveRepo.delete(item.id);
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.displayTitle} restored'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore: $e')),
        );
      }
    }
  }

  void _showArchiveItemOptions(ArchiveItem item, dynamic archiveRepo, dynamic taskRepo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(item.originalType.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.displayTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Restore
          ListTile(
            leading: AppIcon(AppIcons.refresh, size: 20, color: AppColors.success),
            title: const Text('Restore'),
            subtitle: Text('Move back to ${item.originalType.displayName.toLowerCase()}s'),
            onTap: () async {
              Navigator.pop(context);
              await _restoreItem(item, archiveRepo, taskRepo);
            },
          ),

          // Delete permanently
          ListTile(
            leading: AppIcon(AppIcons.delete, size: 20, color: Colors.red),
            title: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This cannot be undone'),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Permanently?'),
                  content: Text('Delete "${item.displayTitle}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete Forever'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await archiveRepo.delete(item.id);
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permanently deleted')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _exportArchive() async {
    final archiveRepo = await ref.read(archiveRepositoryProvider.future);
    final items = archiveRepo.getAll();

    if (items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archive is empty')),
        );
      }
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('FocusFlow Archive');
    buffer.writeln('=================');
    buffer.writeln('');
    buffer.writeln('Total items: ${items.length}');
    buffer.writeln('');

    // Group by type
    final byType = <ArchiveItemType, List<ArchiveItem>>{};
    for (final item in items) {
      byType.putIfAbsent(item.originalType, () => []).add(item);
    }

    for (final entry in byType.entries) {
      buffer.writeln('\n${entry.key.emoji} ${entry.key.displayName}s (${entry.value.length}):');
      for (final item in entry.value) {
        buffer.writeln('  • ${item.displayTitle}');
        buffer.writeln('    ${_formatArchivedDate(item.archivedAt)}');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archive exported! ${items.length} items')),
      );
    }
  }

  void _shareWin(int thisMonth, int thisWeek) async {
    final message = '🎉 I archived $thisMonth items this month ($thisWeek this week) on FocusFlow! #ADHDProductivity';
    try {
      await share_plus.Share.share(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  // Old Archive methods (to be removed)
  void _shareBragDoc(String content) async {
    try {
      await share_plus.Share.share(content, subject: 'FocusFlow Accomplishments');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  void _shareWinOld(int total, int thisWeek) async {
    final message = '🎉 I just completed $total tasks on FocusFlow this month, including $thisWeek this week! #ADHDProductivity';
    try {
      await share_plus.Share.share(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Widget _buildOldArchiveItem(Task task) {
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
                                  _getResourceColor(entry.key),
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
          backgroundColor: _getResourceColor(resource.category).withOpacity(0.2),
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

  Color _getResourceColor(ResourceCategory category) {
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
  // ACHIEVEMENTS PREVIEW SECTION
  // ============================================
  Widget _buildAchievementsPreview() {
    final achievementsAsync = ref.watch(achievementsProvider);
    final definitions = ref.watch(achievementDefinitionsProvider);

    return achievementsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => _buildAchievementsError(error.toString()),
      data: (unlockedAchievements) {
        final unlockedIds = unlockedAchievements.map((a) => a.definitionId).toSet();
        final unlockedCount = unlockedIds.length;
        final totalCount = definitions.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$unlockedCount / $totalCount',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _tabController.animateTo(5), // Achievements tab
                    child: Text(
                      'View all →',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Achievement badges - horizontal scroll
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: definitions.length,
                  itemBuilder: (context, index) {
                    final def = definitions[index];
                    final isUnlocked = unlockedIds.contains(def.id);
                    final unlockedAchievement = unlockedAchievements
                        .where((a) => a.definitionId == def.id)
                        .firstOrNull;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _showAchievementDetail(def, isUnlocked, unlockedAchievement?.unlockedAt),
                        child: SizedBox(
                          width: 70,
                          child: Column(
                            children: [
                              AchievementBadge(
                                definition: def,
                                isUnlocked: isUnlocked,
                                unlockedAt: unlockedAchievement?.unlockedAt,
                                size: 48,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                def.title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: isUnlocked ? AppColors.navy : AppColors.grey500,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? unlockedCount / totalCount : 0,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    unlockedCount == totalCount ? const Color(0xFFFFD700) : AppColors.teal,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementsError(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load achievements',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(achievementsProvider),
            child: Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetail(AchievementDefinition def, bool isUnlocked, DateTime? unlockedAt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? getTierColor(def.tier).withOpacity(0.2)
                    : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isUnlocked ? def.icon : '🔒',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              def.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: getTierColor(def.tier).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${def.tier.name[0].toUpperCase()}${def.tier.name.substring(1)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: getTierColor(def.tier),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              def.description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Status
            if (isUnlocked && unlockedAt != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked on ${_formatDate(unlockedAt)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.grey500, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Keep going to unlock!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // ============================================
  // ACHIEVEMENTS TAB
  // ============================================
  Widget _buildAchievementsTab() {
    return const AchievementGalleryScreen();
  }
}

// Session detail sheet widget
class _SessionDetailSheet extends StatefulWidget {
  final FlowSession session;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _SessionDetailSheet({
    required this.session,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<_SessionDetailSheet> {
  late TextEditingController _reflectionController;
  late MoodTag? _selectedMood;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController(text: widget.session.reflection ?? '');
    _selectedMood = widget.session.moodTag;
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.session.reflection = _reflectionController.text.trim();
    widget.session.moodTag = _selectedMood;
    widget.onUpdate();
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context); // Close detail sheet
      widget.onDelete(); // Delete session
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.session.durationSeconds ~/ 60;

    return Container(
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
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.session.type.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.type.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$minutes minutes',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: AppIcon(AppIcons.close, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date & Time
          if (widget.session.startedAt != null) ...[
            _detailRow('Started', _formatDateTime(widget.session.startedAt!)),
          ],
          if (widget.session.completedAt != null) ...[
            _detailRow('Ended', _formatDateTime(widget.session.completedAt!)),
          ],

          // Linked task
          if (widget.session.taskTitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  AppIcon(AppIcons.task, size: 16, color: AppColors.grey600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.session.taskTitle!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Mood rating section
          const Text(
            'How did it feel?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodTag.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                    _hasChanges = true;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getMoodColor(mood).withOpacity(0.2)
                            : AppColors.grey100,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: _getMoodColor(mood), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? _getMoodColor(mood) : AppColors.grey600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Reflection section
          const Text(
            'Reflection',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reflectionController,
            decoration: InputDecoration(
              hintText: 'How did the session go?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
            maxLength: 280,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _hasChanges ? () {
                    _save();
                    Navigator.pop(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(MoodTag mood) {
    switch (mood) {
      case MoodTag.great:
        return Colors.green;
      case MoodTag.good:
        return Colors.blue;
      case MoodTag.okay:
        return Colors.amber;
      case MoodTag.struggled:
        return Colors.red;
    }
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
}

// Note editor sheet widget
class _NoteEditorSheet extends StatefulWidget {
  final Note? note;
  final Function(Note) onSaved;
  final VoidCallback? onDeleted;

  const _NoteEditorSheet({
    this.note,
    required this.onSaved,
    this.onDeleted,
  });

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late TextEditingController _contentController;
  late Set<String> _selectedTags;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedTags = Set<String>.from(widget.note?.tags ?? []);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_contentController.text.trim().isEmpty) return;

    final note = widget.note ?? Note.create(content: '');
    note.content = _contentController.text.trim();
    note.tags = _selectedTags.toList();
    note.updatedAt = DateTime.now();

    widget.onSaved(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final color = _getNoteTagColorInEditor(_selectedTags.isNotEmpty ? _selectedTags.first : 'note');

    return Container(
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
          // Header
          Row(
            children: [
              Text(
                isEditing ? 'Edit Note' : 'New Note',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: AppIcon(AppIcons.close, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content field
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 5,
            autofocus: !isEditing,
            onChanged: (_) => setState(() => _hasChanges = true),
          ),
          const SizedBox(height: 16),

          // Category selector
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.grey700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NoteTags.all.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              final tagColor = _getNoteTagColorInEditor(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                    _hasChanges = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? tagColor.withOpacity(0.2) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: tagColor, width: 1.5) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(NoteTags.getEmoji(tag), style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        NoteTags.getLabel(tag),
                        style: TextStyle(
                          color: isSelected ? tagColor : AppColors.grey700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              if (isEditing && widget.onDeleted != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      widget.onDeleted!();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              if (isEditing && widget.onDeleted != null) const SizedBox(width: 12),
              Expanded(
                flex: isEditing ? 1 : 2,
                child: ElevatedButton(
                  onPressed: _contentController.text.trim().isNotEmpty ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(isEditing ? 'Save' : 'Create Note'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getNoteTagColorInEditor(String tag) {
    switch (tag) {
      case 'idea':
        return Colors.amber;
      case 'todo':
        return Colors.blue;
      case 'remember':
        return Colors.orange;
      case 'later':
        return Colors.purple;
      case 'reflection':
        return Colors.green;
      default:
        return AppColors.teal;
    }
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
                  const Text('🎤', style: TextStyle(fontSize: 48, color: AppColors.error)),
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
                      ? Text('⏹', style: TextStyle(fontSize: 48, color: Colors.white))
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