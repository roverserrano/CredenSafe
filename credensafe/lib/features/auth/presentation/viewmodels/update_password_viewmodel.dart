import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_status.dart';

class UpdatePasswordViewModel extends ChangeNotifier {
  UpdatePasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  PasswordChangeStatus status = PasswordChangeStatus.initial;
  String? message;

  bool get isLoading => status == PasswordChangeStatus.loading;

  Future<bool> updatePassword({required String newPassword}) async {
    status = PasswordChangeStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await _authRepository.updatePassword(
        newPassword: newPassword,
      );
      status = PasswordChangeStatus.success;
      message = result.message;
      return true;
    } on AppException catch (error) {
      status = PasswordChangeStatus.error;
      message = error.message;
      return false;
    } catch (_) {
      status = PasswordChangeStatus.error;
      message = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void markValidating() {
    status = PasswordChangeStatus.validating;
    message = null;
    notifyListeners();
  }
}
