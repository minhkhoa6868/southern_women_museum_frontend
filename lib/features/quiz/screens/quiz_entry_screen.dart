import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../widgets/quiz_theme.dart';
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
      setState(() { _quizInfo = info; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Không tìm thấy quiz cho phòng này.'; _isLoading = false; });
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
    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        backgroundColor: QuizColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: QuizColors.cream),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz',
          style: TextStyle(color: QuizColors.gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: QuizColors.gold))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: QuizColors.cream)))
              : _buildReady(_quizInfo!),
    );
  }

  Widget _buildReady(QuizInfo info) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            // Header icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: QuizColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: QuizColors.gold, width: 1.5),
              ),
              child: const Icon(Icons.quiz_rounded, size: 40, color: QuizColors.gold),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              info.title,
              style: const TextStyle(
                color: QuizColors.cream,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            if (info.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: QuizColors.goldLight, fontSize: 13),
              ),
            ],

            const SizedBox(height: 32),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: QuizColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: QuizColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Số câu hỏi',
                    value: '${info.totalQuestions} câu',
                  ),
                  const Divider(color: QuizColors.border, height: 24),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Thời gian mỗi câu',
                    value: '${info.timeLimit} giây',
                  ),
                  const Divider(color: QuizColors.border, height: 24),
                  _InfoRow(
                    icon: Icons.star_outline_rounded,
                    label: 'Điểm đạt',
                    value: '${info.passingScore}%',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.play_arrow_rounded, color: QuizColors.background),
                label: const Text(
                  'Bắt đầu',
                  style: TextStyle(
                    color: QuizColors.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuizColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: QuizColors.gold),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: QuizColors.cream, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: QuizColors.goldLight,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
