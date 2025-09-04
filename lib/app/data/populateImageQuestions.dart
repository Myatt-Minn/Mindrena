import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateImageQuestions() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // 15 Flag Questions
  final List<Map<String, dynamic>> questions = [
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fgermany.png?alt=media&token=15e81c3b-3da4-4322-a622-f29d5a6f9931',
      'options': ['Germany', 'France', 'Berlin', 'India'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Ftaiwan.png?alt=media&token=2f55a67b-8352-4e64-9130-a1b26746682e',
      'options': ['Nepal', 'India', 'China', 'Taiwan'],
      'correctIndex': 3,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Ffrance.png?alt=media&token=059adda0-df9f-477c-a742-cc6a0696261f',
      'options': ['Italy', 'France', 'Netherlands', 'Russia'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Findia.png?alt=media&token=6a02b26e-eea9-4ed5-9d90-b188d77e5329',
      'options': ['Bangladesh', 'India', 'Pakistan', 'Sri Lanka'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Frussia.png?alt=media&token=b0458ee9-197f-4376-9ba1-c0d16fd5b631',
      'options': ['Russia', 'Slovakia', 'Serbia', 'Netherlands'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fthailand.png?alt=media&token=5340e9d8-6549-4115-a39a-75b589d77513',
      'options': ['United States', 'Australia', 'Thailand', 'UK'],
      'correctIndex': 2,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fvietnam.png?alt=media&token=0f869660-395f-4d26-91d1-1190a278a79c',
      'options': ['Portugal', 'Vietnam', 'Mexico', 'Italy'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fbrazil.png?alt=media&token=e657af77-b121-4df8-a0be-859cf393dad2',
      'options': ['Brazil', 'Argentina', 'Ecuador', 'Colombia'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fmexico.png?alt=media&token=1a5a605e-d296-47d9-84b6-9250a69f976f',
      'options': ['South Korea', 'China', 'Mexico', 'Singapore'],
      'correctIndex': 2,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fcanada.png?alt=media&token=870bd652-d33f-47ac-8247-1326c1c2fdef',
      'options': ['Canada', 'Austria', 'Switzerland', 'UK'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fturkey.png?alt=media&token=ee846f11-6310-48df-b98c-983b92b02c54',
      'options': ['Tunisia', 'Turkey', 'Pakistan', 'Morocco'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fisrael-flag-png-large.png?alt=media&token=8db0dd7f-4784-4cf2-84ef-e83469c86703',
      'options': ['Israel', 'Lebanon', 'Jordan', 'Syria'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fnorth-korea-flag-png-large.png?alt=media&token=073d0737-dfbb-4830-a8cc-c371b4716f54',
      'options': ['South Korea', 'North Korea', 'Japan', 'China'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fsweden-flag-png-large.png?alt=media&token=3b83e536-5a6d-4d7f-9ec5-e433a38c053d',
      'options': ['Norway', 'Denmark', 'Sweden', 'Finland'],
      'correctIndex': 2,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Flaos-flag-png-large.png?alt=media&token=5a8c8acb-eb90-4ef6-b34a-5f386ee7a2e7',
      'options': ['Thailand', 'Vietnam', 'Laos', 'Cambodia'],
      'correctIndex': 2,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fnepal-flag-png-large.png?alt=media&token=96539167-94f3-44f6-ac98-efeef2eced8c',
      'options': ['India', 'Bhutan', 'Nepal', 'Bangladesh'],
      'correctIndex': 2,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fcambodia-flag-png-large.png?alt=media&token=d48aab29-ceb4-4bb2-850d-b68413471715',
      'options': ['Cambodia', 'Laos', 'Thailand', 'Vietnam'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Findonesia-flag-png-large.png?alt=media&token=113b806f-645a-49f1-ae95-0b12654cc2b1',
      'options': ['Malaysia', 'Indonesia', 'Singapore', 'Monaco'],
      'correctIndex': 1,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fphilippines-flag-png-large.png?alt=media&token=f3cf2fe8-2822-4c41-bbeb-c3a3e4a71fe3',
      'options': ['Philippines', 'Malaysia', 'Thailand', 'Indonesia'],
      'correctIndex': 0,
    },
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fswitzerland-flag-png-large.png?alt=media&token=6cbaf5db-f71f-40a2-8f8e-9f1c5dd6b9de',
      'options': ['Austria', 'Switzerland', 'Denmark', 'Georgia'],
      'correctIndex': 1,
    },
    {
      "text": "Eiffel Tower",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2024/09/21/15/07/eiffel-tower-9064240_1280.jpg ",
      "options": ["Italy", "England", "Spain", "France"],
      "correctIndex": 3,
    },
    {
      "text": "Colosseum",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2025/03/31/21/30/italy-9505450_1280.jpg ",
      "options": ["France", "Italy", "England", "Spain"],
      "correctIndex": 1,
    },
    {
      "text": "Big Ben",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2016/09/14/09/44/big-ben-1669043_1280.jpg ",
      "options": ["Dublin", "Manchester", "London", "Liverpool"],
      "correctIndex": 2,
    },
    {
      "text": "Statue of Liberty",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/06/02/16/14/america-5251611_1280.jpg ",
      "options": ["New York", "Boston", "Washington D.C.", "Chicago"],
      "correctIndex": 0,
    },
    {
      "text": "Sydney Opera House",
      "category": "PlacesImages",
      "image":
          "https://cdn.pixabay.com/photo/2016/03/27/00/01/australia-1281935_1280.jpg",
      "options": ["Australia", "New Zealand", "Canada", "South Africa"],
      "correctIndex": 0,
    },
    {
      "text": "Christ the Redeemer",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/01/31/21/26/brazil-4809014_1280.jpg ",
      "options": ["Brazil", "Argentina", "Peru", "Chile"],
      "correctIndex": 0,
    },
    {
      "text": "Taj Mahal",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2015/07/29/22/56/taj-mahal-866692_1280.jpg ",
      "options": ["India", "Pakistan", "Bangladesh", "Sri Lanka"],
      "correctIndex": 0,
    },
    {
      "text": "Great Wall of China",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2018/05/10/14/36/great-wall-of-china-3387706_1280.jpg ",
      "options": ["Beijing", "Shanghai", "Xi’an", "Chengdu"],
      "correctIndex": 0,
    },
    {
      "text": "Machu Picchu",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2016/09/16/14/24/machu-picchu-1674143_1280.jpg ",
      "options": ["Cusco", "Lima", "Quito", "Bogotá"],
      "correctIndex": 0,
    },
    {
      "text": "Taj Mahal",
      "category": "PlacesImages",
      "image":
          "https://cdn.pixabay.com/photo/2015/07/29/22/56/taj-mahal-866692_1280.jpg ",
      "options": ["New Delhi", "Agra", "Jaipur", "Mumbai"],
      "correctIndex": 1,
    },
    {
      "text": "Pyramids of Giza",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/01/27/01/35/egypt-4796256_1280.jpg ",
      "options": ["Cairo", "Alexandria", "Luxor", "Giza"],
      "correctIndex": 3,
    },
    {
      "text": "Angkor Wat",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2017/10/03/05/58/siem-reap-2811393_1280.jpg ",
      "options": ["Siem Reap", "Phnom Penh", "Battambang", "Sihanoukville"],
      "correctIndex": 0,
    },
    {
      "text": "Mount Fuji",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/05/20/11/12/mt-5195924_1280.jpg ",
      "options": ["Kyoto", "Osaka", "Tokyo", "Shizuoka"],
      "correctIndex": 3,
    },
    {
      "text": "Burj Khalifa",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2016/05/27/19/23/dubai-1420494_1280.jpg  ",
      "options": ["Qatar", "Saudi Arabia", "UAE", "Bahrain"],
      "correctIndex": 2,
    },

    {
      "text": "Niagara Falls",
      "category": "PlacesImages",
      "image":
          " https://plus.unsplash.com/premium_photo-1697730069404-280d3289650f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D ",
      "options": ["Canada", "USA", "Mexico", "Brazil"],
      "correctIndex": 0,
    },
    {
      "text": "Santorini",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/161275/santorini-travel-holidays-vacation-161275.jpeg ",
      "options": ["Greece", "Italy", "Spain", "Turkey"],
      "correctIndex": 0,
    },
    {
      "text": "Stonehenge",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/3793413/pexels-photo-3793413.jpeg ",
      "options": ["Ireland", "England", "Scotland", "Wales"],
      "correctIndex": 1,
    },
    {
      "text": "Sagrada Familia",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2014/11/30/20/46/sagrada-familia-552084_1280.jpg ",
      "options": ["Portugal", "Spain", "Italy", "France"],
      "correctIndex": 1,
    },
    {
      "text": "Acropolis of Athens",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1555993539-1732b0258235?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8QWNyb3BvbGlzJTIwb2YlMjBBdGhlbnN8ZW58MHx8MHx8fDA%3D ",
      "options": ["Greece", "Turkey", "Italy", "Cyprus"],
      "correctIndex": 0,
    },
    {
      "text": "Chichen Itza",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1561577101-aa749bffbb70?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Q2hpY2hlbiUyMEl0emF8ZW58MHx8MHx8fDA%3D ",
      "options": ["Mexico", "Guatemala", "Belize", "Cuba"],
      "correctIndex": 0,
    },
    {
      "text": "Brandenburg Gate",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2013/03/06/15/30/brandenburg-gate-90946_1280.jpg ",
      "options": ["Germany", "Austria", "Switzerland", "Poland"],
      "correctIndex": 0,
    },
    {
      "text": "Mount Rushmore",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/13464687/pexels-photo-13464687.jpeg ",
      "options": ["USA", "Canada", "Mexico", "Chile"],
      "correctIndex": 0,
    },

    {
      "text": "Golden Gate Bridge",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1521747116042-5a810fda9664?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8R29sZGVuJTIwR2F0ZSUyMEJyaWRnZXxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["USA", "Australia", "Canada", "UK"],
      "correctIndex": 0,
    },
    {
      "text": "Hagia Sophia",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/3969150/pexels-photo-3969150.jpeg ",
      "options": ["Turkey", "Greece", "Lebanon", "Egypt"],
      "correctIndex": 0,
    },
    {
      "text": "CN Tower",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2022/09/04/17/07/cn-tower-7432218_1280.jpg ",
      "options": ["USA", "Canada", "UK", "Australia"],
      "correctIndex": 1,
    },
    {
      "text": "Alhambra",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1620677368158-32b1293fac36?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8QWxoYW1icmF8ZW58MHx8MHx8fDA%3D ",
      "options": ["Portugal", "Spain", "France", "Italy"],
      "correctIndex": 1,
    },

    {
      "text": "Blue Mosque",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/19328486/pexels-photo-19328486.jpeg ",
      "options": ["Turkey", "Iran", "Egypt", "Syria"],
      "correctIndex": 0,
    },
    {
      "text": "Edinburgh Castle",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1567802474769-eb1d9ebc9416?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8RWRpbmJ1cmdoJTIwQ2FzdGxlfGVufDB8fDB8fHww ",
      "options": ["England", "Ireland", "Scotland", "Wales"],
      "correctIndex": 2,
    },
    {
      "text": "Times Square",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1548182880-8b7b2af2caa2?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8VGltZXMlMjBTcXVhcmV8ZW58MHx8MHx8fDA%3D ",
      "options": ["USA", "Canada", "Australia", "Brazil"],
      "correctIndex": 0,
    },
    {
      "text": "Shwedagon Pagoda",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/18783419/pexels-photo-18783419.jpeg ",
      "options": ["Thailand", "Myanmar", "Laos", "Cambodia"],
      "correctIndex": 1,
    },
    {
      "text": "Forbidden City",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1577706881850-bf7c7d8906a5?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Rm9yYmlkZGVuJTIwQ2l0eXxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["China", "Japan", "South Korea", "Thailand"],
      "correctIndex": 0,
    },
    {
      "text": "Mont Saint-Michel",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1690474408397-a0fbe72ff7be?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fE1vbnQlMjBTYWludCUyME1pY2hlbHxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["France", "Germany", "Belgium", "Netherlands"],
      "correctIndex": 2,
    },
    {
      "text": "Matterhorn",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1585951619576-6e961950cb60?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWF0dGVyaG9ybnxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Switzerland", "Italy", "Austria", "Germany"],
      "correctIndex": 3,
    },
    {
      "text": "Ha Long Bay",
      "category": "PlacesImages",
      "image":
          " https://media.istockphoto.com/id/537645669/photo/halong-bay-vietnam.jpg?b=1&s=612x612&w=0&k=20&c=IUhOglA4YjeR9yqMvsf9rPRSx7HZqBli--HtRDcR68I= ",
      "options": ["Vietnam", "Thailand", "China", "Philippines"],
      "correctIndex": 2,
    },
    {
      "text": "Salar de Uyuni",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1664272051371-943ce55d7b22?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fFNhbGFyJTIwZGUlMjBVeXVuaXxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Bolivia", "Peru", "Chile", "Argentina"],
      "correctIndex": 1,
    },
    {
      "text": "Cinque Terre",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2019/03/31/14/31/houses-4093227_1280.jpg ",
      "options": ["Italy", "Spain", "France", "Portugal"],
      "correctIndex": 0,
    },
    {
      "text": "Pamukkale",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/3290074/pexels-photo-3290074.jpeg ",
      "options": ["Turkey", "Greece", "Italy", "Spain"],
      "correctIndex": 3,
    },
    {
      "text": "Banff National Park",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/33663480/pexels-photo-33663480.jpeg ",
      "options": ["Canada", "USA", "Norway", "Sweden"],
      "correctIndex": 0,
    },
    {
      "text": "Lake Louise",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/7277037/pexels-photo-7277037.jpeg ",
      "options": ["Canada", "USA", "Norway", "Sweden"],
      "correctIndex": 1,
    },
    {
      "text": "Mount Etna",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/14929274/pexels-photo-14929274.jpeg ",
      "options": ["Italy", "Greece", "Spain", "Turkey"],
      "correctIndex": 3,
    },
    {
      "text": "Victoria Falls",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/695214/pexels-photo-695214.jpeg ",
      "options": ["Zimbabwe", "South Africa", "Zambia", "Botswana"],
      "correctIndex": 2,
    },
    {
      "text": "Rock of Gibraltar",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/32437900/pexels-photo-32437900.jpeg ",
      "options": ["Spain", "UK", "Portugal", "France"],
      "correctIndex": 0,
    },
    {
      "text": "Iguazu Falls",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/04/13/22/17/waterfall-5040208_1280.jpg ",
      "options": ["Argentina", "Brazil", "Chile", "Peru"],
      "correctIndex": 3,
    },
    {
      "text": "Göreme National Park",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/6243243/pexels-photo-6243243.jpeg ",
      "options": ["Turkey", "Greece", "Italy", "Spain"],
      "correctIndex": 1,
    },
    {
      "text": "Komodo Island",
      "category": "PlacesImages",
      "image":
          " https://plus.unsplash.com/premium_photo-1661876927993-bedb3ab87208?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8S29tb2RvJTIwSXNsYW5kfGVufDB8fDB8fHww ",
      "options": ["Indonesia", "Philippines", "Malaysia", "Thailand"],
      "correctIndex": 0,
    },
    {
      "text": "Cappadocia",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/3889724/pexels-photo-3889724.jpeg ",
      "options": ["Turkey", "Greece", "Italy", "Spain"],
      "correctIndex": 2,
    },
    {
      "text": "Banaue Rice Terraces",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/32091983/pexels-photo-32091983.jpeg ",
      "options": ["Philippines", "Indonesia", "Thailand", "Vietnam"],
      "correctIndex": 3,
    },
    {
      "text": "Trolltunga",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1505312917212-9db5bde78aff?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8VHJvbGx0dW5nYXxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Norway", "Sweden", "Finland", "Denmark"],
      "correctIndex": 0,
    },

    {
      "text": "Neuschwanstein Castle",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2014/11/15/23/29/fairytale-532850_1280.jpg  ",
      "options": ["Austria", "Switzerland", "Germany", "France"],
      "correctIndex": 2,
    },
    {
      "text": "Ha Long Bay",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2020/11/10/11/27/ha-long-bay-5729474_1280.jpg ",
      "options": ["Thailand", "Vietnam", "Philippines", "Malaysia"],
      "correctIndex": 1,
    },
    {
      "text": "Mecca Kaaba",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1693590614566-1d3ea9ef32f7?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fE1lY2NhJTIwS2FhYmF8ZW58MHx8MHx8fDA%3D  ",
      "options": ["UAE", "Saudi Arabia", "Qatar", "Oman"],
      "correctIndex": 1,
    },
    {
      "text": "Pamukkale",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2012/02/19/16/21/pamukkale-14986_1280.jpg ",
      "options": ["Turkey", "Greece", "Italy", "Bulgaria"],
      "correctIndex": 0,
    },
    {
      "text": "Burj Al Arab",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2015/09/14/17/31/dubai-939844_1280.jpg ",
      "options": ["Dubai", "Abu Dhabi", "Qatar", "Oman"],
      "correctIndex": 0,
    },
    {
      "text": "Bali Rice Terraces",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1698264855824-95385e9d552a?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8QmFsaSUyMFJpY2UlMjBUZXJyYWNlc3xlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Philippines", "Vietnam", "Indonesia", "Malaysia"],
      "correctIndex": 2,
    },
    {
      "text": "Hallstatt Village",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2023/11/01/11/12/hallstatt-8357170_1280.jpg ",
      "options": ["Austria", "Switzerland", "Germany", "Slovenia"],
      "correctIndex": 0,
    },
    {
      "text": "Petra",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1615811648503-479d06197ff3?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8UGV0cmF8ZW58MHx8MHx8fDA%3D ",
      "options": ["Egypt", "Jordan", "Saudi Arabia", "Syria"],
      "correctIndex": 1,
    },
    {
      "text": "Santorini",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2019/07/30/06/05/oia-4372057_1280.jpg ",
      "options": ["Italy", "Greece", "Spain", "Turkey"],
      "correctIndex": 1,
    },
    {
      "text": "Mount Everest",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2024/09/20/15/58/ai-generated-9061845_1280.jpg ",
      "options": ["Nepal", "China", "India", "Bhutan"],
      "correctIndex": 0,
    },
    {
      "text": "Forbidden City",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/32167833/pexels-photo-32167833.jpeg ",
      "options": ["China", "Japan", "South Korea", "Vietnam"],
      "correctIndex": 0,
    },
    {
      "text": "Hallgrímskirkja",
      "category": "PlacesImages",
      "image":
          " https://cdn.pixabay.com/photo/2017/09/27/20/14/reykjavik-2793273_1280.jpg ",
      "options": ["Norway", "Iceland", "Denmark", "Greenland"],
      "correctIndex": 1,
    },
    {
      "text": "Skellig Michael",
      "category": "PlacesImages",

      "image":
          " https://images.unsplash.com/photo-1627579077914-45cfcd527e1c?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U2tlbGxpZyUyME1pY2hhZWx8ZW58MHx8MHx8fDA%3D ",
      "options": ["Ireland", "Scotland", "Wales", "England"],
      "correctIndex": 0,
    },
    {
      "text": "Teotihuacan",
      "category": "PlacesImages",
      "image":
          " https://images.pexels.com/photos/16880237/pexels-photo-16880237.jpeg ",
      "options": ["Peru", "Mexico", "Ecuador", "Colombia"],
      "correctIndex": 1,
    },
    {
      "text": "Victoria Falls",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1603201236596-eb1a63eb0ede?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8VmljdG9yaWElMjBGYWxsc3xlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Zambia", "Zimbabwe", "South Africa", "Botswana"],
      "correctIndex": 3,
    },
    {
      "text": "Arc de Triomphe",
      "category": "PlacesImages",
      "image":
          " https://images.unsplash.com/photo-1694286433612-cdc3d0c58608?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8QXJjJTIwZGUlMjBUcmlvbXBoZXxlbnwwfHwwfHx8MA%3D%3D ",
      "options": ["Rome", "Paris", "Brussels", "Lyon"],
      "correctIndex": 1,
    },
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('image_questions').doc();

    // Normalize text key
    final text = q['text'] ?? q[' text '] ?? '';
    // Normalize image key
    final image = q['image'] ?? q['place URL'] ?? '';

    batch.set(doc, {
      'text': text.toString().trim(),
      'category': q['category'] ?? 'PlacesImages',
      'image': image.toString().trim(),
      'options': q['options'],
      'correctIndex': q['correctIndex'],
      'randomSeed': random.nextDouble(),
    });
  }

  await batch.commit();
  print(
    'Questions populated successfully with ${questions.length} flag questions!',
  );
}
