// Energy levels for tasks
enum EnergyLevel { quick, deep, low, none }

// Time zones for task scheduling
enum TimeZone { morning, afternoon, evening, anytime, none }

// Priority levels
enum Priority { high, medium, low }

// Session types for flow sessions
enum SessionType { open, pomodoro, deep, custom }

extension SessionTypeExtension on SessionType {
  String get displayName {
    switch (this) {
      case SessionType.open:
        return 'Quick Win';
      case SessionType.pomodoro:
        return 'Pomodoro';
      case SessionType.deep:
        return 'Deep Work';
      case SessionType.custom:
        return 'Custom Timer';
    }
  }

  String get emoji {
    switch (this) {
      case SessionType.open:
        return '⚡';
      case SessionType.pomodoro:
        return '🍅';
      case SessionType.deep:
        return '🧠';
      case SessionType.custom:
        return '⏱️';
    }
  }

  String get shortName {
    switch (this) {
      case SessionType.open:
        return 'Quick';
      case SessionType.pomodoro:
        return 'Pomo';
      case SessionType.deep:
        return 'Deep';
      case SessionType.custom:
        return 'Custom';
    }
  }
}

// Breathing patterns
enum BreathingPattern { box, fourSevenEight, physiologicalSigh }

// Block states
enum BlockState { past, current, future }
