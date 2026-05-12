import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import 'widgets/shared_floor_maps.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, this.onRoomTap});

  final void Function(String code, String floorLabel)? onRoomTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;
    Color textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;
    final surface = isDark
        ? AppColors.backgroundDarkTheme
        : AppColors.backgroundLightTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: textColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: primary, size: 28),
                    const SizedBox(width: 10),
                    Text('Museum Map', style: AppTextStyles.h3(textColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a gallery room to explore its artifacts',
                  style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                _SearchBar(
                  hintText: 'Search for artifacts...',
                  textColor: textColor,
                  background: primary.withValues(alpha: 0.1),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '3 rooms total',
                      style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MapCanvas(
                  primary: primary,
                  textColor: primary,
                  surface: surface,
                  isDark: isDark,
                  onRoomTap: onRoomTap,
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hintText,
    required this.textColor,
    required this.background,
    required this.border,
  });

  final String hintText;
  final Color textColor;
  final Color background;
  final Border border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: textColor.withValues(alpha: 0.4)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.p(textColor.withValues(alpha: 0.4)),
                border: InputBorder.none,
              ),
              style: AppTextStyles.p(textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.primary,
    required this.textColor,
    required this.surface,
    required this.isDark,
    this.onRoomTap,
  });

  final Color primary;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final void Function(String code, String floorLabel)? onRoomTap;

  @override
  Widget build(BuildContext context) {
    final accent = isDark
        ? AppColors.accentDarkTheme
        : AppColors.accentLightTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FirstFloorMap(
            textColor: textColor,
            primary: primary,
            accent: accent,
            onRoomTap: onRoomTap,
          ),
          const SizedBox(height: 14),
          _ConnectorDivider(textColor: textColor),
          const SizedBox(height: 14),
          GroundFloorMap(
            textColor: textColor,
            primary: primary,
            accent: accent,
            onRoomTap: onRoomTap,
          ),
        ],
      ),
    );
  }
}

class _ConnectorDivider extends StatelessWidget {
  const _ConnectorDivider({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'STAIRCASE CONNECTION',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor.withValues(alpha: 0.55),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(
              color: textColor.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
