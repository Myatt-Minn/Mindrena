import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindrena/app/data/AdDataModel.dart';

Future<void> populateFirestoreQuestions() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Extended list of questions in each category (20 questions per category)
  final List<Map<String, dynamic>> questions = [
    // Places (20 questions)
    {
      'category': 'Places',
      'text': 'What is the capital of France?',
      'options': ['Paris', 'Madrid', 'Berlin', 'Rome'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Mount Everest is located in which country?',
      'options': ['Nepal', 'India', 'China', 'Bhutan'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which river flows through London?',
      'options': ['Thames', 'Seine', 'Danube', 'Rhine'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text':
          'The Great Wall of China was primarily built to protect against which group?',
      'options': ['Mongols', 'Huns', 'Russians', 'Japanese'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which continent is the Sahara Desert located on?',
      'options': ['Africa', 'Asia', 'Australia', 'Europe'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country has the most islands in the world?',
      'options': ['Sweden', 'Canada', 'Indonesia', 'Philippines'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'What is the smallest country in the world?',
      'options': ['Vatican City', 'Monaco', 'San Marino', 'Liechtenstein'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which U.S. state is known as the "Sunshine State"?',
      'options': ['California', 'Florida', 'Texas', 'Arizona'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is known as the "Big Apple"?',
      'options': ['Chicago', 'Los Angeles', 'New York City', 'Boston'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which mountain range separates Europe and Asia?',
      'options': ['Ural Mountains', 'Andes', 'Alps', 'Himalayas'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'What is the capital of Australia?',
      'options': ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which African country was never colonized?',
      'options': ['Egypt', 'Ethiopia', 'Libya', 'Morocco'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'The ancient city of Petra is located in which country?',
      'options': ['Egypt', 'Jordan', 'Israel', 'Syria'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which country is home to Machu Picchu?',
      'options': ['Chile', 'Peru', 'Ecuador', 'Bolivia'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'What is the largest island in the Mediterranean Sea?',
      'options': ['Sicily', 'Sardinia', 'Cyprus', 'Corsica'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country has three capital cities?',
      'options': ['Netherlands', 'South Africa', 'Switzerland', 'Belgium'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'The Taj Mahal is located in which Indian city?',
      'options': ['Delhi', 'Mumbai', 'Agra', 'Jaipur'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text':
          'Which waterfall is located on the border between Canada and the United States?',
      'options': [
        'Angel Falls',
        'Victoria Falls',
        'Niagara Falls',
        'Iguazu Falls',
      ],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'What is the longest mountain range in the world?',
      'options': ['Himalayas', 'Rocky Mountains', 'Andes', 'Alps'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which European city is known as the "City of Canals"?',
      'options': ['Amsterdam', 'Venice', 'Bruges', 'Stockholm'],
      'correctIndex': 1,
    },

    // Science & Math (20 questions)
    {
      'category': 'Science & Math',
      'text': 'What is the chemical symbol for water?',
      'options': ['H2O', 'O2', 'CO2', 'NaCl'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What is 7 x 8?',
      'options': ['54', '56', '58', '60'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What planet is known as the Red Planet?',
      'options': ['Mars', 'Venus', 'Mercury', 'Jupiter'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Who developed the theory of relativity?',
      'options': [
        'Isaac Newton',
        'Albert Einstein',
        'Stephen Hawking',
        'Marie Curie',
      ],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the powerhouse of the cell?',
      'options': ['Nucleus', 'Mitochondria', 'Ribosome', 'Chloroplast'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the value of Pi (to two decimal places)?',
      'options': ['3.12', '3.14', '3.16', '3.18'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the chemical symbol for gold?',
      'options': ['Ag', 'Au', 'Gd', 'Go'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'How many planets are in the Solar System?',
      'options': ['7', '8', '9', '10'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which gas do plants absorb from the atmosphere?',
      'options': ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the next prime number after 7?',
      'options': ['9', '10', '11', '13'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the atomic number of carbon?',
      'options': ['4', '6', '8', '12'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the square root of 144?',
      'options': ['11', '12', '13', '14'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which organ in the human body produces insulin?',
      'options': ['Liver', 'Pancreas', 'Kidney', 'Heart'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the speed of light in a vacuum?',
      'options': [
        '300,000 km/s',
        '299,792,458 m/s',
        '186,000 mph',
        'All of the above',
      ],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the formula for calculating the area of a circle?',
      'options': ['πr²', '2πr', 'πd', 'r²'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which element has the chemical symbol "Fe"?',
      'options': ['Fluorine', 'Iron', 'Francium', 'Fermium'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the largest bone in the human body?',
      'options': ['Tibia', 'Femur', 'Humerus', 'Fibula'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'How many chambers does a human heart have?',
      'options': ['2', '3', '4', '5'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'What is 15% of 200?',
      'options': ['25', '30', '35', '40'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet is closest to the Sun?',
      'options': ['Venus', 'Mercury', 'Earth', 'Mars'],
      'correctIndex': 1,
    },

    // General Knowledge (20 questions)
    {
      'category': 'General Knowledge',
      'text': 'Who wrote "Romeo and Juliet"?',
      'options': [
        'Charles Dickens',
        'William Shakespeare',
        'Mark Twain',
        'Jane Austen',
      ],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the largest planet in our solar system?',
      'options': ['Earth', 'Mars', 'Jupiter', 'Saturn'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the main ingredient in guacamole?',
      'options': ['Tomato', 'Avocado', 'Cucumber', 'Pepper'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which animal is known as the King of the Jungle?',
      'options': ['Tiger', 'Lion', 'Leopard', 'Elephant'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'How many continents are there?',
      'options': ['5', '6', '7', '8'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the smallest prime number?',
      'options': ['0', '1', '2', '3'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which sport is known as the "king of sports"?',
      'options': ['Basketball', 'Cricket', 'Soccer', 'Tennis'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the hardest natural substance?',
      'options': ['Gold', 'Iron', 'Diamond', 'Silver'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the longest river in the world?',
      'options': ['Amazon', 'Nile', 'Yangtze', 'Mississippi'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'How many colors are there in a rainbow?',
      'options': ['5', '6', '7', '8'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who painted the Mona Lisa?',
      'options': [
        'Vincent van Gogh',
        'Pablo Picasso',
        'Leonardo da Vinci',
        'Michelangelo',
      ],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the currency of Japan?',
      'options': ['Yuan', 'Won', 'Yen', 'Rupee'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the largest ocean on Earth?',
      'options': ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'In which year did World War II end?',
      'options': ['1944', '1945', '1946', '1947'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the tallest mammal in the world?',
      'options': ['Elephant', 'Giraffe', 'Blue Whale', 'Ostrich'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which instrument has 88 keys?',
      'options': ['Guitar', 'Violin', 'Piano', 'Drums'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What does "www" stand for?',
      'options': [
        'World Wide Web',
        'World Wide Wait',
        'World Wide Watch',
        'World Wide Wave',
      ],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which gas makes up most of Earth\'s atmosphere?',
      'options': ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the smallest country in South America?',
      'options': ['Uruguay', 'Suriname', 'Guyana', 'French Guiana'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text':
          'Which Shakespeare play features the characters Romeo and Juliet?',
      'options': ['Hamlet', 'Macbeth', 'Romeo and Juliet', 'Othello'],
      'correctIndex': 2,
    },
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('questions').doc();
    batch.set(doc, {
      'category': q['category'],
      'text': q['text'],
      'options': q['options'],
      'correctIndex': q['correctIndex'],
      'randomSeed': random
          .nextDouble(), // Add random seed for efficient selection
    });
  }

  await batch.commit();
  print('Questions populated successfully with ${questions.length} questions!');
  print('Categories: Places (20), Science & Math (20), General Knowledge (20)');
}

Future<void> populateAppAds() async {
  final firestore = FirebaseFirestore.instance;

  // Create 3 AdData objects
  final ads = [
    AdData(
      id: '1',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/ad1.jpg?alt=media&token=175e7a68-90c9-4310-b667-04f2722d71aa',
      actionType: 'shop',
      actionValue: '',
    ),
    AdData(
      id: '2',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/ad2.jpg?alt=media&token=528e7fb2-805c-4b09-930f-597eb326f741',
      actionType: 'category',
      actionValue: 'm-category',
    ),
    AdData(
      id: '3',
      imageUrl:
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/ad3.jpg?alt=media&token=5ae08e06-6272-4ae0-8e68-8a4d0156b16b',
      actionType: 'url',
      actionValue:
          'https://play.google.com/store/apps/details?id=com.mobile.legends.usa',
    ),
  ];

  // Batch write for efficiency
  WriteBatch batch = firestore.batch();
  for (var ad in ads) {
    final docRef = firestore.collection('app_ads').doc(ad.id);
    batch.set(docRef, ad.toJson());
  }

  try {
    await batch.commit();
    print("✅ 3 ads added to Firestore successfully!");
  } catch (e) {
    print("❌ Failed to add ads: $e");
  }
}
