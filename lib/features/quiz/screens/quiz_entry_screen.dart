import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildReady(context, _quizInfo!),
    );
  }

  Widget _buildReady(BuildContext context, QuizInfo info) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_rounded, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              info.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (info.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 32),

            // Thông tin quiz
            _InfoRow(
              icon: Icons.help_outline_rounded,
              label: 'Số câu hỏi',
              value: '${info.totalQuestions} câu',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Thời gian mỗi câu',
              value: '${info.timeLimit} giây',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.star_outline_rounded,
              label: 'Điểm đạt',
              value: '${info.passingScore}%',
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Bắt đầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quizService.dispose();
    super.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
