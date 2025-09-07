import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateAudioQuestions() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // 10 Audio Questions
  final List<Map<String, dynamic>> questions = [
    {
      'category': 'Sounds',
      'audio':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Facoustic-guitar-short-intro-ish-live-recording-163329.mp3?alt=media&token=ce77b67b-530d-4b33-a9b9-ce437da8629b',
      'options': ['Acoustic Guitar', 'Piano', 'Violin', 'Flute'],
      'correctIndex': 0,
    },
    {
      'category': 'Sounds',
      'audio':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Fbigg-bass-277247.mp3?alt=media&token=44200e11-b746-496c-8cd9-325303d512e3',
      'options': ['Drum Beat', 'Bass Sound', 'Bell', 'Explosion'],
      'correctIndex': 1,
    },
    {
      'category': 'Sounds',
      'audio':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Fchicken-cluck-very-short-342014.mp3?alt=media&token=478593d8-f85f-4374-9cc8-fd8bcfd67421',
      'options': ['Dog Bark', 'Cat Meow', 'Chicken Cluck', 'Duck Quack'],
      'correctIndex': 2,
    },
    {
      'category': 'Sounds',
      'audio':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Fshort-gust-of-wind-345741.mp3?alt=media&token=7f917845-4a80-4294-8ac1-c8eef420cd8e',
      'options': ['Gust of Wind', 'Ocean Waves', 'Rainfall', 'Fire Crackle'],
      'correctIndex': 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Fsparrow.m4a?alt=media&token=7c9dcddb-3e44-4f96-8ff6-a0291519cc23",
      "options": ["Owl", "Crow", "Sparrow", "Parrot"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FPeckingWood.m4a?alt=media&token=50641fa6-9a0a-4a52-a37a-dbda25fe7494",
      "options": [
        "Knocking on Door",
        "Bird Pecking Wood",
        "Hitting Table",
        "Clapping Hands",
      ],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Fsneezing.m4a?alt=media&token=595b60ad-a8f3-4a97-93aa-4c45fc621ce1",
      "options": ["Coughing", "Sneezing", "Laughing", "Shouting"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FWolf_howl_sound_effect_night_wolf_sound_no_copyright_free128k.m4a?alt=media&token=10ec4551-3a99-4239-95fd-5bbc712b2f9f",
      "options": ["Dog Bark", "Wolf Howl", "Cat Meow", "Goat Bleat"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FMicrowave_beeping(128k).m4a?alt=media&token=18ffb927-c253-4042-8b3e-4f21185542e4",
      "options": ["Alarm Clock", "Doorbell", "Phone Ringing", "Microwave Beep"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FSemi_Truck_Sound_Effect_Truck_Sound_Effect_Semi_Truck_Horn_Sound.m4a?alt=media&token=cefeb8af-9ed7-4955-97df-7d56274d665d",
      "options": ["Car Horn", "Truck Horn", "Bike Horn", "Train Horn"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FSea_Waves_-_Sound_Effect(128k).m4a?alt=media&token=a4b45018-4832-4850-8b11-16a3549a18cc",
      "options": ["Rain", "River Flow", "Shower", "Waves"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FHit_Table___Sound_Effects%2C_Download(128k).m4a?alt=media&token=9dccf5ee-f7d0-4217-a678-6c49394c0e03",
      "options": ["Clapping Hands", "Hitting Table", "Door Closing", "Typing"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FTrain_Horn_-_Sound_Effect__HD_(128k).m4a?alt=media&token=3bc623da-0416-4fa3-9956-f41077037217",
      "options": ["Train Whistle", "Airplane", "Truck", "Boat Horn"],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FAirplane_taking_off_sound_effect(128k).m4a?alt=media&token=e82fa3c1-b81d-4c1f-bd44-abe13fdb3c02",
      "options": ["Car Engine", "Airplane Takeoff", "Helicopter", "Rocket"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FTYPING_ON_KEYBOARD_SOUND_EFFECT(128k).m4a?alt=media&token=625da650-4b13-4e7a-ad3c-659cf1ac7c76",
      "options": [
        "Mouse Click",
        "Typing on Keyboard",
        "Phone Vibration",
        "Writing with Pen",
      ],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio": "audio/bell.mp3",
      "options": ["Alarm Clock", "Church Bell", "Doorbell", "Wind Chime"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio": "audio/goat.mp3",
      "options": ["Sheep Bleat", "Goat Bleat", "Cow Moo", "Camel Sound"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio": "audio/crow.mp3",
      "options": ["Owl", "Crow", "Sparrow", "Eagle"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio": "audio/fire.mp3",
      "options": [
        "Wind Blowing",
        "Fire Crackling",
        "Leaves Rustling",
        "Cooking Fry",
      ],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio": "audio/waterdrop.mp3",
      "options": ["Typing", "Water Droplet", "Clock Tick", "Raindrop"],
      "correctIndex": 3,
    },
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('audio_questions').doc();
    batch.set(doc, {
      'category': q['category'],
      'audio': q['audio'],
      'options': q['options'],
      'correctIndex': q['correctIndex'],
      'randomSeed': random.nextDouble(),
    });
  }

  await batch.commit();
  print(
    'Questions populated successfully with ${questions.length} audio questions!',
  );
}
