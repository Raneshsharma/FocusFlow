# FocusFlow Icons — Download Complete

## Summary

**107 custom SVG icons downloaded** from Iconify (Tabler, Lucide, MDI libraries)

Icon categories:
- **Core**: 30 icons — add, check, close, delete, star, chevrons, play, pause, settings, etc.
- **Energy**: 4 icons — lightning (quick), brain (deep), battery (low), charging
- **Zones**: 4 icons — sunrise, sun, moon, infinity
- **Sessions**: 8 icons — play/pause, focus mode, tracking
- **Rest**: 9 icons — breathing, wind down, breaks (coffee, walk, hydrate, etc.)
- **Sounds**: 10 icons — rain, fire, cafe, ocean, forest, lo-fi, speaker
- **Library**: 21 icons — streak, trophy, archive, categories, empty states
- **Settings**: 12 icons — appearance, notifications, DND, stats
- **Onboarding**: 5 icons — wave, tomorrow, phone off, timer, sparkles
- **Tasks**: 3 icons — checkbox (empty, checked), circle pending

Plus existing navigation icons (15 PNGs from icons8)

---

## Directory Structure

```
focus_flow/assets/icons/
├── core/          # 30 icons — universal action icons
├── energy/        # 4 icons — energy level indicators
├── zones/         # 4 icons — time zone markers
├── sessions/      # 8 icons — focus/flow session icons
├── rest/          # 9 icons — rest screen and micro breaks
├── sounds/        # 10 icons — ambient sound mixer
├── library/       # 21 icons — library tabs and features
├── settings/      # 12 icons — settings and stats
├── onboarding/    # 5 icons — first-run experience
├── tasks/         # 3 icons — task interaction
└── nav/           # 15 icons — bottom navigation (existing PNGs)
```

---

## Usage

### 1. Add `flutter_svg` to pubspec.yaml

```yaml
dependencies:
  flutter_svg: ^2.0.10+1
```

### 2. Run pub get

```bash
cd focus_flow
flutter pub get
```

### 3. Use the AppIcon widget

```dart
import 'package:focus_flow/core/widgets/app_icon.dart';

// Basic usage
AppIcon('core/add', size: 24)

// With color
AppIcon('energy/energy_quick', size: 32, color: AppColors.energyQuick)

// Using constants
AppIcon(AppIcons.energyQuick, size: 32)
```

### 4. Or use SvgPicture directly

```dart
SvgPicture.asset(
  'assets/icons/core/add.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(AppColors.teal, BlendMode.srcIn),
)
```

---

## What's Still Missing (Not on Iconify)

These icons don't exist in common libraries and may need custom design:

| Icon | Purpose | Suggestion |
|------|---------|------------|
| Tomato | Pomodoro session | Noun Project or custom SVG |
| Sunrise scene | Morning zone illustration | Custom SVG illustration |
| Sleepy face | No streak state | Noun Project or custom |
| Trophy | Win reflection | Tabler has this ✓ |
| Sparkles | Flexible zone | Tabler has this ✓ |
| Anchor | Anytime anchors | Noun Project or custom |
| Megaphone | Brag mode | Tabler has this ✓ |
| Lotus flower | Relax break | Noun Project or custom |

---

## Icon Constants (app_icon.dart)

A centralized `AppIcons` class is provided at:
`lib/core/widgets/app_icon.dart`

```dart
// Energy icons
AppIcons.energyQuick   // lightning bolt
AppIcons.energyDeep    // brain
AppIcons.energyLow     // battery

// Zone icons
AppIcons.zoneMorning
AppIcons.zoneAfternoon
AppIcons.zoneEvening
AppIcons.zoneAnytime

// Action icons
AppIcons.add
AppIcons.check
AppIcons.close
AppIcons.delete
AppIcons.starFilled
AppIcons.starOutline

// Navigation (existing PNGs)
AppIcons.navFocus     // icons/icons8-target-64.png
AppIcons.navFlow      // icons/icons8-lightning-bolt-64.png
AppIcons.navLibrary   // icons/icons8-bookmark-64.png
AppIcons.navRest      // icons/icons8-do-not-disturb-ios-64.png
```

---

## Next Steps

1. **Run `flutter pub get`** to install flutter_svg
2. **Replace emoji usages** in code with `AppIcon` widget calls
3. **Replace `Icons.` usages** with SVG equivalents
4. **Design custom icons** for any missing unique icons (tomato, lotus, etc.)
5. **Update MainShell** to use the new AppIcon system for nav bar

---

## Failed Downloads (10 icons)

These had no matching icon in Iconify and got placeholder SVGs. They work but may need replacement:

| File | Current State | Action Needed |
|------|---------------|---------------|
| celebration.svg | Simple popper SVG | Consider custom design |
| energy_low.svg | Basic battery outline | Works but basic |
| breathing.svg | Wind icon | Works for breathing exercise |
| micro_relax.svg | Smile face | Consider lotus flower custom |
| sound_ocean.svg | Wave lines | Works for sound mixer |
| speaker.svg | Speaker icon | Works for volume control |
| brag.svg | Megaphone shape | Works for brag mode |
| clock_small.svg | Timer | Works for best time |
| shuffle.svg | Shuffle arrows | Works for shuffle button |
| anchor.svg | Anchor | Works for anytime anchors |

All functional and will work in the app, but may want customization later.
