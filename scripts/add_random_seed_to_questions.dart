// Script to add randomSeed field to existing questions in Firestore
// Run this script once to optimize random question selection performance

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> addRandomSeedToQuestions() async {
  try {
    // Initialize Firebase (you'll need to configure this for your project)
    await Firebase.initializeApp();

    final firestore = FirebaseFirestore.instance;
    final random = Random();

    print('Starting to add randomSeed to questions...');

    // Get all questions
    final questionsSnapshot = await firestore.collection('questions').get();
    print('Found ${questionsSnapshot.docs.length} questions');

    // Process in batches to avoid hitting Firestore limits
    const batchSize = 500;
    int processedCount = 0;

    for (int i = 0; i < questionsSnapshot.docs.length; i += batchSize) {
      final batch = firestore.batch();
      final endIndex = (i + batchSize < questionsSnapshot.docs.length)
          ? i + batchSize
          : questionsSnapshot.docs.length;

      for (int j = i; j < endIndex; j++) {
        final doc = questionsSnapshot.docs[j];
        final data = doc.data();

        // Only add randomSeed if it doesn't exist
        if (!data.containsKey('randomSeed')) {
          batch.update(doc.reference, {'randomSeed': random.nextDouble()});
        }
      }

      await batch.commit();
      processedCount += (endIndex - i);
      print(
        'Processed $processedCount / ${questionsSnapshot.docs.length} questions',
      );
    }

    print('Successfully added randomSeed to all questions!');
  } catch (e) {
    print('Error adding randomSeed: $e');
  }
}

// Usage instructions:
// 1. Make sure Firebase is properly configured in your project
// 2. Run this script once: dart run scripts/add_random_seed_to_questions.dart
// 3. This will add a 'randomSeed' field (0.0 to 1.0) to all existing questions
// 4. For new questions, always include randomSeed: Random().nextDouble() when creating them

void main() async {
  await addRandomSeedToQuestions();
}
