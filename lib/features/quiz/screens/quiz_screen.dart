import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../widgets/choice_button.dart';
import '../widgets/countdown_timer.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizInfo,
    required this.userId,
    required this.quizService,
  });

  final QuizInfo quizInfo;
  final String userId;
  final QuizService quizService;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _answered = false;

  // key dùng để reset CountdownTimer khi chuyển câu
  int _timerKey = 0;

  // track trạng thái từng choice
  Map<String, ChoiceState> _choiceStates = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions =
          await widget.quizService.getQuestions(widget.quizInfo.id);
      setState(() {
        _questions = questions;
        _isLoading = false;
        _resetChoiceStates();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải câu hỏi: $e')),
        );
      }
    }
  }

  void _resetChoiceStates() {
    if (_questions.isEmpty) return;
    _choiceStates = {
      for (final c in _questions[_currentIndex].choices) c.id: ChoiceState.idle,
    };
    _answered = false;
  }

  /// Người dùng chọn đáp án
  Future<void> _onChoiceTap(String choiceId) async {
    if (_answered || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _answered = true;
    });

    try {
      final result = await widget.quizService.submitAnswer(
        userId: widget.userId,
        questionId: _questions[_currentIndex].id,
        choiceId: choiceId,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        // Đánh dấu đáp án người dùng chọn
        _choiceStates[choiceId] =
            result.isCorrect ? ChoiceState.correct : ChoiceState.wrong;
        // Nếu sai thì highlight đáp án đúng
        if (!result.isCorrect && result.correctChoiceId != null) {
          _choiceStates[result.correctChoiceId!] = ChoiceState.reveal;
        }
      });

      // Chờ 1.2s để user thấy kết quả rồi chuyển câu
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) _nextQuestion();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _answered = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi đáp án: $e')),
      );
    }
  }

  /// Hết giờ — không ghi nhận, chuyển câu tiếp
  void _onTimerExpired() {
    if (_answered) return;
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      _goToResult();
      return;
    }
    setState(() {
      _currentIndex++;
      _timerKey++;
      _resetChoiceStates();
    });
  }

  void _goToResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          quizId: widget.quizInfo.id,
          userId: widget.userId,
          quizService: widget.quizService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có câu hỏi nào.')),
      );
    }

    final question = _questions[_currentIndex];
    final total = _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizInfo.title),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${_currentIndex + 1}/$total',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    '${((_currentIndex) / total * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / total,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer
                    CountdownTimer(
                      key: ValueKey(_timerKey),
                      seconds: widget.quizInfo.timeLimit,
                      onExpired: _onTimerExpired,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.questionText,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Choices
              Expanded(
                child: ListView.separated(
                  itemCount: question.choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final choice = question.choices[i];
                    return ChoiceButton(
                      label: choice.name,
                      state: _choiceStates[choice.id] ?? ChoiceState.idle,
                      disabled: _answered || _isSubmitting,
                      onTap: () => _onChoiceTap(choice.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
