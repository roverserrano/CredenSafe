import 'package:flutter/foundation.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/viewmodels/auth_form_status.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../../vault/application/usecases/set_biometric_unlock_use_case.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this.sessionViewModel,
    required SetBiometricUnlockUseCase setBiometricUnlockUseCase,
    required AuditRepository auditRepository,
    required AuthRepository authRepository,
  }) : _auditRepository = auditRepository,
       _authRepository = authRepository,
       _setBiometricUnlockUseCase = setBiometricUnlockUseCase;

  SessionViewModel sessionViewModel;
  final AuditRepository _auditRepository;
  final AuthRepository _authRepository;
  final SetBiometricUnlockUseCase _setBiometricUnlockUseCase;

  bool isLoading = false;
  BiometricAvailability? biometricAvailability;
  String? securityMessage;
  PasswordChangeStatus passwordStatus = PasswordChangeStatus.initial;
  String? passwordMessage;

  bool get isChangingPassword => passwordStatus == PasswordChangeStatus.loading;

  bool get shouldShowBiometricOption =>
      biometricAvailability != BiometricAvailability.notSupported;

  Future<void> loadBiometricAvailability() async {
    biometricAvailability = await _setBiometricUnlockUseCase
        .checkAvailability();
    notifyListeners();
  }

  Future<bool> setBiometricEnabled(
    bool enabled, {
    String? masterPassword,
  }) async {
    final user = sessionViewModel.currentUser;
    final vault = sessionViewModel.currentVault;
    if (user == null || vault == null) return false;

    try {
      isLoading = true;
      securityMessage = null;
      notifyListeners();

      if (enabled) {
        if (masterPassword == null || masterPassword.isEmpty) {
          securityMessage = 'Confirma tu contraseña maestra para continuar.';
          return false;
        }
        await _setBiometricUnlockUseCase.enable(
          userId: user.id,
          vault: vault,
          masterPassword: masterPassword,
        );
      } else {
        await _setBiometricUnlockUseCase.disable(userId: user.id, vault: vault);
      }

      await sessionViewModel.refreshVault();
      securityMessage = enabled
          ? 'Desbloqueo biométrico activado.'
          : 'Desbloqueo biométrico desactivado.';
      return true;
    } on AppException catch (error) {
      securityMessage = error.message;
      return false;
    } catch (_) {
      securityMessage = 'No se pudo actualizar la seguridad biométrica.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = sessionViewModel.currentUser;
    if (user == null) {
      passwordStatus = PasswordChangeStatus.error;
      passwordMessage = 'Debes iniciar sesión para cambiar la contraseña.';
      notifyListeners();
      return false;
    }

    passwordStatus = PasswordChangeStatus.loading;
    passwordMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.changePassword(
        email: user.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      passwordStatus = PasswordChangeStatus.success;
      passwordMessage = result.message;
      await _auditRepository.insertEvent(
        userId: user.id,
        vaultId: sessionViewModel.currentVault?.id,
        eventType: 'auth_password_changed',
      );
      return true;
    } on AppException catch (error) {
      passwordStatus = PasswordChangeStatus.error;
      passwordMessage = error.message;
      return false;
    } catch (_) {
      passwordStatus = PasswordChangeStatus.error;
      passwordMessage = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void markPasswordValidating() {
    passwordStatus = PasswordChangeStatus.validating;
    passwordMessage = null;
    notifyListeners();
  }
}
