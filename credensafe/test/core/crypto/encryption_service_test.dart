import 'package:credensafe/core/crypto/encryption_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EncryptionService', () {
    test('encrypts and decrypts text with authenticated data', () async {
      const service = EncryptionService();
      final key = service.randomKey();

      final encrypted = await service.encryptText(
        plainText: 'secret-value',
        keyBytes: key,
        aad: {'credential_id': 'credential-1'},
      );

      final decrypted = await service.decryptText(
        payloadEncrypted: encrypted.payloadEncrypted,
        nonceBase64: encrypted.nonceBase64,
        keyBytes: key,
        aad: {'credential_id': 'credential-1'},
      );

      expect(decrypted, 'secret-value');
    });

    test('rejects decryption when authenticated data changes', () async {
      const service = EncryptionService();
      final key = service.randomKey();

      final encrypted = await service.encryptText(
        plainText: 'secret-value',
        keyBytes: key,
        aad: {'credential_id': 'credential-1'},
      );

      expect(
        () => service.decryptText(
          payloadEncrypted: encrypted.payloadEncrypted,
          nonceBase64: encrypted.nonceBase64,
          keyBytes: key,
          aad: {'credential_id': 'credential-2'},
        ),
        throwsA(anything),
      );
    });
  });
}
