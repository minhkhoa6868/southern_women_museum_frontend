import 'package:flutter/material.dart';
import 'quiz_theme.dart';

enum ChoiceState { idle, correct, wrong, reveal }

class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.label,
    required this.index,
    required this.state,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final int index;           // 0=A, 1=B, 2=C, 3=D
  final ChoiceState state;
  final VoidCallback onTap;
  final bool disabled;

  static const _labels = ['A', 'B', 'C', 'D'];

  Color _bgColor() {
    switch (state) {
      case ChoiceState.correct: return QuizColors.olive.withOpacity(0.25);
      case ChoiceState.wrong:   return QuizColors.brown.withOpacity(0.25);
      case ChoiceState.reveal:  return QuizColors.olive.withOpacity(0.12);
      case ChoiceState.idle:    return QuizColors.cardMedium;
    }
  }

  Color _borderColor() {
    switch (state) {
      case ChoiceState.correct: return QuizColors.olive;
      case ChoiceState.wrong:   return QuizColors.brown;
      case ChoiceState.reveal:  return QuizColors.oliveLight;
      case ChoiceState.idle:    return QuizColors.border;
    }
  }

  Color _badgeBg() {
    switch (state) {
      case ChoiceState.correct: return QuizColors.olive;
      case ChoiceState.wrong:   return QuizColors.brown;
      case ChoiceState.reveal:  return QuizColors.oliveLight;
      case ChoiceState.idle:    return QuizColors.border;
    }
  }

  IconData? get _icon {
    switch (state) {
      case ChoiceState.correct: return Icons.check_rounded;
      case ChoiceState.wrong:   return Icons.close_rounded;
      case ChoiceState.reveal:  return Icons.check_rounded;
      case ChoiceState.idle:    return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = index < _labels.length ? _labels[index] : '?';
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor(),
          border: Border.all(color: _borderColor(), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Badge chữ cái A/B/C/D
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _badgeBg(),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: _icon != null
                  ? Icon(_icon, color: QuizColors.cream, size: 18)
                  : Text(
                      letter,
                      style: const TextStyle(
                        color: QuizColors.cream,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: QuizColors.cream,
                  fontWeight: state == ChoiceState.idle
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
