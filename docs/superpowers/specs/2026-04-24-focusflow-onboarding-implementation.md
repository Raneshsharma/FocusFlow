# FocusFlow Onboarding — Implementation Document

**Date**: 2026-04-24
**Project**: FocusFlow Flutter App
**Purpose**: Complete onboarding implementation guide for developers
**Scope**: 4 screens — Welcome, Energy Levels, Time Zones, Add First Task

---

## 1. Architecture Overview

### Navigation Flow

```
App Start
    ↓
Check hasCompletedOnboarding in AppSettings
    ↓
┌─────────────────────────────────┐
│         OnboardingFlow          │
│         (PageView)              │
│                                 │
│  Page 0: WelcomeScreen          │
│  Page 1: EnergyLevelsScreen     │
│  Page 2: TimeZonesScreen        │
│                                 │
│  Page 3 → Bottom Sheet:         │
│  AddFirstTaskSheet              │
└─────────────────────────────────┘
    ↓ (on complete/skip)
  TodayScreen (main app)
```

### Data Flow

```
OnboardingFlow
├── OnboardingNotifier (StateNotifier)
│   ├── currentPage: int
│   ├── hasCompletedOnboarding: bool
│   └── onComplete(): Future<void>
│
├── PageView (swipe between pages 0-2)
│   ├── WelcomeScreen (page 0)
│   ├── EnergyLevelsScreen (page 1)
│   └── TimeZonesScreen (page 2)
│
└── AddFirstTaskSheet (bottom sheet, page 3)
    ├── TaskFormState
    ├── TaskNotifier → TaskRepository → Isar
    └── AppSettings update on complete
```

### File Structure

```
lib/
├── features/
│   └── onboarding/
│       ├── screens/
│       │   ├── onboarding_flow.dart      ← PageView container
│       │   ├── welcome_screen.dart      ← Page 0
│       │   ├── energy_levels_screen.dart ← Page 1
│       │   └── time_zones_screen.dart    ← Page 2
│       ├── widgets/
│       │   ├── add_first_task_sheet.dart ← Bottom sheet (page 3)
│       │   ├── energy_card.dart          ← Shared energy card widget
│       │   └── zone_row.dart             ← Shared zone row widget
│       └── providers/
│           └── onboarding_provider.dart  ← StateNotifier
```

---

## 2. Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `navy` | `#0B1E3D` | Primary dark, headings, app bar |
| `teal` | `#0F969C` | Brand primary, buttons, accents |
| `amber` | `#F5A623` | Secondary brand, favorites |
| `charcoal` | `#1E293B` | Dark mode surface |
| `energyQuick` | `#10B981` | Quick energy indicator |
| `energyDeep` | `#8B5CF6` | Deep energy indicator |
| `energyLow` | `#6366F1` | Low energy indicator |
| `zoneMorning` | `#F59E0B` | Morning zone dot/border |
| `zoneAfternoon` | `#F97316` | Afternoon zone dot/border |
| `zoneEvening` | `#6366F1` | Evening zone dot/border |
| `zoneAnytime` | `#0F969C` | Anytime zone teal |
| `success` | `#10B981` | Completion, checkmarks |
| `error` | `#EF4444` | Error states |
| `grey50` | `#F9FAFB` | Input backgrounds |
| `grey100` | `#F3F4F6` | Chip defaults, card fills |
| `grey200` | `#E5E7EB` | Input borders default |
| `grey300` | `#D1D5DB` | Drag handle, inactive dots |
| `grey400` | `#9CA3AF` | Placeholder, disabled text |
| `grey500` | `#6B7280` | Subtitles, descriptions |
| `grey600` | `#4B5563` | Body text secondary |
| `grey800` | `#1F2937` | Body text primary |
| `white` | `#FFFFFF` | Backgrounds |

### Color Implementation (app_colors.dart)

```dart
class AppColors {
  // Brand
  static const navy = Color(0xFF0B1E3D);
  static const teal = Color(0xFF0F969C);
  static const amber = Color(0xFFF5A623);
  static const charcoal = Color(0xFF1E293B);

  // Energy levels
  static const energyQuick = Color(0xFF10B981);
  static const energyDeep = Color(0xFF8B5CF6);
  static const energyLow = Color(0xFF6366F1);

  // Zones
  static const zoneMorning = Color(0xFFF59E0B);
  static const zoneAfternoon = Color(0xFFF97316);
  static const zoneEvening = Color(0xFF6366F1);

  // Semantic
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Greys
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey800 = Color(0xFF1F2937);
}
```

### Typography

| Style | Font | Size | Weight | Line Height | Color |
|-------|------|------|--------|------------|-------|
| Welcome headline | Montserrat | 28px | 700 (Bold) | 1.2 | Navy |
| Welcome subtext | Inter | 16px | 400 (Regular) | 1.5 | Grey-500 |
| Section title | Montserrat | 22px | 600 (SemiBold) | 1.3 | Navy |
| Section subtitle | Inter | 15px | 400 (Regular) | 1.4 | Grey-500 |
| Card label | Montserrat | 15px | 600 (SemiBold) | 1.3 | Energy color |
| Card description | Inter | 14px | 500 (Medium) | 1.4 | Grey-800 |
| Card example | Inter | 13px | 400 (Regular) | 1.4 | Grey-500, italic |
| Zone name | Inter | 15px | 600 (SemiBold) | 1.3 | Navy |
| Zone time range | Inter | 12px | 400 (Regular) | 1.3 | Grey-400 |
| Zone description | Inter | 13px | 400 (Regular) | 1.4 | Grey-600 |
| Form label | Inter | 13px | 500 (Medium) | 1.3 | Grey-600 |
| Form placeholder | Inter | 16px | 400 (Regular) | 1.4 | Grey-400 |
| Form input | Inter | 16px | 400 (Regular) | 1.4 | Navy |
| Button text | Inter | 16px | 600 (SemiBold) | 1.0 | White |
| Skip link | Inter | 14px | 400 (Regular) | 1.0 | Grey-500 |
| Chip default | Inter | 13px | 500 (Medium) | 1.0 | Grey-600 |
| Chip selected | Inter | 13px | 600 (SemiBold) | 1.0 | Navy |
| NOW badge | Inter | 11px | 600 (SemiBold) | 1.0 | Green-700 |

### Font Setup (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_lints: ^3.0.1
```

### Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXs` | 4px | Tight gaps |
| `spacingSm` | 8px | Between related elements |
| `spacingMd` | 12px | Between elements |
| `spacingLg` | 16px | Card padding, section gaps |
| `spacingXl` | 24px | Screen horizontal padding |
| `spacingXxl` | 32px | Large vertical padding |
| `spacingHero` | 40px | Top illustration spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSm` | 4px | Small badges |
| `radiusMd` | 8px | Priority pills, small cards |
| `radiusLg` | 10px | Input fields, zone rows |
| `radiusXl` | 12px | Buttons, energy cards |
| `radiusXxl` | 20px | Bottom sheet top corners |

---

## 3. State Management

### Onboarding Provider

```dart
// lib/features/onboarding/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../data/models/app_settings.dart';
import '../../../providers/task_provider.dart';

class OnboardingState {
  final int currentPage;
  final bool hasCompletedOnboarding;

  const OnboardingState({
    this.currentPage = 0,
    this.hasCompletedOnboarding = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Isar _isar;

  OnboardingNotifier(this._isar) : super(const OnboardingState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final settings = await _isar.appSettings.where().findFirst();
    if (settings != null) {
      state = state.copyWith(
        hasCompletedOnboarding: settings.hasCompletedOnboarding,
      );
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage() {
    if (state.currentPage < 3) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  Future<void> completeOnboarding() async {
    await _isar.writeTxn(() async {
      var settings = await _isar.appSettings.where().findFirst();
      if (settings == null) {
        settings = AppSettings()..hasCompletedOnboarding = false;
      }
      settings.hasCompletedOnboarding = true;
      await _isar.appSettings.put(settings);
    });
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final isar = ref.watch(isarProvider);
  return OnboardingNotifier(isar);
});
```

### AppSettings Model Update

```dart
// lib/data/models/app_settings.dart

@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;

  bool isDarkMode = false;
  bool soundEnabled = true;
  String? lastActiveDate;
  bool hasCompletedOnboarding = false;  // ← Add this field
  String? lastActiveDate;
}
```

---

## 4. Screen 1: Welcome

**File**: `lib/features/onboarding/screens/welcome_screen.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Background | White (`#FFFFFF`) |
| Wave illustration | SVG gradient (teal → navy), 200×140px, 60px top margin |
| Page dots | Hidden (removed per design) |
| Headline | "Work with your brain," / "not against it" — 28px, Montserrat Bold, navy |
| Subtext | 16px, Inter Regular, grey-500, max-width 300px, centered |
| Continue button | 56px height, full width (max 320px), teal fill, 12px radius |
| Skip link | Bottom of screen, 14px, grey-400 |

### Code

```dart
// lib/features/onboarding/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Wave illustration
              _WaveIllustration(),

              const Spacer(flex: 1),

              // Headline
              Text(
                'Work with your brain,\nnot against it',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 12),

              // Subtext
              Text(
                'FocusFlow helps you match tasks to your energy — not the other way around.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppColors.grey500,
                ),
              ),

              const Spacer(flex: 2),

              // Continue button
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 16),

              // Skip link
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.grey400,
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: const Text('Skip for now'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 140,
      child: CustomPaint(
        painter: _WavePainter(),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌊', style: TextStyle(fontSize: 28)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.teal, AppColors.navy],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.28, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.72, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint..opacity = 0.2);

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.38, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.82, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint..opacity = 0.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 5. Screen 2: Energy Levels

**File**: `lib/features/onboarding/screens/energy_levels_screen.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Section title | 22px, Montserrat SemiBold, navy |
| Section subtitle | 15px, Inter Regular, grey-500 |
| Energy cards | 3 cards stacked vertically, 12px border radius, left border 4px |
| Quick card | Left border: green `#10B981`, icon bg: green @ 10% |
| Deep card | Left border: purple `#8B5CF6`, icon bg: purple @ 10% |
| Low card | Left border: indigo `#6366F1`, icon bg: indigo @ 10% |
| Card icon | 48×48px, 12px border radius, emoji centered (22px) |
| Card label | 15px, Montserrat SemiBold, energy color |
| Card description | 14px, Inter Medium, grey-800 |
| Card example | 13px, Inter Regular, grey-500, italic |
| Got it button | Same style as Continue button |

### Code

```dart
// lib/features/onboarding/screens/energy_levels_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';

class EnergyLevelsScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const EnergyLevelsScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Section title
              Text(
                'Not all tasks need the same brain',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 6),

              // Section subtitle
              Text(
                'Learn to match tasks to your energy type.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: AppColors.grey500,
                ),
              ),

              const SizedBox(height: 20),

              // Energy cards
              Expanded(
                child: ListView(
                  children: [
                    _EnergyCard(
                      energy: EnergyLevel.quick,
                      icon: '⚡',
                      label: 'Quick Energy',
                      description: 'Short bursts, fast wins',
                      example: 'Like clearing emails or a 5-min call',
                      borderColor: AppColors.energyQuick,
                    ),
                    const SizedBox(height: 12),
                    _EnergyCard(
                      energy: EnergyLevel.deep,
                      icon: '🧠',
                      label: 'Deep Energy',
                      description: 'Complex thinking, full focus',
                      example: 'Like coding, writing, or planning',
                      borderColor: AppColors.energyDeep,
                    ),
                    const SizedBox(height: 12),
                    _EnergyCard(
                      energy: EnergyLevel.low,
                      icon: '🔋',
                      label: 'Low Energy',
                      description: 'Gentle tasks, minimal brain effort',
                      example: 'Like organizing files or reviewing',
                      borderColor: AppColors.energyLow,
                    ),
                  ],
                ),
              ),

              // Got it button
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  final EnergyLevel energy;
  final String icon;
  final String label;
  final String description;
  final String example;
  final Color borderColor;

  const _EnergyCard({
    required this.energy,
    required this.icon,
    required this.label,
    required this.description,
    required this.example,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: borderColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Screen 3: Time Zones

**File**: `lib/features/onboarding/screens/time_zones_screen.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Section title | 22px, Montserrat SemiBold, navy |
| Section subtitle | 15px, Inter Regular, grey-500 |
| Zone rows | 4 rows: Morning, Afternoon, Evening, Anytime |
| Zone row bg | Grey-50 tint with zone color @ 8% opacity |
| Zone dot | 14px circle, zone color |
| Zone name | 15px, Inter SemiBold, navy |
| Time range | 12px, Inter Regular, grey-400 |
| Description | 13px, Inter Regular, grey-600 |
| "NOW" badge | Green-100 bg, green-700 text, 11px, SemiBold, 4px radius |
| Anytime card | Teal-50 bg, teal border 1.5px, teal text, "Flexible" tag |
| Continue button | Same style as other screens |

### "NOW" Badge Logic

```dart
String getCurrentZone() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'morning';
  if (hour >= 12 && hour < 18) return 'afternoon';
  return 'evening';
}

// Morning: 5 AM - 12 PM (hour 5-11)
// Afternoon: 12 PM - 6 PM (hour 12-17)
// Evening: 6 PM - 12 AM (hour 18-23)
// Anytime: always available, never gets "NOW"
```

### Code

```dart
// lib/features/onboarding/screens/time_zones_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';

class TimeZonesScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const TimeZonesScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final currentZone = _getCurrentZone();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Section title
              Text(
                'Your energy changes throughout the day',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 6),

              // Section subtitle
              Text(
                'Schedule tasks for when your brain is ready.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: AppColors.grey500,
                ),
              ),

              const SizedBox(height: 20),

              // Zone rows
              Expanded(
                child: ListView(
                  children: [
                    _ZoneRow(
                      zone: TimeZone.morning,
                      label: 'Morning',
                      timeRange: '5 AM – 12 PM',
                      description: 'Usually your sharpest time. Tackle important tasks here.',
                      color: AppColors.zoneMorning,
                      isCurrentZone: currentZone == 'morning',
                    ),
                    const SizedBox(height: 10),
                    _ZoneRow(
                      zone: TimeZone.afternoon,
                      label: 'Afternoon',
                      timeRange: '12 PM – 6 PM',
                      description: 'After-lunch dip is real. Save lighter work for here.',
                      color: AppColors.zoneAfternoon,
                      isCurrentZone: currentZone == 'afternoon',
                    ),
                    const SizedBox(height: 10),
                    _ZoneRow(
                      zone: TimeZone.evening,
                      label: 'Evening',
                      timeRange: '6 PM – 12 AM',
                      description: 'Wind down. Easy tasks only — or save for tomorrow.',
                      color: AppColors.zoneEvening,
                      isCurrentZone: currentZone == 'evening',
                    ),
                    const SizedBox(height: 10),
                    _AnytimeZoneRow(),
                  ],
                ),
              ),

              // Continue button
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentZone() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'evening';
  }
}

class _ZoneRow extends StatelessWidget {
  final TimeZone zone;
  final String label;
  final String timeRange;
  final String description;
  final Color color;
  final bool isCurrentZone;

  const _ZoneRow({
    required this.zone,
    required this.label,
    required this.timeRange,
    required this.description,
    required this.color,
    required this.isCurrentZone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      if (isCurrentZone) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    timeRange,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnytimeZoneRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anytime',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No pressure. Works whenever you have a moment.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '✨ Flexible',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Screen 4: Add First Task — Bottom Sheet

**File**: `lib/features/onboarding/widgets/add_first_task_sheet.dart`

### Visual Specs

| Element | Details |
|---------|---------|
| Sheet border radius | Top: 20px |
| Drag handle | 40×4px, grey-300, centered, 20px bottom margin |
| Sheet title | 20px, Montserrat SemiBold, navy |
| Sheet subtitle | 14px, Inter Regular, grey-500 |
| Title input | Grey-50 bg, grey-200 border, 10px radius, 14px padding |
| Zone chips | 4 chips in Wrap (Morning/Afternoon/Evening/Anytime) |
| Chip default | Grey-100 bg, grey-600 text, 20px radius |
| Chip selected | Zone color bg @ 15%, zone text color, teal border 1.5px |
| Anytime chip | Selected by default |
| Energy buttons | 48×48px, energy color bg @ 15%, emoji centered |
| Priority pills | 3 pills (Low/Medium/High), mutually exclusive |
| Add Task button | Teal, 52px height, full width, 12px radius, disabled until title filled |
| Skip link | Grey-500, 14px, centered, 12px top margin |
| Today header bg | White with gradient fade at bottom |

### Form Logic

```dart
class AddFirstTaskSheet extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const AddFirstTaskSheet({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });
}

class _AddFirstTaskSheetState extends State<AddFirstTaskSheet> {
  final _titleController = TextEditingController();
  TimeZone _selectedZone = TimeZone.anytime;  // Default: Anytime
  EnergyLevel? _selectedEnergy;
  Priority _selectedPriority = Priority.medium;  // Default: Medium

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  // On submit:
  // 1. Create Task with all form values
  // 2. Save via TaskRepository
  // 3. Set hasCompletedOnboarding = true in AppSettings
  // 4. Dismiss sheet
  // 5. Show success SnackBar
  // 6. Navigate to Today
}
```

### Code

```dart
// lib/features/onboarding/widgets/add_first_task_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/task.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/onboarding_provider.dart';

class AddFirstTaskSheet extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const AddFirstTaskSheet({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  ConsumerState<AddFirstTaskSheet> createState() => _AddFirstTaskSheetState();
}

class _AddFirstTaskSheetState extends ConsumerState<AddFirstTaskSheet> {
  final _titleController = TextEditingController();
  TimeZone _selectedZone = TimeZone.anytime;
  EnergyLevel? _selectedEnergy;
  Priority _selectedPriority = Priority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final task = Task()
      ..title = _titleController.text.trim()
      ..zone = _selectedZone
      ..energy = _selectedEnergy ?? EnergyLevel.none
      ..priority = _selectedPriority
      ..completed = false
      ..isFavorite = false
      ..createdAt = DateTime.now();

    await ref.read(taskNotifierProvider.notifier).addTask(task);
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Task added! You\'re ready to flow.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Let\'s add your first task',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pick something small to start.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title input
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.navy,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What do you want to do?',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.grey400,
                      ),
                      filled: true,
                      fillColor: AppColors.grey50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.teal),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Time Zone selector
                  _SectionLabel(text: 'When?'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ZoneChip(
                        label: 'Morning',
                        zone: TimeZone.morning,
                        selected: _selectedZone,
                        onSelected: (z) => setState(() => _selectedZone = z),
                      ),
                      _ZoneChip(
                        label: 'Afternoon',
                        zone: TimeZone.afternoon,
                        selected: _selectedZone,
                        onSelected: (z) => setState(() => _selectedZone = z),
                      ),
                      _ZoneChip(
                        label: 'Evening',
                        zone: TimeZone.evening,
                        selected: _selectedZone,
                        onSelected: (z) => setState(() => _selectedZone = z),
                      ),
                      _ZoneChip(
                        label: 'Anytime',
                        zone: TimeZone.anytime,
                        selected: _selectedZone,
                        onSelected: (z) => setState(() => _selectedZone = z),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Energy selector
                  _SectionLabel(text: 'Energy needed?'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _EnergyButton(
                        icon: '⚡',
                        energy: EnergyLevel.quick,
                        selected: _selectedEnergy,
                        onSelected: (e) => setState(() => _selectedEnergy = e),
                      ),
                      const SizedBox(width: 12),
                      _EnergyButton(
                        icon: '🧠',
                        energy: EnergyLevel.deep,
                        selected: _selectedEnergy,
                        onSelected: (e) => setState(() => _selectedEnergy = e),
                      ),
                      const SizedBox(width: 12),
                      _EnergyButton(
                        icon: '🔋',
                        energy: EnergyLevel.low,
                        selected: _selectedEnergy,
                        onSelected: (e) => setState(() => _selectedEnergy = e),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Priority selector
                  _SectionLabel(text: 'Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _PriorityPill(
                        label: 'Low',
                        priority: Priority.low,
                        selected: _selectedPriority,
                        onSelected: (p) => setState(() => _selectedPriority = p),
                      ),
                      const SizedBox(width: 8),
                      _PriorityPill(
                        label: 'Medium',
                        priority: Priority.medium,
                        selected: _selectedPriority,
                        onSelected: (p) => setState(() => _selectedPriority = p),
                      ),
                      const SizedBox(width: 8),
                      _PriorityPill(
                        label: 'High',
                        priority: Priority.high,
                        selected: _selectedPriority,
                        onSelected: (p) => setState(() => _selectedPriority = p),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? AppColors.teal : AppColors.grey200,
                        foregroundColor: _canSubmit ? Colors.white : AppColors.grey400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _canSubmit
                          ? const Text('Add Task')
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.grey400,
                              ),
                            ),
                    ),
                  ),

                  // Skip link
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await ref.read(onboardingProvider.notifier).completeOnboarding();
                        if (mounted) {
                          Navigator.of(context).pop();
                          widget.onSkip();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.grey500,
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      child: const Text("I'll do this later"),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.grey600,
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String label;
  final TimeZone zone;
  final TimeZone selected;
  final ValueChanged<TimeZone> onSelected;

  const _ZoneChip({
    required this.label,
    required this.zone,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = zone == selected;
    final colors = _zoneColors(zone);

    return GestureDetector(
      onTap: () => onSelected(zone),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.bgColor : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: colors.borderColor, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? colors.textColor : AppColors.grey600,
          ),
        ),
      ),
    );
  }

  _ZoneChipColors _zoneColors(TimeZone zone) {
    switch (zone) {
      case TimeZone.morning:
        return _ZoneChipColors(
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
          borderColor: const Color(0xFFF59E0B),
        );
      case TimeZone.afternoon:
        return _ZoneChipColors(
          bgColor: const Color(0xFFFFEDD5),
          textColor: const Color(0xFFC2410C),
          borderColor: const Color(0xFFF97316),
        );
      case TimeZone.evening:
        return _ZoneChipColors(
          bgColor: const Color(0xFFE0E7FF),
          textColor: const Color(0xFF3730A3),
          borderColor: const Color(0xFF6366F1),
        );
      case TimeZone.anytime:
        return _ZoneChipColors(
          bgColor: const Color(0xFFCCFBF1),
          textColor: const Color(0xFF0F766E),
          borderColor: AppColors.teal,
        );
      case TimeZone.none:
        return _ZoneChipColors(
          bgColor: AppColors.grey100,
          textColor: AppColors.grey600,
          borderColor: Colors.transparent,
        );
    }
  }
}

class _ZoneChipColors {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  _ZoneChipColors({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });
}

class _EnergyButton extends StatelessWidget {
  final String icon;
  final EnergyLevel energy;
  final EnergyLevel? selected;
  final ValueChanged<EnergyLevel?> onSelected;

  const _EnergyButton({
    required this.icon,
    required this.energy,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = energy == selected;
    final color = _energyColor(energy);

    return GestureDetector(
      onTap: () => onSelected(isSelected ? null : energy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  Color _energyColor(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.quick:
        return AppColors.energyQuick;
      case EnergyLevel.deep:
        return AppColors.energyDeep;
      case EnergyLevel.low:
        return AppColors.energyLow;
      case EnergyLevel.none:
        return AppColors.grey400;
    }
  }
}

class _PriorityPill extends StatelessWidget {
  final String label;
  final Priority priority;
  final Priority selected;
  final ValueChanged<Priority> onSelected;

  const _PriorityPill({
    required this.label,
    required this.priority,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = priority == selected;
    final colors = _priorityColors(priority, isSelected);

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colors.bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: colors.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _PriorityColors _priorityColors(Priority priority, bool isSelected) {
    if (!isSelected) {
      return _PriorityColors(
        bgColor: AppColors.grey100,
        textColor: AppColors.grey600,
      );
    }
    switch (priority) {
      case Priority.low:
        return _PriorityColors(
          bgColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF1D4ED8),
        );
      case Priority.medium:
        return _PriorityColors(
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFB45309),
        );
      case Priority.high:
        return _PriorityColors(
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFB91C1C),
        );
    }
  }
}

class _PriorityColors {
  final Color bgColor;
  final Color textColor;
  _PriorityColors({required this.bgColor, required this.textColor});
}
```

---

## 8. Screen 0-2 Container: OnboardingFlow PageView

**File**: `lib/features/onboarding/screens/onboarding_flow.dart`

```dart
// lib/features/onboarding/screens/onboarding_flow.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'welcome_screen.dart';
import 'energy_levels_screen.dart';
import 'time_zones_screen.dart';
import '../widgets/add_first_task_sheet.dart';
import '../providers/onboarding_provider.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddFirstTaskSheet(
          onComplete: () => _navigateToToday(),
          onSkip: () => _navigateToToday(),
        ),
      ),
    );
  }

  void _navigateToToday() {
    context.go('/today');
  }

  Future<void> _skipOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      _navigateToToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),  // Disable swipe, use buttons only
        children: [
          WelcomeScreen(
            onContinue: () => _goToPage(1),
            onSkip: _skipOnboarding,
          ),
          EnergyLevelsScreen(
            onContinue: () => _goToPage(2),
          ),
          TimeZonesScreen(
            onContinue: _showAddTaskSheet,
          ),
        ],
      ),
    );
  }
}
```

---

## 9. Router Integration

**File**: `lib/core/router/app_router.dart`

```dart
// Add this route to your existing GoRouter configuration

import '../../features/onboarding/screens/onboarding_flow.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In your router:
final _hasCompletedOnboarding = ref.read(onboardingProvider).hasCompletedOnboarding;

GoRouter(
  initialLocation: _hasCompletedOnboarding ? '/today' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingFlow(),
    ),
    // ... other routes
  ],
);
```

**Or in main.dart — conditional redirect:**

```dart
// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [TaskSchema, FlowSessionSchema, TemplateSchema, ResourceSchema, DailyStatsSchema, AppSettingsSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      child: _AppWithOnboardingCheck(),
    ),
  );
}

class _AppWithOnboardingCheck extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final hasOnboarded = onboardingState.hasCompletedOnboarding;

    return MaterialApp.router(
      title: 'FocusFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Redirect to onboarding if not completed
        if (!hasOnboarded && AppRouter.router.uri.path == '/today') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRouter.router.go('/onboarding');
          });
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
```

---

## 10. Complete Color Reference Table

| Token | Hex | Light Mode Usage |
|-------|-----|-----------------|
| `navy` | `#0B1E3D` | Headings, app bar, primary text |
| `teal` | `#0F969C` | Primary buttons, accents, brand |
| `amber` | `#F5A623` | Secondary brand, favorites |
| `charcoal` | `#1E293B` | Dark mode surface |
| `energyQuick` | `#10B981` | Quick energy indicator |
| `energyDeep` | `#8B5CF6` | Deep energy indicator |
| `energyLow` | `#6366F1` | Low energy indicator |
| `zoneMorning` | `#F59E0B` | Morning zone dot/border |
| `zoneAfternoon` | `#F97316` | Afternoon zone dot/border |
| `zoneEvening` | `#6366F1` | Evening zone dot/border |
| `zoneAnytime` | `#0F969C` | Anytime zone |
| `success` | `#10B981` | Completion, checkmarks |
| `error` | `#EF4444` | Error states |
| `warning` | `#F59E0B` | Warning states |
| `grey50` | `#F9FAFB` | Input backgrounds, zone rows |
| `grey100` | `#F3F4F6` | Chip defaults, card fills |
| `grey200` | `#E5E7EB` | Input borders default |
| `grey300` | `#D1D5DB` | Drag handle, inactive dots |
| `grey400` | `#9CA3AF` | Placeholder, disabled text |
| `grey500` | `#6B7280` | Subtitles, descriptions |
| `grey600` | `#4B5563` | Body text secondary |
| `grey800` | `#1F2937` | Body text primary |
| `white` | `#FFFFFF` | Backgrounds |
| `green100` | `#D1FAE5` | NOW badge background |
| `green700` | `#047857` | NOW badge text |
| `teal50` | `#F0FDFA` | Anytime card background |
| `tealBorder` | `#99F6E4` | Anytime card border |
| `teal100` | `#CCFBF1` | Anytime chip selected |
| `teal700` | `#0F766E` | Anytime chip text |

---

## 11. Dependencies Required

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  go_router: ^14.0.0
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.0
  flutter_lints: ^3.0.1
```

---

## 12. Implementation Checklist

| Item | File | Status |
|------|------|--------|
| Colors | `lib/core/theme/app_colors.dart` | Add `grey50` token if missing |
| AppSettings update | `lib/data/models/app_settings.dart` | Add `hasCompletedOnboarding` field |
| Onboarding provider | `lib/features/onboarding/providers/onboarding_provider.dart` | Create |
| Welcome screen | `lib/features/onboarding/screens/welcome_screen.dart` | Create |
| Energy levels screen | `lib/features/onboarding/screens/energy_levels_screen.dart` | Create |
| Time zones screen | `lib/features/onboarding/screens/time_zones_screen.dart` | Create |
| Add first task sheet | `lib/features/onboarding/widgets/add_first_task_sheet.dart` | Create |
| Onboarding flow | `lib/features/onboarding/screens/onboarding_flow.dart` | Create |
| Router update | `lib/core/router/app_router.dart` | Add `/onboarding` route |
| Run build_runner | Terminal | `flutter pub run build_runner build --delete-conflicting-outputs` |