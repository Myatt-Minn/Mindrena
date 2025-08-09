import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateFirestoreQuestions() async {
  final firestore = FirebaseFirestore.instance;

  // Extended list of questions in each category
  final List<Map<String, dynamic>> questions = [
    // Places
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

    // Science & Math
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

    // General Knowledge
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
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('questions').doc();
    batch.set(doc, {
      'category': q['category'],
      'text': q['text'],
      'options': q['options'],
      'correctIndex': q['correctIndex'],
    });
  }

  await batch.commit();
  print('Questions populated successfully!');
}
