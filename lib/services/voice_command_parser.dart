/// Pure parsing of a recognized voice phrase into a [VoiceCommand].
///
/// Two commands are supported on the reminder screen:
///  * ignore this location  ("ignorér lokation", "ignore location", ...)
///  * set the parking time   ("parkeringstid 30 minutter", "en time", ...)
///
/// Handles the app's nine languages (da, de, en, es, fi, fr, is, nb, sv).
/// Digits work in any language regardless.
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

// Substrings that mean "ignore this location". "ignor" covers da/en/de/es/fr/
// nb/sv (ignorér/ignore/ignorieren/ignorar/ignorer/ignorera); fi/is need their
// own words.
const _ignoreKeywords = [
  'ignor', 'undlad', 'spring over', 'skip', // da/en/de/es/fr/nb/sv
  'ohita', 'sivuuta', // fi
  'hunsa', 'sleppa', // is
  'hoppa över', 'hopp over', // sv/nb
  // Natural phrases that mirror the on-screen "ignore" button, so the button
  // teaches a spoken command that actually works. Phrases (not lone words) to
  // avoid false positives.
  'stop alarmer her', 'stop alarm her', 'ingen alarm', // da
  'stop alarms here', 'stop alarm here', 'no alarm here', // en
];

// Number words (single tokens) across the nine languages. The recognizer
// usually returns digits, so this is a supplement for spoken-out numbers.
// Keys must be unique — shared Nordic words appear once.
const Map<String, int> _numberWords = {
  // Danish / Norwegian / Swedish (Nordic, largely shared)
  'nul': 0, 'null': 0,
  'en': 1, 'et': 1, 'ett': 1, 'én': 1,
  'to': 2, 'tre': 3,
  'fire': 4, 'fyra': 4,
  'fem': 5,
  'seks': 6, 'sex': 6,
  'syv': 7, 'sju': 7,
  'otte': 8, 'åtte': 8, 'åtta': 8,
  'ni': 9, 'nio': 9,
  'ti': 10, 'tio': 10,
  'elleve': 11, 'elva': 11,
  'tolv': 12,
  'tretten': 13, 'tretton': 13,
  'fjorten': 14, 'fjorton': 14,
  'femten': 15, 'femton': 15,
  'seksten': 16, 'sexton': 16,
  'sytten': 17, 'sytton': 17,
  'atten': 18, 'arton': 18,
  'nitten': 19, 'nitton': 19,
  'tyve': 20, 'tjue': 20, 'tjugo': 20,
  'femogtyve': 25,
  'tredive': 30, 'tretti': 30, 'trettio': 30,
  'fyrre': 40, 'førti': 40, 'fyrtio': 40,
  'femogfyrre': 45, 'førtifem': 45, 'fyrtiofem': 45,
  'halvtreds': 50, 'femti': 50, 'femtio': 50,
  // English
  'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6,
  'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12,
  'thirteen': 13, 'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
  'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30, 'forty': 40,
  'fortyfive': 45, 'fifty': 50, 'sixty': 60,
  // German
  'eins': 1, 'ein': 1, 'eine': 1, 'zwei': 2, 'drei': 3, 'vier': 4, 'fünf': 5,
  'funf': 5, 'sechs': 6, 'sieben': 7, 'acht': 8, 'neun': 9, 'zehn': 10,
  'elf': 11, 'zwölf': 12, 'zwolf': 12, 'dreizehn': 13, 'vierzehn': 14,
  'fünfzehn': 15, 'funfzehn': 15, 'zwanzig': 20, 'dreißig': 30, 'dreissig': 30,
  'vierzig': 40, 'fünfundvierzig': 45, 'funfundvierzig': 45, 'fünfzig': 50,
  'funfzig': 50, 'sechzig': 60,
  // Spanish
  'cero': 0, 'uno': 1, 'una': 1, 'un': 1, 'dos': 2, 'tres': 3, 'cuatro': 4,
  'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9, 'diez': 10,
  'once': 11, 'doce': 12, 'quince': 15, 'veinte': 20, 'treinta': 30,
  'cuarenta': 40, 'cincuenta': 50, 'sesenta': 60,
  // French
  'une': 1, 'deux': 2, 'trois': 3, 'quatre': 4, 'cinq': 5, 'sept': 7, 'huit': 8,
  'neuf': 9, 'dix': 10, 'onze': 11, 'douze': 12, 'quinze': 15, 'vingt': 20,
  'vingt-cinq': 25, 'trente': 30, 'trente-cinq': 35, 'quarante': 40,
  'quarante-cinq': 45, 'cinquante': 50, 'soixante': 60,
  // Finnish
  'yksi': 1, 'kaksi': 2, 'kolme': 3, 'neljä': 4, 'viisi': 5, 'kuusi': 6,
  'seitsemän': 7, 'kahdeksan': 8, 'yhdeksän': 9, 'kymmenen': 10,
  'viisitoista': 15, 'kaksikymmentä': 20, 'kolmekymmentä': 30,
  'neljäkymmentä': 40, 'neljäkymmentäviisi': 45, 'viisikymmentä': 50,
  'kuusikymmentä': 60,
  // Icelandic
  'einn': 1, 'eitt': 1, 'tveir': 2, 'tvær': 2, 'tvö': 2, 'þrír': 3,
  'þrjár': 3, 'þrjú': 3, 'fjórir': 4, 'fjórar': 4, 'fjögur': 4, 'fimm': 5,
  'sjö': 7, 'átta': 8, 'níu': 9, 'tíu': 10, 'fimmtán': 15, 'tuttugu': 20,
  'þrjátíu': 30, 'fjörutíu': 40, 'sextíu': 60,
};

const _hourWords = {
  'time', 'timer', 't', // da/nb
  'hour', 'hours', 'hr', 'hrs', 'h', // en (+ es/fr abbrev)
  'stunde', 'stunden', 'std', // de
  'hora', 'horas', // es
  'heure', 'heures', // fr
  'tunti', 'tuntia', // fi
  'timme', 'timmar', 'tim', // sv
  'klukkustund', 'klukkustundir', 'klukkutími', 'klukkutíma', 'tími', 'tíma',
  'klst', // is
};

const _minuteWords = {
  'minut', 'minutter', 'min', 'mins', 'm', 'minute', 'minutes', // da/en
  'minuten', // de
  'minuto', 'minutos', // es
  'minuutti', 'minuuttia', // fi
  'minutt', // nb
  'minuter', // sv
  'mínúta', 'mínútur', 'mínútu', 'minuta', 'minutur', 'minutu', // is
};

// Fixed phrases → minutes, most specific first. When a group matches, its
// minutes are added once and all its phrases are stripped from the text so the
// number+unit scan below doesn't double-count leftover unit words.
const _durationIdioms = <(int, List<String>)>[
  (90, [
    'halvanden time', 'halvanden', 'halvannen time', 'halvannan timme',
    'en och en halv timme', 'anderthalb stunden', 'eineinhalb stunden',
    'puolitoista tuntia', 'hora y media', "une heure et demie", 'heure et demie',
    'einn og hálfur tími', 'hálfur annar tími',
  ]),
  (45, [
    'trekvarter', 'tre kvarter', 'trekvart', 'dreiviertelstunde',
    "trois quarts d'heure", 'trois quarts',
  ]),
  (30, [
    'en halv time', 'halv time', 'halvtime', 'halbe stunde', 'halben stunde',
    'media hora', 'demi-heure', 'demie heure', 'demi heure', 'puoli tuntia',
    'halv timme', 'halvtimme', 'half an hour', 'half hour', 'hálftími',
    'hálftíma', 'hálfur tími',
  ]),
  (15, [
    'et kvarter', 'kvarter', 'kvart', 'viertelstunde', 'cuarto de hora',
    "quart d'heure", 'vartti', 'varttitunti', 'korter', 'kortér',
    'stundarfjórðungur',
  ]),
];

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
/// "1 time og 30 minutter", and the equivalents in all nine languages.
Duration? parseSpokenDuration(String rawText) {
  var text = ' ${rawText.toLowerCase()} ';
  // Normalise punctuation to spaces and split glued number+unit ("30min" ->
  // "30 min") so a single token pass can read them.
  text = text.replaceAll(RegExp(r'[.,;:]'), ' ');
  text = text.replaceAllMapped(
      RegExp(r'(\d)([a-zæøå])'), (m) => '${m.group(1)} ${m.group(2)}');

  var minutes = 0;
  var matched = false;

  // ── Fixed idioms (half hour, quarter, 1½ hours, ...) ────────────────────
  for (final (mins, phrases) in _durationIdioms) {
    if (phrases.any(text.contains)) {
      minutes += mins;
      matched = true;
      for (final p in phrases) {
        text = text.replaceAll(p, ' ');
      }
    }
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
  if (minutes < 1) return null;
  if (minutes > 24 * 60) minutes = 24 * 60;
  return Duration(minutes: minutes);
}
