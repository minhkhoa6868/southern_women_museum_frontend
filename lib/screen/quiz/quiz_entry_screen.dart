import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import 'quiz_screen.dart';

class QuizEntryScreen extends StatefulWidget {
  const QuizEntryScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

  final String roomId;
  final String userId;

  @override
  State<QuizEntryScreen> createState() => _QuizEntryScreenState();
}

class _QuizEntryScreenState extends State<QuizEntryScreen> {
  final QuizService _quizService = QuizService();
  QuizInfo? _quizInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final info = await _quizService.getQuizByRoom(widget.roomId);
      setState(() {
        _quizInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không tìm thấy quiz cho phòng này.';
        _isLoading = false;
      });
    }
  }

  void _startQuiz() {
    if (_quizInfo == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          quizInfo: _quizInfo!,
          userId: widget.userId,
          quizService: _quizService,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quizService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. DYNAMIC THEME DETECTION
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 2. ADAPTABLE COLORS
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primaryLightTheme;
    final textColor = isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;
    final accent = isDark ? AppColors.accentDarkTheme : AppColors.accentLightTheme;
    final surface = isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLightTheme;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor.withValues(alpha: 0.8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiz',
          style: AppTextStyles.h4(primary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: AppTextStyles.p(textColor.withValues(alpha: 0.7)),
                  ),
                )
              : _buildReady(_quizInfo!, primary, textColor, accent, surface),
    );
  }

  Widget _buildReady(
    QuizInfo info,
    Color primary,
    Color textColor,
    Color accent,
    Color surface,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Header icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Icon(Icons.quiz_rounded, size: 44, color: primary),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              info.title,
              style: AppTextStyles.h3(textColor),
              textAlign: TextAlign.center,
            ),

            if (info.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.p(textColor.withValues(alpha: 0.6)).copyWith(height: 1.5),
              ),
            ],

            const SizedBox(height: 36),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: textColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Số câu hỏi',
                    value: '${info.totalQuestions} câu',
                    primary: primary,
                    textColor: textColor,
                    accent: accent,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: textColor.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Thời gian mỗi câu',
                    value: '${info.timeLimit} giây',
                    primary: primary,
                    textColor: textColor,
                    accent: accent,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: textColor.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.star_outline_rounded,
                    label: 'Điểm đạt',
                    value: '${info.passingScore}%',
                    primary: primary,
                    textColor: textColor,
                    accent: accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: Icon(Icons.play_arrow_rounded, color: surface, size: 24),
                label: Text(
                  'Bắt đầu',
                  style: AppTextStyles.s1(surface).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primary,
    required this.textColor,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color primary;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: AppTextStyles.s1(textColor.withValues(alpha: 0.8)),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.h5(accent),
        ),
      ],
    );
  }
}