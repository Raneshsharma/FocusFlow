import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/settings_provider.dart';

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

  runApp(const ProviderScope(child: FocusFlowApp()));
}

class FocusFlowApp extends ConsumerWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: router,
    );
  }
}