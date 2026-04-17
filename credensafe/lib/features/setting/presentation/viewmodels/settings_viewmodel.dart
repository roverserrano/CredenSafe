import 'package:flutter/foundation.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/viewmodels/auth_form_status.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this.sessionViewModel,
    required AuditRepository auditRepository,
    required AuthRepository authRepository,
  })  : _auditRepository = auditRepository,
        _authRepository = authRepository;

  SessionViewModel sessionViewModel;
  final AuditRepository _auditRepository;
  final AuthRepository _authRepository;

  bool isLoading = false;
  PasswordChangeStatus passwordStatus = PasswordChangeStatus.initial;
  String? passwordMessage;

  bool get isChangingPassword =>
      passwordStatus == PasswordChangeStatus.loading;

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
