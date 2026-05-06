import 'package:flutter/material.dart';

enum ChoiceState { idle, correct, wrong, reveal }

class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final ChoiceState state;
  final VoidCallback onTap;
  final bool disabled;

  Color _bgColor(BuildContext context) {
    switch (state) {
      case ChoiceState.correct:
        return Colors.green.shade100;
      case ChoiceState.wrong:
        return Colors.red.shade100;
      case ChoiceState.reveal:
        return Colors.green.shade50;
      case ChoiceState.idle:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Color _borderColor(BuildContext context) {
    switch (state) {
      case ChoiceState.correct:
        return Colors.green;
      case ChoiceState.wrong:
        return Colors.red;
      case ChoiceState.reveal:
        return Colors.green.shade300;
      case ChoiceState.idle:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData? get _icon {
    switch (state) {
      case ChoiceState.correct:
        return Icons.check_circle_rounded;
      case ChoiceState.wrong:
        return Icons.cancel_rounded;
      case ChoiceState.reveal:
        return Icons.check_circle_outline_rounded;
      case ChoiceState.idle:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _borderColor(context);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgColor(context),
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (_icon != null) ...[
              const SizedBox(width: 8),
              Icon(_icon, color: borderColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
