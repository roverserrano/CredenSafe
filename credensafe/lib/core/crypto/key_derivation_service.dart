import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class DerivedKeyResult {
  DerivedKeyResult({
    required this.keyBytes,
    required this.saltBase64,
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
  });

  final Uint8List keyBytes;
  final String saltBase64;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
}

class KeyDerivationService {
  const KeyDerivationService();

  Uint8List randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Future<DerivedKeyResult> deriveNewKey({
    required String password,
    int memoryKiB = 19456,
    int iterations = 3,
    int parallelism = 1,
    int outputLength = 32,
  }) async {
    final salt = randomBytes(16);
    final key = await deriveExistingKey(
      password: password,
      saltBase64: base64Encode(salt),
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      outputLength: outputLength,
    );
    return DerivedKeyResult(
      keyBytes: key,
      saltBase64: base64Encode(salt),
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
    );
  }

  Future<Uint8List> deriveExistingKey({
    required String password,
    required String saltBase64,
    required int memoryKiB,
    required int iterations,
    required int parallelism,
    int outputLength = 32,
  }) async {
    final salt = base64Decode(saltBase64);
    final algorithm = Argon2id(
      memory: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: outputLength,
    );
    final secretKey = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return Uint8List.fromList(await secretKey.extractBytes());
  }
}
