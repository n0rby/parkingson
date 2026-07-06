/// Pure parsing of a recognized voice phrase into a [VoiceCommand].
///
/// Two commands are supported on the reminder screen:
///  * ignore this location  ("ignorér lokation", "ignore location", ...)
///  * set the parking time   ("parkeringstid 30 minutter", "en time", ...)
///
/// Danish and English are handled explicitly; digits work in any language.
library;

enum VoiceCommandType { ignoreLocation, setDuration, none }

class VoiceCommand {
  final VoiceCommandType type;
  final Duration? duration;

  const VoiceCommand.ignore()
      : type = VoiceCommandType.ignoreLocation,
        duration = null;
  const VoiceCommand.setDuration(this.duration) : type = VoiceCommandType.setDuration;
  const VoiceCommand.none()
      : type = VoiceCommandType.none,
        duration = null;
}

// Substrings that mean "ignore this location". Kept broad so several phrasings
// match ("ignorer", "ignorér", "ignore").
const _ignoreKeywords = ['ignor', 'undlad', 'spring over', 'skip'];

// Danish + English number words (0–59-ish) commonly spoken for durations.
// The recognizer usually returns digits, so this is a supplement.
const Map<String, int> _numberWords = {
  // Danish
  'nul': 0, 'en': 1, 'et': 1, 'én': 1, 'to': 2, 'tre': 3, 'fire': 4, 'fem': 5,
  'seks': 6, 'syv': 7, 'otte': 8, 'ni': 9, 'ti': 10, 'elleve': 11, 'tolv': 12,
  'tretten': 13, 'fjorten': 14, 'femten': 15, 'seksten': 16, 'sytten': 17,
  'atten': 18, 'nitten': 19, 'tyve': 20, 'femogtyve': 25, 'tredive': 30,
  'fyrre': 40, 'femogfyrre': 45, 'halvtreds': 50,
  // English
  'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
  'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12,
  'thirteen': 13, 'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
  'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30, 'forty': 40,
  'fortyfive': 45, 'fifty': 50,
};

const _hourWords = {'time', 'timer', 't', 'hour', 'hours', 'hr', 'hrs'};
const _minuteWords = {'minut', 'minutter', 'min', 'mins', 'm', 'minute', 'minutes'};

/// Classifies a list of recognizer candidates (best first), returning the first
/// candidate that yields a real command. Falls back to [VoiceCommand.none] if
/// none match.
VoiceCommand classifyBestOf(List<String> candidates) {
  for (final c in candidates) {
    final command = classifyVoiceCommand(c);
    if (command.type != VoiceCommandType.none) return command;
  }
  return const VoiceCommand.none();
}

VoiceCommand classifyVoiceCommand(String rawText) {
  final text = rawText.toLowerCase().trim();
  if (text.isEmpty) return const VoiceCommand.none();

  // Ignore takes priority — it's a discrete, unambiguous action.
  if (_ignoreKeywords.any(text.contains)) return const VoiceCommand.ignore();

  final duration = parseSpokenDuration(text);
  if (duration != null && duration.inMinutes > 0) {
    return VoiceCommand.setDuration(duration);
  }
  return const VoiceCommand.none();
}

/// Extracts a parking duration from spoken text. Returns null if none found.
/// Handles "30 minutter", "en time", "halvanden time", "et kvarter",
/// "trekvarter", "1 time og 30 minutter", English equivalents, etc.
Duration? parseSpokenDuration(String rawText) {
  var text = ' ${rawText.toLowerCase()} ';
  // Normalise separators/punctuation to spaces and split glued number+unit
  // ("30min" -> "30 min") so a single token pass can read them.
  text = text.replaceAll(RegExp(r'[.,;:]'), ' ');
  text = text.replaceAllMapped(
      RegExp(r'(\d)([a-zæøå])'), (m) => '${m.group(1)} ${m.group(2)}');

  var minutes = 0;
  var matched = false;

  // ── Danish idioms first (order matters: longest first) ──────────────────
  // "halvanden time" = 1½ hours = 90 min. Also bare "halvanden".
  if (text.contains('halvanden')) {
    minutes += 90;
    matched = true;
    text = text.replaceAll('halvanden', ' ');
  }
  // "trekvarter" / "tre kvarter" = 45 min.
  if (text.contains('trekvarter') || text.contains('tre kvarter')) {
    minutes += 45;
    matched = true;
    text = text.replaceAll('trekvarter', ' ').replaceAll('tre kvarter', ' ');
  }
  // "et kvarter" / "kvarter" = 15 min ("kvart" too).
  if (RegExp(r'\bkvarter?\b').hasMatch(text)) {
    minutes += 15;
    matched = true;
    text = text.replaceAll(RegExp(r'\bkvarter?\b'), ' ');
  }
  // "en halv time" / "halv time" / "half an hour" = 30 min.
  if (text.contains('halv time') || text.contains('half an hour') ||
      text.contains('half hour')) {
    minutes += 30;
    matched = true;
    text = text
        .replaceAll('en halv time', ' ')
        .replaceAll('halv time', ' ')
        .replaceAll('half an hour', ' ')
        .replaceAll('half hour', ' ');
  }

  // ── Number (digit or word) followed by a unit: "30 minutter", "2 timer",
  //    "en time", "1 time og 30 min" ──────────────────────────────────────
  final tokens = text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  for (var i = 0; i < tokens.length - 1; i++) {
    final n = int.tryParse(tokens[i]) ?? _numberWords[tokens[i]];
    if (n == null) continue;
    final unit = tokens[i + 1];
    if (_hourWords.contains(unit)) {
      minutes += n * 60;
      matched = true;
    } else if (_minuteWords.contains(unit)) {
      minutes += n;
      matched = true;
    }
  }

  if (!matched) return null;
  // Clamp to something sane (1 min … 24 h).
  if (minutes < 1) return null;
  if (minutes > 24 * 60) minutes = 24 * 60;
  return Duration(minutes: minutes);
}
