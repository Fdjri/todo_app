import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../injection_container.dart';

class PianoSynth {
  static final Map<String, double> noteFreqs = {
    'C5': 523.25,
    'C#5': 554.37,
    'D5': 587.33,
    'D#5': 622.25,
    'E5': 659.25,
    'F5': 698.46,
    'F#5': 739.99,
    'G5': 783.99,
    'G#5': 830.61,
    'A5': 880.00,
    'A#5': 932.33,
    'B5': 987.77,
    'C6': 1046.50,
  };

  static final Map<String, String> _cachedPaths = {};

  static Future<void> init() async {
    if (_cachedPaths.isNotEmpty) return;
    final tempDir = await getTemporaryDirectory();
    for (final note in noteFreqs.keys) {
      final file = File('${tempDir.path}/piano_$note.wav');
      if (!await file.exists()) {
        final bytes = _generateSineWav(noteFreqs[note]!, 1.2, 22050);
        await file.writeAsBytes(bytes);
      }
      _cachedPaths[note] = file.path;
    }
  }

  static String? getPath(String note) => _cachedPaths[note];

  static Uint8List _generateSineWav(double frequency, double duration, int sampleRate) {
    final numSamples = (sampleRate * duration).toInt();
    final numBytes = numSamples * 2; // 16-bit mono
    final headerSize = 44;
    final wavData = Uint8List(headerSize + numBytes);
    final byteData = ByteData.sublistView(wavData);

    // RIFF Header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    
    byteData.setUint32(4, 36 + numBytes, Endian.little);
    
    byteData.setUint8(8, 0x57);  // W
    byteData.setUint8(9, 0x41);  // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E

    // fmt subchunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6d); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // ' '
    
    byteData.setUint32(16, 16, Endian.little); // subchunk1 size
    byteData.setUint16(20, 1, Endian.little);  // PCM format
    byteData.setUint16(22, 1, Endian.little);  // mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    byteData.setUint16(32, 2, Endian.little);  // block align
    byteData.setUint16(34, 16, Endian.little); // 16-bit

    // data subchunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    
    byteData.setUint32(40, numBytes, Endian.little);

    // Generate Chime Sine wave with soft exponential decay
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double val = sin(2 * pi * frequency * t);
      // Soft decay envelope
      final decay = exp(-t / 0.38);
      val *= decay;
      
      final sample = (val * 32767).toInt();
      byteData.setInt16(44 + i * 2, sample, Endian.little);
    }

    return wavData;
  }
}

class PianoEvent {
  final String note;
  final int timeMs;

  PianoEvent({required this.note, required this.timeMs});
}

class PianoRecorderDialog extends StatefulWidget {
  const PianoRecorderDialog({super.key});

  @override
  State<PianoRecorderDialog> createState() => _PianoRecorderDialogState();
}

class _PianoRecorderDialogState extends State<PianoRecorderDialog> {
  bool _isSynthReady = false;
  bool _isRecording = false;
  bool _isPlayingPreview = false;
  bool _hasRecordedFile = false;

  final List<AudioPlayer> _playerPool = List.generate(8, (_) => AudioPlayer());
  int _poolIndex = 0;

  final AudioPlayer _previewPlayer = AudioPlayer();

  Stopwatch? _stopwatch;
  final List<PianoEvent> _events = [];
  final Set<String> _activeNotes = {};

  Timer? _recordTimer;
  double _elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _initSynth();
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
        });
      }
    });
  }

  Future<void> _initSynth() async {
    await PianoSynth.init();
    if (mounted) {
      setState(() {
        _isSynthReady = true;
      });
    }
  }

  @override
  void dispose() {
    for (final p in _playerPool) {
      p.dispose();
    }
    _previewPlayer.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  void _handleKeyPress(String note) {
    setState(() {
      _activeNotes.add(note);
    });

    final path = PianoSynth.getPath(note);
    if (path != null) {
      final player = _playerPool[_poolIndex];
      _poolIndex = (_poolIndex + 1) % _playerPool.length;
      try {
        player.stop();
        player.play(DeviceFileSource(path));
      } catch (_) {}
    }

    if (_isRecording && _stopwatch != null) {
      _events.add(PianoEvent(note: note, timeMs: _stopwatch!.elapsedMilliseconds));
    }
  }

  void _handleKeyRelease(String note) {
    setState(() {
      _activeNotes.remove(note);
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording
      _recordTimer?.cancel();
      _stopwatch?.stop();
      setState(() {
        _isRecording = false;
        _hasRecordedFile = _events.isNotEmpty;
      });
    } else {
      // Start recording
      _events.clear();
      _elapsedSeconds = 0.0;
      _stopwatch = Stopwatch()..start();
      _isRecording = true;
      _hasRecordedFile = false;
      _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (mounted) {
          setState(() {
            _elapsedSeconds = (_stopwatch?.elapsedMilliseconds ?? 0) / 1000.0;
          });
        }
      });
      setState(() {});
    }
  }

  Future<void> _playPreview() async {
    if (_isPlayingPreview) {
      await _previewPlayer.stop();
      setState(() {
        _isPlayingPreview = false;
      });
      return;
    }

    // Synthesize preview temporarily and play
    setState(() {
      _isPlayingPreview = true;
    });

    try {
      final tempPath = await _synthesizeRecordingPath();
      if (tempPath != null) {
        await _previewPlayer.play(DeviceFileSource(tempPath));
      } else {
        setState(() {
          _isPlayingPreview = false;
        });
      }
    } catch (_) {
      setState(() {
        _isPlayingPreview = false;
      });
    }
  }

  Future<String?> _synthesizeRecordingPath() async {
    if (_events.isEmpty) return null;
    final double totalDur = (_events.last.timeMs / 1000.0) + 1.2;
    final double duration = totalDur.clamp(1.0, 15.0);
    final int sampleRate = 22050;
    final int numSamples = (duration * sampleRate).toInt();

    final List<double> mixBuffer = List.filled(numSamples, 0.0);

    for (final event in _events) {
      final double freq = PianoSynth.noteFreqs[event.note]!;
      final int startIdx = (event.timeMs / 1000.0 * sampleRate).toInt();
      final int noteSamples = (1.2 * sampleRate).toInt();

      for (int i = 0; i < noteSamples; i++) {
        final int mixIdx = startIdx + i;
        if (mixIdx >= numSamples) break;
        final double t = i / sampleRate;
        final double sampleVal = sin(2 * pi * freq * t) * exp(-t / 0.38);
        mixBuffer[mixIdx] += sampleVal * 0.40; // scale note to avoid clipping
      }
    }

    // Clip buffer
    for (int i = 0; i < numSamples; i++) {
      if (mixBuffer[i] > 1.0) mixBuffer[i] = 1.0;
      if (mixBuffer[i] < -1.0) mixBuffer[i] = -1.0;
    }

    // Convert to WAV bytes
    final wavBytes = _generateWavFromBuffer(mixBuffer, sampleRate);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/preview_custom_ringtone.wav');
    await file.writeAsBytes(wavBytes);
    return file.path;
  }

  Uint8List _generateWavFromBuffer(List<double> buffer, int sampleRate) {
    final numSamples = buffer.length;
    final numBytes = numSamples * 2;
    final headerSize = 44;
    final wavData = Uint8List(headerSize + numBytes);
    final byteData = ByteData.sublistView(wavData);

    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    
    byteData.setUint32(4, 36 + numBytes, Endian.little);
    
    byteData.setUint8(8, 0x57);  // W
    byteData.setUint8(9, 0x41);  // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E

    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6d); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // ' '
    
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, 1, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);

    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    
    byteData.setUint32(40, numBytes, Endian.little);

    for (int i = 0; i < numSamples; i++) {
      final val = (buffer[i] * 32767).toInt();
      byteData.setInt16(44 + i * 2, val, Endian.little);
    }

    return wavData;
  }

  Future<void> _saveRecording() async {
    final path = await _synthesizeRecordingPath();
    if (path != null) {
      final customFile = File(await sl<SoundService>().getCustomSoundPath());
      await File(path).copy(customFile.path);
      await sl<SoundService>().setSelectedSound('Custom Recording');
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;
    final blush = theme.colorScheme.primaryContainer;

    if (!_isSynthReady) {
      return Dialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primary),
              const SizedBox(height: 20),
              Text(
                'Warming up the piano keys, bestie... 🎀',
                style: AppTypography.body(color: textPrimary).copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: blush.withValues(alpha: isDark ? 0.3 : 0.8), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Piano Recorder 🎹',
                  style: AppTypography.h2(color: textPrimary),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: textHint),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording
                  ? 'Recording... 🔴 [${_elapsedSeconds.toStringAsFixed(1)}s]'
                  : _hasRecordedFile
                      ? 'Recorded successfully! 🎀 Tap Play or Save.'
                      : 'Play piano keys below to record your melody! ✨',
              style: AppTypography.small(color: _isRecording ? Colors.red : textHint).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // ─── Controls ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Record/Stop Button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red.withValues(alpha: 0.15) : primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _isRecording ? Colors.red : primary, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
                        color: _isRecording ? Colors.red : primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                
                if (_hasRecordedFile && !_isRecording) ...[
                  const SizedBox(width: 20),
                  // Play Preview
                  GestureDetector(
                    onTap: _playPreview,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isPlayingPreview ? primary : primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: primary, width: 2),
                      ),
                      child: Icon(
                        _isPlayingPreview ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        color: _isPlayingPreview ? Colors.white : primary,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),
                  // Save Button
                  GestureDetector(
                    onTap: _saveRecording,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.successDark, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 28),

            // ─── Piano Keyboard ───
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: blush.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 272, // 8 white keys * 34px
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White Keys Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildWhiteKey('C5', primary, surface, textPrimary),
                          _buildWhiteKey('D5', primary, surface, textPrimary),
                          _buildWhiteKey('E5', primary, surface, textPrimary),
                          _buildWhiteKey('F5', primary, surface, textPrimary),
                          _buildWhiteKey('G5', primary, surface, textPrimary),
                          _buildWhiteKey('A5', primary, surface, textPrimary),
                          _buildWhiteKey('B5', primary, surface, textPrimary),
                          _buildWhiteKey('C6', primary, surface, textPrimary),
                        ],
                      ),
                      
                      // Black Keys Positioned (Centered on boundaries of white keys)
                      Positioned(left: 34 - 10, top: 0, child: _buildBlackKey('C#5', primary)),
                      Positioned(left: 68 - 10, top: 0, child: _buildBlackKey('D#5', primary)),
                      // Gap between E5 and F5
                      Positioned(left: 136 - 10, top: 0, child: _buildBlackKey('F#5', primary)),
                      Positioned(left: 170 - 10, top: 0, child: _buildBlackKey('G#5', primary)),
                      Positioned(left: 204 - 10, top: 0, child: _buildBlackKey('A#5', primary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteKey(String note, Color primary, Color surface, Color textPrimary) {
    final isActive = _activeNotes.contains(note);
    return Listener(
      onPointerDown: (_) => _handleKeyPress(note),
      onPointerUp: (_) => _handleKeyRelease(note),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: 34,
        height: 134,
        decoration: BoxDecoration(
          color: isActive ? primary.withValues(alpha: 0.25) : surface,
          border: Border.all(color: primary.withValues(alpha: 0.3), width: 1.0),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          boxShadow: isActive ? [] : [
            BoxShadow(
              color: primary.withValues(alpha: 0.08),
              offset: const Offset(0, 3),
              blurRadius: 3,
            )
          ],
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              note,
              style: AppTypography.small(color: textPrimary).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlackKey(String note, Color primary) {
    final isActive = _activeNotes.contains(note);
    return Listener(
      onPointerDown: (_) => _handleKeyPress(note),
      onPointerUp: (_) => _handleKeyRelease(note),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: 20,
        height: 75,
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.black,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
          boxShadow: isActive ? [] : [
            const BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 2),
              blurRadius: 2,
            )
          ],
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              note.substring(0, 2),
              style: AppTypography.small(color: Colors.white).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
