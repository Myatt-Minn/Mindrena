import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateMemorizeQuestions() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // 15 Flag Questions
  final List<Map<String, dynamic>> questions = [
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_21_37%20AM.png?alt=media&token=97440ea2-2161-4801-a412-bf54bdd0b130',
      'question': 'Which of these objects is shown in the image?',
      'options': ['Banana', 'Suitcase', 'Alarm Clock', 'Whistle'],
      'correctIndex': 1,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_22_03%20AM.png?alt=media&token=fb13c7e5-a41f-4a10-80c6-1d5dda42e6bd',
      'question': 'Which of these objects is NOT in the image?',
      'options': ['Balloon', 'Banana', 'Airplane', 'Rubber Duck'],
      'correctIndex': 2,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_22_46%20AM.png?alt=media&token=0a5cf4e3-0e32-45bb-bcb9-dff28e907938',
      'question': 'Which of these objects is in the image?',
      'options': ['Cookie', 'Camera', 'Bicycle', 'Parachute'],
      'correctIndex': 0,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_21_37%20AM.png?alt=media&token=97440ea2-2161-4801-a412-bf54bdd0b130',
      'question': 'What color is the bicycle in the image?',
      'options': ['Red', 'Blue', 'Yellow', 'Green'],
      'correctIndex': 2,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_22_03%20AM.png?alt=media&token=fb13c7e5-a41f-4a10-80c6-1d5dda42e6bd',
      'question': 'Which fruit can be seen in the image?',
      'options': ['Apple', 'Banana', 'Tomato', 'Lemon'],
      'correctIndex': 1,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_22_46%20AM.png?alt=media&token=0a5cf4e3-0e32-45bb-bcb9-dff28e907938',
      'question': 'Which type of ball appears in the image?',
      'options': ['Basketball', 'Tennis Ball', 'Football (Soccer)', 'Baseball'],
      'correctIndex': 2,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_19_47%20AM.png?alt=media&token=44fc3ce3-f7dd-4452-a424-47ccd3052cda",
      "question": "Which of these objects is shown in the image?",
      "options": ["Banana", "Wrench", "Camera", "Glasses"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_20_18%20AM.png?alt=media&token=89f0ad3b-b5c5-4873-87e8-c60bcf931bf2",
      "question": "Which of these objects is shown in the image?",
      "options": ["Stopwatch", "Cookie", "Flower", "Soccer Ball"],
      "correctIndex": 0,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_20_57%20AM.png?alt=media&token=b01c23f4-8681-499e-8c44-62cb340d2b9c",
      "question": "Which of these objects is shown in the image?",
      "options": ["Tie", "Paintbrush", "Envelope", "Starfish"],
      "correctIndex": 3,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_19_47%20AM.png?alt=media&token=44fc3ce3-f7dd-4452-a424-47ccd3052cda",
      "question": "Which of these objects is shown in the image?",
      "options": ["Spider", "Banana", "Car", "Glasses"],
      "correctIndex": 0,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_20_18%20AM.png?alt=media&token=89f0ad3b-b5c5-4873-87e8-c60bcf931bf2",
      "question": "Which of these objects is shown in the image?",
      "options": ["Cookie", "Flower", "Airplane", "Tie"],
      "correctIndex": 2,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_20_57%20AM.png?alt=media&token=b01c23f4-8681-499e-8c44-62cb340d2b9c",
      "question": "Which of these objects is shown in the image?",
      "options": ["Soccer Ball", "Tie", "Paint Palette", "Keycard"],
      "correctIndex": 0,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_15_47%20AM.png?alt=media&token=048010d4-c394-4703-a558-92960f059aec',
      'question': 'What is the color of the cup in the image?',
      'options': ['Red', 'Blue', 'Yellow', 'Green'],
      'correctIndex': 3,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_15_47%20AM.png?alt=media&token=048010d4-c394-4703-a558-92960f059aec',
      'question': 'How many donuts are shown in the image?',
      'options': ['One', 'Two', 'Three', 'Four'],
      'correctIndex': 1,
    },

    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_18_09%20AM.png?alt=media&token=4fbe633f-f289-4f89-87e0-89a911673240',
      'question': 'Which drink was shown in the image?',
      'options': ['Tea', 'Juice', 'Coffee', 'Milk'],
      'correctIndex': 2,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_18_09%20AM.png?alt=media&token=4fbe633f-f289-4f89-87e0-89a911673240',
      'question': 'How many yellow rubber ducks were there?',
      'options': ['1', '2', '3', '4'],
      'correctIndex': 1,
    },

    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_17_56%20AM.png?alt=media&token=b0d26bd5-b3fd-438f-be15-388c71820c12',
      'question': 'Which sport-related item was in the image?',
      'options': ['Football', 'Baseball', 'Tennis racket', 'Basketball'],
      'correctIndex': 3,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_17_56%20AM.png?alt=media&token=b0d26bd5-b3fd-438f-be15-388c71820c12',
      'question': 'What shape was shown that represents an animal?',
      'options': ['Feather', 'Paw print', 'Tail', 'Wing'],
      'correctIndex': 1,
    },

    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_16_13%20AM.png?alt=media&token=911062f7-d64c-422c-b1f3-573127a98936',
      'question': 'Which fruit was shown in the image?',
      'options': ['Mango', 'Pear', 'Apple', 'Orange'],
      'correctIndex': 2,
    },
    {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_16_13%20AM.png?alt=media&token=911062f7-d64c-422c-b1f3-573127a98936',
      'question': 'Which musical instrument appeared in the picture?',
      'options': ['Piano', 'Drum', 'Guitar', 'Violin'],
      'correctIndex': 2,
    },

    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
    {
      "category": "MemorizeVideos",
      "image": "https://youtube.com/shorts/8tTCbPUYOd8?si=m7Il-9D4i1dHX1mZ",
      "question": "How many photo with hat?",
      "options": ["2", "3", "4", "5"],
      "correctIndex": 1,
    },
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('memorize_questions').doc();
    batch.set(doc, {
      'category': q['category'],
      'image': q['image'],
      'question': q['question'],
      'options': q['options'],
      'correctIndex': q['correctIndex'],
      'randomSeed': random.nextDouble(),
    });
  }

  await batch.commit();
  print(
    'Questions populated successfully with ${questions.length} memorize image questions!',
  );
}
