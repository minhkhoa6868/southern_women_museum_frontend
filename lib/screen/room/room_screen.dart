import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:southern_women_museum/core/theme/text_styles.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/floor_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/language_service.dart';
import '../../models/artifact_model.dart';
import '../../models/room_model.dart';
import '../shared/artifact_detail_modal.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.roomCode,
    this.floorLabel,
    this.onBack,
    this.onMoveToRoom,
  });

  final String roomCode;
  final String? floorLabel;
  final VoidCallback? onBack;
  final Function(String roomCode, String floorLabel)? onMoveToRoom;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late Future<_RoomPageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRoom();
  }

  @override
  void didUpdateWidget(RoomScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload room data if roomCode changed
    if (oldWidget.roomCode != widget.roomCode) {
      _future = _loadRoom();
    }
  }

  Future<_RoomPageData> _loadRoom() async {
    debugPrint('RoomScreen._loadRoom -> loading room: ${widget.roomCode}');
    final api = context.read<ApiService>();
    final languageService = context.read<LanguageService>();
    final language = languageService.locale.languageCode;

    final room = await api.getRoomByCode(widget.roomCode, language: language);
    debugPrint('RoomScreen._loadRoom -> got room id: ${room.id}');
    List<Artifact> artifacts = const [];
    try {
      artifacts = await api.getRoomArtifacts(room.id, language: language);
    } catch (e) {
      debugPrint('RoomScreen._loadRoom: primary artifacts fetch failed: $e');
      // Try fallback using room code (some APIs expect filters by code)
      try {
        artifacts = await api.getRoomArtifacts(room.code, language: language);
        debugPrint('RoomScreen._loadRoom: fallback fetch by code succeeded');
      } catch (e2) {
        debugPrint('Unable to load room artifacts (fallback): $e2');
      }
    }
    return _RoomPageData(room: room, artifacts: artifacts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: FutureBuilder<_RoomPageData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _future = _loadRoom();
                  });
                },
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return _ErrorState(
                message: 'Room not found.',
                onRetry: () {
                  setState(() {
                    _future = _loadRoom();
                  });
                },
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoomHeader(
                      roomCode: data.room.code,
                      roomName: data.room.nameEn.isNotEmpty
                          ? data.room.nameEn
                          : data.room.name,
                      floorLabel:
                          widget.floorLabel ??
                          inferFloorLabelFromRoomCode(data.room.code),
                      primary: primary,
                      textColor: textColor,
                      onBack: widget.onBack,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Text(
                        data.room.descriptionEn.isNotEmpty
                            ? data.room.descriptionEn
                            : data.room.description,
                        style: AppTextStyles.p(
                          textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap a dot to view artifact details',
                            style: AppTextStyles.p(
                              textColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _RoomMapPanel(
                        roomCode: data.room.code,
                        roomName: data.room.nameEn.isNotEmpty
                            ? data.room.nameEn
                            : data.room.name,
                        artifacts: data.artifacts,
                        primary: primary,
                        textColor: textColor,
                        onMoveToRoom: widget.onMoveToRoom,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 18, color: primary),
                          const SizedBox(width: 8),
                          Text(
                            'Artifacts in this Room',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data.artifacts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _EmptyArtifacts(textColor: textColor),
                      )
                    else
                      ...data.artifacts.map(
                        (artifact) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _ArtifactCard(
                            artifact: artifact,
                            primary: primary,
                            textColor: textColor,
                            locationLabel: data.room.nameEn.isNotEmpty
                                ? data.room.nameEn
                                : data.room.name,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.roomCode,
    required this.roomName,
    required this.floorLabel,
    required this.primary,
    required this.textColor,
    this.onBack,
  });

  final String roomCode;
  final String roomName;
  final String floorLabel;
  final Color primary;
  final Color textColor;
  final VoidCallback? onBack;

  /// Get room-specific header colors based on room code
  Map<String, Color> _getHeaderColors() {
    // Default for others
    return {'bg': primary.withValues(alpha: 0.1), 'accent': primary};
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getHeaderColors();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
      decoration: BoxDecoration(
        color: colors['bg'],
        border: Border(
          bottom: BorderSide(color: textColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(
            primary: colors['accent']!,
            textColor: textColor,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  floorLabel,
                  style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 24,
                      color: colors['accent'],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$roomName ($roomCode)',
                        style: AppTextStyles.h4(textColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.primary,
    required this.textColor,
    this.onTap,
  });

  final Color primary;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.2),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Icon(Icons.arrow_back_rounded, color: primary, size: 20),
      ),
    );
  }
}

class _RoomMapPanel extends StatelessWidget {
  const _RoomMapPanel({
    required this.roomCode,
    required this.roomName,
    required this.artifacts,
    required this.primary,
    required this.textColor,
    this.onMoveToRoom,
  });

  final String roomCode;
  final String roomName;
  final List<Artifact> artifacts;
  final Color primary;
  final Color textColor;
  final Function(String roomCode, String floorLabel)? onMoveToRoom;

  /// Get room-specific artifact map height
  double _getMapHeight() {
    // Different room types have different map sizes based on design
    if (roomCode.startsWith('R1.')) return 430; // Ảo dãi Gallery (larger)
    if (roomCode == 'R2.1') return 450; // Ceramic Gallery floor 1 (largest)
    if (roomCode == 'R2.2') return 380; // Ceramic Gallery floor 2 (medium)
    if (roomCode == 'R3') return 340; // Weaving Gallery (smaller)
    return 400; // default
  }

  /// Get the adjacent room and direction for the move button
  Map<String, String>? _getAdjacentRoom() {
    // Room navigation mapping
    final adjacentRooms = {
      'R1.1': {
        'code': 'R1.2',
        'floor': FloorLabels.firstFloor,
        'direction': 'right',
      },
      'R1.2': {
        'code': 'R1.1',
        'floor': FloorLabels.firstFloor,
        'direction': 'left',
      },
      'R2.1': {
        'code': 'R2.2',
        'floor': FloorLabels.firstFloor,
        'direction': 'right',
      },
      'R2.2': {
        'code': 'R2.1',
        'floor': FloorLabels.firstFloor,
        'direction': 'left',
      },
      // R3 (Weaving Gallery) does not have adjacent rooms
    };
    return adjacentRooms[roomCode];
  }

  /// Get room-specific button positioning
  Map<String, double> _getButtonPosition(double height) {
    // Room-specific button positions (top and side offsets)
    final positions = {
      'R1.1': {'top': height * 0.15, 'side': 18.0},
      'R1.2': {'top': height * 0.10, 'side': 18.0},
      'R2.1': {'top': height * 0.25, 'side': 18.0},
      'R2.2': {'top': height * 0.72, 'side': 18.0},
    };
    return positions[roomCode] ?? {'top': height * 0.35, 'side': 18.0};
  }

  /// Compute entrance placement depending on room code and canvas size
  Map<String, dynamic> _getEntrancePlacement(double width, double height) {
    // Only show entrance for specific rooms. Other rooms return show:false.
    if (roomCode == 'R1.1') {
      // Right-side vertical label
      return {
        'show': true,
        'right': 8.0,
        'top': height * 0.5,
        'quarterTurns': 1,
      };
    }

    if (roomCode == 'R2.1') {
      // Bottom-center horizontal label
      return {
        'show': true,
        'bottom': 12.0,
        'left': (width * 0.5) - 60.0,
        'quarterTurns': 0,
      };
    }

    if (roomCode == 'R3') {
      // Bottom-center horizontal label for R3
      return {
        'show': true,
        'bottom': 12.0,
        'left': (width * 0.5) - 10.0,
        'quarterTurns': 0,
      };
    }

    return {'show': false};
  }

  void _showArtifactDetails(
    BuildContext context,
    Artifact artifact,
    Color primary,
    Color textColor,
  ) {
    showArtifactDetailModal(
      context: context,
      artifact: artifact,
      primary: primary,
      textColor: textColor,
      locationLabel: roomName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...artifacts]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

    final adjacent = _getAdjacentRoom();
    final isLeftDirection = adjacent?['direction'] == 'left';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: SizedBox(
        height: _getMapHeight(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary, width: 2),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    final buttonPos = _getButtonPosition(height);
                    return Stack(
                      children: [
                        ...sorted.map((artifact) {
                          final x = artifact.positionX.clamp(0.06, 0.94);
                          final y = artifact.positionY.clamp(0.08, 0.92);
                          return Positioned(
                            left: width * x - 17,
                            top: height * y - 17,
                            child: GestureDetector(
                              onTap: () {
                                _showArtifactDetails(
                                  context,
                                  artifact,
                                  primary,
                                  textColor,
                                );
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary.withValues(alpha: 0.3),
                                  border: Border.all(color: primary, width: 2),
                                ),
                                child: Text(
                                  '${artifact.orderNo}',
                                  style: AppTextStyles.p(primary),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (adjacent != null)
                          Positioned(
                            right: isLeftDirection ? null : buttonPos['side'],
                            left: isLeftDirection ? buttonPos['side'] : null,
                            top: buttonPos['top'],
                            child: GestureDetector(
                              onTap: () {
                                debugPrint(
                                  'RoomMapPanel.onTap move -> ${adjacent['code']}',
                                );
                                if (onMoveToRoom != null) {
                                  onMoveToRoom!(
                                    adjacent['code']!,
                                    adjacent['floor']!,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.38),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primary.withValues(alpha: 0.95),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLeftDirection)
                                      Icon(
                                        Icons.west,
                                        color: primary,
                                        size: 16,
                                      ),
                                    if (isLeftDirection)
                                      const SizedBox(width: 8),
                                    Text(
                                      'Move to ${adjacent['code']}',
                                      style: AppTextStyles.p(primary),
                                    ),
                                    if (!isLeftDirection)
                                      const SizedBox(width: 8),
                                    if (!isLeftDirection)
                                      Icon(
                                        Icons.east,
                                        color: primary,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Entrance placement (per-room) — only show for certain rooms
                        () {
                          final placement = _getEntrancePlacement(
                            width,
                            height,
                          );
                          if (!(placement['show'] == true)) {
                            return const SizedBox.shrink();
                          }

                          return Positioned(
                            left: placement.containsKey('left')
                                ? placement['left'] as double
                                : null,
                            right: placement.containsKey('right')
                                ? placement['right'] as double
                                : null,
                            top: placement.containsKey('top')
                                ? placement['top'] as double
                                : null,
                            bottom: placement.containsKey('bottom')
                                ? placement['bottom'] as double
                                : null,
                            child: (placement['quarterTurns'] as int? ?? 0) == 0
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.west,
                                        color: textColor.withValues(alpha: 0.5),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Entrance',
                                        style: AppTextStyles.p(
                                          textColor.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Icon(
                                        Icons.east,
                                        color: textColor.withValues(alpha: 0.5),
                                        size: 18,
                                      ),
                                    ],
                                  )
                                : RotatedBox(
                                    quarterTurns:
                                        placement['quarterTurns'] as int,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.west,
                                          color: textColor.withValues(
                                            alpha: 0.5,
                                          ),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Entrance',
                                          style: AppTextStyles.p(
                                            textColor.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Icon(
                                          Icons.east,
                                          color: textColor.withValues(
                                            alpha: 0.5,
                                          ),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        }(),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Entrance labels are handled inside the LayoutBuilder per-room.
          ],
        ),
      ),
    );
  }
}

class _ArtifactCard extends StatelessWidget {
  const _ArtifactCard({
    required this.artifact,
    required this.primary,
    required this.textColor,
    required this.locationLabel,
  });

  final Artifact artifact;
  final Color primary;
  final Color textColor;
  final String locationLabel;

  void _showArtifactDetails(BuildContext context) {
    showArtifactDetailModal(
      context: context,
      artifact: artifact,
      primary: primary,
      textColor: textColor,
      locationLabel: locationLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showArtifactDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              _ArtifactThumbnail(url: artifact.imgUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ArtifactIndex(
                          index: artifact.orderNo,
                          primary: primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            artifact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h6(textColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artifact.formattedDate.isNotEmpty
                          ? artifact.formattedDate
                          : 'No date available',
                      style: AppTextStyles.p(primary),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtifactThumbnail extends StatelessWidget {
  const _ArtifactThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: Colors.black.withValues(alpha: 0.08),
      child: const Icon(Icons.image_outlined),
    );

    if (url == null || url!.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 62, height: 62, child: fallback),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url!,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            SizedBox(width: 78, height: 78, child: fallback),
      ),
    );
  }
}

class _ArtifactIndex extends StatelessWidget {
  const _ArtifactIndex({required this.index, required this.primary});

  final int index;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.3),
        border: Border.all(color: primary),
      ),
      child: Text('$index', style: AppTextStyles.s1(primary)),
    );
  }
}

class _EmptyArtifacts extends StatelessWidget {
  const _EmptyArtifacts({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.12)),
      ),
      child: Text(
        'No artifacts found for this room.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load room',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _RoomPageData {
  const _RoomPageData({required this.room, required this.artifacts});

  final RoomModel room;
  final List<Artifact> artifacts;
}
