import 'package:flutter/foundation.dart';

import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../domain/repositories/vault_repository.dart';
import 'session_viewmodel.dart';

class UnlockVaultViewModel extends ChangeNotifier {
  UnlockVaultViewModel({
    required VaultRepository vaultRepository,
    required SessionViewModel sessionViewModel,
    required AuditRepository auditRepository,
  })  : _vaultRepository = vaultRepository,
        sessionViewModel = sessionViewModel,
        _auditRepository = auditRepository;

  final VaultRepository _vaultRepository;
  final AuditRepository _auditRepository;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  bool isBiometricLoading = false;
  String? errorMessage;

  Future<bool> unlockWithPassword(String masterPassword) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await sessionViewModel.unlockWithMasterPassword(masterPassword);
      await sessionViewModel.registerAudit(eventType: 'vault_unlocked');
      return true;
    } catch (_) {
      errorMessage = 'Contraseña maestra incorrecta o bóveda inválida';
      await _auditRepository.insertEvent(
        userId: sessionViewModel.currentUser?.id ?? '',
        vaultId: sessionViewModel.currentVault?.id,
        eventType: 'vault_unlock_failed',
        eventStatus: 'failed',
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unlockWithBiometrics() async {
    try {
      isBiometricLoading = true;
      errorMessage = null;
      notifyListeners();
      final canUse = await _vaultRepository.canUseBiometricUnlock();
      if (!canUse) {
        errorMessage = 'Biometría no disponible en este dispositivo';
        return false;
      }
      final approved = await _vaultRepository.promptBiometricUnlock();
      if (!approved) {
        errorMessage = 'La autenticación biométrica fue cancelada o rechazada';
        return false;
      }
      final ok = await sessionViewModel.tryBiometricUnlock();
      if (ok) {
        await sessionViewModel.registerAudit(eventType: 'vault_unlocked_biometric');
      } else {
        errorMessage = 'No hay una clave segura almacenada para este dispositivo';
      }
      return ok;
    } finally {
      isBiometricLoading = false;
      notifyListeners();
    }
  }
}
