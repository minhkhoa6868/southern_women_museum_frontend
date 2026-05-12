import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';
import 'core/services/language_service.dart';
import 'core/services/theme_service.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LanguageService>(
      builder: (context, themeService, languageService, _) {
        return MaterialApp(
          title: 'Guide to Southern Women\'s Museum',
          theme: LightTheme.theme,
          darkTheme: DarkTheme.theme,
          themeMode: themeService.mode,
          locale: languageService.locale,
          supportedLocales: const [Locale('en'), Locale('vi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: context.read<AuthService>().isAuthenticated
              ? AppRouter.mainLayout
              : AppRouter.login,
        );
      },
    );
  }
}
