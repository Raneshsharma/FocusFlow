import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/settings_provider.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';
import 'services/streak_service.dart';
import 'services/overlay_service.dart';
import 'features/library/widgets/welcome_back_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes for JSON storage
  await Hive.openBox<String>('tasks');
  await Hive.openBox<String>('sessions');
  await Hive.openBox<String>('templates');
  await Hive.openBox<String>('resources');
  await Hive.openBox<String>('stats');
  await Hive.openBox<String>('settings');
  await Hive.openBox<String>('notes');
  await Hive.openBox<String>('wind_down');
  await Hive.openBox<String>('achievements');
  await Hive.openBox<String>('gamification');

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: FocusFlowApp()));
}

class FocusFlowApp extends ConsumerStatefulWidget {
  const FocusFlowApp({super.key});

  @override
  ConsumerState<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends ConsumerState<FocusFlowApp> with WidgetsBindingObserver {
  bool _checkedWelcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // Initialize overlay service with OverlayState (available after first frame)
    if (!overlayService.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final overlayState = Overlay.of(context);
        overlayService.initializeWithOverlayState(overlayState);
      });
    }

    // Check for welcome back on first build
    if (!_checkedWelcome) {
      _checkedWelcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkWelcomeBack();
      });
    }

    return MaterialApp.router(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: router,
    );
  }

  Future<void> _checkWelcomeBack() async {
    final settingsAsync = ref.read(appSettingsProvider);

    // Only show welcome back for returning users who completed onboarding
    final settings = settingsAsync.valueOrNull;
    if (settings != null && settings.hasCompletedOnboarding) {
      final streakService = StreakService();
      final result = await streakService.checkStreakStatus();

      // Show welcome back if streak was broken or it's a grace day
      if (result.wasBroken || result.isGraceDay) {
        if (mounted) {
          WelcomeBackSheet.show(context);
        }
      }
    }
  }
}
