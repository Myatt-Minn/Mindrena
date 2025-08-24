import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';

TriviaQuestionResponse triviaQuestionResponseFromJson(String str) =>
    TriviaQuestionResponse.fromJson(json.decode(str));

String triviaQuestionResponseToJson(TriviaQuestionResponse data) =>
    json.encode(data.toJson());

class TriviaQuestionResponse {
  final int responseCode;
  final List<Question> questions;

  TriviaQuestionResponse({required this.responseCode, required this.questions});

  factory TriviaQuestionResponse.fromJson(Map<String, dynamic> json) =>
      TriviaQuestionResponse(
        responseCode: json["response_code"],
        questions: List<Question>.from(
          json["results"].map((x) => Question.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "results": List<dynamic>.from(questions.map((x) => x.toJson())),
  };
}

class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String decodeHtmlEntities(String text) {
      final unescape = HtmlUnescape();
      return unescape.convert(text);
    }

    return Question(
      questionText: decodeHtmlEntities(json['question'] ?? 'N/A'),
      correctAnswer: decodeHtmlEntities(json['correct_answer'] ?? 'N/A'),
      incorrectAnswers:
          (json['incorrect_answers'] as List<dynamic>? ?? [])
              .map((answer) => decodeHtmlEntities(answer.toString()))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    "question": questionText,
    "correct_answer": correctAnswer,
    "incorrect_answers": incorrectAnswers,
  };
}
