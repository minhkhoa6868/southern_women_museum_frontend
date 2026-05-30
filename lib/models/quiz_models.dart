// ─── Quizzes ───────────────────────────────────────────────
// ID | room_id | title | description | time_limit | passing_score | is_active | created_at | updated_at | title_en

class QuizInfo {
  QuizInfo({
    required this.id,
    required this.roomId,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.timeLimit,
    required this.passingScore,
    required this.isActive,
    required this.totalQuestions,
  });

  factory QuizInfo.fromJson(Map<String, dynamic> json) => QuizInfo(
        id: json['id'] as String,
        roomId: json['room_id'] as String,
        title: json['title'] as String,
        titleEn: json['title_en'] as String? ?? '',
        description: json['description'] as String? ?? '',
        timeLimit: json['time_limit'] as int,
        passingScore: json['passing_score'] as int,
        isActive: json['is_active'] as bool? ?? true,
        totalQuestions: json['total_questions'] as int,
      );

  final String id;
  final String roomId;
  final String title;
  final String titleEn;
  final String description;
  final int timeLimit;
  final int passingScore;
  final bool isActive;
  final int totalQuestions; // tính từ server, không có trong DB
}

// ─── QuizQuestions ─────────────────────────────────────────
// ID | quiz_id | question_text | created_at | updated_at | question_text_en

class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionTextEn,
    required this.choices,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        quizId: json['quiz_id'] as String,
        questionText: json['question_text'] as String,
        questionTextEn: json['question_text_en'] as String? ?? '',
        choices: (json['choices'] as List<dynamic>)
            .map((c) => QuizChoice.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String quizId;
  final String questionText;
  final String questionTextEn;
  final List<QuizChoice> choices;
}

// ─── QuizChoices ───────────────────────────────────────────
// ID | question_id | name | is_correct | created_at | updated_at | name_en
// is_correct KHÔNG được trả về từ API (xử lý phía server)

class QuizChoice {
  QuizChoice({
    required this.id,
    required this.questionId,
    required this.name,
    required this.nameEn,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) => QuizChoice(
        id: json['id'] as String,
        questionId: json['question_id'] as String,
        name: json['name'] as String,
        nameEn: json['name_en'] as String? ?? '',
      );

  final String id;
  final String questionId;
  final String name;
  final String nameEn;
}

// ─── UserAnswer ────────────────────────────────────────────
// ID | user_id | question_id | is_correct | created_at | updated_at
// Dùng để nhận phản hồi sau khi POST /api/quiz/answer

class AnswerResult {
  AnswerResult({
    required this.isCorrect,
    required this.correctChoiceId,
  });

  factory AnswerResult.fromJson(Map<String, dynamic> json) => AnswerResult(
        isCorrect: json['is_correct'] as bool,
        correctChoiceId: json['correct_choice_id'] as String?,
      );

  final bool isCorrect;
  final String? correctChoiceId; // server trả về để highlight đáp án đúng
}

// ─── Kết quả cuối (tổng hợp từ UserAnswer) ─────────────────

class QuizResult {
  QuizResult({
    required this.score,
    required this.correct,
    required this.answered,
    required this.total,
    required this.passingScore,
    required this.passed,
    required this.message,
    required this.quizTitle,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        score: json['score'] as int,
        correct: json['correct'] as int,
        answered: json['answered'] as int,
        total: json['total'] as int,
        passingScore: json['passing_score'] as int,
        passed: json['passed'] as bool,
        message: json['message'] as String,
        quizTitle: json['quiz_title'] as String? ?? '',
      );

  final int score;
  final int correct;
  final int answered; // số câu đã trả lời (không tính hết giờ)
  final int total;
  final int passingScore;
  final bool passed;
  final String message;
  final String quizTitle;
}
