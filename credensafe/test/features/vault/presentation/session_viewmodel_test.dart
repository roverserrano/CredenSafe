import 'package:credensafe/features/vault/presentation/viewmodels/session_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_doubles.dart';

void main() {
  test(
    'stops loading and exposes a friendly error when Supabase is unreachable',
    () async {
      final session = SessionViewModel(
        authRepository: FakeAuthRepository(),
        vaultRepository: FakeVaultRepository(
          fetchError: Exception('Failed host lookup: supabase.co'),
        ),
        auditRepository: FakeAuditRepository(),
      );

      await session.initialize();

      expect(session.isInitializing, isFalse);
      expect(session.currentVault, isNull);
      expect(session.sessionErrorMessage, contains('Supabase'));
    },
  );

  test(
    'sign out locks the vault without changing biometric preference',
    () async {
      final session =
          SessionViewModel(
              authRepository: FakeAuthRepository(),
              vaultRepository: FakeVaultRepository(),
              auditRepository: FakeAuditRepository(),
            )
            ..currentUser = testUser
            ..currentVault = testVault(biometric: true);

      session.unlockWithVaultKey(FakeBiometricService().vaultKey);
      await session.signOut();

      expect(session.unlockedContext, isNull);
      expect(session.currentVault?.isBiometricEnabled, isTrue);
    },
  );
}
