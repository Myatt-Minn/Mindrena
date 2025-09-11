Purchase Model

 final purchaseData = {
        'userId': user.uid,
        'userEmail': user.email,
        'packageId': selectedPackage.value?.id,
        'coins': selectedPackage.value?.coins,
        'price': selectedPackage.value?.price,
        'paymentMethod': paymentMethod.value?.id,
        'paymentMethodName': paymentMethod.value?.name,
        'transactionImageUrl': imageUrl,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };


I 
Normal Question Model

    {
      'category': 'Science & Math',
      'text': 'What is the chemical formula of carbon dioxide?',
      'options': ['CO2', 'C2O', 'CO', 'C2O2'],
      'correctIndex': 0,
    },


Image Question Model
    {
      'text': 'Guess the country of this flag',
      'category': 'Flags',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/flags%2Fgermany.png?alt=media&token=15e81c3b-3da4-4322-a622-f29d5a6f9931',
      'options': ['Germany', 'France', 'Berlin', 'India'],
      'correctIndex': 0,
    },


Audio Question Model
    {
      'category': 'Sounds',
      'audio':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/audios%2Facoustic-guitar-short-intro-ish-live-recording-163329.mp3?alt=media&token=ce77b67b-530d-4b33-a9b9-ce437da8629b',
      'options': ['Acoustic Guitar', 'Piano', 'Violin', 'Flute'],
      'correctIndex': 0,
    },


Memory Question Model
 {
      'category': 'MemorizeImage',
      'image':
          'https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_21_37%20AM.png?alt=media&token=97440ea2-2161-4801-a412-bf54bdd0b130',
      'question': 'What color is the bicycle in the image?',
      'options': ['Red', 'Blue', 'Yellow', 'Green'],
      'correctIndex': 2,
    },


UserModel
  String? uid;
  String username;
  String email;
  String avatarUrl;
  String? currentGameId;
  String? role; // Optional role field
  Map<String, dynamic> stats;
  List<String> friends; // List of friend UIDs
  List<String> friendRequests; // List of pending friend request UIDs
  List<String> sentRequests; // List of sent friend request UIDs
  String fcmToken; // Firebase Cloud Messaging token
  DateTime? createdAt; // Account creation timestamp


NotificationModel
  final int id;
  final int userId;
  final String title;
  final String body;
  final String image;
  final bool isRead;


