import 'package:get/get.dart';
import 'package:mindrena/app/data/question_model.dart';

class QuestionsService {
  //get questions
  Future<List<Question>> getQuestions({
    required int categoryId,
    required String difficulty,
  }) async {
    String url = 'https://opentdb.com/api.php?amount=10&type=multiple';

    if (categoryId != 0) {
      url += '&category=$categoryId';
    }
    if (difficulty != 'Any Difficulty') {
      url += '&difficulty=${difficulty.toLowerCase()}';
    }
    final response = await GetConnect().get(url);

    if (response.statusCode == 200) {
      return TriviaQuestionResponse.fromJson(response.body).questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
