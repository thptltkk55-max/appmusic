import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../utils/constants.dart';
import 'rotating_vinyl_art.dart';

class TurntableArt extends StatelessWidget {
  const TurntableArt({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.size,
  });

  final SongModel song;
  final bool isPlaying;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tonearmWidth = size * 0.36;
    final tonearmHeight = size * 0.48;

    return SizedBox(
      width: size + tonearmWidth * 0.34,
      height: size + 12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: RotatingVinylArt(
              song: song,
              isPlaying: isPlaying,
              size: size,
            ),
          ),
          Positioned(
            right: 0,
            top: size * 0.02,
            child: _Tonearm(
              isPlaying: isPlaying,
              width: tonearmWidth,
              height: tonearmHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tonearm extends StatelessWidget {
  const _Tonearm({
    required this.isPlaying,
    required this.width,
    required this.height,
  });

  final bool isPlaying;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: width * 0.34,
            height: width * 0.34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF343434),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: width * 0.14,
                height: width * 0.14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.spotifyGreen,
                ),
              ),
            ),
          ),
          Positioned(
            right: width * 0.12,
            top: width * 0.18,
            child: AnimatedRotation(
              turns: isPlaying ? 0.115 : 0.04,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topRight,
              child: SizedBox(
                width: width * 0.22,
                height: height * 0.82,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: width * 0.045,
                      height: height * 0.66,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE7E7E7),
                            Color(0xFF9A9A9A),
                            Color(0xFFF3F3F3),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 6,
                            offset: Offset(1, 3),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: height * 0.10,
                      child: Transform.rotate(
                        angle: -0.38,
                        child: Container(
                          width: width * 0.18,
                          height: width * 0.085,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDDDDD),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: height * 0.075,
                      child: Container(
                        width: width * 0.035,
                        height: width * 0.09,
                        decoration: const BoxDecoration(
                          color: Color(0xFF101010),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
