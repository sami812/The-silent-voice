/// ## Sign Language Decoder
///
/// Dictionary key format: "thumb,index,middle,ring,pinky,motion"
/// Each finger: 1 = extended, 0 = curled.
/// Motions: still | up | down | side | shake
///
/// ICONIC PRINCIPLE: gestures are designed to feel guessable —
/// open palm still = Hello, fist up = Yes, index at viewer = You,
/// index at self = Me, fist at chest = Sorry, phone shape = Phone.
///
/// FUZZY MATCHING: tolerates 1 misclassified finger per lookup
/// (Hamming distance ≤ 1, same motion bucket). Two entries that
/// tie for closest are both discarded — silence is safer than a
/// confident wrong word.
class SignLanguageDecoder {
  static const Map<String, String> _dict = {
    // All fingers extended (1,1,1,1,1)
    '1,1,1,1,1,still': 'Hello',
    '1,1,1,1,1,side':  'Goodbye',
    '1,1,1,1,1,up':    'Help',
    '1,1,1,1,1,down':  'Stop',
    '1,1,1,1,1,shake': 'Happy',

    // Closed fist (0,0,0,0,0)
    '0,0,0,0,0,still': 'Sorry',
    '0,0,0,0,0,up':    'Yes',
    '0,0,0,0,0,down':  'No',
    '0,0,0,0,0,shake': 'Angry',
    '0,0,0,0,0,side':  'Bad',

    // Index only (0,1,0,0,0) - pointing
    '0,1,0,0,0,still': 'You',
    '0,1,0,0,0,up':    'Where',
    '0,1,0,0,0,side':  'Go',
    '0,1,0,0,0,down':  'Me',
    '0,1,0,0,0,shake': 'What',

    // Index + middle (0,1,1,0,0) - peace/eyes
    '0,1,1,0,0,still': 'Look',
    '0,1,1,0,0,up':    'Walk',
    '0,1,1,0,0,side':  'Come',
    '0,1,1,0,0,shake': 'Run',
    '0,1,1,0,0,down':  'Sit',

    // Index + middle + ring (0,1,1,1,0)
    '0,1,1,1,0,still': 'Water',
    '0,1,1,1,0,up':    'Want',
    '0,1,1,1,0,side':  'Need',
    '0,1,1,1,0,shake': 'Food',
    '0,1,1,1,0,down':  'More',

    // Middle + ring + pinky (0,0,1,1,1)
    '0,0,1,1,1,still': 'Okay',
    '0,0,1,1,1,up':    'Good',
    '0,0,1,1,1,side':  'Wait',
    '0,0,1,1,1,shake': 'Give',
    '0,0,1,1,1,down':  'Take',

    // Thumb + index + pinky (1,1,0,0,1) - phone shape
    '1,1,0,0,1,still': 'Phone',
    '1,1,0,0,1,up':    'Who',
    '1,1,0,0,1,side':  'Listen',
    '1,1,0,0,1,shake': 'How',
    '1,1,0,0,1,down':  'Medicine',

    // Thumb + pinky (1,0,0,0,1) - spread
    '1,0,0,0,1,still': 'Family',
    '1,0,0,0,1,up':    'Father',
    '1,0,0,0,1,side':  'Friend',
    '1,0,0,0,1,shake': 'Love',
    '1,0,0,0,1,down':  'Mother',

    // Thumb + index (1,1,0,0,0) - pinch
    '1,1,0,0,0,still': 'Home',
    '1,1,0,0,0,up':    'School',
    '1,1,0,0,0,side':  'Doctor',
    '1,1,0,0,0,shake': 'Money',
    '1,1,0,0,0,down':  'Bed',

    // 4 fingers no thumb (0,1,1,1,1)
    '0,1,1,1,1,still': 'Sad',
    '0,1,1,1,1,up':    'Sister',
    '0,1,1,1,1,side':  'Daughter',
    '0,1,1,1,1,shake': 'Tired',
    '0,1,1,1,1,down':  'Sick',

    // Thumb + middle + ring + pinky (1,0,1,1,1)
    '1,0,1,1,1,still': 'Thank you',
    '1,0,1,1,1,up':    'Please',
    '1,0,1,1,1,side':  'Brother',
    '1,0,1,1,1,shake': 'Son',
    '1,0,1,1,1,down':  'Baby',

    // Thumb + index + middle (1,1,1,0,0)
    '1,1,1,0,0,still': 'Eat',
    '1,1,1,0,0,up':    'Drink',
    '1,1,1,0,0,side':  'Hot',
    '1,1,1,0,0,shake': 'Fast',
    '1,1,1,0,0,down':  'New',

    // 4 fingers no pinky (1,1,1,1,0)
    '1,1,1,1,0,still': 'Hungry',
    '1,1,1,1,0,up':    'Thirsty',
    '1,1,1,1,0,side':  'Finished',
    '1,1,1,1,0,shake': 'Hurt',
    '1,1,1,1,0,down':  'Scared',

    // Ring + pinky (0,0,0,1,1)
    '0,0,0,1,1,still': 'Cold',
    '0,0,0,1,1,up':    'Sleep',
    '0,0,0,1,1,side':  'Old',
    '0,0,0,1,1,shake': 'Slow',
    '0,0,0,1,1,down':  'Small',

    // Middle + ring (0,0,1,1,0)
    '0,0,1,1,0,still': 'Why',
    '0,0,1,1,0,up':    'When',
    '0,0,1,1,0,side':  'Stand',
    '0,0,1,1,0,shake': 'Open',
    '0,0,1,1,0,down':  'Close',

    // Index + pinky (0,1,0,0,1) - devil horns
    '0,1,0,0,1,still': 'Red',
    '0,1,0,0,1,up':    'Blue',
    '0,1,0,0,1,side':  'Green',
    '0,1,0,0,1,shake': 'Yellow',
    '0,1,0,0,1,down':  'Big',

    // Thumb only (1,0,0,0,0)
    '1,0,0,0,0,still': 'Bathroom',
  };

  /// Decodes a finger-state vector + motion into a word.
  /// Tries exact match first, then nearest-neighbour (Hamming ≤ 1,
  /// same motion bucket). Returns "Scanning..." if nothing matches
  /// or if the result is ambiguous (two equally-close entries).
  static String decode(List<int> fingers, String motion) {
    assert(fingers.length == 5);

    // 1. Exact match
    final exactKey = '${fingers.join(',')},$motion';
    if (_dict.containsKey(exactKey)) return _dict[exactKey]!;

    // 2. Fuzzy match — tolerance 1 finger, same motion
    String? bestWord;
    int bestDist = 2; // threshold: only accept distance <= 1
    bool tie = false;

    for (final entry in _dict.entries) {
      final parts = entry.key.split(',');
      if (parts.last != motion) continue;
      final entryFingers = parts.sublist(0, 5).map(int.parse).toList();
      var dist = 0;
      for (var j = 0; j < 5; j++) {
        if (entryFingers[j] != fingers[j]) dist++;
      }
      if (dist < bestDist) {
        bestDist = dist;
        bestWord = entry.value;
        tie = false;
      } else if (dist == bestDist) {
        tie = true;
      }
    }

    return (tie || bestWord == null) ? 'Scanning...' : bestWord;
  }
}
