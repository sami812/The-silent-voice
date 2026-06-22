/// ## Sign Dictionary
///
/// Maps a hand-shape "key" to its meaning. The key is built from 5 finger
/// flags (thumb, index, middle, ring, pinky - 1 = extended, 0 = curled)
/// plus a motion category, joined with commas:
///
///   "thumb,index,middle,ring,pinky,motion"
///
/// e.g. "0,0,0,0,0,still" -> "Help"
///
/// VOCABULARY: curated around everyday conversational needs (greetings,
/// requests, feelings, family, common objects, question words, basic
/// descriptors) rather than raw word-frequency or arbitrary nouns -
/// these are the words someone actually reaches for in daily
/// communication, similar to core vocabulary used in AAC (augmentative
/// and alternative communication) tools.
///
/// MOTION SET: intentionally limited to 5 motions that are reliably
/// readable from a 2D camera over a short burst of frames: still, up,
/// down, side, shake. Depth-based motions (forward/toward camera, away
/// from camera) were deliberately excluded - judging distance change
/// from a single 2D camera over ~800ms of frames is unreliable, so
/// rather than guess, those entries were dropped instead of kept as a
/// source of misclassification.
///
/// SIZE: theoretical max with 5 binary fingers x 5 motions is 32 x 5 =
/// 160 possible entries. This dictionary deliberately uses far fewer
/// (~80) - packing the space too densely increases the odds that a
/// near-miss classification (one finger misread) lands on the WRONG
/// neighboring word instead of the right one. Leaving gaps in the
/// combination space is a deliberate reliability buffer, not an
/// oversight.
const Map<String, String> signDictionary = {
  // Group 1: all fingers extended
  '1,1,1,1,1,up': 'Hello',
  '1,1,1,1,1,down': 'Goodbye',
  '1,1,1,1,1,side': 'Thank you',
  '1,1,1,1,1,still': 'Please',

  // Group 2: closed fist
  '0,0,0,0,0,still': 'Sorry',
  '0,0,0,0,0,down': 'Yes',
  '0,0,0,0,0,up': 'No',
  '0,0,0,0,0,shake': 'Okay',

  // Group 3: 3 fingers extended (index, middle, ring)
  '0,1,1,1,0,still': 'Help',
  '0,1,1,1,0,up': 'Want',
  '0,1,1,1,0,side': 'Need',
  '0,1,1,1,0,shake': 'More',

  // Group 4: OK sign
  '0,0,1,1,1,still': 'Stop',
  '0,0,1,1,1,up': 'Wait',
  '0,0,1,1,1,side': 'Finished',
  '0,0,1,1,1,shake': 'Give',

  // Group 5: index finger only
  '0,1,0,0,0,still': 'Take',
  '0,1,0,0,0,up': 'Go',
  '0,1,0,0,0,side': 'Come',
  '0,1,0,0,0,down': 'Happy',
  '0,1,0,0,0,shake': 'Sad',

  // Group 6: phone sign
  '1,1,0,0,1,still': 'Angry',
  '1,1,0,0,1,shake': 'Scared',
  '1,1,0,0,1,side': 'Tired',

  // Group 7: 2 fingers extended (index, middle)
  '0,1,1,0,0,shake': 'Sick',
  '0,1,1,0,0,side': 'Hurt',
  '0,1,1,0,0,up': 'Hungry',
  '0,1,1,0,0,still': 'Thirsty',

  // Group 8: thumb and pinky
  '1,0,0,0,1,still': 'Love',
  '1,0,0,0,1,shake': 'Mother',
  '1,0,0,0,1,side': 'Father',

  // Remaining combinations
  '1,1,0,0,0,up': 'Friend',
  '1,1,0,0,0,still': 'Family',
  '1,1,0,0,0,down': 'Brother',

  '0,1,1,1,1,up': 'Sister',
  '0,1,1,1,1,still': 'Baby',
  '0,1,1,1,1,down': 'Son',

  '1,0,1,1,1,still': 'Daughter',
  '1,0,1,1,1,up': 'Me',
  '1,0,1,1,1,side': 'You',

  '1,1,1,0,0,still': 'Bathroom',
  '1,1,1,0,0,shake': 'Home',
  '1,1,1,0,0,up': 'Water',

  '1,1,1,1,0,still': 'Food',
  '1,1,1,1,0,up': 'Medicine',
  '1,1,1,1,0,shake': 'Phone',

  '0,0,0,1,1,still': 'Money',
  '0,0,0,1,1,shake': 'School',
  '0,0,0,1,1,down': 'Doctor',

  '0,0,1,1,0,still': 'Bed',
  '0,0,1,1,0,shake': 'Big',
  '0,0,1,1,0,up': 'Small',
  '0,0,1,1,0,side': 'Hot',

  '0,1,0,0,1,still': 'Cold',
  '0,1,0,0,1,up': 'Good',
  '0,1,0,0,1,shake': 'Bad',

  '1,0,1,0,1,still': 'Fast',
  '1,0,1,0,1,shake': 'Slow',
  '1,0,1,0,1,side': 'New',

  '1,0,0,1,1,still': 'Old',
  '1,0,0,1,1,side': 'Where',
  '1,0,0,1,1,down': 'Who',

  '1,1,0,1,0,still': 'What',
  '1,1,0,1,0,shake': 'Why',
  '1,1,0,1,0,up': 'How',

  '1,0,1,1,0,still': 'When',
  '1,0,1,1,0,shake': 'Red',
  '1,0,1,1,0,up': 'Blue',

  '0,1,1,0,1,still': 'Green',
  '0,1,1,0,1,shake': 'Yellow',
  '0,1,1,0,1,up': 'Eat',

  '0,1,0,1,1,still': 'Drink',
  '0,1,0,1,1,side': 'Sleep',

  '0,1,0,1,0,still': 'Walk',
  '0,1,0,1,0,up': 'Run',
  '0,1,0,1,0,shake': 'Sit',

  '1,0,0,1,0,up': 'Stand',
  '1,0,0,1,0,down': 'Open',
  '1,0,0,1,0,side': 'Close',

  '0,0,1,0,1,still': 'Look',
  '0,0,0,0,1,still': 'Listen',
};

/// All motion categories actually used in the dictionary above. Fed
/// directly into the AI prompt so the two can never silently drift out
/// of sync - add a new motion to the dictionary and the prompt picks it
/// up automatically, no manual list to maintain in two places.
final List<String> signMotionCategories = signDictionary.keys
    .map((key) => key.split(',').last)
    .toSet()
    .toList()
  ..sort();

/// Finds the dictionary entry matching [fingers] (5 values, each 0 or 1)
/// and [motion]. Tries an exact match first; if that fails, looks for the
/// closest entry with the SAME motion whose finger pattern differs by at
/// most [maxDistance] fingers (Hamming distance) - this tolerates a single
/// misclassified finger instead of failing outright on a near-miss.
///
/// Motion itself is never fuzzy-matched (there's no meaningful "distance"
/// between e.g. "up" and "side" - they're just different, not close or
/// far), only the 5 finger flags are.
///
/// Returns null if there's no entry within tolerance, OR if multiple
/// entries are tied for the closest match (ambiguous - safer to report
/// "unclear" than guess wrong between two equally-likely words).
String? findClosestSign(List<int> fingers, String motion, {int maxDistance = 1}) {
  assert(fingers.length == 5);

  final exactKey = '${fingers.join(',')},$motion';
  final exact = signDictionary[exactKey];
  if (exact != null) return exact;

  String? bestWord;
  int bestDistance = maxDistance + 1;
  bool tie = false;

  for (final entry in signDictionary.entries) {
    final parts = entry.key.split(',');
    final entryMotion = parts.last;
    if (entryMotion != motion) continue;

    final entryFingers = parts.sublist(0, 5).map(int.parse).toList();
    var distance = 0;
    for (var i = 0; i < 5; i++) {
      if (entryFingers[i] != fingers[i]) distance++;
    }
    if (distance > maxDistance) continue;

    if (distance < bestDistance) {
      bestDistance = distance;
      bestWord = entry.value;
      tie = false;
    } else if (distance == bestDistance) {
      tie = true;
    }
  }

  return tie ? null : bestWord;
}
