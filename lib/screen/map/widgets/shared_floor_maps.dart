import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/floor_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../router/app_router.dart';

class FirstFloorMap extends StatelessWidget {
  const FirstFloorMap({
    super.key,
    required this.textColor,
    required this.primary,
    required this.accent,
    this.onRoomTap,
  });

  final Color textColor;
  final Color primary;
  final Color accent;
  final void Function(String code, String floorLabel)? onRoomTap;

  @override
  Widget build(BuildContext context) {
    return FloorPlanShared(
      floorLabel: '1F',
      textColor: textColor,
      primary: primary,
      accent: accent,
      rooms: const [
        RoomDataShared(
          label: 'R2.1',
          code: 'R2.1',
          left: 32,
          top: 45,
          width: 100,
          height: 48,
        ),
        RoomDataShared(
          label: 'R2.2',
          code: 'R2.2',
          left: 118,
          top: 60,
          width: 78,
          height: 40,
        ),
        RoomDataShared(
          label: 'R1.1',
          code: 'R1.1',
          left: 163,
          top: 89,
          width: 150,
          height: 70,
        ),
        RoomDataShared(
          label: 'R1.2',
          code: 'R1.2',
          left: 300,
          top: 112,
          width: 82,
          height: 40,
        ),
      ],
      pins: const [
        PinDataShared(left: 125, top: 100, icon: Icons.elevator_rounded),
      ],
      leftStairsLabel: 'stairs\ndown',
      rightStairsLabel: 'stairs down',
      isGF: false,
      onRoomTap: onRoomTap,
    );
  }
}

class GroundFloorMap extends StatelessWidget {
  const GroundFloorMap({
    super.key,
    required this.textColor,
    required this.primary,
    required this.accent,
    this.onRoomTap,
  });

  final Color textColor;
  final Color primary;
  final Color accent;
  final void Function(String code, String floorLabel)? onRoomTap;

  @override
  Widget build(BuildContext context) {
    return FloorPlanShared(
      floorLabel: 'GF',
      textColor: textColor,
      primary: primary,
      accent: accent,
      rooms: const [
        RoomDataShared(
          label: 'R3',
          code: 'R3',
          left: 35,
          top: 45,
          width: 108,
          height: 50,
        ),
        RoomDataShared(
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
        PinDataShared(left: 115, top: 95, icon: Icons.elevator_rounded),
        PinDataShared(left: 150, top: 110, icon: Icons.wc_rounded),
      ],
      leftStairsLabel: 'stairs\nup',
      rightStairsLabel: 'stairs up',
      entranceLabel: 'entrance',
      isGF: true,
      onRoomTap: onRoomTap,
    );
  }
}

class FloorPlanShared extends StatelessWidget {
  const FloorPlanShared({
    super.key,
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
  final List<RoomDataShared> rooms;
  final List<PinDataShared> pins;
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
          Positioned(
            left: 14,
            top: 94,
            child: Transform.rotate(
              angle: math.pi / 18,
              child: isGF
                  ? HallwayStripGFShared(textColor: primary, glow: glow)
                  : HallwayStrip1FShared(textColor: primary, glow: glow),
            ),
          ),
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
          Positioned(
            left: 0,
            top: 45,
            child: Text(
              leftStairsLabel,
              style: AppTextStyles.s1(textColor.withValues(alpha: 0.5)),
            ),
          ),
          Positioned(
            left: isGF ? 320 : 310,
            bottom: isGF ? 60 : 30,
            child: Text(
              rightStairsLabel,
              style: AppTextStyles.s1(textColor.withValues(alpha: 0.5)),
            ),
          ),
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
          ...rooms.map((room) {
            if (room.isInfo) {
              return Positioned(
                left: room.left,
                top: room.top,
                child: InfoDiamondShared(
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
                    onRoomTap!(
                      room.code,
                      isGF ? FloorLabels.groundFloor : FloorLabels.firstFloor,
                    );
                    return;
                  }
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.room, arguments: room.code);
                },
                child: Transform.rotate(
                  angle: -math.pi / 90,
                  child: RoomTileShared(
                    label: room.label,
                    width: room.width,
                    height: room.height,
                    textColor: textColor,
                  ),
                ),
              ),
            );
          }),
          ...pins.map(
            (pin) => Positioned(
              left: pin.left,
              top: pin.top,
              child: PinChipShared(icon: pin.icon, accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class HallwayStripGFShared extends StatelessWidget {
  const HallwayStripGFShared({
    super.key,
    required this.textColor,
    required this.glow,
  });

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

class HallwayStrip1FShared extends StatelessWidget {
  const HallwayStrip1FShared({
    super.key,
    required this.textColor,
    required this.glow,
  });

  final Color textColor;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 120,
      child: Stack(
        children: [
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

class RoomTileShared extends StatelessWidget {
  const RoomTileShared({
    super.key,
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
      painter: RoomPainterShared(textColor),
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

class RoomPainterShared extends CustomPainter {
  RoomPainterShared(this.textColor);

  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

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

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = textColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(path, borderPaint);

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

class InfoDiamondShared extends StatelessWidget {
  const InfoDiamondShared({
    super.key,
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
      painter: InfoDiamondPainterShared(accent),
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

class InfoDiamondPainterShared extends CustomPainter {
  InfoDiamondPainterShared(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

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

    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PinChipShared extends StatelessWidget {
  const PinChipShared({super.key, required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiamondPinPainterShared(accent),
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

class DiamondPinPainterShared extends CustomPainter {
  DiamondPinPainterShared(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path();

    outer.moveTo(size.width / 2, 0);
    outer.lineTo(size.width, size.height / 2);
    outer.lineTo(size.width / 2, size.height);
    outer.lineTo(0, size.height / 2);
    outer.close();

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

    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(outer, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoomDataShared {
  const RoomDataShared({
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

class PinDataShared {
  const PinDataShared({
    required this.left,
    required this.top,
    required this.icon,
  });

  final double left;
  final double top;
  final IconData icon;
}
