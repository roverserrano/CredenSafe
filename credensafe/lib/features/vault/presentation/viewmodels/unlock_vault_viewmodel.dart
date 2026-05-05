import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../application/usecases/authenticate_with_biometric_use_case.dart';
import '../../application/usecases/unlock_vault_use_case.dart';
import 'session_viewmodel.dart';

class UnlockVaultViewModel extends ChangeNotifier {
  UnlockVaultViewModel({
    required UnlockVaultUseCase unlockVaultUseCase,
    required AuthenticateWithBiometricUseCase authenticateWithBiometricUseCase,
    required this.sessionViewModel,
    required AuditRepository auditRepository,
  }) : _unlockVaultUseCase = unlockVaultUseCase,
       _authenticateWithBiometricUseCase = authenticateWithBiometricUseCase,
       _auditRepository = auditRepository;

  final UnlockVaultUseCase _unlockVaultUseCase;
  final AuthenticateWithBiometricUseCase _authenticateWithBiometricUseCase;
  final AuditRepository _auditRepository;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  bool isBiometricLoading = false;
  String? errorMessage;

  Future<bool> unlockWithPassword(String masterPassword) async {
    final vault = sessionViewModel.currentVault;
    if (vault == null) return false;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final unlocked = await _unlockVaultUseCase(
        vault: vault,
        masterPassword: masterPassword,
      );
      sessionViewModel.unlockWithVaultKey(unlocked.vaultKey);
      await sessionViewModel.registerAudit(eventType: 'vault_unlocked');
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      await _auditRepository.insertEvent(
        userId: sessionViewModel.currentUser?.id ?? '',
        vaultId: sessionViewModel.currentVault?.id,
        eventType: 'vault_unlock_failed',
        eventStatus: 'failed',
      );
      return false;
    } catch (_) {
      errorMessage = 'Contraseña maestra incorrecta o bóveda inválida';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unlockWithBiometrics() async {
    final user = sessionViewModel.currentUser;
    final vault = sessionViewModel.currentVault;
    if (user == null || vault == null) return false;

    try {
      isBiometricLoading = true;
      errorMessage = null;
      notifyListeners();
      final vaultKey = await _authenticateWithBiometricUseCase(
        userId: user.id,
        vaultId: vault.id,
      );
      sessionViewModel.unlockWithVaultKey(vaultKey);
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'No se pudo desbloquear con biometría';
      return false;
    } finally {
      isBiometricLoading = false;
      notifyListeners();
    }
  }
}
