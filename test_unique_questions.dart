import 'dart:math';

// Simple test to verify question uniqueness logic
void main() {
  print('Testing question uniqueness logic...');

  // Simulate question data
  final allQuestions = List.generate(
    20,
    (index) => {
      'id': 'question_$index',
      'text': 'Question $index',
      'category': 'General Knowledge',
    },
  );

  // Simulate recent questions for players
  final recentQuestions = ['question_0', 'question_1', 'question_2'];

  print('Total questions available: ${allQuestions.length}');
  print('Recent questions to avoid: $recentQuestions');

  // Filter out recent questions
  final availableQuestions = allQuestions
      .where((question) => !recentQuestions.contains(question['id']))
      .toList();

  print('Available questions after filtering: ${availableQuestions.length}');

  // Shuffle and select
  availableQuestions.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
  final selectedQuestions = availableQuestions.take(10).toList();

  print(
    'Selected questions: ${selectedQuestions.map((q) => q['id']).toList()}',
  );

  // Verify no duplicates with recent questions
  final selectedIds = selectedQuestions.map((q) => q['id']).toSet();
  final recentSet = recentQuestions.toSet();
  final overlap = selectedIds.intersection(recentSet);

  print('Overlap with recent questions: $overlap');
  print('Test passed: ${overlap.isEmpty ? "YES" : "NO"}');
}
