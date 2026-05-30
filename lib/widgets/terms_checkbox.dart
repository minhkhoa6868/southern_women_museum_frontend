import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final textColor = textTheme.bodyLarge?.color ?? Colors.black;
    
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
          side: BorderSide(color: textColor.withValues(alpha: 0.5)),
        ),
        Expanded(
          child: Text(
            'I agree to the terms and conditions',
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}