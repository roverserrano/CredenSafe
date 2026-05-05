import 'dart:math';

enum PasswordStrength { veryWeak, weak, fair, strong, veryStrong }

enum PasswordGeneratorMode { random, pronounceable, memorable }

abstract class IPasswordGeneratorService {
  GeneratedPassword generate(PasswordPolicy policy);
  double calculateEntropy(String password);
  String generateMemorablePassword({
    required int wordCount,
    required String locale,
  });
  String generatePronounceablePassword({required int length});
}

class PasswordPolicy {
  const PasswordPolicy({
    this.length = 20,
    this.uppercase = true,
    this.lowercase = true,
    this.digits = true,
    this.symbols = true,
    this.avoidAmbiguous = true,
    this.customSymbols,
  });

  final int length;
  final bool uppercase;
  final bool lowercase;
  final bool digits;
  final bool symbols;
  final bool avoidAmbiguous;
  final String? customSymbols;

  PasswordPolicy copyWith({
    int? length,
    bool? uppercase,
    bool? lowercase,
    bool? digits,
    bool? symbols,
    bool? avoidAmbiguous,
    String? customSymbols,
  }) {
    return PasswordPolicy(
      length: length ?? this.length,
      uppercase: uppercase ?? this.uppercase,
      lowercase: lowercase ?? this.lowercase,
      digits: digits ?? this.digits,
      symbols: symbols ?? this.symbols,
      avoidAmbiguous: avoidAmbiguous ?? this.avoidAmbiguous,
      customSymbols: customSymbols ?? this.customSymbols,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PasswordPolicy &&
        other.length == length &&
        other.uppercase == uppercase &&
        other.lowercase == lowercase &&
        other.digits == digits &&
        other.symbols == symbols &&
        other.avoidAmbiguous == avoidAmbiguous &&
        other.customSymbols == customSymbols;
  }

  @override
  int get hashCode => Object.hash(
    length,
    uppercase,
    lowercase,
    digits,
    symbols,
    avoidAmbiguous,
    customSymbols,
  );
}

class GeneratedPassword {
  const GeneratedPassword({
    required this.value,
    required this.entropyBits,
    required this.strength,
    required this.generatedAt,
  });

  final String value;
  final double entropyBits;
  final PasswordStrength strength;
  final DateTime generatedAt;

  GeneratedPassword copyWith({
    String? value,
    double? entropyBits,
    PasswordStrength? strength,
    DateTime? generatedAt,
  }) {
    return GeneratedPassword(
      value: value ?? this.value,
      entropyBits: entropyBits ?? this.entropyBits,
      strength: strength ?? this.strength,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GeneratedPassword &&
        other.value == value &&
        other.entropyBits == entropyBits &&
        other.strength == strength &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode => Object.hash(value, entropyBits, strength, generatedAt);
}

class PasswordGeneratorService implements IPasswordGeneratorService {
  PasswordGeneratorService({Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _digits = '0123456789';
  static const _symbols = '!@#%^&*()-_=+[]{};:,.?/';
  static const _ambiguous = {'0', 'O', 'l', '1', 'I'};
  static const _consonants = 'bcdfghjklmnprstvwxyz';
  static const _vowels = 'aeiou';

  @override
  GeneratedPassword generate(PasswordPolicy policy) {
    final safePolicy = policy.copyWith(length: policy.length.clamp(8, 128));
    final buckets = _selectedBuckets(safePolicy);
    final requiredChars = buckets
        .map((bucket) => bucket[_random.nextInt(bucket.length)])
        .toList();
    final pool = buckets.join();
    final remaining = safePolicy.length - requiredChars.length;
    final chars = [
      ...requiredChars,
      ...List.generate(remaining, (_) => pool[_random.nextInt(pool.length)]),
    ]..shuffle(_random);
    final value = chars.join();
    final entropy = calculateEntropy(value);
    return GeneratedPassword(
      value: value,
      entropyBits: entropy,
      strength: _strengthForEntropy(entropy),
      generatedAt: DateTime.now(),
    );
  }

  @override
  double calculateEntropy(String password) {
    if (password.isEmpty) return 0;
    var poolSize = 0;
    if (password.contains(RegExp('[a-z]'))) poolSize += 26;
    if (password.contains(RegExp('[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp('[0-9]'))) poolSize += 10;
    final symbolCount = password
        .split('')
        .where((char) => !RegExp(r'[a-zA-Z0-9]').hasMatch(char))
        .toSet()
        .length;
    if (symbolCount > 0) poolSize += max(symbolCount, _symbols.length);
    if (poolSize == 0) return 0;
    return password.length * (log(poolSize) / ln2);
  }

  @override
  String generateMemorablePassword({
    required int wordCount,
    required String locale,
  }) {
    final words = _Wordlists.forLocale(locale);
    final count = wordCount.clamp(3, 4);
    return List.generate(
      count,
      (_) => words[_random.nextInt(words.length)],
    ).join('-');
  }

  @override
  String generatePronounceablePassword({required int length}) {
    final target = length.clamp(8, 128);
    final buffer = StringBuffer();
    while (buffer.length < target) {
      final pattern = _random.nextBool() ? 'cvc' : 'cvv';
      for (final token in pattern.split('')) {
        if (buffer.length >= target) break;
        final source = token == 'c' ? _consonants : _vowels;
        buffer.write(source[_random.nextInt(source.length)]);
      }
    }
    return buffer.toString();
  }

  List<String> _selectedBuckets(PasswordPolicy policy) {
    final buckets = <String>[];
    if (policy.uppercase) buckets.add(_filterAmbiguous(_upper, policy));
    if (policy.lowercase) buckets.add(_filterAmbiguous(_lower, policy));
    if (policy.digits) buckets.add(_filterAmbiguous(_digits, policy));
    if (policy.symbols) {
      final selectedSymbols = policy.customSymbols?.isNotEmpty == true
          ? policy.customSymbols!
          : _symbols;
      buckets.add(_filterAmbiguous(selectedSymbols, policy));
    }
    if (buckets.isEmpty) {
      buckets.add(_filterAmbiguous(_lower, policy));
    }
    return buckets.where((bucket) => bucket.isNotEmpty).toList();
  }

  String _filterAmbiguous(String value, PasswordPolicy policy) {
    if (!policy.avoidAmbiguous) return value;
    return value.split('').where((char) => !_ambiguous.contains(char)).join();
  }

  PasswordStrength _strengthForEntropy(double entropy) {
    if (entropy < 28) return PasswordStrength.veryWeak;
    if (entropy < 40) return PasswordStrength.weak;
    if (entropy < 60) return PasswordStrength.fair;
    if (entropy < 80) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }
}

class _Wordlists {
  const _Wordlists._();

  static List<String> forLocale(String locale) {
    final language = locale.toLowerCase();
    return language.startsWith('en') ? _english : _spanish;
  }

  static final List<String> _spanish = _expandTo2048(const [
    'agua',
    'aire',
    'alma',
    'amigo',
    'arbol',
    'arena',
    'azul',
    'barco',
    'beso',
    'brisa',
    'cafe',
    'calle',
    'campo',
    'canto',
    'casa',
    'cielo',
    'claro',
    'cobre',
    'costa',
    'duna',
    'eco',
    'faro',
    'flor',
    'fuego',
    'gato',
    'hoja',
    'isla',
    'jardin',
    'lago',
    'luna',
    'luz',
    'mano',
    'mar',
    'mesa',
    'monte',
    'nube',
    'oro',
    'pan',
    'piedra',
    'playa',
    'puente',
    'rio',
    'roble',
    'rosa',
    'sal',
    'senda',
    'sol',
    'sombra',
    'sur',
    'tarde',
    'tierra',
    'tren',
    'valle',
    'vela',
    'verde',
    'viaje',
    'vida',
    'viento',
    'vino',
    'zorro',
    'norte',
    'llave',
    'pluma',
    'rayo',
  ]);

  static final List<String> _english = _expandTo2048(const [
    'apple',
    'anchor',
    'amber',
    'beach',
    'bloom',
    'bridge',
    'brook',
    'candle',
    'cedar',
    'cloud',
    'copper',
    'crystal',
    'dawn',
    'delta',
    'ember',
    'field',
    'forest',
    'garden',
    'harbor',
    'hazel',
    'island',
    'jasmine',
    'lantern',
    'leaf',
    'meadow',
    'mint',
    'moon',
    'north',
    'ocean',
    'olive',
    'pearl',
    'pine',
    'river',
    'rose',
    'shadow',
    'silver',
    'sky',
    'stone',
    'summer',
    'sun',
    'trail',
    'valley',
    'violet',
    'water',
    'willow',
    'wind',
    'winter',
    'wood',
    'yellow',
    'zephyr',
    'maple',
    'coral',
    'flame',
    'quiet',
    'bright',
    'swift',
    'gentle',
    'golden',
    'hidden',
    'honest',
    'lively',
    'simple',
    'steady',
    'tender',
  ]);

  static List<String> _expandTo2048(List<String> seed) {
    const suffixes = [
      '',
      'a',
      'e',
      'i',
      'o',
      'u',
      'al',
      'ar',
      'el',
      'en',
      'ia',
      'io',
      'la',
      'le',
      'li',
      'lo',
      'ma',
      'me',
      'mi',
      'mo',
      'na',
      'ne',
      'ni',
      'no',
      'ra',
      're',
      'ri',
      'ro',
      'sa',
      'se',
      'si',
      'so',
    ];
    final words = <String>[];
    for (final base in seed) {
      for (final suffix in suffixes) {
        words.add('$base$suffix');
        if (words.length == 2048) return words;
      }
    }
    return words;
  }
}
