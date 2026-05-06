import 'dart:async';
import 'package:flutter/material.dart';

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

  Color get _color {
    if (_remaining > widget.seconds * 0.5) return Colors.green;
    if (_remaining > widget.seconds * 0.25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / widget.seconds;
    return Column(
      children: [
        Text(
          '$_remaining',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _color,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}
