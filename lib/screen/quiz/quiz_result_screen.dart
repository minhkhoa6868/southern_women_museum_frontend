import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_styles.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.quizId,
    required this.userId,
    required this.quizService,
  });

  final String quizId;
  final String userId;
  final QuizService quizService;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  QuizResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final result = await widget.quizService.getResult(
        quizId: widget.quizId,
        userId: widget.userId,
      );
      setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. DYNAMIC THEME DETECTION
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 2. ADAPTABLE COLORS
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primaryLightTheme;
    final textColor = isDark ? AppColors.textDarkTheme : AppColors.textLightTheme;
    final surface = isDark ? AppColors.backgroundDarkTheme : AppColors.backgroundLightTheme;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Kết quả',
          style: AppTextStyles.h4(primary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _error != null
              ? Center(
                  child: Text(
                    'Lỗi: $_error', 
                    style: AppTextStyles.p(textColor),
                  ),
                )
              : _buildResult(_result!, primary, textColor, surface),
    );
  }

  Widget _buildResult(
    QuizResult result,
    Color primary,
    Color textColor,
    Color surface,
  ) {
    final passed = result.passed;
    final accentColor = passed ? AppColors.successColor : AppColors.errorColor;
    final accentLight = passed
        ? AppColors.successColor.withValues(alpha: 0.9)
        : AppColors.errorColor.withValues(alpha: 0.9);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Trophy / icon
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(
                passed ? Icons.emoji_events_rounded : Icons.sentiment_neutral_rounded,
                size: 52,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 24),

            // Score
            Text(
              '${result.score}%',
              style: AppTextStyles.h2(accentLight).copyWith(
                fontSize: 56,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.correct}/${result.total} câu đúng',
              style: AppTextStyles.s1(textColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Điểm đạt: ${result.passingScore}%',
              style: AppTextStyles.s2(textColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),

            // Message card (Tinted with Success/Error color)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.card_giftcard_rounded : Icons.refresh_rounded,
                    color: accentLight,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.p(accentLight).copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: textColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Đúng', 
                    value: '${result.correct}', 
                    color: AppColors.successColor.withValues(alpha: 0.9),
                    textColor: textColor,
                  ),
                  _Divider(textColor: textColor),
                  _StatItem(
                    label: 'Sai', 
                    value: '${result.answered - result.correct}', 
                    color: AppColors.errorColor.withValues(alpha: 0.9),
                    textColor: textColor,
                  ),
                  _Divider(textColor: textColor),
                  _StatItem(
                    label: 'Bỏ qua', 
                    value: '${result.total - result.answered}', 
                    color: textColor.withValues(alpha: 0.6),
                    textColor: textColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Về trang chủ',
                  style: AppTextStyles.s1(surface).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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

// ============================================================================
// RESULT COMPONENT WIDGETS
// ============================================================================

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label, 
    required this.value, 
    required this.color,
    required this.textColor,
  });
  
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value, 
          style: AppTextStyles.h3(color),
        ),
        const SizedBox(height: 6),
        Text(
          label, 
          style: AppTextStyles.s2(textColor.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.textColor});
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, 
      height: 36, 
      color: textColor.withValues(alpha: 0.15),
    );
  }
}