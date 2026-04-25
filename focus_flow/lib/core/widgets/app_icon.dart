import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AppIcon - Centralized icon widget for FocusFlow
///
/// Usage:
///   AppIcon('core/add', size: 24, color: AppColors.teal)
///   AppIcon('energy/energy_quick', size: 32)
///   AppIcon('zones/zone_morning', size: 44, color: AppColors.zoneMorning)
class AppIcon extends StatelessWidget {
  final String assetPath; // e.g., 'core/add' or 'energy/energy_quick'
  final double size;
  final Color? color;
  final BoxFit fit;
  final String? semanticLabel;

  const AppIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Handle both SVG and PNG assets
    // Check if assetPath ends with known file extensions
    final isSvgAsset = !assetPath.contains('.') || assetPath.endsWith('.svg');
    final isPngAsset = assetPath.endsWith('.png');

    if (isPngAsset) {
      return Image.asset(
        'assets/icons/$assetPath',
        width: size,
        height: size,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // SVG asset (or path without extension defaults to SVG)
    final svgPath = isSvgAsset && !assetPath.contains('.')
        ? 'assets/icons/$assetPath.svg'
        : 'assets/icons/$assetPath';

    return SvgPicture.asset(
      svgPath,
      width: size,
      height: size,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => _buildPlaceholder(),
      semanticsLabel: semanticLabel,
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: size * 0.6,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

/// Icon paths organized by category
/// Use these constants to ensure consistency across the app
class AppIcons {
  AppIcons._();

  // ============================================
  // CORE ACTION ICONS
  // ============================================
  static const add = 'core/add';
  static const addAlt = 'core/add_alt';
  static const close = 'core/close';
  static const closeAlt = 'core/close_alt';
  static const check = 'core/check';
  static const checkAlt = 'core/check_alt';
  static const checkCircle = 'core/check_circle';
  static const checkCircleAlt = 'core/check_circle_alt';
  static const delete = 'core/delete';
  static const deleteAlt = 'core/delete_alt';
  static const deleteForever = 'core/delete_forever';
  static const starFilled = 'core/star_filled';
  static const starFilledAlt = 'core/star_filled_alt';
  static const starOutline = 'core/star_outline';
  static const starOutlineAlt = 'core/star_outline_alt';
  static const chevronRight = 'core/chevron_right';
  static const chevronRightAlt = 'core/chevron_right_alt';
  static const chevronUp = 'core/chevron_up';
  static const chevronDown = 'core/chevron_down';
  static const expandLess = 'core/expand_less';
  static const expandMore = 'core/expand_more';
  static const moreHoriz = 'core/more_horiz';
  static const moreHorizontal = 'core/more_horiz';
  static const play = 'core/play';
  static const playAlt = 'core/play_arrow';
  static const playCircle = 'core/play_circle_alt';
  static const pause = 'core/pause';
  static const pauseCircle = 'core/pause_circle_alt';
  static const stop = 'core/stop';
  static const settings = 'core/settings';
  static const settingsOutline = 'core/settings_outline';
  static const search = 'core/search';
  static const inbox = 'core/inbox';
  static const inboxAlt = 'core/inbox_alt';
  static const share = 'core/share';
  static const externalLink = 'core/external_link';
  static const refresh = 'core/refresh';
  static const refreshAlt = 'core/refresh_alt';
  static const copy = 'core/copy';
  static const copyAlt = 'core/copy_alt';
  static const edit = 'core/edit';
  static const editAlt = 'core/edit_alt';
  static const download = 'core/download';
  static const downloadAlt = 'core/download_alt';
  static const upload = 'core/upload';
  static const uploadAlt = 'core/upload_alt';
  static const heart = 'core/heart';
  static const heartAlt = 'core/heart_alt';
  static const lock = 'core/lock';
  static const lockAlt = 'core/lock_alt';
  static const mic = 'core/mic';
  static const micAlt = 'core/mic_alt';
  static const celebration = 'core/celebration';
  static const celebrationAlt = 'core/celebration_alt';
  static const circle = 'core/circle';
  static const target = 'core/target';
  static const archive = 'core/archive';
  static const link = 'core/link';

  // Navigation / Status
  static const gpsFixed = 'core/gps_fixed';
  static const flashOn = 'core/flash_on';
  static const bolt = 'core/bolt';
  static const trackChanges = 'core/track_changes';
  static const speaker = 'core/speaker';
  static const volumeUp = 'core/volume_up';

  // Energy / Mood
  static const psychology = 'core/psychology';
  static const batteryChargingFull = 'core/battery_charging_full';
  static const adjust = 'core/adjust';
  static const cloud = 'core/cloud';
  static const moon = 'core/moon';
  static const nightlight = 'core/nightlight';
  static const bed = 'core/bed';
  static const sun = 'core/sun';

  // Time / Schedule
  static const history = 'core/history';
  static const note = 'core/note';
  static const schedule = 'library/clock_small';

  // Infinity / Anytime
  static const infinity = 'core/infinity';
  static const allInclusive = 'core/infinity'; // alias

  // Bookmarks
  static const bookmarkFilled = 'core/bookmark_filled';
  static const bookmarkOutline = 'core/bookmark_outline';

  // Rest / Breaks
  static const walk = 'core/walk';
  static const visibilityOff = 'core/visibility_off';
  static const accessibility = 'core/accessibility';
  static const waterDrop = 'core/water_drop';
  static const spa = 'core/spa';
  static const air = 'core/air';
  static const phone = 'core/phone';

  // Trophy / Win
  static const trophy = 'core/trophy';
  static const emojiEvents = 'core/trophy'; // alias

  // ============================================
  // ENERGY ICONS
  // ============================================
  static const energyQuick = 'energy/energy_quick';
  static const energyDeep = 'energy/energy_deep';
  static const energyLow = 'energy/energy_low';
  static const batteryCharging = 'energy/battery_charging';

  // ============================================
  // TIME ZONE ICONS
  // ============================================
  static const zoneMorning = 'zones/zone_morning';
  static const zoneAfternoon = 'zones/zone_afternoon';
  static const zoneEvening = 'zones/zone_evening';
  static const zoneAnytime = 'zones/zone_anytime';

  // ============================================
  // SESSION ICONS
  // ============================================
  static const sessionQuick = 'sessions/session_quick';
  static const sessionDeep = 'sessions/session_deep';
  static const sessionPomodoro = 'sessions/session_pomodoro';
  static const playCircleSession = 'sessions/play_circle';
  static const focusMode = 'sessions/focus_mode';
  static const focusGps = 'sessions/focus_gps';
  static const track = 'sessions/track';
  static const lightningActive = 'sessions/lightning_active';
  static const pauseBadge = 'sessions/pause_badge';

  // ============================================
  // REST & BREAK ICONS
  // ============================================
  static const breathing = 'rest/breathing';
  static const windDown = 'rest/wind_down';
  static const volume = 'rest/volume';
  static const microCoffee = 'rest/micro_coffee';
  static const microWalk = 'rest/micro_walk';
  static const microLookAway = 'rest/micro_look_away';
  static const microStretch = 'rest/micro_stretch';
  static const microHydrate = 'rest/micro_hydrate';
  static const microRelax = 'rest/micro_relax';

  // ============================================
  // SOUND MIXER ICONS
  // ============================================
  static const soundRain = 'sounds/sound_rain';
  static const soundFire = 'sounds/sound_fire';
  static const soundCafe = 'sounds/sound_cafe';
  static const soundOcean = 'sounds/sound_ocean';
  static const soundNoise = 'sounds/sound_noise';
  static const soundForest = 'sounds/sound_forest';
  static const soundLofi = 'sounds/sound_lofi';
  static const soundPause = 'sounds/pause_circle';
  static const soundPlay = 'sounds/play_circle';
  static const speakerSound = 'sounds/speaker';

  // ============================================
  // LIBRARY ICONS
  // ============================================
  static const streak = 'library/streak';
  static const sleeping = 'library/sleeping';
  static const shuffle = 'library/shuffle';
  static const trophyLibrary = 'library/trophy';
  static const anchor = 'library/anchor';
  static const emptyHistory = 'library/empty_history';
  static const emptyTemplates = 'library/empty_templates';
  static const emptyStar = 'library/empty_star';
  static const emptyNotes = 'library/empty_notes';
  static const emptyArchive = 'library/empty_archive';
  static const emptyResources = 'library/empty_resources';
  static const categoryArticle = 'library/category_article';
  static const categoryTool = 'library/category_tool';
  static const categoryVideo = 'library/category_video';
  static const categoryCourse = 'library/category_course';
  static const categoryLink = 'library/category_link';
  static const bookmarkLibrary = 'library/bookmark';
  static const sparkles = 'library/sparkles';
  static const brag = 'library/brag';
  static const archiveCheck = 'library/archive_check';
  static const celebrationShare = 'library/celebration_share';
  static const clockSmall = 'library/clock_small';
  static const moodOkay = 'library/mood_okay';

  // ============================================
  // SETTINGS ICONS
  // ============================================
  static const appearance = 'settings/appearance';
  static const notifications = 'settings/notifications';
  static const dnd = 'settings/dnd';
  static const statistics = 'settings/statistics';
  static const about = 'settings/about';
  static const darkMode = 'settings/dark_mode';
  static const soundEffects = 'settings/sound';
  static const statsStreak = 'settings/stats_streak';
  static const statsTasks = 'settings/stats_tasks';
  static const statsSessions = 'settings/stats_sessions';
  static const statsFocus = 'settings/stats_focus';
  static const trophySettings = 'settings/trophy';

  // ============================================
  // ONBOARDING ICONS
  // ============================================
  static const wave = 'onboarding/wave';
  static const tomorrow = 'onboarding/tomorrow';
  static const phoneOff = 'onboarding/phone_off';
  static const timer = 'onboarding/timer';
  static const flexible = 'onboarding/flexible';

  // ============================================
  // TASK ICONS
  // ============================================
  static const checkboxEmpty = 'tasks/checkbox_empty';
  static const checkboxChecked = 'tasks/checkbox_checked';
  static const circlePending = 'tasks/circle_pending';

  // ============================================
  // NAVIGATION ICONS (from existing assets)
  // ============================================
  static const navFocus = 'nav/icons8-target-64.png';
  static const navFlow = 'nav/icons8-lightning-bolt-64.png';
  static const navLibrary = 'nav/icons8-bookmark-64.png';
  static const navRest = 'nav/icons8-do-not-disturb-ios-64.png';
}
