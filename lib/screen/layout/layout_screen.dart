import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/color_constants.dart';
import '../../core/services/auth_service.dart';
import '../../router/app_router.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../tour/tour_screen.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? AppRouter.home;
  }

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(label: 'Home', icon: Icons.home_rounded, route: AppRouter.home),
    _NavItem(label: 'Map', icon: Icons.map_rounded, route: AppRouter.map),
    _NavItem(
      label: 'Tour',
      icon: Icons.explore_rounded,
      route: AppRouter.tours,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_rounded,
      route: AppRouter.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Container(
        color: isDark
            ? AppColors.backgroundDarkTheme
            : AppColors.backgroundLightTheme,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<String>(_currentRoute),
                      child: _buildPageWidget(_currentRoute),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
        child: _GlassNavigationBar(
          items: _items,
          selectedIndex: _getSelectedIndex(_currentRoute),
          onTap: (String routeName) {
            _onNavTap(routeName);
          },
        ),
      ),
    );
  }

  Widget _buildPageWidget(String routeName) {
    switch (routeName) {
      case AppRouter.map:
        return const MapScreen();
      case AppRouter.tours:
        return const TourScreen();
      case AppRouter.profile:
        return ProfileScreen();
      case AppRouter.home:
      default:
        final user = context.read<AuthService>().currentUser;
        final name = user != null
            ? '${user.firstName} ${user.lastName}'.trim()
            : 'Guest';
        return HomeScreen(userName: name);
    }
  }

  int _getSelectedIndex(String routeName) {
    return _items.indexWhere((item) => item.route == routeName);
  }

  void _onNavTap(String routeName) {
    if (_currentRoute != routeName) {
      setState(() {
        _currentRoute = routeName;
      });
    }
  }
}

class _GlassNavigationBar extends StatelessWidget {
  const _GlassNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color selectedColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;
    final Color unselectedColor = isDark
        ? AppColors.textDarkTheme.withValues(alpha: 0.62)
        : AppColors.textLightTheme.withValues(alpha: 0.58);
    final Color borderColor = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.30)
        : AppColors.secondaryLightTheme.withValues(alpha: 0.70);
    final Color barColor = isDark
        ? AppColors.backgroundDarkTheme.withValues(alpha: 0.96)
        : AppColors.backgroundLightTheme.withValues(alpha: 0.98);
    final Color shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.38)
        : AppColors.primaryLightTheme.withValues(alpha: 0.16);

    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),

            // Outer glass border
            border: Border.all(color: borderColor, width: 1.4),
            color: barColor,

            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadowColor,
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 14),
              ),
            ],
          ),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              color: isDark
                  ? AppColors.backgroundDarkTheme.withValues(alpha: 0.40)
                  : AppColors.backgroundLightTheme.withValues(alpha: 0.35),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              child: Row(
                children: List<Widget>.generate(items.length, (int index) {
                  final bool isSelected = index == selectedIndex;
                  final _NavItem item = items[index];

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => onTap(item.route),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 6,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 34,
                              color: isSelected
                                  ? selectedColor
                                  : unselectedColor,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
