import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // BRAND COLORS (Primary Design System)
  // ============================================

  /// Primary — Deep Slate #1A1A2E
  /// Headers, active states, primary actions
  static const Color deepSlate = Color(0xFF1A1A2E);

  /// Primary Variant — Navy #16213E
  /// Hover states, secondary emphasis
  static const Color navy = Color(0xFF16213E);

  /// Accent — Warm Amber #F5B800
  /// CTAs, highlights, active chips, FAB
  static const Color amber = Color(0xFFF5B800);

  /// Accent Secondary — Electric Teal #0F969C
  /// Energy chip "Deep", rest elements
  static const Color teal = Color(0xFF0F969C);

  /// Rest Zone — Deep Teal #0D4F4F
  /// Rest screen hero background, wind-down mode
  static const Color restZone = Color(0xFF0D4F4F);

  // ============================================
  // SURFACE COLORS
  // ============================================

  /// Surface — Off-White #F8F9FA
  /// Card backgrounds, screen backgrounds
  static const Color surface = Color(0xFFF8F9FA);

  /// Surface Alt — Cool Gray #EEF0F4
  /// Anytime Pool background, input fields
  static const Color surfaceAlt = Color(0xFFEEF0F4);

  // ============================================
  // BLOCK STATE COLORS
  // ============================================

  /// Block Past — Muted Gray #D1D5DB
  /// Past M/A/E block background
  static const Color blockPast = Color(0xFFD1D5DB);

  /// Block Current — Warm White #FFFFFF
  /// Active M/A/E block with left accent border
  static const Color blockCurrent = Color(0xFFFFFFFF);

  /// Block Future — Surface White #F8F9FA
  /// Future M/A/E block
  static const Color blockFuture = Color(0xFFF8F9FA);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Text Primary — Charcoal #1A1A2E
  /// Headings, body text
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Text Secondary — Slate Gray #64748B
  /// Subtitles, labels, metadata
  static const Color textSecondary = Color(0xFF64748B);

  /// Text Muted — Light Gray #9CA3AF
  /// Past block text, placeholder
  static const Color textMuted = Color(0xFF9CA3AF);

  // ============================================
  // ENERGY LEVEL COLORS
  // ============================================

  /// Energy Quick — Warm Amber #F59E0B
  /// ⚡ Quick chip background
  static const Color energyQuick = Color(0xFFF59E0B);

  /// Energy Deep — Sage Green #10B981
  /// 🧠 Deep chip background
  static const Color energyDeep = Color(0xFF10B981);

  /// Energy Low — Sky Blue #3B82F6
  /// 🪫 Low energy chip background
  static const Color energyLow = Color(0xFF3B82F6);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success — Signal Green #22C55E
  /// Completion states, "showed up" chip
  static const Color success = Color(0xFF22C55E);

  /// Error / Low Score — Crimson #DC2626
  /// Only for critical errors (delete confirm, sync failure)
  static const Color error = Color(0xFFDC2626);

  // ============================================
  // LEGACY / COMPATIBILITY ALIASES
  // (Keeping for existing code references)
  // ============================================

  static const Color charcoal = Color(0xFF1A1A2E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8B5CF6);

  // ============================================
  // TIME ZONE COLORS
  // ============================================

  static const Color zoneMorning = Color(0xFFF5B800);
  static const Color zoneAfternoon = Color(0xFFF97316);
  static const Color zoneEvening = Color(0xFF6366F1);

  // ============================================
  // GREY SCALE
  // ============================================

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color white = Color(0xFFFFFFFF);

  // NOW badge colors
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green700 = Color(0xFF047857);

  // Teal variations
  static const Color teal50 = Color(0xFFF0FDFA);
  static const Color tealBorder = Color(0xFF99F6E4);
  static const Color teal100 = Color(0xFFCCFBF1);
  static const Color teal700 = Color(0xFF0F766E);

  // ─────────────────────────────────────────────────────────────────
  // SETTINGS UI COLORS
  // ─────────────────────────────────────────────────────────────────

  /// Settings tile background — white in light, charcoal in dark
  static Color settingsTileBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? charcoal
        : white;
  }

  /// Settings section label color
  static const Color settingsSectionLabel = teal;

  /// Settings tile border in light mode
  static const Color settingsTileBorder = grey200;

  /// Divider color for settings lists
  static const Color settingsDivider = grey200;

  /// Disabled / inactive text in settings
  static const Color settingsDisabledText = grey400;

  /// Settings icon background (tinted circle)
  static const Color settingsIconBg = grey100;

  /// Settings destructive action color
  static const Color destructive = error;
}
