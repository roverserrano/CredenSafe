import 'package:credensafe/features/setting/presentation/viewmodels/settings_viewmodel.dart';
import 'package:credensafe/features/setting/presentation/views/setting_page.dart';
import 'package:credensafe/features/vault/application/usecases/set_biometric_unlock_use_case.dart';
import 'package:credensafe/features/vault/presentation/viewmodels/session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../test_doubles.dart';

void main() {
  testWidgets('asks for the master password before enabling biometrics', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('Desbloqueo biométrico'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar identidad'), findsOneWidget);
    expect(find.text('Contraseña maestra'), findsOneWidget);
  });
}

Widget _buildPage() {
  final auditRepository = FakeAuditRepository();
  final vaultRepository = FakeVaultRepository(vault: testVault());
  final biometricService = FakeBiometricService();
  final session =
      SessionViewModel(
          authRepository: FakeAuthRepository(),
          vaultRepository: vaultRepository,
          auditRepository: auditRepository,
        )
        ..isInitializing = false
        ..currentUser = testUser
        ..currentVault = testVault();

  final settingsViewModel = SettingsViewModel(
    sessionViewModel: session,
    setBiometricUnlockUseCase: SetBiometricUnlockUseCase(
      vaultRepository: vaultRepository,
      biometricService: biometricService,
      auditRepository: auditRepository,
    ),
    auditRepository: auditRepository,
    authRepository: FakeAuthRepository(),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SessionViewModel>.value(value: session),
      ChangeNotifierProvider<SettingsViewModel>.value(value: settingsViewModel),
    ],
    child: const MaterialApp(home: SettingsPage()),
  );
}
