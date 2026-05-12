import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:southern_women_museum/app.dart';
import 'package:southern_women_museum/core/services/api_service.dart';
import 'package:southern_women_museum/core/services/auth_service.dart';
import 'package:southern_women_museum/core/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
          Provider<ApiService>(create: (_) => ApiService()),
          ChangeNotifierProxyProvider<ApiService, AuthService>(
            create: (context) =>
                AuthService(apiService: context.read<ApiService>()),
            update: (_, apiService, previousAuthService) =>
                previousAuthService ?? AuthService(apiService: apiService),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in to continue your journey'), findsOneWidget);
  });
}
