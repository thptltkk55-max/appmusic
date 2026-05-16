import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../models/song_model.dart';
import '../utils/constants.dart';

class RotatingVinylArt extends StatefulWidget {
  const RotatingVinylArt({
    super.key,
    required this.song,
    required this.isPlaying,
    this.size = 280,
  });

  final SongModel song;
  final bool isPlaying;
  final double size;

  @override
  State<RotatingVinylArt> createState() => _RotatingVinylArtState();
}

class _RotatingVinylArtState extends State<RotatingVinylArt> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant RotatingVinylArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _controller.value = 0;
    }
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: RotationTransition(
          turns: _controller,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _FullDiscArtwork(
                    song: widget.song,
                    size: widget.size,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.58),
                          ],
                          stops: const [0.36, 0.68, 1],
                        ),
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: Size.square(widget.size),
                    painter: _VinylGroovePainter(),
                  ),
                  Container(
                    width: widget.size * 0.095,
                    height: widget.size * 0.095,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF050505),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullDiscArtwork extends StatelessWidget {
  const _FullDiscArtwork({
    required this.song,
    required this.size,
  });

  final SongModel song;
  final double size;

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(song.id);
    if (numericId == null) {
      return _DefaultDiscArtwork(size: size);
    }

    return SizedBox.square(
      dimension: size,
      child: audio_query.QueryArtworkWidget(
        key: ValueKey('vinyl-full-artwork-${song.id}'),
        id: numericId,
        type: audio_query.ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkWidth: size,
        artworkHeight: size,
        artworkBorder: BorderRadius.circular(size / 2),
        keepOldArtwork: true,
        nullArtworkWidget: _DefaultDiscArtwork(size: size),
      ),
    );
  }
}

class _DefaultDiscArtwork extends StatelessWidget {
  const _DefaultDiscArtwork({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF3A3A3A),
            Color(0xFF101010),
            Color(0xFF050505),
          ],
          stops: [0.08, 0.45, 1],
        ),
      ),
      child: Icon(
        Icons.music_note,
        size: size * 0.24,
        color: AppConstants.spotifyGreen,
      ),
    );
  }
}

class _VinylGroovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.10);
    final darkGroovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.16);
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.12);

    for (var r = radius * 0.16; r < radius * 0.94; r += radius * 0.06) {
      canvas.drawCircle(center, r, groovePaint);
      canvas.drawCircle(center, r + 2, darkGroovePaint);
    }

    final rect = Rect.fromCircle(center: center, radius: radius * 0.78);
    canvas.drawArc(rect, -math.pi * 0.18, math.pi * 0.42, false, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _VinylGroovePainter oldDelegate) => false;
}
