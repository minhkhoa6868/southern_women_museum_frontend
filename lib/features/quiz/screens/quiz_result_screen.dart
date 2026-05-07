import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../widgets/quiz_theme.dart';

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
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        backgroundColor: QuizColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kết quả',
          style: TextStyle(color: QuizColors.gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: QuizColors.gold))
          : _error != null
              ? Center(child: Text('Lỗi: $_error', style: const TextStyle(color: QuizColors.cream)))
              : _buildResult(_result!),
    );
  }

  Widget _buildResult(QuizResult result) {
    final passed = result.passed;
    final accentColor = passed ? QuizColors.olive : QuizColors.brown;
    final accentLight = passed ? QuizColors.oliveLight : QuizColors.brownLight;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Trophy / icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: QuizColors.cardDark,
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
              ),
              child: Icon(
                passed ? Icons.emoji_events_rounded : Icons.sentiment_neutral_rounded,
                size: 52,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),

            // Score
            Text(
              '${result.score}%',
              style: TextStyle(
                color: accentLight,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${result.correct}/${result.total} câu đúng',
              style: const TextStyle(color: QuizColors.cream, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Điểm đạt: ${result.passingScore}%',
              style: const TextStyle(color: QuizColors.goldLight, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // Message card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QuizColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.card_giftcard_rounded : Icons.refresh_rounded,
                    color: accentLight,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accentLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: QuizColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: QuizColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Đúng', value: '${result.correct}', color: QuizColors.oliveLight),
                  _Divider(),
                  _StatItem(label: 'Sai', value: '${result.answered - result.correct}', color: QuizColors.brownLight),
                  _Divider(),
                  _StatItem(label: 'Bỏ qua', value: '${result.total - result.answered}', color: QuizColors.goldLight),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuizColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Về trang chủ',
                  style: TextStyle(
                    color: QuizColors.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: QuizColors.goldLight, fontSize: 12)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: QuizColors.border);
  }
}
