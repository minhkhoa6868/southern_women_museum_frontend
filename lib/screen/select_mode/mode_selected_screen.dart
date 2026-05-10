import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(String mode) => Navigator.of(context).pop(mode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkTheme,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Museum photo background
          Image.asset(
            'assets/images/congbaotang.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(color: AppColors.backgroundDarkTheme),
          ),

          // Gradient overlay — dark at bottom for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 1.0],
                colors: [
                  Color(0xBB140F0B),
                  Color(0xCC140F0B),
                  Color(0xF5140F0B),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Top label
                      Row(
                        children: [
                          Icon(
                            Icons.star_rate_rounded,
                            size: 13,
                            color: AppColors.primaryDarkTheme,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GUIDE TO SOUTHERN WOMEN\'S MUSEUM',
                            style: TextStyle(
                              color: AppColors.primaryDarkTheme,
                              fontSize: 11,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Main heading
                      Text(
                        'Choose your\njourney',
                        style: TextStyle(
                          color: AppColors.textDarkTheme,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explore the Southern Women\'s Museum\nyour own way.',
                        style: TextStyle(
                          color: AppColors.textDarkTheme.withValues(alpha: 0.55),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // Traditional card
                      _ModeCard(
                        badge: 'TRADITIONAL',
                        title: 'Explore\nMap',
                        description:
                            'Follow the history and exhibits through the guided museum map.',
                        icon: Icons.map_outlined,
                        accentColor: AppColors.primaryDarkTheme,
                        onTap: () => _select('traditional'),
                      ),

                      const SizedBox(height: 14),

                      // Adventure card
                      _ModeCard(
                        badge: 'ADVENTURE',
                        title: 'Discovery\nJourney',
                        description:
                            'Complete challenges to unlock hidden secrets.',
                        icon: Icons.explore_rounded,
                        accentColor: AppColors.accentDarkTheme,
                        onTap: () => _select('adventure'),
                      ),

                      const SizedBox(height: 32),

                      // Footer hint
                      Center(
                        child: Text(
                          'You can switch modes at any time',
                          style: TextStyle(
                            color: AppColors.textDarkTheme.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.badge,
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.textDarkTheme,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: AppColors.textDarkTheme.withValues(alpha: 0.5),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Right: icon circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}