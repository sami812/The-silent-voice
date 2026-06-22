import 'package:the_silent_voice/services/sign_language_service.dart';

/// ## Sign Dictionary
///
/// Key format: "thumb,index,middle,ring,pinky,orientation"
/// Each finger: 1 = extended/straight, 0 = curled into palm.
///
/// ORIENTATION (replaces the old motion system):
///   toward_them  — palm facing outward/camera  → social, directed, questions
///   toward_you   — palm facing inward/self      → feelings, self-reference
///   palm_up      — palm facing ceiling          → requests, offerings
///   palm_down    — palm facing floor            → stop, descriptions, objects
///   side_up      — blade hand, fingers up       → people, places
///   side_forward — blade hand, fingers at camera→ actions, colors, pointing
///
/// Why orientation instead of motion: orientation is a single-frame
/// spatial judgment the vision model can read from one image. Motion
/// requires comparing frames over time, which is less reliable and
/// more sensitive to how steadily the user holds the gesture.
///
/// ICONIC PRINCIPLE: gestures are assigned to words so they feel
/// natural/guessable rather than arbitrary — index pointing at camera
/// = "You", index pointing inward = "Me", open palm up = "Help",
/// flat palm down = "Stop", thumbs up = "Yes", etc.
const Map<String, String> signDictionary = {
  // Palm facing outward — social, directed at others, questions
  '1,1,1,1,1,toward_them': 'Hello',
  '1,1,1,1,0,toward_them': 'Goodbye',
  '1,1,1,0,0,toward_them': 'Thank you',
  '1,1,0,0,0,toward_them': 'Please',
  '0,0,0,0,0,toward_them': 'Sorry',
  '1,0,0,0,0,toward_them': 'Yes',
  '0,0,0,0,1,toward_them': 'No',
  '0,0,1,1,1,toward_them': 'Okay',
  '0,1,0,0,0,toward_them': 'You',
  '0,1,1,0,0,toward_them': 'Where',
  '0,1,1,1,0,toward_them': 'Who',
  '0,1,1,1,1,toward_them': 'What',
  '1,0,1,1,1,toward_them': 'Why',
  '1,1,0,1,1,toward_them': 'How',

  // Palm facing inward/self — feelings, self-reference
  '0,1,0,0,0,toward_you': 'Me',
  '0,0,0,0,0,toward_you': 'Love',
  '1,1,1,1,1,toward_you': 'Happy',
  '0,1,1,1,1,toward_you': 'Sad',
  '1,0,0,0,0,toward_you': 'Angry',
  '0,0,0,1,1,toward_you': 'Scared',
  '1,0,1,1,1,toward_you': 'Tired',
  '0,1,0,1,0,toward_you': 'Sick',
  '0,1,0,0,1,toward_you': 'Hurt',
  '0,0,1,1,0,toward_you': 'Hungry',
  '0,0,0,1,0,toward_you': 'Thirsty',
  '1,1,0,0,1,toward_you': 'Good',
  '0,0,1,0,1,toward_you': 'Bad',

  // Palm facing ceiling — requests, offerings, receiving
  '1,1,1,1,1,palm_up': 'Help',
  '1,1,1,0,0,palm_up': 'Want',
  '0,1,1,1,0,palm_up': 'Need',
  '1,0,0,0,1,palm_up': 'More',
  '0,1,0,0,0,palm_up': 'Give',
  '1,1,0,0,0,palm_up': 'Take',
  '0,1,1,0,0,palm_up': 'Come',
  '0,0,0,0,1,palm_up': 'Wait',
  '0,0,0,0,0,palm_up': 'Finished',
  '1,1,1,1,0,palm_up': 'Money',
  '0,0,1,0,0,palm_up': 'Medicine',
  '0,0,0,1,1,palm_up': 'Water',
  '1,0,1,0,0,palm_up': 'Food',

  // Palm facing floor — stopping, descriptions, objects
  '1,1,1,1,1,palm_down': 'Stop',
  '1,0,0,0,1,palm_down': 'Big',
  '0,0,0,0,0,palm_down': 'Small',
  '1,1,1,0,0,palm_down': 'Hot',
  '0,0,0,1,1,palm_down': 'Cold',
  '0,1,0,0,0,palm_down': 'Fast',
  '0,1,1,1,1,palm_down': 'Slow',
  '1,0,1,1,0,palm_down': 'New',
  '0,1,0,1,1,palm_down': 'Old',
  '0,1,1,0,1,palm_down': 'Open',
  '1,0,1,0,0,palm_down': 'Close',
  '0,0,1,1,1,palm_down': 'Bed',
  '1,1,0,1,0,palm_down': 'Home',
  '1,1,0,0,1,palm_down': 'Phone',

  // Blade hand fingers pointing up — people, places
  '1,1,1,1,1,side_up': 'Mother',
  '1,1,1,1,0,side_up': 'Father',
  '1,1,1,0,0,side_up': 'Brother',
  '0,1,1,1,0,side_up': 'Sister',
  '1,1,0,0,0,side_up': 'Son',
  '0,1,1,0,0,side_up': 'Daughter',
  '0,0,0,0,0,side_up': 'Baby',
  '0,1,0,0,1,side_up': 'Friend',
  '1,0,0,0,1,side_up': 'Family',
  '1,0,0,0,0,side_up': 'Bathroom',
  '0,0,1,0,0,side_up': 'School',
  '0,0,0,1,0,side_up': 'Doctor',
  '0,0,1,1,0,side_up': 'When',
  '0,0,0,0,1,side_up': 'Yellow',

  // Blade hand fingers toward camera — actions, colors, pointing
  '0,1,0,0,0,side_forward': 'Go',
  '0,1,1,0,0,side_forward': 'Look',
  '0,0,0,0,1,side_forward': 'Listen',
  '0,0,0,0,0,side_forward': 'Eat',
  '1,0,0,0,0,side_forward': 'Drink',
  '1,1,1,1,1,side_forward': 'Sleep',
  '0,1,0,1,0,side_forward': 'Walk',
  '0,1,1,1,0,side_forward': 'Run',
  '0,0,1,1,0,side_forward': 'Sit',
  '1,0,0,1,0,side_forward': 'Stand',
  '1,1,0,0,1,side_forward': 'Red',
  '0,1,0,1,1,side_forward': 'Blue',
  '1,0,1,0,0,side_forward': 'Green',
};

/// All orientation values used in the dictionary - fed directly into
/// the AI prompt so they can never silently drift out of sync.
final List<String> signOrientations = signDictionary.keys
    .map((key) => key.split(',').last)
    .toSet()
    .toList()
  ..sort();

/// Fuzzy lookup — tries exact match first, then finds the closest entry
/// with the SAME orientation whose finger pattern differs by at most
/// [maxDistance] fingers (Hamming distance). Returns null if no match
/// is within tolerance, or if two entries tie (ambiguous).
String? findClosestSign(
  List<int> fingers,
  String orientation, {
  int maxDistance = 1,
}) {
  assert(fingers.length == 5);

  final exactKey = '${fingers.join(',')},$orientation';
  final exact = signDictionary[exactKey];
  if (exact != null) return exact;

  String? bestWord;
  int bestDistance = maxDistance + 1;
  bool tie = false;

  for (final entry in signDictionary.entries) {
    final parts = entry.key.split(',');
    if (parts.last != orientation) continue;
    final entryFingers = parts.sublist(0, 5).map(int.parse).toList();
    var dist = 0;
    for (var i = 0; i < 5; i++) {
      if (entryFingers[i] != fingers[i]) dist++;
    }
    if (dist > maxDistance) continue;
    if (dist < bestDistance) {
      bestDistance = dist;
      bestWord = entry.value;
      tie = false;
    } else if (dist == bestDistance) {
      tie = true;
    }
  }

  return tie ? null : bestWord;
}
