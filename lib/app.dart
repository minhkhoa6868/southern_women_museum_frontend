import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: 'Guide to Southern Women\'s Museum',
          theme: LightTheme.theme,
          darkTheme: DarkTheme.theme,
          themeMode: themeService.mode,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: context.read<AuthService>().isAuthenticated
              ? AppRouter.mainLayout
              : AppRouter.login,
        );
      },
    );
  }
}
