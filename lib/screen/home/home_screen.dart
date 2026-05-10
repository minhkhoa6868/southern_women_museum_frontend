import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color_constants.dart';
import '../../core/services/api_service.dart';
import '../../models/event_model.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String? userAvatar;

  const HomeScreen({super.key, required this.userName, this.userAvatar});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _events = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);
    try {
      final events = await ApiService().getEvents();
      if (mounted) setState(() => _events = events);
    } catch (_) {
      // keep empty list on error
    } finally {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() =>
      DateFormat('EEEE, MMMM d').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(
            userName: widget.userName,
            greeting: _getGreeting(),
            date: _getFormattedDate(),
          ),
          const SizedBox(height: 14),
          _MuseumInfoCard(),
          const SizedBox(height: 14),
          _NewsSection(
            events: _events,
            isLoading: _isLoadingEvents,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Hero card ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.userName,
    required this.greeting,
    required this.date,
  });

  final String userName;
  final String greeting;
  final String date;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Museum photo
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Image.asset(
              'assets/images/congbaotang.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: AppColors.backgroundDarkTheme),
            ),
          ),

          // Dark gradient overlay
          Container(
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [
                  Color(0x88000000),
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),

          // Foreground content
          SizedBox(
            height: 230,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_rate_rounded,
                              size: 12, color: primary),
                          const SizedBox(width: 5),
                          Text(
                            'GUIDE TO SOUTHERN WOMEN\'S MUSEUM',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 9.5,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35)),
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Date
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Greeting + name
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$greeting, ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: userName,
                          style: TextStyle(
                            color: primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats row
                  _StatsRow(accent: primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
                icon: Icons.people_alt_outlined, value: '500', label: 'Visitors today'),
            _Divider(),
            _StatItem(
                icon: Icons.grid_view_rounded, value: '3', label: 'Galleries Open'),
            _Divider(),
            _StatItem(
                icon: Icons.access_time_rounded,
                value: '7:30AM - 5PM',
                label: 'Opening Hours'),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.65), size: 15),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

// ─── Museum info card ─────────────────────────────────────────────────────────

class _MuseumInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.primaryDarkTheme : AppColors.primaryLightTheme;
    final textColor =
        isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;
    final cardColor =
        isDark ? const Color(0xFF1E1710) : AppColors.backgroundLightTheme;
    final borderColor = primary.withValues(alpha: 0.15);

    const bodyStyle = TextStyle(fontSize: 13, height: 1.6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(Icons.account_balance_rounded, color: primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Southern Women\'s Museum',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Located at 202 Vo Thi Sau, District 3, Ho Chi Minh City, the museum '
            'was founded on April 29, 1985, growing from the Southern Women\'s '
            'Traditional House — built to preserve Vietnamese women\'s patriotic '
            'spirit and cultural traditions.',
            style: bodyStyle.copyWith(
                color: textColor.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 8),
          Text(
            'Its origins began in 1983, when 13 veteran female cadres, led by Ms. '
            'Nguyen Thi Thap (former President of the Vietnam Women\'s Union), '
            'established the Southern Women\'s History Research Group to document '
            'the history of Southern women\'s movement.',
            style: bodyStyle.copyWith(
                color: textColor.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 8),
          Text(
            'Today, it remains a cherished destination for both local and '
            'international visitors.',
            style: bodyStyle.copyWith(
                color: textColor.withValues(alpha: 0.72)),
          ),
        ],
      ),
    );
  }
}

// ─── News section ─────────────────────────────────────────────────────────────

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.events, required this.isLoading});

  final List<Event> events;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.primaryDarkTheme : AppColors.primaryLightTheme;
    final textColor =
        isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.newspaper_rounded, color: primary, size: 17),
                const SizedBox(width: 7),
                Text(
                  'News',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLoading ? '…' : '${events.length} news',
                style: TextStyle(
                  color: primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No news available',
                style: TextStyle(color: textColor.withValues(alpha: 0.45)),
              ),
            ),
          )
        else
          ...List.generate(
            events.length > 5 ? 5 : events.length,
            (i) => _NewsItem(event: events[i]),
          ),
      ],
    );
  }
}

class _NewsItem extends StatelessWidget {
  const _NewsItem({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;
    final cardColor = isDark ? const Color(0xFF1E1710) : Colors.white;
    final borderColor = isDark
        ? AppColors.primaryDarkTheme.withValues(alpha: 0.12)
        : Colors.grey.withValues(alpha: 0.15);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 52,
            height: 52,
            child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Southern Women\'s Museum · ${event.date}',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.45),
              fontSize: 11.5,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: textColor.withValues(alpha: 0.35),
          size: 20,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E1710),
        child: const Icon(Icons.article_outlined,
            color: Colors.grey, size: 22),
      );
}
