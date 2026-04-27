import 'package:flutter/material.dart';

/// Global overlay entry manager for showing toasts and overlays.
/// Initialized in StatefulWidget.initState() - no Riverpod provider needed.
class OverlayService {
  static OverlayService? _instance;
  static OverlayService get instance => _instance ??= OverlayService._();

  OverlayService._();

  OverlayEntry? _currentEntry;
  OverlayState? _overlayState;

  /// Initialize with an OverlayState. Called from initState() before build.
  void initializeWithOverlayState(OverlayState overlayState) {
    _overlayState = overlayState;
  }

  bool get isInitialized => _overlayState != null;

  /// Show an overlay with a builder function that creates the widget.
  void showOverlay({
    required Widget Function(BuildContext) builder,
    Duration? duration,
  }) {
    if (_overlayState == null) {
      debugPrint('OverlayService: Not initialized with OverlayState');
      return;
    }

    // Remove any existing overlay
    hideOverlay();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: builder,
    );
    _currentEntry = entry;

    _overlayState!.insert(entry);

    if (duration != null) {
      Future.delayed(duration, () {
        entry.remove();
        _currentEntry = null;
      });
    }
  }

  void hideOverlay() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// Global overlay service singleton.
final overlayService = OverlayService.instance;
