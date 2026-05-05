import 'dart:typed_data';

class EncryptedPayload {
  EncryptedPayload({required this.payloadEncrypted, required this.nonceBase64});

  final String payloadEncrypted;
  final String nonceBase64;
}

abstract class ICryptoService {
  Uint8List randomKey({int length = 32});

  Future<EncryptedPayload> encryptText({
    required String plainText,
    required Uint8List keyBytes,
    Map<String, dynamic>? aad,
  });

  Future<String> decryptText({
    required String payloadEncrypted,
    required String nonceBase64,
    required Uint8List keyBytes,
    Map<String, dynamic>? aad,
  });
}
