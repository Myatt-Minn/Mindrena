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
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FDoor_Bell_Sound_Effect(128k).m4a?alt=media&token=f4be31be-95b3-4d71-885d-17060b7f5ca7",
      "options": ["Alarm Clock", "Church Bell", "Doorbell", "Wind Chime"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FGoat_-_Sound_Effect___ProSounds(128k).m4a?alt=media&token=a379c8e8-6e94-4dd4-b19c-808233a55c54",
      "options": ["Sheep Bleat", "Goat Bleat", "Cow Moo", "Camel Sound"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FCrow_Sound_Effect(128k).m4a?alt=media&token=5feaf237-7bb5-4d83-9df5-0ca70caa33d1",
      "options": ["Owl", "Crow", "Sparrow", "Eagle"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FFire_Crackling_-_Sound_Effect_%5BHQ%5D(128k).m4a?alt=media&token=5825d525-8e9b-4961-8fca-5e639654bfd9",
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
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FRain_Sounds_10_Seconds___Ad(128k).m4a?alt=media&token=bc78ba69-d46c-4820-b316-3be69bf6ec62",
      "options": ["Typing", "Water Droplet", "Clock Tick", "Raindrop"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FSparrow_-_Sound_Effect___ProSounds(128k).m4a?alt=media&token=81b8435d-65c4-4367-a83a-636e90c25e3a",
      "options": ["Parrot", "Sparrow", "Crow", "Owl"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FCow_Moo_-_Sound_Effect___ProSounds(128k).m4a?alt=media&token=1c53f873-15a5-4e1b-a150-8583043581b0",
      "options": ["Goat Bleat", "Sheep Bleat", "Cow Moo", "Buffalo"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FPig_Sound_Effect_-_Oink(128k).m4a?alt=media&token=0cdae4b4-8ff0-449d-934c-b93e277104d6",
      "options": ["Pig Oink", "Cow Moo", "Goat Bleat", "Dog Growl"],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FHORSE_-_Sound_Effect(128k).m4a?alt=media&token=0244428a-030c-4f2c-973a-e6d5f7ebdba3",
      "options": ["Zebra", "Horse Neigh", "Donkey", "Camel"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FFrog_Sound_%231___Sound_Effects(128k).m4a?alt=media&token=94ce1540-97c5-4c2d-9aa9-3ef88e655563",
      "options": ["Duck Quack", "Frog Croak", "Toad", "Bird"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FSound_Effects_-_Footsteps(128k).m4a?alt=media&token=db43e169-2952-4729-be11-d68d0aaddf78",
      "options": ["Typing", "Footsteps", "Running Water", "Drumming"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FREFEREE_WHISTLE_SOUND_EFFECT(128k).m4a?alt=media&token=b806bde6-7bab-42d9-996e-324fb6a6cbb2",
      "options": ["Flute", "Bird Chirp", "Whistle", "Wind Blowing"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FPolice_Siren_%F0%9F%9A%A8_Sound_Effect_-__10_Seconds_(128k).m4a?alt=media&token=18468a16-f41b-4a11-ab3f-9d244675fa50",
      "options": [
        "Police Siren",
        "Ambulance Siren",
        "Fire Truck Siren",
        "Car Alarm",
      ],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FBear_Sound_Effect(128k).m4a?alt=media&token=50266cb5-879b-4bb7-843c-d6c87b1aa5bb",
      "options": ["Lion Roar", "Tiger Growl", "Bear Growl", "Elephant Trumpet"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FHelicopter_Sound_Effect(128k).m4a?alt=media&token=9c38da2b-cac9-4fbb-b149-b58d5a486114",
      "options": ["Helicopter", "Airplane", "Drone", "Rocket"],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2F10_sec_waterfall_sounds_HD(128k).m4a?alt=media&token=a959b7bb-8022-422c-9a19-5b4eed942660",
      "options": ["Waves Crashing", "River Flow", "Rainfall", "Waterfall"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FBus_stopping_squeaking_breakes_Royalty_Free_Copyright_Free_Sound.m4a?alt=media&token=b0f01e4b-53ad-4b25-a7d4-0f390bc2243b",
      "options": [
        "Motorcycle Engine",
        "Car Engine",
        "Bus Engine",
        "Truck Engine",
      ],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FGlass_Breaking_Sound_Effects(128k).m4a?alt=media&token=ee2cc163-2cfc-4059-b483-bf3c5d4e6370",
      "options": [
        "Glass Breaking",
        "Plate Dropping",
        "Cup Falling",
        "Window Shatter",
      ],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FDrilling_-_Sound_Effect(128k).m4a?alt=media&token=457e913b-edb8-4828-b109-ac0c251e7060",
      "options": [
        "Hammer Hitting Nail",
        "Drilling",
        "Saw Cutting",
        "Screwdriver Turning",
      ],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FTurkey_Gobble_Sound_Effect(128k).m4a?alt=media&token=08651bc7-aac7-4781-99dc-16ee75730e8f",
      "options": ["Duck Quack", "Goose Honk", "Swan Sound", "Turkey Gobble"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FSnake__Hiss__-_Sound_Effect___ProSounds(128k).m4a?alt=media&token=17fa0008-dd61-476b-8a39-64cc5c48d3f6",
      "options": ["Snake Hiss", "Cat Hiss", "Air Leak", "Wind Blow"],
      "correctIndex": 0,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FHeart_Beat_%5BSOUND_EFFECT%5D(128k)%20(1).m4a?alt=media&token=5310d593-9d06-4b33-8734-c773489a5d51",
      "options": ["Typing", "Clock Tick", "Metronome", "Heartbeat"],
      "correctIndex": 3,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FBuffalo_Sound_Effect(128k).m4a?alt=media&token=6da5b416-080e-4a6e-9da0-75447c997d3d",
      "options": ["Cow Moo", "Buffalo", "Elephant Trumpet", "Camel"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2F_Guitar_sound_effects-NO_COPYRIGHT_HD_(128k).m4a?alt=media&token=1369a126-ff84-4622-a1d8-c79ae9fa8ba1",
      "options": ["Violin", "Guitar", "Piano", "Flute"],
      "correctIndex": 1,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FThomas_C2_School_Bus_Engine_Sound_Effect(128k).m4a?alt=media&token=140e0e5e-2cf2-4d79-bcf8-850849ab18d1",
      "options": ["Train Moving", "Subway", "Bus Brakes", "Car Skid"],
      "correctIndex": 2,
    },
    {
      "category": "Sounds",
      "audio":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2FParrot_Natural_Sounds_-_Parrot_Talking(128k).m4a?alt=media&token=a6876c97-707f-40c8-bfa6-d47cf506fe33",
      "options": ["Owl Hoot", "Crow Caw", "Eagle Screech", "Parrot Talk"],
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
