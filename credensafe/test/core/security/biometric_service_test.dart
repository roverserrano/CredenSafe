import 'dart:typed_data';

import 'package:credensafe/core/crypto/secure_key_store_service.dart';
import 'package:credensafe/core/errors/app_exceptions.dart';
import 'package:credensafe/core/security/biometric_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_doubles.dart';

void main() {
  group('BiometricService', () {
    test('stores and returns the vault key after biometric approval', () async {
      final store = MemorySecureStore();
      final service = BiometricService(
        storage: store,
        authenticator: FakeLocalAuthenticator(),
      );
      final vaultKey = Uint8List.fromList([9, 8, 7, 6]);

      await service.enable(vaultKey: vaultKey);
      final restored = await service.authenticate();

      expect(store.values[SecureStorageKeys.biometricVaultKey], isNotNull);
      expect(restored, orderedEquals(vaultKey));
    });

    test(
      'reports notEnrolled when device supports auth but has no biometrics',
      () async {
        final service = BiometricService(
          storage: MemorySecureStore(),
          authenticator: FakeLocalAuthenticator(
            canCheck: false,
            availableBiometrics: const [],
          ),
        );

        final availability = await service.checkAvailability();

        expect(availability, BiometricAvailability.notEnrolled);
      },
    );

    test('throws a typed exception when no vault key is stored', () async {
      final service = BiometricService(
        storage: MemorySecureStore(),
        authenticator: FakeLocalAuthenticator(),
      );

      expect(
        service.authenticate,
        throwsA(
          isA<BiometricException>().having(
            (error) => error.code,
            'code',
            'biometric_missing_vault_key',
          ),
        ),
      );
    });
  });
}
