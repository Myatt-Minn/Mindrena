import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindrena/app/data/AdDataModel.dart';

Future<void> populateFirestoreQuestions() async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  // Extended list of questions in each category (20 questions per category)
  final List<Map<String, dynamic>> questions = [
    {
      'category': 'Places',
      'text': 'What is the capital of Japan?',
      'options': ['Kyoto', 'Osaka', 'Tokyo', 'Hiroshima'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'In which country is the Taj Mahal located?',
      'options': ['Nepal', 'India', 'Bangladesh', 'Pakistan'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is known as the Big Apple?',
      'options': ['New York', 'Miami', 'Chicago', 'Los Angeles'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which U.S. state is famous for Hollywood?',
      'options': ['Florida', 'California', 'Nevada', 'Texas'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is known as the City of Love?',
      'options': ['Prague', 'Vienna', 'Paris', 'Venice'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'In which country is Machu Picchu located?',
      'options': ['Brazil', 'Peru', 'Chile', 'Mexico'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which European city has the Eiffel Tower?',
      'options': ['Madrid', 'London', 'Paris', 'Berlin'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'In which country is the city of Rio de Janeiro?',
      'options': ['Brazil', 'Portugal', 'Argentina', 'Spain'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country is known as the Land of the Rising Sun?',
      'options': ['South Korea', 'China', 'Japan', 'Thailand'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'What is the smallest country in the world?',
      'options': ['San Marino', 'Vatican City', 'Liechtenstein', 'Monaco'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which African country is known for the Serengeti National Park?',
      'options': ['South Africa', 'Tanzania', 'Ethiopia', 'Kenya'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is famous for its canals and gondolas?',
      'options': ['Venice', 'Bangkok', 'Amsterdam', 'Bruges'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country is the largest by land area?',
      'options': ['China', 'USA', 'Canada', 'Russia'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which city hosted the 2012 Summer Olympics?',
      'options': ['London', 'Tokyo', 'Beijing', 'Rio de Janeiro'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country has the pyramids of Giza?',
      'options': ['Egypt', 'Italy', 'Greece', 'Spain'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'The Colosseum is located in which city?',
      'options': ['Madrid', 'Athens', 'Rome', 'Cairo'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'What is the largest desert in the world?',
      'options': ['Antarctica', 'Gobi', 'Atlantis', 'Sahara'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which river is the longest in the world?',
      'options': ['Yangtze', 'Amazon', 'Mississippi', 'Nile'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which mountain is the highest in the world?',
      'options': ['Mount Everest', 'Kangchenjunga', 'Mount Fuji', 'K2'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which desert covers much of northern Africa?',
      'options': ['Atacama', 'Mojave', 'Kalahari', 'Sahara'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which city is the capital of South Korea?',
      'options': ['Beijing', 'Seoul', 'Busan', 'Tokyo'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which continent is the Amazon rainforest located on?',
      'options': ['South America', 'Australia', 'Africa', 'Asia'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is known as the Eternal City?',
      'options': ['Cairo', 'Rome', 'Athens', 'Jerusalem'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'What is the capital of Argentina?',
      'options': ['Buenos Aires', 'Rio de Janeiro', 'Lima', 'Santiago'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which sea separates Europe and Africa?',
      'options': ['Black Sea', 'Red Sea', 'Mediterranean', 'Caspian'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which city has the famous landmark Big Ben?',
      'options': ['New York', 'London', 'Berlin', 'Paris'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which country is famous for the ancient ruins of Angkor Wat?',
      'options': ['Cambodia', 'India', 'Vietnam', 'Thailand'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which U.S. state is known as the Sunshine State?',
      'options': ['Texas', 'Florida', 'Hawaii', 'California'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is home to the Kremlin?',
      'options': ['Warsaw', 'Berlin', 'Moscow', 'St. Petersburg'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which island nation is famous for Mount Fuji?',
      'options': ['Japan', 'Philippines', 'Indonésia', 'Taiwan'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country has the city of Havana?',
      'options': ['Colombia', 'Mexico', 'Cuba', 'Spain'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which European country is famous for tulips and windmills?',
      'options': ['Belgium', 'Switzerland', 'Netherlands', 'Denmark'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which country is home to the Dead Sea?',
      'options': ['Israel', 'Jordan', 'Egypt', 'Lebanon'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which Asian city is known as the Lion City?',
      'options': ['Singapore', 'Jakarta', 'Bangkok', 'Hong Kong'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is known for the Brandenburg Gate?',
      'options': ['Warsaw', 'Munich', 'Berlin', 'Vienna'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which country is known as the Land of Fire and Ice?',
      'options': ['Finland', 'Norway', 'Iceland', 'Greenland'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which country has the ancient city of Carthage?',
      'options': ['Tunisia', 'Italy', 'Egypt', 'Greece'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is famous for the Blue Mosque?',
      'options': ['Athens', 'Baghdad', 'Cairo', 'Istanbul'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which country is home to the Great Wall?',
      'options': ['China', 'Korea', 'Mongolia', 'Japan'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country has Mount Elbrus, the highest in Europe?',
      'options': ['Italy', 'Russia', 'France', 'Switzerland'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which city is famous for its canals and gondolas?',
      'options': ['Amsterdam', 'Venice', 'Bruges', 'Bangkok'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which European country is known for chocolate and waffles?',
      'options': ['France', 'Netherlands', 'Switzerland', 'Belgium'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which European country is famous for pasta and pizza?',
      'options': ['Greece', 'France', 'Italy', 'Spain'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which city is famous for the skyline of Marina Bay Sands?',
      'options': ['Singapore', 'Dubai', 'Hong Kong', 'Shanghai'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is home to the Angkor Wat temple complex?',
      'options': ['Hanoi', 'Siem Reap', 'Bangkok', 'Jakarta'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which city is the capital of Indonesia?',
      'options': ['Bandung', 'Bali', 'Surabaya', 'Jakarta'],
      'correctIndex': 3,
    },
    {
      'category': 'Places',
      'text': 'Which country has the Taj Mahal?',
      'options': ['India', 'Bangladesh', 'Nepal', 'Pakistan'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country is home to the Sahara Desert?',
      'options': ['Algeria', 'Libya', 'Morocco', 'Egypt'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is famous for Table Mountain?',
      'options': ['Johannesburg', 'Durban', 'Cape Town', 'Nairobi'],
      'correctIndex': 2,
    },
    {
      'category': 'Places',
      'text': 'Which city is the capital of Vietnam?',
      'options': ['Hue', 'Hanoi', 'Da Nang', 'Ho Chi Minh City'],
      'correctIndex': 1,
    },
    {
      'category': 'Places',
      'text': 'Which country is known for the ancient city of Bagan?',
      'options': ['Myanmar', 'Thailand', 'India', 'Cambodia'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which country is home to Mount Everest?',
      'options': ['Nepal', 'Bhutan', 'China', 'India'],
      'correctIndex': 0,
    },
    {
      'category': 'Places',
      'text': 'Which city is the capital of Malaysia?',
      'options': ['Singapore', 'Jakarta', 'Bangkok', 'Kuala Lumpur'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the chemical symbol for water?',
      'options': ['CO2', 'H2O', 'O2', 'NaCl'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is 7 x 8?',
      'options': ['58', '60', '54', '56'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'What planet is known as the Red Planet?',
      'options': ['Mercury', 'Mars', 'Venus', 'Jupiter'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Who developed the theory of relativity?',
      'options': [
        'Marie Curie',
        'Isaac Newton',
        'Albert Einstein',
        'Stephen Hawking',
      ],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the powerhouse of the cell?',
      'options': ['Mitochondria', 'Chloroplast', 'Ribosome', 'Nucleus'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What gas do plants absorb from the atmosphere?',
      'options': ['Oxygen', 'Hydrogen', 'Carbon Dioxide', 'Nitrogen'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet has the most moons?',
      'options': ['Mars', 'Saturn', 'Earth', 'Jupiter'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the largest organ in the human body?',
      'options': ['Lung', 'Heart', 'Skin', 'Liver'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'How many bones are in the adult human body?',
      'options': ['210', '201', '206', '215'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'Which element has the atomic number 1?',
      'options': ['Oxygen', 'Hydrogen', 'Helium', 'Carbon'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text':
          'Which organ is responsible for pumping blood throughout the body?',
      'options': ['Liver', 'Heart', 'Lung', 'Kidney'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the speed of light in vacuum (approximate km/s)?',
      'options': ['300,000', '150,000', '450,000', '100,000'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which gas is most abundant in the Earth’s atmosphere?',
      'options': ['Nitrogen', 'Oxygen', 'Carbon Dioxide', 'Hydrogen'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the freezing point of water in Celsius?',
      'options': ['0°C', '32°C', '-10°C', '100°C'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet is closest to the Sun?',
      'options': ['Mercury', 'Venus', 'Earth', 'Mars'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the chemical formula of carbon dioxide?',
      'options': ['CO2', 'C2O', 'CO', 'C2O2'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the largest planet in our solar system?',
      'options': ['Earth', 'Neptune', 'Jupiter', 'Saturn'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet is known for its rings?',
      'options': ['Saturn', 'Uranus', 'Jupiter', 'Neptune'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which is the smallest unit of life?',
      'options': ['Molecule', 'Cell', 'Atom', 'Organ'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What type of energy is stored in food?',
      'options': ['Thermal', 'Chemical', 'Kinetic', 'Nuclear'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'What is the center of an atom called?',
      'options': ['Electron', 'Proton', 'Nucleus', 'Neutron'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet is called the Morning Star or Evening Star?',
      'options': ['Venus', 'Mercury', 'Mars', 'Jupiter'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which force keeps us on the ground?',
      'options': ['Gravity', 'Friction', 'Magnetism', 'Inertia'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which gas do humans exhale?',
      'options': ['Oxygen', 'Nitrogen', 'Hydrogen', 'Carbon Dioxide'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'Which organ filters blood in the human body?',
      'options': ['Heart', 'Kidney', 'Liver', 'Lung'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet has a Great Red Spot?',
      'options': ['Jupiter', 'Mars', 'Saturn', 'Neptune'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet is known as the Blue Planet?',
      'options': ['Neptune', 'Uranus', 'Earth', 'Saturn'],
      'correctIndex': 2,
    },
    {
      'category': 'Science & Math',
      'text': 'Who is known as the father of modern physics?',
      'options': [
        'Isaac Newton',
        'Albert Einstein',
        'Galileo Galilei',
        'Niels Bohr',
      ],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which gas is used in balloons to make them float?',
      'options': ['Helium', 'Hydrogen', 'Oxygen', 'Nitrogen'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet rotates the fastest?',
      'options': ['Saturn', 'Earth', 'Mars', 'Jupiter'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'How many planets are in our solar system?',
      'options': ['9', '10', '7', '8'],
      'correctIndex': 3,
    },
    {
      'category': 'Science & Math',
      'text': 'Which particle has a negative charge?',
      'options': ['Neutron', 'Electron', 'Photon', 'Proton'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet has rings?',
      'options': ['Mars', 'Saturn', 'Earth', 'Venus'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which organ purifies blood in humans?',
      'options': ['Kidney', 'Liver', 'Lung', 'Heart'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which force pulls objects toward Earth?',
      'options': ['Gravity', 'Friction', 'Magnetism', 'Inertia'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which planet has the shortest day?',
      'options': ['Jupiter', 'Earth', 'Mars', 'Venus'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'What is 9 x 9?',
      'options': ['99', '81', '72', '90'],
      'correctIndex': 1,
    },
    {
      'category': 'Science & Math',
      'text': 'Which unit measures frequency?',
      'options': ['Hertz', 'Volt', 'Ampere', 'Joule'],
      'correctIndex': 0,
    },
    {
      'category': 'Science & Math',
      'text': 'Which is the largest planet in the solar system?',
      'options': ['Neptune', 'Saturn', 'Jupiter', 'Earth'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who was the first President of the United States?',
      'options': [
        'Abraham Lincoln',
        'John Adams',
        'George Washington',
        'Thomas Jefferson',
      ],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which language has the most native speakers worldwide?',
      'options': ['Mandarin Chinese', 'English', 'Spanish', 'Hindi'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which continent is known as the "Dark Continent"?',
      'options': ['Africa', 'Asia', 'South America', 'Australia'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which blood type is known as the universal donor?',
      'options': ['AB', 'B', 'A', 'O negative'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the largest internal organ in the human body?',
      'options': ['Liver', 'Heart', 'Kidney', 'Lung'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the national flower of Japan?',
      'options': ['Cherry Blossom', 'Tulip', 'Lotus', 'Rose'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the smallest country in the world?',
      'options': ['San Marino', 'Monaco', 'Liechtenstein', 'Vatican City'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the currency of the United Kingdom?',
      'options': ['Euro', 'Franc', 'Pound Sterling', 'Dollar'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the capital of Canada?',
      'options': ['Ottawa', 'Toronto', 'Vancouver', 'Montreal'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who invented the telephone?',
      'options': [
        'Alexander Graham Bell',
        'Nikola Tesla',
        'Thomas Edison',
        'James Watt',
      ],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which country is known as the Land of the Rising Sun?',
      'options': ['South Korea', 'Japan', 'China', 'Thailand'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'How many players are there in a football (soccer) team?',
      'options': ['11', '12', '10', '9'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the fastest land animal?',
      'options': ['Leopard', 'Lion', 'Cheetah', 'Horse'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the capital city of Egypt?',
      'options': ['Cairo', 'Alexandria', 'Luxor', 'Giza'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which company created the iPhone?',
      'options': ['Samsaung', 'Microsoft', 'Google', 'Apple'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the largest island in the world?',
      'options': ['Madagascar', 'Greenland', 'New Guinea', 'Borneo'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who discovered penicillin?',
      'options': [
        'Marie Curie',
        'Alexander Fleming',
        'Louis Pasteur',
        'Isaac Newton',
      ],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which planet is closest to the Sun?',
      'options': ['Venus', 'Earth', 'Mars', 'Mercury'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the longest bone in the human body?',
      'options': ['Tibia', 'Femur', 'Humerus', 'Fibula'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the largest mammal in the world?',
      'options': ['Blue Whale', 'Elephant', 'Hippopotamus', 'Giraffe'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which continent is the Sahara Desert located in?',
      'options': ['Asia', 'Africa', 'Australia', 'South America'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which ocean is the largest?',
      'options': ['Indian', 'Pacific', 'Atlantic', 'Arctic'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the national sport of Japan?',
      'options': ['Sumo Wrestling', 'Karate', 'Judo', 'Baseball'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'How many bones are in the adult human body?',
      'options': ['214', '220', '198', '206'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which country gifted the Statue of Liberty to the USA?',
      'options': ['Italy', 'France', 'Germany', 'Spain'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the fastest land animal?',
      'options': ['Horse', 'Cheetah', 'Tiger', 'Leopard'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the largest country in Africa by area?',
      'options': ['Nigeria', 'Egypt', 'Algeria', 'Sudan'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which Asian country is known as the "Land of the Rising Sun"?',
      'options': ['South Korea', 'Thailand', 'China', 'Japan'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who was the first man to walk on the moon?',
      'options': [
        'Buzz Aldrin',
        'Neil Armstrong',
        'Yuri Gagarin',
        'Michael Collins',
      ],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which country hosted the 2010 FIFA World Cup?',
      'options': ['Brazil', 'South Africa', 'Germany', 'Spain'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who painted the Mona Lisa?',
      'options': [
        'Leonardo da Vinci',
        'Michelangelo',
        'Pablo Picasso',
        'Vincent van Gogh',
      ],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who was the first female Prime Minister of the United Kingdom?',
      'options': [
        'Indira Gandhi',
        'Margaret Thatcher',
        'Angela Merkel',
        'Golda Meir',
      ],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'What is the smallest country in the world?',
      'options': ['Vatican City', 'Monaco', 'San Marino', 'Liechtenstein'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which ocean is the largest on Earth?',
      'options': ['Atlantic', 'Indian', 'Pacific', 'Arctic'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the largest mammal in the world?',
      'options': ['Giraffe', 'Blue Whale', 'Elephant', 'Hippopotamus'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Who discovered gravity?',
      'options': [
        'Isaac Newton',
        'Galileo Galilei',
        'Albert Einstein',
        'Nikola Tesla',
      ],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which gas do humans breathe in to survive?',
      'options': ['Hydrogen', 'Carbon Dioxide', 'Nitrogen', 'Oxygen'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which fruit is known as the king of fruits?',
      'options': ['Banana', 'Mango', 'Durian', 'Apple'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which instrument has six strings?',
      'options': ['Violin', 'Guitar', 'Piano', 'Drums'],
      'correctIndex': 1,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which bird is known for mimicking human speech?',
      'options': ['Parrot', 'Crow', 'Sparrow', 'Eagle'],
      'correctIndex': 0,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which country is famous for pizza?',
      'options': ['Greece', 'France', 'Spain', 'Italy'],
      'correctIndex': 3,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which is the largest volcano in the world?',
      'options': ['Mount Etna', 'Mount Fuji', 'Mauna Loa', 'Krakatoa'],
      'correctIndex': 2,
    },
    {
      'category': 'General Knowledge',
      'text': 'Which country has the longest coastline?',
      'options': ['Russia', 'USA', 'Canada', 'Australia'],
      'correctIndex': 2,
    },
    {
      "category": "General Knowledge",
      "text": "Which instrument has black and white keys?",
      "options": ["Drums", "Piano", "Violin", "Guitar"],
      "correctIndex": 1,
    },
    {
      "category": "General Knowledge",
      "text": "Which is the largest island in the world?",
      "options": ["Madagascar", "Greenland", "Borneo", "New Guinea"],
      "correctIndex": 1,
    },
    {
      "category": "General Knowledge",
      "text":
          "Which fruit is known as the “King of Fruits” in many Asian countries?",
      "options": ["Banana", "Durian", "Apple", "Mango"],
      "correctIndex": 3,
    },
    {
      "category": "General Knowledge",
      "text": "What is the capital of Italy?",
      "options": ["Milan", "Rome", "Florence", "Venice"],
      "correctIndex": 1,
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

Future<void> populateMemorizeImageQuestions() async {
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
      "options": ["Starfish", "Paintbrush", "Envelope", "Tie"],
      "correctIndex": 0,
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
      "options": ["Airplane", "Flower", "Cookie", "Tie"],
      "correctIndex": 0,
    },
    {
      "category": "MemorizeImage",
      "image":
          "https://firebasestorage.googleapis.com/v0/b/xstore-faa86.appspot.com/o/memorizeImages%2FChatGPT%20Image%20Aug%2024%2C%202025%2C%2011_20_57%20AM.png?alt=media&token=b01c23f4-8681-499e-8c44-62cb340d2b9c",
      "question": "Which of these objects is shown in the image?",
      "options": ["Soccer Ball", "Tie", "Paint Palette", "Keycard"],
      "correctIndex": 0,
    },
  ];

  WriteBatch batch = firestore.batch();

  for (final q in questions) {
    final doc = firestore.collection('memorize_images_questions').doc();
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
