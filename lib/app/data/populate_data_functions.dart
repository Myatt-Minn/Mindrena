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

Future<void> populateSampleUserGuides() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Sample user guide data
    final sampleGuides = [
      {
        'title': 'getting-started',
        'guide_items': [
          {
            'description': 'Learn the basics of using Mindrena quiz app',
            'content':
                'Welcome to Mindrena! This is your ultimate quiz companion...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'description': 'Set up your personal profile',
            'content':
                'To get started, go to Settings and complete your profile...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'description': 'Navigate through the app easily',
            'content':
                'The main screen shows your dashboard with recent activities...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      {
        'title': 'quizzes',
        'guide_items': [
          {
            'description': 'How to begin playing quizzes',
            'content': 'Browse available quizzes from the home screen...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'description': 'Explore different types of quizzes',
            'content': 'Mindrena offers various categories like Science...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'description': 'How points and scoring work',
            'content': 'Earn points for correct answers. Faster responses...',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      {
        'id': 3,
        'title': 'friends',
        'guide_items': [
          {
            'id': 7,
            'guide_id': 3,
            'title': 'Adding Friends',
            'description': 'Connect with other players',
            'content':
                'Use the Friends tab to search for other players by username or email. Send friend requests and wait for acceptance. You can also accept incoming friend requests from the notifications.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 8,
            'guide_id': 3,
            'title': 'Challenging Friends',
            'description': 'Compete with your friends',
            'content':
                'Challenge your friends to quiz battles! Select a quiz and invite friends to compete. You\'ll see real-time results and can compare scores at the end.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 9,
            'guide_id': 3,
            'title': 'Friend Leaderboards',
            'description': 'See how you rank among friends',
            'content':
                'Check the Friends Leaderboard to see your ranking among your friends. Compare total points, completed quizzes, and achievements with your friend circle.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      {
        'id': 4,
        'title': 'account',
        'guide_items': [
          {
            'id': 10,
            'guide_id': 4,
            'title': 'Managing Your Account',
            'description': 'Account settings and preferences',
            'content':
                'Access your account settings through the Settings tab. Here you can update your profile information, change password, manage notifications, and adjust app preferences.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 11,
            'guide_id': 4,
            'title': 'Notification Settings',
            'description': 'Control your notifications',
            'content':
                'Customize which notifications you receive. You can enable/disable friend requests, quiz invitations, achievement unlocks, and daily quiz reminders.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 12,
            'guide_id': 4,
            'title': 'Privacy Settings',
            'description': 'Manage your privacy preferences',
            'content':
                'Control who can find you, send friend requests, and see your quiz history. You can set your profile to public, friends-only, or private mode.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      {
        'id': 5,
        'title': 'troubleshooting',
        'guide_items': [
          {
            'id': 13,
            'guide_id': 5,
            'title': 'Connection Issues',
            'description': 'Solving internet connectivity problems',
            'content':
                'If you\'re experiencing connection issues, check your internet connection first. The app requires a stable internet connection to sync data and compete with friends. Try switching between WiFi and mobile data.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 14,
            'guide_id': 5,
            'title': 'Quiz Not Loading',
            'description': 'What to do when quizzes won\'t load',
            'content':
                'If quizzes aren\'t loading, try refreshing the app by pulling down on the quiz list. If the problem persists, restart the app or check your internet connection.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 15,
            'guide_id': 5,
            'title': 'Login Problems',
            'description': 'Trouble signing in to your account',
            'content':
                'If you can\'t log in, verify your email and password. Use the "Forgot Password" option to reset your password. For Google Sign-In issues, make sure Google Play Services is updated.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      {
        'id': 6,
        'title': 'general',
        'guide_items': [
          {
            'id': 16,
            'guide_id': 6,
            'title': 'App Features Overview',
            'description': 'Complete overview of Mindrena features',
            'content':
                'Mindrena offers quiz competitions, friend challenges, leaderboards, achievements, profile customization, and much more. Explore all features to get the most out of your quiz experience.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 17,
            'guide_id': 6,
            'title': 'Tips for Better Performance',
            'description': 'Get the most out of Mindrena',
            'content':
                'To improve your quiz performance: practice regularly, read questions carefully, manage your time wisely, and learn from incorrect answers. Consistent practice leads to better scores!',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
          {
            'id': 18,
            'guide_id': 6,
            'title': 'Contact Support',
            'description': 'How to get help when needed',
            'content':
                'Need help? Contact our support team through the Settings menu. You can also check our FAQ section or join our community forums for quick answers to common questions.',
            'images': [],
            'video_url': '',
            'last_updated': '2025-08-13',
          },
        ],
      },
      // Add other guides here...
    ];

    for (final guide in sampleGuides) {
      // 1. Add guide to user_guides
      final guideRef = await firestore.collection('user_guides').add({
        'title': guide['title'],
        'last_updated': DateTime.now().toIso8601String(),
      });

      final guideId = guideRef.id;

      // 2. Add related guide_items
      for (final item in guide['guide_items'] as List) {
        await firestore.collection('guide_items').add({
          'user_guide_id': guideId, // FK to user_guides
          'title': guide['title'], // same as parent guide title
          'description': item['description'],
          'content': item['content'],
          'images': item['images'],
          'video_url': item['video_url'],
          'last_updated': item['last_updated'],
        });
      }
    }

    print('Sample user guides and guide items populated successfully!');
  } catch (e) {
    print('Error loading sample user guides: $e');
  }
}
