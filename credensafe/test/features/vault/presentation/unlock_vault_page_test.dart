import 'package:credensafe/features/vault/application/usecases/authenticate_with_biometric_use_case.dart';
import 'package:credensafe/features/vault/application/usecases/unlock_vault_use_case.dart';
import 'package:credensafe/features/vault/presentation/viewmodels/session_viewmodel.dart';
import 'package:credensafe/features/vault/presentation/viewmodels/unlock_vault_viewmodel.dart';
import 'package:credensafe/features/vault/presentation/views/unlock_vault_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../test_doubles.dart';

void main() {
  testWidgets('hides biometric unlock when it is disabled', (tester) async {
    await tester.pumpWidget(_buildPage(biometricEnabled: false));

    expect(find.text('Usar biometría'), findsNothing);
    expect(find.text('Desbloquear'), findsOneWidget);
  });

  testWidgets('shows biometric unlock when it is enabled', (tester) async {
    await tester.pumpWidget(_buildPage(biometricEnabled: true));

    expect(find.text('Usar biometría'), findsOneWidget);
  });
}

Widget _buildPage({required bool biometricEnabled}) {
  final auditRepository = FakeAuditRepository();
  final vaultRepository = FakeVaultRepository(
    vault: testVault(biometric: biometricEnabled),
  );
  final session =
      SessionViewModel(
          authRepository: FakeAuthRepository(),
          vaultRepository: vaultRepository,
          auditRepository: auditRepository,
        )
        ..isInitializing = false
        ..currentUser = testUser
        ..currentVault = testVault(biometric: biometricEnabled);

  final unlockViewModel = UnlockVaultViewModel(
    unlockVaultUseCase: UnlockVaultUseCase(vaultRepository),
    authenticateWithBiometricUseCase: AuthenticateWithBiometricUseCase(
      biometricService: FakeBiometricService(),
      auditRepository: auditRepository,
    ),
    sessionViewModel: session,
    auditRepository: auditRepository,
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SessionViewModel>.value(value: session),
      ChangeNotifierProvider<UnlockVaultViewModel>.value(
        value: unlockViewModel,
      ),
    ],
    child: const MaterialApp(home: UnlockVaultPage()),
  );
}
