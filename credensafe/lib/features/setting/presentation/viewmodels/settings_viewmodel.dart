import 'package:flutter/foundation.dart';

import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SessionViewModel sessionViewModel,
    required AuditRepository auditRepository,
  })  : sessionViewModel = sessionViewModel,
        _auditRepository = auditRepository;

  SessionViewModel sessionViewModel;
  final AuditRepository _auditRepository;

  bool isLoading = false;

  Future<void> setBiometricEnabled(bool enabled) async {
    final user = sessionViewModel.currentUser;
    final vault = sessionViewModel.currentVault;
    if (user == null || vault == null) return;

    isLoading = true;
    notifyListeners();
    await sessionViewModel.setBiometricEnabled(enabled);
    await _auditRepository.insertEvent(
      userId: user.id,
      vaultId: vault.id,
      eventType: enabled
          ? 'biometric_unlock_enabled'
          : 'biometric_unlock_disabled',
    );
    isLoading = false;
    notifyListeners();
  }
}
