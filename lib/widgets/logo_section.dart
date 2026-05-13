import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 100,
      width: 100,
      // decoration: BoxDecoration(
      //   color: colorScheme.primary.withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/logo_gold.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.museum,
                size: 40,
                color: AppColors.textDarkTheme,
              ),
            );
          },
        ),
      ),
    );
  }
}