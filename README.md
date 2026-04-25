# FocusFlow

A Flutter-based productivity application designed specifically for individuals with ADHD. FocusFlow helps users manage their time, energy, and tasks through a gamified and structured interface.

## Features

- **Flow Sessions**: Pomodoro-style focus sessions with integrated rest periods.
- **Energy Tracking**: Monitor and manage your energy levels throughout the day.
- **Task Management**: Simple and effective task tracking tailored for ADHD focus.
- **Library**: Store and organize resources, notes, and session templates.
- **Onboarding**: Personalized setup to tailor the experience to your needs.
- **Ambient Sounds**: Integrated sound mixer for better focus.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Database**: [Hive](https://docs.hivedb.dev/) (Local NoSQL database)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Raneshsharma/FocusFlow.git
   ```

2. Navigate to the project directory:
   ```bash
   cd focus_flow
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/core`: Constants, themes, routers, and global widgets.
- `lib/data`: Models and repositories for data persistence.
- `lib/features`: Feature-based modules (Flow, Focus, Library, Onboarding, Rest, Settings).
- `lib/providers`: Riverpod providers for state management.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
