import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../../../providers/stats_provider.dart';
import '../widgets/breathing_timer.dart';
import '../widgets/micro_break_card.dart';
import '../widgets/wind_down_routine.dart';
import '../widgets/ambient_sound_mixer.dart';

class RestScreen extends ConsumerWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider);
    final greeting = utils.DateUtils.getGreeting();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest & Recovery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Center(
                child: Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "You've earned this break.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Session summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppIcon(
                          AppIcons.checkCircle,
                          color: AppColors.teal,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You showed up today!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statsAsync.when(
                                data: (stats) => stats != null
                                    ? '${stats.sessionsCompleted} session${stats.sessionsCompleted == 1 ? '' : 's'} completed • ${stats.focusMinutes} min focused'
                                    : 'Start your journey!',
                                loading: () => 'Loading...',
                                error: (_, __) => 'Start your journey!',
                              ),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Take a break section
              Text(
                'Take a Break',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Micro breaks
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    MicroBreakCard(
                      icon: 'coffee',
                      title: 'Coffee Break',
                      duration: '5 min',
                      color: Colors.brown,
                    ),
                    SizedBox(width: 12),
                    MicroBreakCard(
                      icon: 'walk',
                      title: 'Take a Walk',
                      duration: '10 min',
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    MicroBreakCard(
                      icon: 'visibility_off',
                      title: 'Look Away',
                      duration: '20 sec',
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    MicroBreakCard(
                      icon: 'accessibility',
                      title: 'Stretch',
                      duration: '5 min',
                      color: Colors.purple,
                    ),
                    SizedBox(width: 12),
                    MicroBreakCard(
                      icon: 'water_drop',
                      title: 'Hydrate',
                      duration: '2 min',
                      color: Colors.cyan,
                    ),
                    SizedBox(width: 12),
                    MicroBreakCard(
                      icon: 'spa',
                      title: 'Relax',
                      duration: '5 min',
                      color: Colors.pink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Breathing exercises
              Text(
                'Calm Your Mind',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Breathing timer card
              InkWell(
                onTap: () => _showBreathingTimer(context),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppIcon(
                            AppIcons.air,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Breathing Exercise',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Box breathing, 4-7-8, or physiological sigh',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        AppIcon(AppIcons.chevronRight),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Wind down card
              InkWell(
                onTap: () => _showWindDownRoutine(context),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppIcon(
                            AppIcons.nightlight,
                            color: Colors.purple,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wind Down Routine',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prepare for better sleep',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        AppIcon(AppIcons.chevronRight),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ambient Sound Mixer card
              InkWell(
                onTap: () => _showAmbientSoundMixer(context),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.energyDeep.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AppIcon(
                            AppIcons.volumeUp,
                            color: AppColors.energyDeep,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ambient Sounds',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rain, fireplace, ocean waves & more',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        AppIcon(AppIcons.chevronRight),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showBreathingTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BreathingTimerSheet(),
    );
  }

  void _showWindDownRoutine(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WindDownRoutineSheet(),
    );
  }

  void _showAmbientSoundMixer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AmbientSoundMixer(),
    );
  }
}
