import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import 'widgets/shared_floor_maps.dart';
import '../../models/artifact_model.dart'; 
import '../shared/artifact_detail_modal.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key, 
    this.artifacts = const [], // Accept list of artifacts
    this.onRoomTap,
  });

  final List<Artifact> artifacts;
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
                  artifacts: artifacts, // Pass artifacts to search bar
                  hintText: 'Search for artifacts...',
                  textColor: textColor,
                  background: primary.withValues(alpha: 0.1),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                  primary: primary,
                  surfaceColor: surface,
                  onRoomSelected: onRoomTap,
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

// ============================================================================
// STATEFUL SEARCH BAR WITH OVERLAY DROPDOWN
// ============================================================================

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.artifacts,
    required this.hintText,
    required this.textColor,
    required this.background,
    required this.border,
    required this.primary,
    required this.surfaceColor,
    this.onRoomSelected,
  });

  final List<Artifact> artifacts;
  final String hintText;
  final Color textColor;
  final Color background;
  final Border border;
  final Color primary;
  final Color surfaceColor;
  final void Function(String code, String floorLabel)? onRoomSelected;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;

  List<Artifact> _filteredArtifacts = [];

  @override
  void initState() {
    super.initState();
    _filteredArtifacts = widget.artifacts;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.artifacts != oldWidget.artifacts) {
      _filterResults(_controller.text);
    }
  }

  void _filterResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArtifacts = widget.artifacts;
      } else {
        _filteredArtifacts = widget.artifacts
            .where((artifact) => artifact.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  // Helper method to determine the floor based on your dummy data logic
  String _getFloorLabel(String roomId) {
    if (roomId.toUpperCase().startsWith('R3')) {
      return 'GROUND FLOOR';
    }
    return '1ST FLOOR';
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8),
          child: Material(
            elevation: 8,
            color: widget.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.textColor.withValues(alpha: 0.15)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: _filteredArtifacts.isEmpty ? 1 : _filteredArtifacts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  color: widget.textColor.withValues(alpha: 0.1)
                ),
                itemBuilder: (context, index) {
                  if (_filteredArtifacts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No artifacts found.', 
                        style: AppTextStyles.p(widget.textColor.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final artifact = _filteredArtifacts[index];
                  final roomDisplay = artifact.roomName ?? artifact.roomId;
                  final floorDisplay = _getFloorLabel(artifact.roomId);

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.history_edu_rounded, color: widget.primary, size: 20),
                    ),
                    title: Text(artifact.name, style: AppTextStyles.s1(widget.textColor)),
                    subtitle: Text(
                      '$roomDisplay • $floorDisplay', 
                      style: AppTextStyles.s2(widget.textColor.withValues(alpha: 0.6))
                    ),
                    onTap: () {
                      // 1. Dismiss the keyboard and overlay
                      _focusNode.unfocus();
                      _controller.clear();
                      
                      // 2. Open the Artifact Detail Modal instead of navigating
                      showArtifactDetailModal(
                        context: context,
                        artifact: artifact,
                        primary: widget.primary,
                        textColor: widget.textColor,
                        locationLabel: '$roomDisplay ($floorDisplay)', 
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: widget.background,
          borderRadius: BorderRadius.circular(10),
          border: widget.border,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: widget.textColor.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _filterResults,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.p(widget.textColor.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
                style: AppTextStyles.p(widget.textColor),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  _filterResults('');
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.close_rounded, color: widget.textColor.withValues(alpha: 0.6), size: 18),
                ),
              ),
          ],
        ),
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