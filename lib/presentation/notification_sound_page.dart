import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../core/constants/app_typography.dart';
import '../core/services/sound_service.dart';
import '../injection_container.dart';

class NotificationSoundPage extends StatefulWidget {
  const NotificationSoundPage({super.key});

  @override
  State<NotificationSoundPage> createState() => _NotificationSoundPageState();
}

class _NotificationSoundPageState extends State<NotificationSoundPage> {
  final _player = AudioPlayer();
  String? _playingSound;
  late String _selectedSound;

  final List<String> _soundOptions = [
    'Soft Chime',
    'Gentle Bell',
    'Sparkle',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSound = sl<SoundService>().getSelectedSound();
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingSound = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSoundPreview(String soundName) async {
    if (soundName == 'None') {
      await _player.stop();
      setState(() {
        _playingSound = null;
      });
      return;
    }

    if (_playingSound == soundName) {
      await _player.stop();
      setState(() {
        _playingSound = null;
      });
    } else {
      await _player.stop();
      final path = sl<SoundService>().getSoundAssetPath(soundName);
      if (path.isNotEmpty) {
        try {
          await _player.play(AssetSource(path));
          setState(() {
            _playingSound = soundName;
          });
        } catch (_) {}
      }
    }
  }

  Future<void> _selectSound(String soundName) async {
    await sl<SoundService>().setSelectedSound(soundName);
    setState(() {
      _selectedSound = soundName;
    });
    // Also auto-play preview when selected (unless 'None')
    if (soundName != 'None') {
      await _playSoundPreview(soundName);
    } else {
      await _player.stop();
      setState(() {
        _playingSound = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;
    final blush = theme.colorScheme.primaryContainer;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification Sound',
          style: AppTypography.h2(color: textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ─── Header Quote/Card ───
            Card(
              color: surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: blush.withValues(alpha: isDark ? 0.3 : 0.8), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Text('🎀', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Select a sweet tune for your reminders and alarms, bestie! ✨',
                        style: AppTypography.body(color: textPrimary).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Sound List ───
            ..._soundOptions.map((opt) {
              final isSelected = _selectedSound == opt;
              final isPlaying = _playingSound == opt;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withValues(alpha: isDark ? 0.12 : 0.06) : surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : blush.withValues(alpha: isDark ? 0.2 : 0.5),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectSound(opt),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Choice Icon (Checkmark / empty circle)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? primary : textHint.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              color: isSelected ? primary : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),

                          // Text Label
                          Expanded(
                            child: Text(
                              opt,
                              style: AppTypography.h3(color: textPrimary).copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),

                          // Preview Button
                          if (opt != 'None')
                            IconButton(
                              onPressed: () => _playSoundPreview(opt),
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? primary
                                      : primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                  color: isPlaying ? Colors.white : primary,
                                  size: 20,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.volume_off_rounded,
                                color: textHint.withValues(alpha: 0.5),
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
