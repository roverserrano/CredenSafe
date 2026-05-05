import 'dart:typed_data';

import 'package:credensafe/core/errors/app_exceptions.dart';
import 'package:credensafe/features/vault/application/usecases/unlock_vault_use_case.dart';
import 'package:credensafe/features/vault/domain/models/vault_unlock_context.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_doubles.dart';

void main() {
  group('UnlockVaultUseCase', () {
    test('returns the unlock context from the repository', () async {
      final expectedKey = Uint8List.fromList([4, 3, 2, 1]);
      final repository = FakeVaultRepository(
        unlockContext: VaultUnlockContext(
          vaultId: 'vault-1',
          vaultKey: expectedKey,
        ),
      );
      final useCase = UnlockVaultUseCase(repository);

      final result = await useCase(
        vault: testVault(),
        masterPassword: 'valid-master-password',
      );

      expect(result.vaultId, 'vault-1');
      expect(result.vaultKey, orderedEquals(expectedKey));
    });

    test('wraps repository failures as a vault exception', () async {
      final repository = FakeVaultRepository(
        unlockError: StateError('bad key'),
      );
      final useCase = UnlockVaultUseCase(repository);

      expect(
        () => useCase(
          vault: testVault(),
          masterPassword: 'invalid-master-password',
        ),
        throwsA(
          isA<VaultException>().having(
            (error) => error.code,
            'code',
            'vault_unlock_failed',
          ),
        ),
      );
    });
  });
}
