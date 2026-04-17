import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_status.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  PasswordRecoveryStatus status = PasswordRecoveryStatus.initial;
  String? message;

  bool get isLoading => status == PasswordRecoveryStatus.loading;

  Future<bool> sendResetEmail({required String email}) async {
    status = PasswordRecoveryStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await _authRepository.sendPasswordResetEmail(
        email: email.trim(),
      );
      status = PasswordRecoveryStatus.emailSent;
      message = result.message;
      return true;
    } on AppException catch (error) {
      status = PasswordRecoveryStatus.error;
      message = error.message;
      return false;
    } catch (_) {
      status = PasswordRecoveryStatus.error;
      message = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void markValidating() {
    status = PasswordRecoveryStatus.validating;
    message = null;
    notifyListeners();
  }
}
