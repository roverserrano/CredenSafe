import 'dart:math';

import 'package:credensafe/core/crypto/password_generator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordGeneratorService', () {
    test('generates a password that respects length and enabled buckets', () {
      final service = PasswordGeneratorService(random: Random(7));
      const policy = PasswordPolicy(
        length: 32,
        uppercase: true,
        lowercase: true,
        digits: true,
        symbols: false,
      );

      final generated = service.generate(policy);

      expect(generated.value.length, 32);
      expect(generated.value, matches(RegExp('[A-Z]')));
      expect(generated.value, matches(RegExp('[a-z]')));
      expect(generated.value, matches(RegExp('[0-9]')));
      expect(generated.value, isNot(matches(RegExp(r'[^a-zA-Z0-9]'))));
      expect(generated.entropyBits, greaterThan(100));
    });

    test('avoids ambiguous characters when requested', () {
      final service = PasswordGeneratorService(random: Random(8));
      const policy = PasswordPolicy(length: 64, avoidAmbiguous: true);

      final generated = service.generate(policy);

      expect(generated.value, isNot(contains('0')));
      expect(generated.value, isNot(contains('O')));
      expect(generated.value, isNot(contains('l')));
      expect(generated.value, isNot(contains('1')));
      expect(generated.value, isNot(contains('I')));
    });

    test('generates pronounceable passwords with the requested length', () {
      final service = PasswordGeneratorService(random: Random(9));

      final password = service.generatePronounceablePassword(length: 18);

      expect(password.length, 18);
      expect(password, matches(RegExp(r'^[a-z]+$')));
    });

    test('generates memorable passwords from the localized wordlist', () {
      final service = PasswordGeneratorService(random: Random(10));

      final password = service.generateMemorablePassword(
        wordCount: 4,
        locale: 'es',
      );

      expect(password.split('-'), hasLength(4));
      expect(password, isNot(contains(' ')));
    });

    test('classifies entropy using semantic strength values', () {
      final service = PasswordGeneratorService(random: Random(11));

      expect(
        service.generate(const PasswordPolicy(length: 8)).strength,
        isNotNull,
      );
      expect(service.calculateEntropy('abc'), lessThan(20));
      expect(
        service.calculateEntropy('A1!bcdefghijklmnopqrstuvwxyz'),
        greaterThan(100),
      );
    });
  });
}
