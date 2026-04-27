import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import 'text_styles.dart';

class LightTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.backgroundLightTheme,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLightTheme,
      secondary: AppColors.secondaryLightTheme,
      surface: AppColors.backgroundLightTheme,
    ),

    textTheme: TextTheme(
      // Main headings
      displayLarge: AppTextStyles.h1(AppColors.textLightTheme),
      displayMedium: AppTextStyles.h2(AppColors.textLightTheme),
      displaySmall: AppTextStyles.h3(AppColors.textLightTheme),

      // Section titles
      headlineLarge: AppTextStyles.h4(AppColors.textLightTheme),
      headlineMedium: AppTextStyles.h5(AppColors.textLightTheme),
      headlineSmall: AppTextStyles.h6(AppColors.textLightTheme),

      // Paragraphs
      bodyLarge: AppTextStyles.p(AppColors.textLightTheme),
      bodyMedium: AppTextStyles.s1(AppColors.textLightTheme),
      bodySmall: AppTextStyles.s2(AppColors.textLightTheme),
    ),
  );
}
