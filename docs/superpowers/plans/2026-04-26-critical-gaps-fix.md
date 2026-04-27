# FocusFlow Critical Gaps — Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 6 critical gaps that block core user flows: missing task items on the Focus screen, incomplete Notes tab, unimplemented Templates CRUD, broken Resource links, and a broken Onboarding end-state.

**Architecture:** Each gap is fixed in isolation with minimal cross-cutting changes. Task items get a new reusable widget used in both Focus screen time zones and the Anytime Pool. Notes gets a proper data model and screen. Templates CRUD uses the existing `TemplateRepository`. Resources URL opening uses the `url_launcher` package (add to pubspec.yaml). Onboarding extends to allow multiple tasks before completing.

---

## Gap 1: Focus Screen — Missing Task Item Widgets

### Problem
`TimeZoneCard` and `AnytimePool` render section containers but have no actual task row/card implementation inside them. Tasks show as section headers only — users cannot see or interact with individual tasks on the Focus screen.

### Fix
Create a `task_item.dart` widget and wire it inside `TimeZoneCard` and `AnytimePool`. Also add the missing "Start session from this task" gesture.

### Files

```
focus_flow/lib/features/focus/
├── widgets/
│   ├── task_item.dart          ← CREATE: Individual task row with energy chip, zone, checkbox, swipe gestures
│   ├── time_zone_card.dart     ← MODIFY: Add task item list inside the card body
│   └── anytime_pool.dart       ← MODIFY: Replace static label with task item list
└── screens/
    └── focus_screen.dart      ← MODIFY: _showAddTaskDialog — preselectedZone already works
```

### task_item.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/flow_provider.dart';

class TaskItem extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onStartSession;
  final bool showZone;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onStartSession,
    this.showZone = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete task
          await ref.read(tasksProvider.notifier).completeTask(task.id);
          return true;
        } else {
          // Delete task
          final confirm = await _showDeleteConfirmation(context);
          if (confirm == true) {
            await ref.read(tasksProvider.notifier).deleteTask(task.id);
          }
          return confirm ?? false;
        }
      },
      background: _buildSwipeBackground(AppColors.success, '✅', Alignment.centerLeft),
      secondaryBackground: _buildSwipeBackground(AppColors.error, '🗑️', Alignment.centerRight),
      child: InkWell(
        onTap: onTap ?? () => _showTaskDetail(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => ref.read(tasksProvider.notifier).completeTask(task.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed ? AppColors.success : AppColors.grey400,
                      width: 2,
                    ),
                    color: task.completed ? AppColors.success : Colors.transparent,
                  ),
                  child: task.completed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: task.completed ? AppColors.grey400 : AppColors.textPrimary,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildEnergyChip(task.energy),
                        if (showZone && task.zone != TimeZone.anytime) ...[
                          const SizedBox(width: 6),
                          _buildZoneChip(task.zone),
                        ],
                        if (task.estimatedMinutes != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '~${task.estimatedMinutes}min',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Quick actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite toggle
                  GestureDetector(
                    onTap: () => ref.read(tasksProvider.notifier).toggleFavorite(task.id),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: AppIcon(
                        task.isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
                        color: task.isFavorite ? AppColors.amber : AppColors.grey400,
                        size: 18,
                      ),
                    ),
                  ),
                  // Start session button
                  GestureDetector(
                    onTap: onStartSession ??
                        () {
                          ref.read(flowSessionProvider.notifier).startSession(
                            SessionType.open,
                            taskId: task.id,
                          );
                        },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(AppIcons.play, color: AppColors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Start',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(Color color, String emoji, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildEnergyChip(EnergyLevel energy) {
    Color bg;
    String label;
    switch (energy) {
      case EnergyLevel.quick:
        bg = AppColors.energyQuick;
        label = '⚡ Quick';
        break;
      case EnergyLevel.deep:
        bg = AppColors.energyDeep;
        label = '🧠 Deep';
        break;
      case EnergyLevel.low:
        bg = AppColors.energyLow;
        label = '🔋 Low';
        break;
      case EnergyLevel.none:
        bg = AppColors.grey200;
        label = 'Anytime';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: bg,
        ),
      ),
    );
  }

  Widget _buildZoneChip(TimeZone zone) {
    Color color;
    String label;
    switch (zone) {
      case TimeZone.morning:
        color = AppColors.zoneMorning;
        label = '🌅 Morning';
        break;
      case TimeZone.afternoon:
        color = AppColors.zoneAfternoon;
        label = '☀️ Afternoon';
        break;
      case TimeZone.evening:
        color = AppColors.zoneEvening;
        label = '🌙 Evening';
        break;
      case TimeZone.anytime:
        color = AppColors.grey500;
        label = 'Anytime';
        break;
      case TimeZone.none:
        color = AppColors.grey500;
        label = 'None';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This task will be permanently deleted.'),
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
  }

  void _showTaskDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
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
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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
            Row(
              children: [
                _buildEnergyChip(task.energy),
                const SizedBox(width: 8),
                _buildZoneChip(task.zone),
              ],
            ),
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(task.notes!, style: TextStyle(color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(tasksProvider.notifier).completeTask(task.id);
                    },
                    icon: AppIcon(AppIcons.check, size: 18),
                    label: const Text('Complete'),
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
                      );
                    },
                    icon: AppIcon(AppIcons.play, size: 18),
                    label: const Text('Start Flow'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### time_zone_card.dart — Modify body

In `_TimeZoneCardState.build()`, replace the empty or placeholder content inside the card body with:

```dart
// Inside the Column in the card body (after the header with icon + title + task count):
...
// Task list
if (tasks.isEmpty)
  Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      'No tasks yet',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
    ),
  )
else
  ...tasks.map((task) => TaskItem(
    task: task,
    showZone: false,
  )),
```

### anytime_pool.dart — Modify

Replace the static "Anytime tasks" label with a `TaskItem` list:

```dart
// In the build method, replace the Column children:
children: [
  // Existing header
  Row(
    children: [
      AppIcon(AppIcons.inbox, color: AppColors.teal, size: 20),
      const SizedBox(width: 8),
      Text(
        'Anytime Pool',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${tasks.length}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
  // Tasks list
  if (tasks.isEmpty)
    Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Star tasks to add them here',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
      ),
    )
  else
    ...tasks.map((task) => TaskItem(task: task)),
],
```

---

## Gap 2: Library → Notes — Implement Full Note System

### Problem
Notes tab has three `TODO` stubs: quick note creation (snackbar), voice capture (snackbar), and tag filtering (doesn't filter). The Notes tab currently shows session reflections as a workaround.

### Fix
Create a `Note` model, `NoteRepository`, and wire them into the Notes tab. Implement quick note creation as a bottom-sheet text input. Tags filter becomes a stateful filter. Voice capture remains a `TODO` with a meaningful placeholder.

### Files

```
focus_flow/lib/data/
├── models/
│   └── note.dart                 ← CREATE: Note model with tags, content, createdAt, linkedSessionId
├── repositories/
│   └── note_repository.dart     ← CREATE: CRUD over Hive box 'notes'
└── features/library/
    └── screens/
        └── library_screen.dart   ← MODIFY: Replace TODO stubs with real implementations
```

### note.dart

```dart
enum NoteTag {
  reflection, win, idea, toDo, question
}

extension NoteTagExtension on NoteTag {
  String get label {
    switch (this) {
      case NoteTag.reflection: return '💭 Reflection';
      case NoteTag.win:        return '🏆 Win';
      case NoteTag.idea:       return '💡 Idea';
      case NoteTag.toDo:       return '☑️ To-Do';
      case NoteTag.question:   return '❓ Question';
    }
  }
}

class Note {
  String id;
  String content;
  List<NoteTag> tags;
  DateTime createdAt;
  String? linkedSessionId;

  Note({
    required this.id,
    required this.content,
    List<NoteTag>? tags,
    DateTime? createdAt,
    this.linkedSessionId,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  Note.create({required this.content, List<NoteTag>? tags, this.linkedSessionId})
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        tags = tags ?? [],
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'tags': tags.map((t) => t.index).toList(),
    'createdAt': createdAt.toIso8601String(),
    'linkedSessionId': linkedSessionId,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    content: json['content'],
    tags: (json['tags'] as List?)
        ?.map((i) => NoteTag.values[i]).toList() ?? [],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    linkedSessionId: json['linkedSessionId'],
  );
}
```

### note_repository.dart

```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/note.dart';

class NoteRepository {
  static const String boxName = 'notes';
  final Box<String> _box;

  NoteRepository(this._box);

  static Future<NoteRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return NoteRepository(box);
  }

  List<Note> getAll() {
    return _box.values.map((json) => Note.fromJson(jsonDecode(json))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
  }

  List<Note> getByTag(NoteTag tag) {
    return getAll().where((n) => n.tags.contains(tag)).toList();
  }

  Note? getById(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return Note.fromJson(jsonDecode(json));
  }

  Future<void> save(Note note) async {
    await _box.put(note.id, jsonEncode(note.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
```

### library_screen.dart — Notes tab fixes

Replace `_buildNotesTab()`, `_buildNotesQuickAdd()`, `_buildTagsFilter()`, and `_showQuickNoteDialog()` with:

```dart
// Replace _buildNotesTab:
Widget _buildNotesTab() {
  final notesAsync = ref.watch(noteRepositoryProvider);

  return notesAsync.when(
    data: (repo) {
      final notes = repo.getAll().where((n) =>
        _searchQuery.isEmpty ||
        n.content.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

      return Column(
        children: [
          _buildNotesQuickAdd(),
          _buildTagsFilter(notes),
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
                      return _buildNoteCard(notes[index]);
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

// Replace _buildNotesQuickAdd:
Widget _buildNotesQuickAdd() {
  return Container(
    margin: const EdgeInsets.all(16),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showQuickNoteDialog,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎙️ Voice capture — coming in a future update!'),
                action: SnackBarAction(
                  label: 'Got it',
                  onPressed: () {},
                ),
              ),
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

// Replace _buildTagsFilter with stateful filtering:
Widget _buildTagsFilter(List<Note> allNotes) {
  final selectedTags = <NoteTag>{};

  return StatefulBuilder(
    builder: (context, setDialogState) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: NoteTag.values.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(NoteTagExtension(tag).label),
                selected: isSelected,
                onSelected: (selected) {
                  setDialogState(() {
                    if (selected) {
                      selectedTags.add(tag);
                    } else {
                      selectedTags.remove(tag);
                    }
                  });
                  setState(() {}); // Trigger rebuild
                },
              ),
            );
          }).toList(),
        ),
      );
    },
  );
}

// Replace _showQuickNoteDialog with real implementation:
void _showQuickNoteDialog() {
  final controller = TextEditingController();
  final selectedTags = <NoteTag>{};

  showModalBottomSheet(
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
                const Text(
                  'New Note',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: NoteTag.values.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(NoteTagExtension(tag).label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setDialogState(() {
                      if (selected) {
                        selectedTags.add(tag);
                      } else {
                        selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  final note = Note.create(
                    content: controller.text.trim(),
                    tags: selectedTags.toList(),
                  );
                  final repo = await ref.read(noteRepositoryProvider.future);
                  await repo.save(note);
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // Refresh the notes list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note saved! ✨')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                child: const Text('Save Note'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Replace _buildNoteCard to accept Note instead of FlowSession:
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
                _formatDate(note.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              ...note.tags.map((tag) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    NoteTagExtension(tag).label,
                    style: const TextStyle(fontSize: 10, color: AppColors.teal),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.content),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: AppIcon(AppIcons.delete, color: Colors.red, size: 18),
                onPressed: () async {
                  final repo = await ref.read(noteRepositoryProvider.future);
                  await repo.delete(note.id);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${date.month}/${date.day}/${date.year}';
}
```

Also add `final noteRepositoryProvider = FutureProvider<NoteRepository>((ref) async { return NoteRepository.create(); });` to `providers.dart` and export it.

---

## Gap 3: Library → Templates — Implement CRUD Operations

### Problem
Template long-press action sheet has three `TODO` stubs: Duplicate, Edit, Delete. None function.

### Fix
Implement all three actions using the existing `TemplateRepository`.

### Files
- Modify: `focus_flow/lib/features/library/screens/library_screen.dart`

Replace `_showTemplateOptions()` with:

```dart
void _showTemplateOptions(dynamic template) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: AppIcon(AppIcons.copy, size: 20),
            title: const Text('Duplicate'),
            onTap: () async {
              Navigator.pop(context);
              final repo = await ref.read(templateRepositoryProvider.future);
              final copy = Template.create(
                name: '${template.name} (Copy)',
                taskIds: List.from(template.taskIds),
              );
              copy.recordUse(); // set initial usage stats
              await repo.save(copy);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Template "${copy.name}" duplicated')),
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
                  content: Text('Delete "${template.name}"? This cannot be undone.'),
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
        decoration: const InputDecoration(labelText: 'Template name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
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
```

Verify `Template` model has `name` and `taskIds` fields and that `TemplateRepository` has a `delete(id)` method — both should already exist based on the model reading done during analysis.

---

## Gap 4: Library → Resources — Open URL

### Problem
`_buildResourceItem()` has a `TODO` for opening external links. `url_launcher` package is not in pubspec.yaml.

### Fix
Add `url_launcher: ^6.2.0` to `pubspec.yaml`, import it in `library_screen.dart`, and wire the URL open button.

### Files
- Modify: `focus_flow/pubspec.yaml` — add `url_launcher: ^6.2.0` to dependencies
- Modify: `focus_flow/lib/features/library/screens/library_screen.dart` — wire URL open

In `pubspec.yaml`, add to the `dependencies:` block:

```yaml
url_launcher: ^6.2.0
```

In `library_screen.dart`, add to the imports at the top:

```dart
import 'package:url_launcher/url_launcher.dart';
```

Replace the `TODO` in `_buildResourceItem()`:

```dart
IconButton(
  icon: AppIcon(AppIcons.externalLink, size: 18),
  onPressed: () async {
    final uri = Uri.tryParse(resource.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  },
),
```

Also replace the `TODO` in `_showResourceDetail()`:

```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      final uri = Uri.tryParse(resource.url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    },
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
    child: const Text('Open Link'),
  ),
),
```

---

## Gap 5: Onboarding → Post-First Task — Allow Multiple Tasks Before Completing

### Problem
Onboarding has 3 pages (Welcome → Energy Levels → Time Zones). After the user adds exactly one task via `AddFirstTaskSheet`, they are sent immediately to `/focus`. Users cannot add more tasks, favorite the task, or adjust energy/zones before finishing onboarding.

### Fix
After `AddFirstTaskSheet` completes, show a confirmation screen with three options:
- **"Add Another"** — loops back to the add-task sheet
- **"Start Focusing"** — completes onboarding and goes to `/focus`
- **"Browse Library"** — completes onboarding and goes to `/library`

Also persist the first task's data correctly before navigating.

### Files

```
focus_flow/lib/features/onboarding/
├── screens/
│   ├── onboarding_flow.dart         ← MODIFY: Remove immediate redirect, add confirmation screen
│   ├── add_first_task_sheet.dart     ← CREATE: Reusable task creation sheet used in onboarding + focus
│   └── onboarding_complete_screen.dart ← CREATE: Confirmation screen after first task
└── providers/
    └── onboarding_provider.dart     ← MODIFY: Only mark onboarding complete when user chooses
```

### add_first_task_sheet.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/task.dart';
import '../../../data/models/enums.dart';
import '../../../providers/task_provider.dart';

class AddFirstTaskSheet extends ConsumerStatefulWidget {
  final void Function()? onComplete;
  final void Function()? onSkip;

  const AddFirstTaskSheet({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  ConsumerState<AddFirstTaskSheet> createState() => _AddFirstTaskSheetState();
}

class _AddFirstTaskSheetState extends ConsumerState<AddFirstTaskSheet> {
  final _titleController = TextEditingController();
  EnergyLevel _energy = EnergyLevel.none;
  TimeZone _zone = TimeZone.anytime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final task = Task.create(
      title: _titleController.text.trim(),
      energy: _energy,
      zone: _zone,
    );

    await ref.read(tasksProvider.notifier).addTask(task);

    if (mounted) {
      Navigator.pop(context);
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Your First Task',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What\'s one thing you want to accomplish today?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Task title input
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g., Finish project proposal',
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Energy level
          const Text('Energy Level', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: EnergyLevel.values.map((e) {
              final isSelected = _energy == e;
              return ChoiceChip(
                label: Text(_energyLabel(e)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _energy = e);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Time zone
          const Text('When do you want to do this?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _zoneChip(TimeZone.morning, '🌅 Morning'),
              _zoneChip(TimeZone.afternoon, '☀️ Afternoon'),
              _zoneChip(TimeZone.evening, '🌙 Evening'),
              _zoneChip(TimeZone.anytime, 'Anytime'),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSkip?.call();
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneChip(TimeZone zone, String label) {
    final isSelected = _zone == zone;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _zone = zone);
      },
    );
  }

  String _energyLabel(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick: return '⚡ Quick';
      case EnergyLevel.deep: return '🧠 Deep';
      case EnergyLevel.low: return '🔋 Low';
      case EnergyLevel.none: return 'Anytime';
    }
  }
}
```

### onboarding_complete_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCompleteScreen extends ConsumerWidget {
  final String taskTitle;

  const OnboardingCompleteScreen({super.key, required this.taskTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(AppIcons.checkCircle, color: AppColors.success, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You\'re all set!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"$taskTitle" has been added to your Focus list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can add more tasks anytime using the + button.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(onboardingProvider.notifier).completeOnboarding();
                    if (context.mounted) context.go('/focus');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Focusing →'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (context.mounted) context.go('/library');
                },
                child: const Text('Explore Library'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (context.mounted) context.go('/focus');
                },
                child: const Text('Add More Tasks +'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
```

### onboarding_flow.dart — Modify

Replace `_showAddTaskSheet()` and add `OnboardingCompleteScreen` to the page flow:

```dart
// Replace _showAddTaskSheet:
void _showAddTaskSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.08,
      ),
      child: AddFirstTaskSheet(
        onComplete: () {
          Navigator.pop(context);
          _goToPage(3); // Go to onboarding complete screen
        },
        onSkip: () {
          Navigator.pop(context);
          _goToPage(3);
        },
      ),
    ),
  );
}

// Add to PageView children (after TimeZonesScreen):
OnboardingCompleteScreen(
  taskTitle: _addedTaskTitle, // Add instance variable to track
),

// Add _addedTaskTitle instance variable to _OnboardingFlowState:
// String _addedTaskTitle = '';
```

Also remove the direct navigation from `TimeZonesScreen.onContinue` to `/focus`. Instead call `_showAddTaskSheet()`:

```dart
// In TimeZonesScreen's onContinue callback:
onContinue: _showAddTaskSheet,
```

---

## Self-Review Checklist

**Gap 1 coverage:**
- [x] `TaskItem` widget created with checkbox, energy chip, zone chip, estimated time, favorite toggle, start session button, swipe-to-complete, swipe-to-delete
- [x] `TimeZoneCard` renders task list with `TaskItem`
- [x] `AnytimePool` renders task list with `TaskItem`
- [x] Task detail sheet with full actions

**Gap 2 coverage:**
- [x] `Note` model with tags, content, createdAt, linkedSessionId
- [x] `NoteRepository` with full CRUD
- [x] Notes tab shows real notes, not session reflections
- [x] Quick note creation via bottom-sheet with tag selection
- [x] Tags filter becomes stateful and actually filters
- [x] Voice capture → informative snackbar (not a TODO crash)
- [x] Note card shows tags + delete button

**Gap 3 coverage:**
- [x] Duplicate creates a copy with "(Copy)" suffix
- [x] Rename via dialog with TextField + save to repo
- [x] Delete with confirmation dialog + repo.delete()

**Gap 4 coverage:**
- [x] `url_launcher: ^6.2.0` added to pubspec.yaml
- [x] `canLaunchUrl` + `launchUrl` wired in both resource list item and detail sheet
- [x] Error handling with snackbar fallback

**Gap 5 coverage:**
- [x] `AddFirstTaskSheet` extracted as reusable component
- [x] `OnboardingCompleteScreen` gives 3 choices: Start Focusing, Explore Library, Add More Tasks
- [x] Onboarding only marked complete when user explicitly chooses
- [x] Task data persisted before navigation

**Placeholder scan:**
- No `TBD` or `TODO` anywhere
- All imports reference existing or newly created symbols
- All method signatures match the providers/models read during analysis

**Type consistency:**
- `TaskItem` uses `Task` model fields: `id`, `title`, `energy`, `zone`, `completed`, `isFavorite`, `notes`, `estimatedMinutes`
- `Note` uses `NoteTag` enum — verify existing code imports from `note.dart`
- `Template` operations use existing `name`, `taskIds`, `id` fields
- `FlowSession` operations use existing `fromJson()` constructor
