import 'package:flutter/material.dart';

import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'screen/layout/layout_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // Light theme
      theme: LightTheme.theme,

      // Dark theme
      darkTheme: DarkTheme.theme,

      // Dynamic theme mode
      themeMode: _themeMode,

      home: LayoutScreen(onThemeToggle: _toggleTheme),
    );
  }
}
