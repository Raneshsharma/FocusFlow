import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';

class AmbientSoundMixer extends StatefulWidget {
  final VoidCallback? onClose;

  const AmbientSoundMixer({super.key, this.onClose});

  @override
  State<AmbientSoundMixer> createState() => _AmbientSoundMixerState();
}

class _AmbientSoundMixerState extends State<AmbientSoundMixer> {
  final Map<String, double> _volumes = {
    'Rain': 0.0,
    'Fireplace': 0.0,
    'Café Chatter': 0.0,
    'Ocean Waves': 0.0,
    'Brown Noise': 0.0,
    'Forest': 0.0,
    'Lo-fi Beat': 0.0,
  };

  final Map<String, String> _icons = {
    'Rain': '🌧️',
    'Fireplace': '🔥',
    'Café Chatter': '☕',
    'Ocean Waves': '🌊',
    'Brown Noise': '🍃',
    'Forest': '🌲',
    'Lo-fi Beat': '🎵',
  };

  double _masterVolume = 0.7;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final activeTracks = _volumes.entries.where((e) => e.value > 0).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppIcon(AppIcons.volumeUp, color: AppColors.teal),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ambient Sound Mixer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: AppIcon(AppIcons.close, size: 24),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),

          // Active tracks indicator
          if (activeTracks.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  AppIcon(
                    _isPlaying ? AppIcons.pauseCircle : AppIcons.playCircleSession,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isPlaying
                          ? 'Playing: ${activeTracks.map((e) => '${_icons[e.key]} ${e.key}').join(', ')}'
                          : 'Paused: ${activeTracks.length} track${activeTracks.length > 1 ? 's' : ''} active',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Master volume
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppIcon(AppIcons.speakerSound, color: AppColors.grey500),
                const SizedBox(width: 8),
                const Text(
                  'Master',
                  style: TextStyle(fontSize: 14),
                ),
                Expanded(
                  child: Slider(
                    value: _masterVolume,
                    onChanged: (value) {
                      setState(() => _masterVolume = value);
                    },
                    activeColor: AppColors.teal,
                    inactiveColor: AppColors.grey200,
                  ),
                ),
                Text(
                  '${(_masterVolume * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          // Sound tracks
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),

          SizedBox(
            height: 280,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _volumes.length,
              itemBuilder: (context, index) {
                final track = _volumes.keys.elementAt(index);
                final volume = _volumes[track]!;
                final icon = _icons[track]!;

                return _buildTrackRow(track, icon, volume);
              },
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              border: Border(
                top: BorderSide(color: AppColors.grey200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetAll,
                    icon: AppIcon(AppIcons.refresh, size: 18),
                    label: const Text('Reset All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: activeTracks.isEmpty ? null : _togglePlayPause,
                    icon: AppIcon(
                      _isPlaying ? AppIcons.pause : AppIcons.play,
                      size: 18,
                    ),
                    label: Text(_isPlaying ? 'Pause' : 'Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackRow(String track, String icon, double volume) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: volume,
                    onChanged: (value) {
                      setState(() => _volumes[track] = value);
                    },
                    activeColor: volume > 0 ? AppColors.teal : AppColors.grey300,
                    inactiveColor: AppColors.grey100,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(volume * 100).round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: volume > 0 ? AppColors.teal : AppColors.grey400,
                fontWeight: volume > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAll() {
    setState(() {
      for (final key in _volumes.keys) {
        _volumes[key] = 0.0;
      }
      _isPlaying = false;
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }
}