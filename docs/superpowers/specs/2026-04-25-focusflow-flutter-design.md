# FocusFlow Flutter Design Specification

**Date**: 2026-04-25
**Project**: FocusFlow Flutter Android App
**Platform**: Android only, mobile-first
**Architecture**: Clean Architecture with Riverpod + Hive

---

## 1. Project Overview

FocusFlow is an ADHD-friendly productivity app that helps users match tasks to their energy levels and time zones throughout the day.

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Persistence | Hive (JSON storage) |
| Navigation | GoRouter |
| Typography | Google Fonts (Inter, Montserrat) |
| UI | Material 3 |

### Folder Structure

```
focus_flow/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart     # Brand colors
│   │   │   └── app_theme.dart      # Material 3 theme
│   │   ├── constants/
│   │   │   └── app_constants.dart  # App-wide constants
│   │   ├── utils/
│   │   │   ├── date_utils.dart     # Date/time helpers
│   │   │   └── streak_calculator.dart
│   │   ├── router/
│   │   │   └── app_router.dart    # GoRouter config
│   │   └── widgets/
│   │       └── main_shell.dart    # Bottom navigation shell
│   ├── data/
│   │   ├── models/
│   │   │   ├── task.dart
│   │   │   ├── flow_session.dart
│   │   │   ├── template.dart
│   │   │   ├── resource.dart
│   │   │   ├── daily_stats.dart
│   │   │   ├── app_settings.dart
│   │   │   └── enums.dart
│   │   └── repositories/
│   │       ├── task_repository.dart
│   │       ├── session_repository.dart
│   │       ├── stats_repository.dart
│   │       ├── template_repository.dart
│   │       ├── resource_repository.dart
│   │       └── settings_repository.dart
│   ├── providers/
│   │   ├── task_provider.dart
│   │   ├── flow_provider.dart
│   │   ├── stats_provider.dart
│   │   └── providers.dart         # Provider exports
│   └── features/
│       ├── onboarding/            # 4-screen onboarding flow
│       ├── focus/                 # Main tasks screen (was "today")
│       ├── flow/                  # Timer/session screen
│       ├── rest/                  # Breaks & recovery
│       ├── library/               # Sessions, templates, resources
│       └── settings/              # App settings
```

---

## 2. Navigation Structure

### Bottom Navigation (4 tabs)

| Index | Label | Icon | Route | Screen |
|-------|-------|------|-------|--------|
| 0 | Focus | `adjust` (target/crosshair) | `/focus` | FocusScreen |
| 1 | Flow | `play_circle` | `/flow` | FlowScreen |
| 2 | Library | `library_books` | `/library` | LibraryScreen |
| 3 | Rest | `self_improvement` | `/rest` | RestScreen |

Settings accessible via AppBar action → `/settings`

### Route Hierarchy

```
/onboarding          → OnboardingFlow (first launch)
/focus               → FocusScreen (default after onboarding)
/flow                → FlowScreen
/library              → LibraryScreen
/rest                 → RestScreen
/settings             → SettingsScreen
```

---

## 3. Color System

### Brand Colors (from design.md)

| Token | Hex | Usage |
|-------|-----|-------|
| `deepSlate` | `#1A1A2E` | Primary — Headers, active states, primary actions |
| `navy` | `#16213E` | Primary Variant — Hover states, secondary emphasis |
| `amber` | `#F5B800` | Accent — CTAs, highlights, active chips, FAB |
| `teal` | `#0F969C` | Accent Secondary — Energy Deep, rest elements |
| `restZone` | `#0D4F4F` | Rest Zone — Rest hero background, wind-down mode |

### Surface Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `surface` | `#F8F9FA` | Off-White — Card backgrounds, screen backgrounds |
| `surfaceAlt` | `#EEF0F4` | Cool Gray — Anytime Pool background, input fields |

### Block State Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `blockPast` | `#D1D5DB` | Past M/A/E block background |
| `blockCurrent` | `#FFFFFF` | Active M/A/E block |
| `blockFuture` | `#F8F9FA` | Future M/A/E block |

### Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#1A1A2E` | Charcoal — Headings, body text |
| `textSecondary` | `#64748B` | Slate Gray — Subtitles, labels, metadata |
| `textMuted` | `#9CA3AF` | Light Gray — Past block text, placeholder |

### Energy Level Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `energyQuick` | `#FFD9A8` | Warm Amber — ⚡ Quick chip background |
| `energyDeep` | `#C4E8D4` | Soft Sage — 🧠 Deep chip background |
| `energyLow` | `#A8C5E2` | Soft Blue — 🪫 Low energy chip background |

### Time Zone Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `zoneMorning` | `#F5B800` | Amber |
| `zoneAfternoon` | `#F97316` | Orange |
| `zoneEvening` | `#6366F1` | Indigo |

### Grey Scale

| Token | Hex | Usage |
|-------|-----|-------|
| `grey50` | `#F9FAFB` | Input backgrounds |
| `grey100` | `#F3F4F6` | Chip defaults, card fills |
| `grey200` | `#E5E7EB` | Input borders |
| `grey300` | `#D1D5DB` | Drag handle, inactive dots |
| `grey400` | `#9CA3AF` | Placeholder, disabled |
| `grey500` | `#6B7280` | Subtitles, descriptions |
| `grey600` | `#4B5563` | Body text secondary |
| `grey800` | `#1F2937` | Body text primary |
| `white` | `#FFFFFF` | Backgrounds |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#22C55E` | Signal Green — Completion states |
| `error` | `#DC2626` | Crimson — Critical errors only |

---

## 4. Typography

### Font Families (from design.md)

| Font | Usage | Source |
|------|-------|--------|
| Montserrat | Headlines, titles, navigation | Google Fonts |
| Inter | Body text, descriptions, labels | Google Fonts |
| JetBrains Mono | Timers, counters, elapsed time | Google Fonts |

### Text Styles

| Style | Font | Size | Weight | Line Height |
|-------|------|------|--------|------------|
| Display | Montserrat | 48–64px | ExtraBold (800) | tight |
| H1 | Montserrat | 32–36px | ExtraBold (800) | tight |
| H2 | Montserrat | 24–28px | Bold (700) | snappy |
| H3 | Montserrat | 18–20px | SemiBold (600) | normal |
| Body Large | Inter | 16px | Regular (400) | relaxed |
| Body Medium | Inter | 14px | Regular (400) | relaxed |
| Caption / Label | Inter | 12px | Medium (500) | normal |
| Score / Timer | JetBrains Mono | 14–24px | Regular (400) | mono |
| Section Header | Montserrat | 14px | SemiBold (600) | normal |

### Accessibility
- Minimum body text: 14px
- Caption text: 12px, Medium weight
- All text passes WCAG AA contrast ratio

---

## 5. Spacing System (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4px | Icon padding, tight gaps |
| `space-sm` | 8px | Chip padding, inline element gaps |
| `space-md` | 16px | Card padding, standard gaps |
| `space-lg` | 24px | Section padding, screen margins |
| `space-xl` | 32px | Major section gaps |
| `space-2xl` | 48px | Screen top/bottom padding |

### Component-specific spacing
- Card padding: space-md (16px all sides)
- Card gap in grid: space-sm (8px)
- Section gap: space-lg (24px)
- Screen horizontal margin: space-lg (24px on mobile)
- FAB bottom offset: 72dp above bottom nav

---

## 6. Elevation & Shadows (from design.md)

| Level | Shadow | Usage |
|-------|--------|-------|
| Elevation 0 | No shadow | Flat cards, past blocks |
| Elevation 1 | 0 1px 2px rgba(0,0,0,0.05) | Subtle card distinction |
| Elevation 2 | 0 2px 4px rgba(0,0,0,0.1) | Default task cards |
| Elevation 3 | 0 4px 8px rgba(0,0,0,0.12) | FAB, bottom sheets, modals |
| Elevation 4 | 0 8px 16px rgba(0,0,0,0.15) | Full-screen sheets |

## 7. Component System (from design.md)

### Card System

| Type | Style |
|------|-------|
| Task Card (in block) | White bg, rounded-2xl (16dp corners), elevation 2 |
| Session Card (Library) | White bg, rounded-xl, elevation 1, left accent border on hover |
| Template Card | White bg, rounded-xl, elevation 1, star icon top-right |
| Rest Break Card | Off-white bg, rounded-2xl, teal left border, 32dp icons |
| Hero Card (Rest) | Full-width gradient, Rest Zone color, generous padding |

### Chip System

| Chip | Style |
|------|-------|
| Energy: Quick (⚡) | Warm Amber bg #FFD9A8, amber text, rounded-full, 12px Inter Medium |
| Energy: Deep (🧠) | Soft Sage bg #C4E8D4, teal text, rounded-full |
| Energy: Low (🪫) | Soft Blue bg #A8C5E2, slate text, rounded-full |
| "Focus mode" toggle | Outlined pill, brand-navy border, tap to fill amber |
| "You showed up today" | Signal Green bg, white text, no counter |
| Active tab | Amber underline, 2dp, animated slide |

## 8. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 4px | Small badges |
| `md` | 8px | Priority pills |
| `lg` | 10px | Input fields |
| `xl` | 12px | Buttons, cards |
| `xxl` | 20px | Bottom sheet corners |

---

## 9. Data Models

### Enums

```dart
enum EnergyLevel { quick, deep, low, none }
enum TimeZone { morning, afternoon, evening, anytime, none }
enum Priority { high, medium, low }
enum SessionType { open, pomodoro, deep }
enum BreathingPattern { box, fourSevenEight, physiologicalSigh }
```

### Task

```dart
class Task {
  String id;
  String title;
  EnergyLevel energy;
  TimeZone zone;
  Priority priority;
  List<String> tags;
  int? estimatedMinutes;
  bool completed;
  DateTime? completedAt;
  bool isFavorite;
  String? notes;
  DateTime createdAt;
}
```

### FlowSession

```dart
class FlowSession {
  String id;
  String? taskId;
  SessionType type;
  DateTime startedAt;
  int durationSeconds;
  DateTime? completedAt;
  String? reflection;
  EnergyLevel? energyLevel;
}
```

### DailyStats

```dart
class DailyStats {
  String date; // yyyy-MM-dd
  int tasksCompleted;
  int sessionsCompleted;
  int focusMinutes;
}
```

### AppSettings

```dart
class AppSettings {
  bool isDarkMode;
  bool soundEnabled;
  String? lastActiveDate;
  bool hasCompletedOnboarding;
}
```

---

## 10. Screen Specifications

### 10.1 Focus Screen (`/focus`) — The Heart of the App

**Purpose**: Visual flow of the day divided into Morning, Afternoon, Evening. Tasks placed by time zone. Anytime Pool for energy-based task selection.

**Philosophy**: "Time is a flow, not a grid. The system moves with you."

**Layout**:
- AppBar: Date "Wednesday, April 23" (Montserrat Bold 18px, left-aligned) + Settings icon
- DailySummary card at top
- TimeZoneSection × 3 (Morning, Afternoon, Evening)
- AnytimePool
- FAB (+) for adding tasks

**Header Bar Elements**:
| Element | Appearance | Behavior |
|---------|------------|----------|
| Date | "Wednesday, April 23" — Montserrat Bold 18px, left-aligned | Context anchor, not clickable |
| "You showed up today" chip | Signal Green pill, white text, no counter | Appears after ≥1 task completed |

**Time Zone Blocks (Morning/Afternoon/Evening)**:
| Element | Description |
|---------|-------------|
| Section header | "Morning" / "Afternoon" / "Evening" — Montserrat SemiBold 14px, uppercase |
| Time range label | "5 AM – 11:59 AM" — collapses on scroll |
| Task cards | Floating cards positioned within block |
| Now indicator | Animated pulse bar + dot when current time falls in this block |

**Block States**:
| State | Visual |
|-------|--------|
| Past | Muted Gray bg #D1D5DB, task text in Text Muted #9CA3AF, cards non-interactive |
| Current | White bg with amber left accent border (4dp), now indicator pulses |
| Future | Surface White bg #F8F9FA, full vividness, all interactions active |

**Task Cards**:
| Element | Where | Purpose |
|---------|-------|---------|
| Task name | Top, Inter 14px | Primary content, wraps to 2 lines max |
| Energy chip | Bottom left | Shows ⚡/🧠/🪫 chip if set |
| Time label | Bottom right | Shows placed time for zone tasks |
| Completed state | — | Green glow 200ms → card fades 400ms → removed |

**Anytime Pool**:
- Energy Filter Chips: ⚡ Quick / 🧠 Deep / 🪫 Low energy
- Multi-select logic: None active → All shown; ⚡+🧠 → Either; all → All
- No order — user scans → identifies state → picks

**Purpose**: Main task management with time zone organization

**Layout**:
- AppBar: "Focus" title + settings icon
- DailySummary card at top
- TimeZoneSection × 3 (Morning, Afternoon, Evening)
- AnytimePool
- FloatingActionButton: "Add Task"

**Widgets**:
| Widget | File | Description |
|--------|------|-------------|
| DailySummary | `focus/widgets/daily_summary.dart` | Progress card with celebration |
| TimeZoneSection | `focus/widgets/time_zone_section.dart` | Zone header + task list |
| TaskCard | `focus/widgets/task_card.dart` | Individual task item |
| AnytimePool | `focus/widgets/anytime_pool.dart` | Collapsible anytime tasks |
| AddTaskDialog | `focus/widgets/add_task_dialog.dart` | Bottom sheet for new tasks |

**Interactions**:
- Tap task → TaskDetailSheet
- Tap checkbox → Complete task with celebration
- Tap FAB → AddTaskDialog
- Pull to refresh → Reload tasks

### 10.2 Flow Screen (`/flow`)

**Purpose**: Focus timer with session tracking

**Layout**:
- AppBar: "Flow Session"
- SegmentedButton: Open / Pomodoro / Deep Work
- TimerDisplay (circular progress)
- Pomodoro round indicators (4 dots)
- Session description text
- Control buttons (Start/Pause/Resume/Stop)

**Widgets**:
| Widget | File | Description |
|--------|------|-------------|
| TimerDisplay | `flow/widgets/timer_display.dart` | Circular timer with progress |
| SessionCompleteSheet | `flow/widgets/session_complete_sheet.dart` | End-of-session summary |
| BodyDoublePill | `flow/widgets/body_double_pill.dart` | Optional body double feature |

**Pomodoro Constants**:
| Constant | Value |
|----------|-------|
| Work duration | 25 min |
| Short break | 5 min |
| Long break | 15 min |
| Rounds | 4 |

### 10.3 Rest Screen (`/rest`)

**Purpose**: Breaks, breathing exercises, recovery

**Layout**:
- AppBar: "Rest & Recovery"
- Contextual greeting
- Session summary card
- "Take a Break" section with horizontal MicroBreakCards
- "Calm Your Mind" section with Breathing/Wind Down cards

**Widgets**:
| Widget | File | Description |
|--------|------|-------------|
| MicroBreakCard | `rest/widgets/micro_break_card.dart` | Horizontal scrollable break options |
| BreathingTimer | `rest/widgets/breathing_timer.dart` | Animated breathing exercises |
| WindDownRoutine | `rest/widgets/wind_down_routine.dart` | Evening wind-down guidance |

### 10.4 Library Screen (`/library`)

**Purpose**: Sessions history, templates, resources

**Layout**:
- AppBar: "Library"
- TabBar (scrollable): Sessions / Templates / Favorites / Notes / Archive / Resources
- Search bar
- Tab content (ListView or GridView)

**Widgets**:
| Widget | File | Description |
|--------|------|-------------|
| SessionListItem | `library/widgets/session_list_item.dart` | Session history row |
| TemplateCard | `library/widgets/template_card.dart` | Template grid item |
| ResourceTile | `library/widgets/resource_tile.dart` | Saved link item |

### 10.5 Settings Screen (`/settings`)

**Route**: `/settings`

**Sections**:
- Data Management (Export, Import, Clear)
- Preferences (Dark Mode, Sound)
- Stats Summary
- About

---

## 11. Onboarding Flow

**Route**: `/onboarding` (first launch only)

### Screens (PageView)

| Index | Screen | Description |
|-------|--------|-------------|
| 0 | WelcomeScreen | Wave illustration + tagline |
| 1 | EnergyLevelsScreen | Quick/Deep/Low energy cards |
| 2 | TimeZonesScreen | Morning/Afternoon/Evening/Anytime |
| 3 | AddFirstTaskSheet | Bottom sheet to add first task |

### Navigation

- Button-based (no swipe)
- Skip option on each screen
- Completes → navigates to `/focus`

---

## 12. Theme Configuration

### Light Theme

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey.shade50,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.navy,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### NavigationBar

```dart
NavigationBar(
  height: 65,
  backgroundColor: Colors.white,
  indicatorColor: AppColors.teal.withOpacity(0.2),
  destinations: [
    NavigationDestination(
      icon: Icon(Icons.adjust_outlined),
      selectedIcon: Icon(Icons.adjust, color: AppColors.teal),
      label: 'Focus',
    ),
    // ... Flow, Library, Rest
  ],
)
```

---

## 13. State Management (Riverpod)

### Providers

```dart
// Repository providers
final taskRepositoryProvider = FutureProvider<TaskRepository>(...);
final sessionRepositoryProvider = FutureProvider<SessionRepository>(...);
final statsRepositoryProvider = FutureProvider<StatsRepository>(...);

// State providers
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>(...);
final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>(...);
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(...);
final todayStatsProvider = FutureProvider<DailyStats?>(...);
```

---

## 14. Persistence (Hive)

### Boxes

| Box Name | Type | Purpose |
|----------|------|---------|
| `tasks` | `String` (JSON) | Task storage |
| `sessions` | `String` (JSON) | Flow session history |
| `templates` | `String` (JSON) | Task templates |
| `resources` | `String` (JSON) | Saved links |
| `stats` | `String` (JSON) | Daily statistics |
| `settings` | `String` (JSON) | App settings |

### Initialization

```dart
await Hive.initFlutter();
await Hive.openBox<String>('tasks');
await Hive.openBox<String>('sessions');
// ... etc
```

---

## 15. Implementation Status

| Feature | Status |
|---------|--------|
| Onboarding (4 screens) | ✅ Complete |
| Focus Screen | ✅ Complete |
| Flow Screen | ✅ Complete |
| Rest Screen | ✅ Complete |
| Library Screen | ✅ Complete |
| Settings Screen | ✅ Complete |
| Navigation | ✅ Complete |
| Theme/Colors | ✅ Complete |
| Data Persistence | ✅ Complete |
| Gamification | 📋 Spec available |

---

## 16. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  go_router: ^14.0.0
  google_fonts: ^6.1.0
  intl: ^0.20.2
  share_plus: ^7.2.1
  file_picker: ^6.1.1
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

---

## 17. File Reference

### Core Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Hive init, ProviderScope |
| `lib/core/theme/app_colors.dart` | All color constants |
| `lib/core/theme/app_theme.dart` | Material 3 theme config |
| `lib/core/router/app_router.dart` | GoRouter with conditional routing |
| `lib/core/widgets/main_shell.dart` | Bottom navigation container |

### Feature Files

| Feature | Screen | Widgets |
|---------|--------|---------|
| Onboarding | `onboarding_flow.dart` | `welcome_screen.dart`, `energy_levels_screen.dart`, `time_zones_screen.dart`, `add_first_task_sheet.dart` |
| Focus | `focus_screen.dart` | `daily_summary.dart`, `time_zone_section.dart`, `task_card.dart`, `add_task_dialog.dart`, `anytime_pool.dart` |
| Flow | `flow_screen.dart` | `timer_display.dart`, `session_complete_sheet.dart` |
| Rest | `rest_screen.dart` | `breathing_timer.dart`, `micro_break_card.dart`, `wind_down_routine.dart` |
| Library | `library_screen.dart` | `session_list_item.dart`, `template_card.dart`, `resource_tile.dart` |
| Settings | `settings_screen.dart` | — |
