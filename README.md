# FocusFlow

<div align="center">

### ADHD-Friendly Focus & Productivity App

**FocusFlow** is a productivity app designed specifically for people with ADHD. It uses time-based motivation, gamification, and ADHD-friendly UI patterns to help users stay focused and accomplish their goals.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## Features

### 🎯 Focus Modes
- **Quick Win** - Short 5-15 minute sessions for quick tasks
- **Pomodoro** - Classic 25/5 minute work/break cycles with customizable rounds
- **Deep Work** - Extended 50/10 minute focus sessions
- **Custom Timer** - Set your own session duration

### 📊 Smart Task Management
- **Time-zone based planning** - Morning, Afternoon, Evening, Anytime
- **Energy-aware tasks** - Match tasks to your energy levels (Quick, Deep, Low Energy)
- **Priority system** - Visual priority indicators
- **Swipe to complete/delete** - Quick task actions
- **Archive system** - Soft delete with restore capability

### 🏆 Gamification
- **Achievements** - 20+ unlockable achievements across Bronze, Silver, Gold, and Platinum tiers
- **XP System** - Earn experience for completing sessions and tasks
- **Streak Tracking** - Build daily focus habits
- **Level progression** - Watch your focus skills level up

### 📚 Library
- **Sessions history** - Review past focus sessions
- **Templates** - Save and reuse task combinations
- **Notes** - Quick capture with categories
- **Archive** - Recover deleted items
- **Resources** - Curated ADHD-friendly tools

### 🧠 ADHD-Specific Features
- **Visual time blocks** - Clear morning/afternoon/evening organization
- **Energy tracking** - Match tasks to your current energy
- **Celebration feedback** - Positive reinforcement for completions
- **Gentle reminders** - Non-intrusive notifications
- **Wind-down routines** - Prepare for better rest (v2.0)

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Raneshsharma/FocusFlow.git
cd FocusFlow
```

2. **Install dependencies**
```bash
cd focus_flow
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build APK

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

---

## Architecture

FocusFlow is built with modern Flutter architecture:

### State Management
- **Riverpod** - Provider-based state management
- **AsyncNotifier** - For async data operations
- **StateNotifier** - For complex state logic

### Data Persistence
- **Hive** - Fast, lightweight NoSQL database
- **Box-based storage** - Each data type has its own box

### Navigation
- **GoRouter** - Declarative routing with shell routes

### Key Modules

```
lib/
├── core/
│   ├── constants/     # App constants, achievements definitions
│   ├── router/        # GoRouter configuration
│   ├── theme/         # App theme and colors
│   └── utils/        # Utility functions
├── data/
│   ├── models/        # Data models (Task, Session, Note, etc.)
│   └── repositories/  # Data access layer
├── features/
│   ├── achievements/  # Achievement system
│   ├── flow/          # Focus timer and sessions
│   ├── focus/         # Task management
│   ├── library/       # Library and insights
│   ├── onboarding/    # First-time user experience
│   ├── rest/          # Rest & recovery (v2.0)
│   └── settings/      # App settings
├── providers/         # Riverpod providers
└── services/          # App services (notifications, etc.)
```

---

## Achievement System

FocusFlow includes a comprehensive achievement system:

| Tier | Count | Examples |
|:---|:---:|:---|
| 🥉 Bronze | 6 | First Focus, Quick Win, Note Taker |
| 🥈 Silver | 6 | Task Crusher, Week Warrior, Deep Worker |
| 🥇 Gold | 4 | Flow Regular, 1000 Minutes |
| 💎 Platinum | 4 | Super Focus, Task Legend, Collection King |

Achievements are automatically tracked based on:
- Sessions completed
- Tasks completed
- Focus streak
- Total minutes focused
- Energy ratings used
- Notes created
- Templates saved

---

## Technology Stack

| Category | Technology |
|:---|:---|
| Framework | Flutter 3.0+ |
| Language | Dart 3.0+ |
| State Management | Riverpod |
| Navigation | GoRouter |
| Local Storage | Hive |
| Charts | fl_chart |
| Animations | flutter_animate |
| Notifications | flutter_local_notifications |

---

## Privacy

FocusFlow respects your privacy. All data is stored locally on your device. We do not collect, transmit, or share any personal information. See our [Privacy Policy](Privacy%20Policy) for details.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Built with ❤️ for the ADHD community
- Inspired by various productivity techniques (Pomodoro, Deep Work, etc.)
- Designed with ADHD-friendly UI principles

---

<div align="center">

**Made with Flutter**

</div>
