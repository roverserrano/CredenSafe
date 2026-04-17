import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptedPayload {
  EncryptedPayload({
    required this.payloadEncrypted,
    required this.nonceBase64,
  });

  final String payloadEncrypted;
  final String nonceBase64;
}

class EncryptionService {
  const EncryptionService();

  Uint8List randomKey({int length = 32}) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Future<EncryptedPayload> encryptText({
    required String plainText,
    required Uint8List keyBytes,
    Map<String, dynamic>? aad,
  }) async {
    final algorithm = Xchacha20.poly1305Aead();
    final secretKey = SecretKey(keyBytes);
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
      aad: utf8.encode(jsonEncode(aad ?? const <String, dynamic>{})),
    );

    final payload = jsonEncode({
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });

    return EncryptedPayload(
      payloadEncrypted: payload,
      nonceBase64: base64Encode(secretBox.nonce),
    );
  }

  Future<String> decryptText({
    required String payloadEncrypted,
    required String nonceBase64,
    required Uint8List keyBytes,
    Map<String, dynamic>? aad,
  }) async {
    final algorithm = Xchacha20.poly1305Aead();
    final payload = jsonDecode(payloadEncrypted) as Map<String, dynamic>;
    final secretBox = SecretBox(
      base64Decode(payload['cipherText'] as String),
      nonce: base64Decode(nonceBase64),
      mac: Mac(base64Decode(payload['mac'] as String)),
    );

    final bytes = await algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(keyBytes),
      aad: utf8.encode(jsonEncode(aad ?? const <String, dynamic>{})),
    );

    return utf8.decode(bytes);
  }
}
