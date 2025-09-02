import 'package:get/get.dart';
import 'package:mindrena/app/data/question_model.dart';
import 'package:mindrena/app/modules/single_player/sg_quiz/controllers/questions_service.dart';

class SgQuizController extends GetxController {
  // Observable properties
  var score = 0.obs;
  var isLoading = false.obs;
  var currentQuestionIndex = 0.obs;
  var currentQuestion = ''.obs;
  var timerEndTime = DateTime.now().add(Duration(milliseconds: 1100)).obs;
  var isGameFinished = false.obs;
  var selectedCategoryId = 0.obs;
  var answers = <String>[].obs;
  var choosenAnswers = <String>[].obs;
  var summary = <Map<String, dynamic>>[].obs;
  var selectedAnswer = Rx<String?>(null);
  var changeColor = false.obs;

  // Data
  var selectedCategory = Get.arguments['category'];
  var selectedDifficulty = Get.arguments['difficulty'].toLowerCase();
  var selectedType = Get.arguments['type'];
  var questions = <Question>[];

  //functions

  //services
  final questionsService = QuestionsService();

  @override
  void onInit() {
    super.onInit();
    selectedCategoryId.value = getCategoryId();
    getQuestions().then((_) {
      isLoading.value = false;
    });
  }

  //get category id
  int getCategoryId() {
    if (selectedCategory == 'General Knowledge') {
      return 9;
    } else if (selectedCategory == 'Places') {
      return 22;
    } else if (selectedCategory == 'Science & Math') {
      return 19;
    }
    return 0;
  }

  //get questions
  Future<bool> getQuestions() async {
    try {
      isLoading.value = true;
      questions = await questionsService.getQuestions(
        categoryId: selectedCategoryId.value,
        difficulty: selectedDifficulty,
        type: selectedType,
      );
      if (questions.isEmpty) {
        Get.snackbar(
          'No Questions',
          'No questions found for the selected category and difficulty.',
        );
        return false;
      }
      getQuestionAndAnswers();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch questions.');
      return false;
    }
  }

  //get questions
  Future<void> getQuestionAndAnswers() async {
    if (currentQuestionIndex.value >= questions.length) {
      return;
    }
    currentQuestion.value = questions[currentQuestionIndex.value].questionText;
    restartTimer();
    mixAnswers();
  }

  // restart timer
  void restartTimer() async {
    timerEndTime.value = DateTime.now().add(
      const Duration(seconds: 10, milliseconds: 500),
    );
  }

  //mix answers
  void mixAnswers() {
    final question = questions[currentQuestionIndex.value];
    final allAnswers = [...question.incorrectAnswers, question.correctAnswer];
    allAnswers.shuffle();
    answers.value = allAnswers;
  }

  //choose answer and next question
  void chooseAnswer(String answer) {
    if (selectedAnswer.value != null) return;

    choosenAnswers.add(answer);
    selectedAnswer.value = answer;
    changeColor.value = false;

    if (answer == questions[currentQuestionIndex.value].correctAnswer) {
      score.value++;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      nextQuestion();
    });
  }

  void _createSummary() {
    final List<Map<String, dynamic>> summaryData = [];
    for (var i = 0; i < questions.length; i++) {
      summaryData.add({
        'question_index': i + 1,
        'question': questions[i].questionText,
        'correct_answer': questions[i].correctAnswer,
        'user_answer': choosenAnswers[i],
      });
    }
    summary.value = summaryData;
  }

  //next question
  void nextQuestion() {
    if (currentQuestionIndex.value >= questions.length - 1) {
      _createSummary();
      isGameFinished.value = true;
    } else {
      selectedAnswer.value = null;
      currentQuestionIndex.value++;
      getQuestionAndAnswers();
    }
  }

  void exitGame() {
    Get.offAllNamed('/sg-home');
  }

  void playAgain() {
    score.value = 0;
    isLoading.value = false;
    currentQuestionIndex.value = 0;
    isGameFinished.value = false;
    choosenAnswers.clear();
    summary.clear();
    selectedAnswer.value = null;

    // Restart the game
    getQuestions().then((_) {
      isLoading.value = false;
    });
  }

  int get questionProgress {
    if (questions.isEmpty) return 0;
    return ((currentQuestionIndex.value + 1) / questions.length * 100).round();
  }
}
