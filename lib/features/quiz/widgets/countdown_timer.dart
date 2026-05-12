import 'dart:async';
import 'package:flutter/material.dart';
import 'quiz_theme.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.onExpired,
  });

  final int seconds;
  final VoidCallback onExpired;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimer old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) {
      _timer?.cancel();
      _remaining = widget.seconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _barColor {
    final ratio = _remaining / widget.seconds;
    if (ratio > 0.5) return QuizColors.olive;
    if (ratio > 0.25) return QuizColors.gold;
    return QuizColors.brown;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_remaining / widget.seconds).clamp(0.0, 1.0);
    return Row(
      children: [
        // Icon đồng hồ
        Icon(Icons.timer_outlined, color: _barColor, size: 18),
        const SizedBox(width: 8),
        // Số giây
        SizedBox(
          width: 28,
          child: Text(
            '$_remaining',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _barColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: QuizColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ),
      ],
    );
  }
}
