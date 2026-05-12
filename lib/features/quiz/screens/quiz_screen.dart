import 'package:flutter/material.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../widgets/choice_button.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/quiz_theme.dart';
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
  int _timerKey = 0;
  Map<String, ChoiceState> _choiceStates = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await widget.quizService.getQuestions(widget.quizInfo.id);
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

  Future<void> _onChoiceTap(String choiceId) async {
    if (_answered || _isSubmitting) return;
    setState(() { _isSubmitting = true; _answered = true; });

    try {
      final result = await widget.quizService.submitAnswer(
        userId: widget.userId,
        questionId: _questions[_currentIndex].id,
        choiceId: choiceId,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _choiceStates[choiceId] = result.isCorrect ? ChoiceState.correct : ChoiceState.wrong;
        if (!result.isCorrect && result.correctChoiceId != null) {
          _choiceStates[result.correctChoiceId!] = ChoiceState.reveal;
        }
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) _nextQuestion();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isSubmitting = false; _answered = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi đáp án: $e')),
      );
    }
  }

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
        backgroundColor: QuizColors.background,
        body: Center(child: CircularProgressIndicator(color: QuizColors.gold)),
      );
    }
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: QuizColors.background,
        body: Center(child: Text('Không có câu hỏi nào.', style: TextStyle(color: QuizColors.cream))),
      );
    }

    final question = _questions[_currentIndex];
    final total = _questions.length;

    return Scaffold(
      backgroundColor: QuizColors.background,
      appBar: AppBar(
        backgroundColor: QuizColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.quizInfo.title,
          style: const TextStyle(color: QuizColors.gold, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar + label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Câu ${_currentIndex + 1}/$total',
                    style: const TextStyle(color: QuizColors.goldLight, fontSize: 13),
                  ),
                  Text(
                    '${((_currentIndex + 1) / total * 100).round()}%',
                    style: const TextStyle(color: QuizColors.goldLight, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / total,
                  minHeight: 5,
                  backgroundColor: QuizColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(QuizColors.gold),
                ),
              ),
              const SizedBox(height: 20),

              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: QuizColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuizColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountdownTimer(
                      key: ValueKey(_timerKey),
                      seconds: widget.quizInfo.timeLimit,
                      onExpired: _onTimerExpired,
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: QuizColors.border, height: 1),
                    const SizedBox(height: 14),
                    Text(
                      question.questionText,
                      style: const TextStyle(
                        color: QuizColors.cream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Choices
              Expanded(
                child: ListView.separated(
                  itemCount: question.choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final choice = question.choices[i];
                    return ChoiceButton(
                      label: choice.name,
                      index: i,
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
