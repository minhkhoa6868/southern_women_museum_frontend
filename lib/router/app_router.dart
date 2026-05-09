import 'package:flutter/material.dart';

import '../screen/auth/login_screen.dart';
import '../screen/auth/signup_screen.dart';
import '../screen/home/home_screen.dart';
import '../screen/layout/layout_screen.dart';
import '../screen/map/map_screen.dart';
import '../screen/profile/profile_screen.dart';
import '../screen/tour/tour_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mainLayout = '/';
  static const String home = '/home';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String tours = '/tours';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case mainLayout:
        return MaterialPageRoute(builder: (_) => const LayoutScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case map:
        return MaterialPageRoute(builder: (_) => const MapScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case tours:
        return MaterialPageRoute(builder: (_) => const TourScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
