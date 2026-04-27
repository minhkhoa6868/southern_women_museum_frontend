import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import 'text_styles.dart';

class DarkTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.backgroundDarkTheme,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDarkTheme,
      secondary: AppColors.secondaryDarkTheme,
      surface: AppColors.backgroundDarkTheme,
    ),

    textTheme: TextTheme(
      // Main headings
      displayLarge: AppTextStyles.h1(AppColors.textDarkTheme),
      displayMedium: AppTextStyles.h2(AppColors.textDarkTheme),
      displaySmall: AppTextStyles.h3(AppColors.textDarkTheme),

      // Section titles
      headlineLarge: AppTextStyles.h4(AppColors.textDarkTheme),
      headlineMedium: AppTextStyles.h5(AppColors.textDarkTheme),
      headlineSmall: AppTextStyles.h6(AppColors.textDarkTheme),

      // Paragraphs
      bodyLarge: AppTextStyles.p(AppColors.textDarkTheme),
      bodyMedium: AppTextStyles.s1(AppColors.textDarkTheme),
      bodySmall: AppTextStyles.s2(AppColors.textDarkTheme),
    ),
  );
}