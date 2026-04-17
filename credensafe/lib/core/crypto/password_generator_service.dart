import 'dart:math';

class PasswordGeneratorService {
  const PasswordGeneratorService();

  String generate({
    int length = 20,
    bool includeSymbols = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const symbols = '!@#%^&*()-_=+[]{};:,.?/';

    final pool = StringBuffer()
      ..write(upper)
      ..write(lower)
      ..write(digits);

    if (includeSymbols) {
      pool.write(symbols);
    }

    final chars = pool.toString();
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
