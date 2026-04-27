import 'package:flutter/material.dart';

/// AppIcon - Centralized icon widget for FocusFlow using emojis
///
/// Usage:
///   AppIcon(AppIcons.add, size: 24, color: AppColors.teal)
///   AppIcon(AppIcons.star, size: 32)
class AppIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      icon,
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
      semanticsLabel: semanticLabel,
    );
  }
}

/// Emoji icons organized by category
class AppIcons {
  AppIcons._();

  // ============================================
  // CORE ACTION ICONS
  // ============================================
  static const add = '+';
  static const close = '✕';
  static const check = '✓';
  static const checkCircle = '⭯';
  static const delete = '🗑';
  static const starFilled = '★';
  static const starOutline = '☆';
  static const chevronRight = '›';
  static const chevronUp = '▲';
  static const chevronDown = '▼';
  static const expandMore = '⌄';
  static const expandLess = '⌃';
  static const play = '▶';
  static const playCircle = '▶';
  static const pause = '⏸';
  static const stop = '⏹';
  static const settings = '⚙';
  static const search = '🔍';
  static const share = '↗';
  static const refresh = '↻';
  static const edit = '✎';
  static const download = '⬇';
  static const upload = '⬆';
  static const heart = '♥';
  static const lock = '🔒';
  static const mic = '🎤';
  static const celebration = '🎉';
  static const circle = '⭕';
  static const target = '◎';
  static const archive = '📦';
  static const link = '🔗';

  // Navigation / Status
  static const flashOn = '⚡';
  static const bolt = '⚡';
  static const speaker = '🔊';
  static const volumeUp = '🔊';

  // Energy / Mood
  static const psychology = '🧠';
  static const batteryChargingFull = '🔋';
  static const cloud = '☁';
  static const moon = '🌙';
  static const sun = '☀';
  static const bed = '🛏';

  // Time / Schedule
  static const history = '📜';
  static const schedule = '🕐';

  // Infinity / Anytime
  static const infinity = '♾️';

  // Bookmarks
  static const bookmarkFilled = '🔖';
  static const bookmarkOutline = '📑';

  // Rest / Breaks
  static const walk = '🚶';
  static const waterDrop = '💧';
  static const spa = '🧘';
  static const air = '💨';
  static const phone = '📱';

  // Trophy / Win
  static const trophy = '🏆';

  // ============================================
  // ENERGY ICONS
  // ============================================
  static const energyQuick = '⚡';
  static const energyDeep = '🧠';
  static const energyLow = '🔋';

  // ============================================
  // TIME ZONE ICONS
  // ============================================
  static const zoneMorning = '🌅';
  static const zoneAfternoon = '☀️';
  static const zoneEvening = '🌙';
  static const zoneAnytime = '♾️';

  // ============================================
  // SESSION ICONS
  // ============================================
  static const sessionQuick = '⚡';
  static const sessionDeep = '🧠';
  static const sessionPomodoro = '🍅';
  static const focusMode = '🎯';
  static const track = '📊';
  static const lightningActive = '⚡';
  static const pauseBadge = '⏸';
  static const playCircleSession = '▶';

  // ============================================
  // REST & BREAK ICONS
  // ============================================
  static const breathing = '🌬';
  static const windDown = '🌙';
  static const volume = '🔊';
  static const microCoffee = '☕';
  static const microWalk = '🚶';
  static const microLookAway = '👀';
  static const microStretch = '🧘';
  static const microHydrate = '💧';
  static const microRelax = '😌';

  // ============================================
  // SOUND MIXER ICONS
  // ============================================
  static const soundRain = '🌧';
  static const soundFire = '🔥';
  static const soundCafe = '☕';
  static const soundOcean = '🌊';
  static const soundNoise = '📢';
  static const soundForest = '🌲';
  static const soundLofi = '🎵';
  static const soundPause = '⏸';
  static const soundPlay = '▶';
  static const speakerSound = '🔈';

  // ============================================
  // LIBRARY ICONS
  // ============================================
  static const streak = '🔥';
  static const sleeping = '😴';
  static const shuffle = '🔀';
  static const trophyLibrary = '🏆';
  static const archiveCheck = '✅';
  static const clockSmall = '🕐';
  static const moodOkay = '😐';
  static const sparkle = '✨';

  // ============================================
  // SETTINGS ICONS
  // ============================================
  static const appearance = '🎨';
  static const notifications = '🔔';
  static const dnd = '🔕';
  static const statistics = '📊';
  static const about = 'ℹ';
  static const darkMode = '🌙';
  static const soundEffects = '🔊';
  static const statsStreak = '🔥';
  static const statsTasks = '✅';
  static const statsSessions = '⏱';
  static const statsFocus = '🎯';
  static const trophySettings = '🏆';
  static const insights = '📈';

  // ============================================
  // ONBOARDING ICONS
  // ============================================
  static const wave = '👋';
  static const tomorrow = '📆';
  static const phoneOff = '📴';
  static const timer = '⏱';
  static const flexible = '🔄';

  // ============================================
  // TASK ICONS
  // ============================================
  static const checkboxEmpty = '☐';
  static const checkboxChecked = '☑';
  static const circlePending = '⭘';

  // ============================================
  // NAVIGATION ICONS
  // ============================================
  static const navFocus = '🎯';
  static const navFlow = '⚡';
  static const navLibrary = '📚';
  static const navRest = '🌙';

  // ============================================
  // ALTERNATE ICONS (for backwards compatibility)
  // ============================================
  static const addAlt = '+';
  static const closeAlt = '✕';
  static const checkAlt = '✓';
  static const checkCircleAlt = '⭯';
  static const deleteAlt = '🗑';
  static const deleteForever = '🚫';
  static const starFilledAlt = '★';
  static const starOutlineAlt = '☆';
  static const chevronRightAlt = '›';
  static const playAlt = '▶';
  static const pauseCircle = '⏸';
  static const settingsOutline = '⚙';
  static const inbox = '📥';
  static const inboxAlt = '📥';
  static const externalLink = '↗';
  static const refreshAlt = '↻';
  static const copy = '📋';
  static const copyAlt = '📋';
  static const editAlt = '✎';
  static const downloadAlt = '⬇';
  static const uploadAlt = '⬆';
  static const heartAlt = '♥';
  static const lockAlt = '🔒';
  static const micAlt = '🎤';
  static const celebrationAlt = '🎉';
  static const gpsFixed = '📍';
  static const trackChanges = '🔄';
  static const nightlight = '🌙';
  static const batteryCharging = '🔋';
  static const note = '📝';
  static const allInclusive = '♾️';
  static const emojiEvents = '🏆';
  static const visibilityOff = '👁';
  static const accessibility = '♿';
  static const moreHoriz = '☰';
  static const moreHorizontal = '☰';
  static const adjust = '🔧';

  // More library icons
  static const anchor = '⚓';
  static const emptyHistory = '📜';
  static const emptyTemplates = '📋';
  static const emptyStar = '☆';
  static const emptyNotes = '📝';
  static const emptyArchive = '📦';
  static const emptyResources = '📚';
  static const categoryArticle = '📄';
  static const categoryTool = '🔧';
  static const categoryVideo = '🎬';
  static const categoryCourse = '🎓';
  static const categoryLink = '🔗';
  static const bookmarkLibrary = '🔖';
  static const sparkles = '✨';
  static const brag = '💪';
  static const celebrationShare = '🎉';

  // More settings icons
  static const sound = '🔊';
}
