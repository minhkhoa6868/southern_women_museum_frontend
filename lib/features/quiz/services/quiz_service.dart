import '../../../services/api_service.dart';
import '../models/quiz_models.dart';

class QuizService {
  QuizService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  // Lấy thông tin quiz theo roomId
  Future<QuizInfo> getQuizByRoom(String roomId) async {
    final data = await _api.getJson(path: '/quiz/room/$roomId');
    return QuizInfo.fromJson(data);
  }

  // Lấy toàn bộ câu hỏi + đáp án của quiz (không có is_correct)
  Future<List<QuizQuestion>> getQuestions(String quizId) async {
    final data = await _api.getJson(path: '/quiz/$quizId/questions');
    final list = data['questions'] as List<dynamic>;
    return list
        .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  // Ghi nhận câu trả lời của user
  Future<AnswerResult> submitAnswer({
    required String userId,
    required String questionId,
    required String choiceId,
  }) async {
    final data = await _api.postJson(
      path: '/quiz/answer',
      body: {
        'user_id': userId,
        'question_id': questionId,
        'choice_id': choiceId,
      },
    );
    return AnswerResult.fromJson(data);
  }

  // Lấy kết quả cuối sau khi hoàn thành quiz
  Future<QuizResult> getResult({
    required String quizId,
    required String userId,
  }) async {
    final data =
        await _api.getJson(path: '/quiz/$quizId/result?user_id=$userId');
    return QuizResult.fromJson(data);
  }

  void dispose() => _api.dispose();
}
