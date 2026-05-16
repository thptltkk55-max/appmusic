import 'package:flutter/material.dart';

import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeDuration = duration.inMilliseconds <= 0 ? const Duration(milliseconds: 1) : duration;
    final safePosition = position > safeDuration ? safeDuration : position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          child: Slider(
            value: safePosition.inMilliseconds.toDouble(),
            min: 0,
            max: safeDuration.inMilliseconds.toDouble(),
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) => onChanged(Duration(milliseconds: value.round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(position), style: Theme.of(context).textTheme.labelSmall),
              Text(formatDuration(duration), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}
