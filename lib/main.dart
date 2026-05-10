import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthService>(
          create: (_) => AuthService(apiService: ApiService()),
          update: (_, apiService, previousAuthService) =>
              previousAuthService ?? AuthService(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
