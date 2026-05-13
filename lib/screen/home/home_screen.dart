import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:southern_women_museum/core/theme/text_styles.dart';
import '../../core/constants/color_constants.dart';
import '../../core/services/api_service.dart';
import '../../models/event_model.dart';
import '../../models/artifact_model.dart';
import '../shared/artifact_detail_modal.dart';

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
  List<Artifact> _artifacts = [];
  bool _isLoadingArtifacts = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadEvents();
      _loadRandomArtifacts();
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoadingEvents = true);
    try {
      // Use the singleton ApiService from Provider — it already carries the auth token.
      final events = await context.read<ApiService>().getActiveEvents();
      if (mounted) setState(() => _events = events);
    } catch (e) {
      debugPrint('[HomeScreen] Failed to load events: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _loadRandomArtifacts() async {
    setState(() => _isLoadingArtifacts = true);
    try {
      final artifacts = await context.read<ApiService>().getRandomArtifacts();
      if (mounted) setState(() => _artifacts = artifacts);
    } catch (_) {
      // ignore errors
    } finally {
      if (mounted) setState(() => _isLoadingArtifacts = false);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;
    Color textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 14),
                _MuseumInfoCard(primary: primary, textColor: textColor),
                const SizedBox(height: 14),
                _NewsSection(events: _events, isLoading: _isLoadingEvents),
                const SizedBox(height: 8),
                _ArtifactsSection(
                  artifacts: _artifacts,
                  isLoading: _isLoadingArtifacts,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtifactsSection extends StatelessWidget {
  const _ArtifactsSection({required this.artifacts, required this.isLoading});

  final List<Artifact> artifacts;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;
    final textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: primary, size: 17),
            const SizedBox(width: 7),
            Text('Key Features', style: AppTextStyles.h6(textColor)),
          ],
        ),

        const SizedBox(height: 10),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (artifacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No artifacts',
                style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
              ),
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final artifact = artifacts[index];
                return GestureDetector(
                  onTap: () => showArtifactDetailModal(
                    context: context,
                    artifact: artifact,
                    primary: primary,
                    textColor: textColor,
                    locationLabel: artifact.roomName ?? 'Ao Dai Gallery',
                  ),
                  child: Container(
                    width: 190,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: SizedBox(
                            height: 170,
                            width: double.infinity,
                            child:
                                (artifact.presignedImgUrl != null &&
                                        artifact.presignedImgUrl!.isNotEmpty) ||
                                    (artifact.imgUrl != null &&
                                        artifact.imgUrl!.isNotEmpty)
                                ? Image.network(
                                    artifact.presignedImgUrl ??
                                        artifact.imgUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: const Color(0xFF1E1710),
                                            ),
                                  )
                                : Container(color: const Color(0xFF1E1710)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                artifact.name,
                                style: AppTextStyles.p(textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                artifact.formattedDate.isNotEmpty
                                    ? artifact.formattedDate
                                    : '',
                                style: AppTextStyles.s1(primary),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      artifact.roomName ?? '',
                                      style: AppTextStyles.s1(
                                        textColor.withValues(alpha: 0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemCount: artifacts.length,
            ),
          ),
      ],
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
              errorBuilder: (context, error, stackTrace) =>
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
                          Icon(
                            Icons.star_rate_rounded,
                            size: 12,
                            color: primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'GUIDE TO SOUTHERN WOMEN\'S MUSEUM',
                            style: TextStyle(
                              color: AppColors.whiteColor.withValues(alpha: 0.88),
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
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatItem(
              icon: Icons.people_alt_outlined,
              value: '500',
              label: 'Visitors today',
            ),
            _Divider(),
            _StatItem(
              icon: Icons.grid_view_rounded,
              value: '3',
              label: 'Galleries Open',
            ),
            _Divider(),
            _StatItem(
              icon: Icons.access_time_rounded,
              value: '7:30AM - 5PM',
              label: 'Opening Hours',
            ),
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
  const _MuseumInfoCard({required this.primary, required this.textColor});

  final Color primary;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
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
                style: AppTextStyles.h5(primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Located at 202 Vo Thi Sau, District 3, Ho Chi Minh City, the museum '
            'was founded on April 29, 1985, growing from the Southern Women\'s '
            'Traditional House — built to preserve Vietnamese women\'s patriotic '
            'spirit and cultural traditions.',
            style: AppTextStyles.p(textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Its origins began in 1983, when 13 veteran female cadres, led by Ms. '
            'Nguyen Thi Thap (former President of the Vietnam Women\'s Union), '
            'established the Southern Women\'s History Research Group to document '
            'the history of Southern women\'s movement.',
            style: AppTextStyles.p(textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Today, it remains a cherished destination for both local and '
            'international visitors.',
            style: AppTextStyles.p(textColor),
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
    final primary = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;
    final textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;

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
                Text('Events & News', style: AppTextStyles.h6(textColor)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLoading
                    ? '…'
                    : '${events.length > 2 ? 2 : events.length} active',
                style: AppTextStyles.p(primary),
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
                'No events available',
                style: AppTextStyles.p(textColor.withValues(alpha: 0.6)),
              ),
            ),
          )
        else
          ...List.generate(
            events.length > 2 ? 2 : events.length,
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
    final textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 52,
            height: 52,
            child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(),
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
            'Southern Women\'s Museum · ${event.formattedDate}',
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
        onTap: () => _showEventDetail(context),
      ),
    );
  }

  void _showEventDetail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.primaryDarkTheme
        : AppColors.primaryLightTheme;
    final textColor = isDark
        ? AppColors.textDarkTheme
        : AppColors.textLightTheme;
    final surface = Theme.of(context).colorScheme.surface;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: surface,
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Image
                  if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        event.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E1710),
                          child: const Icon(
                            Icons.article_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.newspaper_rounded,
                        color: primary.withValues(alpha: 0.4),
                        size: 48,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.status.toUpperCase(),
                            style: TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(event.title, style: AppTextStyles.h5(textColor)),
                        const SizedBox(height: 8),

                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.formattedDate,
                              style: AppTextStyles.p(
                                textColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Divider(
                          color: textColor.withValues(alpha: 0.1),
                          height: 1,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          event.description,
                          style: AppTextStyles.p(textColor),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF1E1710),
    child: const Icon(Icons.article_outlined, color: Colors.grey, size: 22),
  );
}
