import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/models/auth_operation_result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_status.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._authRepository);

  final AuthRepository _authRepository;

  RegisterStatus status = RegisterStatus.initial;
  String? message;

  bool get isLoading => status == RegisterStatus.loading;
  String? get errorMessage =>
      status == RegisterStatus.error ? message : null;
  String? get successMessage =>
      status == RegisterStatus.success ||
              status == RegisterStatus.confirmationRequired
          ? message
          : null;

  Future<bool> signUp({required String email, required String password}) async {
    status = RegisterStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(
        email: email.trim(),
        password: password,
      );
      status = result.status == AuthOperationStatus.confirmationRequired
          ? RegisterStatus.confirmationRequired
          : RegisterStatus.success;
      message = result.message;
      return true;
    } on AppException catch (error) {
      status = RegisterStatus.error;
      message = error.message;
      return false;
    } catch (_) {
      status = RegisterStatus.error;
      message = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void markValidating() {
    status = RegisterStatus.validating;
    message = null;
    notifyListeners();
  }
}
