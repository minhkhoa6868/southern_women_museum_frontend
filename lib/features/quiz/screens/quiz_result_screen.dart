import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';

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
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _buildResult(context, _result!),
    );
  }

  Widget _buildResult(BuildContext context, QuizResult result) {
    final passed = result.passed;
    final color = passed ? Colors.green : Colors.orange;
    final icon = passed ? Icons.emoji_events_rounded : Icons.sentiment_neutral_rounded;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 16),

            // Score
            Text(
              '${result.score}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 8),

            // Correct/Total
            Text(
              '${result.correct}/${result.total} câu đúng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Điểm đạt: ${result.passingScore}%',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Message card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                result.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 40),

            // Back button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Về trang chủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
