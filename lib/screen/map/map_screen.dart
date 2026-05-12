import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import '../../router/app_router.dart';

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
                    Text('3 rooms total', style: AppTextStyles.p(textColor.withValues(alpha: 0.6))),
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
          _FloorPlan(
            floorLabel: '1F',
            textColor: textColor,
            primary: primary,
            accent: accent,
            rooms: const [
              _RoomData(
                label: 'R2.1',
                code: 'R2.1',
                left: 32,
                top: 45,
                width: 100,
                height: 48,
              ),
              _RoomData(
                label: 'R2.2',
                code: 'R2.2',
                left: 118,
                top: 60,
                width: 78,
                height: 40,
              ),
              _RoomData(
                label: 'R1.1',
                code: 'R1.1',
                left: 163,
                top: 89,
                width: 150,
                height: 70,
              ),
              _RoomData(
                label: 'R1.2',
                code: 'R1.2',
                left: 300,
                top: 112,
                width: 82,
                height: 40,
              ),
            ],
            pins: const [
              _PinData(left: 125, top: 100, icon: Icons.elevator_rounded),
            ],
            leftStairsLabel: 'stairs\ndown',
            rightStairsLabel: 'stairs down',
            isGF: false,
            onRoomTap: onRoomTap,
          ),
          const SizedBox(height: 14),
          _ConnectorDivider(textColor: textColor),
          const SizedBox(height: 14),
          _FloorPlan(
            floorLabel: 'GF',
            textColor: textColor,
            primary: primary,
            accent: accent,
            rooms: const [
              _RoomData(
                label: 'R3',
                code: 'R3',
                left: 35,
                top: 45,
                width: 108,
                height: 50,
              ),
              _RoomData(
                label: '',
                code: '',
                left: 245,
                top: 175,
                width: 100,
                height: 51,
                isInfo: true,
              ),
            ],
            pins: const [
              _PinData(left: 115, top: 95, icon: Icons.elevator_rounded),
              _PinData(left: 150, top: 110, icon: Icons.wc_rounded),
            ],
            leftStairsLabel: 'stairs\nup',
            rightStairsLabel: 'stairs up',
            entranceLabel: 'entrance',
            isGF: true,
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

class _FloorPlan extends StatelessWidget {
  const _FloorPlan({
    required this.floorLabel,
    required this.textColor,
    required this.primary,
    required this.accent,
    required this.rooms,
    required this.pins,
    required this.leftStairsLabel,
    required this.rightStairsLabel,
    this.entranceLabel,
    required this.isGF,
    this.onRoomTap,
  });

  final String floorLabel;
  final Color textColor;
  final Color primary;
  final Color accent;
  final List<_RoomData> rooms;
  final List<_PinData> pins;
  final String leftStairsLabel;
  final String rightStairsLabel;
  final String? entranceLabel;
  final bool isGF;
  final void Function(String code, String floorLabel)? onRoomTap;

  @override
  Widget build(BuildContext context) {
    final glow = primary.withValues(alpha: 0.11);

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hallway strip (diagonal)
          Positioned(
            left: 14,
            top: 94,
            child: Transform.rotate(
              angle: math.pi / 18,
              child: isGF
                  ? _HallwayStripGF(textColor: primary, glow: glow)
                  : _HallwayStrip1F(textColor: primary, glow: glow),
            ),
          ),
          // Floor label — top-right
          Positioned(
            right: 10,
            top: 2,
            child: Text(
              floorLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // Left stairs label
          Positioned(
            left: 0,
            top: 45,
            child: Text(
              leftStairsLabel,
              style: AppTextStyles.s1(textColor.withValues(alpha: 0.5)),
            ),
          ),
          // Right stairs label
          Positioned(
            left: isGF ? 320 : 310,
            bottom: isGF ? 60 : 30,
            child: Text(
              rightStairsLabel,
              style: AppTextStyles.s1(textColor.withValues(alpha: 0.5)),
            ),
          ),
          // Arrow pointing to stairs (left)
          Positioned(
            left: 5,
            top: 75,
            child: Transform.rotate(
              angle: -2.7,
              child: Icon(
                Icons.east,
                size: 18,
                color: textColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Arrow pointing to stairs (right)
          Positioned(
            left: isGF ? 300 : 295,
            bottom: isGF ? 55 : 45,
            child: Transform.rotate(
              angle: -30.9,
              child: Icon(
                Icons.east,
                size: 18,
                color: textColor.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Entrance label (GF only)
          if (entranceLabel != null)
            Positioned(
              left: 180,
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entranceLabel!,
                    style: AppTextStyles.s1(textColor.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          if (isGF)
            Positioned(
              left: 200,
              bottom: 15,
              child: Transform.rotate(
                angle: 24.6,
                child: Icon(
                  Icons.east,
                  size: 18,
                  color: textColor.withValues(alpha: 0.45),
                ),
              ),
            ),

          // Rooms
          ...rooms.map((room) {
            if (room.isInfo) {
              return Positioned(
                left: room.left,
                top: room.top,
                child: _InfoDiamond(
                  width: room.width,
                  height: room.height,
                  accent: accent,
                ),
              );
            }
            return Positioned(
              left: room.left,
              top: room.top,
              child: GestureDetector(
                onTap: () {
                  if (room.code.isEmpty || room.isInfo) return;
                  if (onRoomTap != null) {
                    onRoomTap!(room.code, isGF ? 'GROUND FLOOR' : '1ST FLOOR');
                    return;
                  }
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.room, arguments: room.code);
                },
                child: Transform.rotate(
                  angle: -math.pi / 90,
                  child: _RoomTile(
                    label: room.label,
                    width: room.width,
                    height: room.height,
                    textColor: textColor,
                  ),
                ),
              ),
            );
          }),
          // Pins
          ...pins.map(
            (pin) => Positioned(
              left: pin.left,
              top: pin.top,
              child: _PinChip(icon: pin.icon, accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _HallwayStripGF extends StatelessWidget {
  const _HallwayStripGF({required this.textColor, required this.glow});

  final Color textColor;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hallway text
          Positioned(
            left: 95,
            bottom: 55,
            child: Transform.rotate(
              angle: 0.23,
              child: Text(
                'HALLWAY',
                style: AppTextStyles.h6(textColor.withValues(alpha: 0.5)),
              ),
            ),
          ),

          // Decorative edge line left
          Positioned(
            left: 0,
            bottom: 60,
            child: Transform.rotate(
              angle: 0.23,
              child: Container(
                width: 205,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 74,
            bottom: 73,
            child: Transform.rotate(
              angle: 2.5,
              child: Container(
                width: 65,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Decorative edge line right
          Positioned(
            left: 1,
            top: 39,
            child: Transform.rotate(
              angle: 0.23,
              child: Container(
                width: 230,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 70,
            bottom: 40,
            child: Transform.rotate(
              angle: 2.5,
              child: Container(
                width: 80,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 155,
            bottom: 31,
            child: Transform.rotate(
              angle: 2.5,
              child: Container(
                width: 20,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HallwayStrip1F extends StatelessWidget {
  const _HallwayStrip1F({required this.textColor, required this.glow});

  final Color textColor;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 120,
      child: Stack(
        // alignment: Alignment.center,
        children: [
          // Hallway text
          Positioned(
            left: 95,
            bottom: 55,
            child: Transform.rotate(
              angle: 0.23,
              child: Text(
                'HALLWAY',
                style: AppTextStyles.h6(textColor.withValues(alpha: 0.5)),
              ),
            ),
          ),

          // Decorative edge line left
          Positioned(
            left: 0,
            bottom: 55,
            child: Transform.rotate(
              angle: 0.23,
              child: Container(
                width: 240,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 74,
            bottom: 73,
            child: Transform.rotate(
              angle: 2.5,
              child: Container(
                width: 65,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Decorative edge line right
          Positioned(
            left: 1,
            top: 39,
            child: Transform.rotate(
              angle: 0.23,
              child: Container(
                width: 230,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 78,
            bottom: 43,
            child: Transform.rotate(
              angle: 2.5,
              child: Container(
                width: 50,
                height: 1.5,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.label,
    required this.width,
    required this.height,
    required this.textColor,
  });

  final String label;
  final double width;
  final double height;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RoomPainter(textColor),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.p(textColor.withValues(alpha: 0.9)),
          ),
        ),
      ),
    );
  }
}

class _RoomPainter extends CustomPainter {
  final Color textColor;

  _RoomPainter(this.textColor);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Diamond shape
    path.moveTo(size.width / 2, 0); // top
    path.lineTo(size.width, size.height / 2); // right
    path.lineTo(size.width / 2, size.height); // bottom
    path.lineTo(0, size.height / 2); // left
    path.close();

    // Gradient fill
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          textColor.withValues(alpha: 0.20),
          textColor.withValues(alpha: 0.08),
        ],
      ).createShader(rect);

    // Fill
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = textColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(path, borderPaint);

    // Bottom edge highlight
    final bottomLine = Paint()
      ..color = textColor.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width, size.height / 2),
      bottomLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoDiamond extends StatelessWidget {
  const _InfoDiamond({
    required this.width,
    required this.height,
    required this.accent,
  });

  final double width;
  final double height;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InfoDiamondPainter(accent),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.8),
                width: 1.4,
              ),
              color: accent.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.info_rounded,
              size: 14,
              color: accent.withValues(alpha: 0.92),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoDiamondPainter extends CustomPainter {
  final Color accent;

  _InfoDiamondPainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Diamond shape
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.22),
          accent.withValues(alpha: 0.08),
        ],
      ).createShader(rect);

    canvas.drawPath(path, fillPaint);

    // Outer border
    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PinChip extends StatelessWidget {
  const _PinChip({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiamondPinPainter(accent),
      child: SizedBox(
        width: 54,
        height: 24,
        child: Center(
          child: Icon(icon, size: 18, color: accent.withValues(alpha: 0.9)),
        ),
      ),
    );
  }
}

class _DiamondPinPainter extends CustomPainter {
  final Color accent;

  _DiamondPinPainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path();

    // Main diamond
    outer.moveTo(size.width / 2, 0);
    outer.lineTo(size.width, size.height / 2);
    outer.lineTo(size.width / 2, size.height);
    outer.lineTo(0, size.height / 2);
    outer.close();

    // Fill
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.08),
        ],
      ).createShader(rect);

    canvas.drawPath(outer, fillPaint);

    // Outer border
    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(outer, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoomData {
  const _RoomData({
    required this.label,
    required this.code,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.isInfo = false,
  });

  final String label;
  final String code;
  final double left;
  final double top;
  final double width;
  final double height;
  final bool isInfo;
}

class _PinData {
  const _PinData({required this.left, required this.top, required this.icon});

  final double left;
  final double top;
  final IconData icon;
}
