import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'router/app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide to Southern Women\'s Museum',
      // Light theme
      theme: LightTheme.theme,

      // Dark theme
      darkTheme: DarkTheme.theme,

      // Dynamic theme mode
      themeMode: _themeMode,

      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: _getInitialRoute(),
    );
  }

  String _getInitialRoute() {
    final authService = context.read<AuthService>();
    return authService.isAuthenticated ? AppRouter.home : AppRouter.login;
  }
}
