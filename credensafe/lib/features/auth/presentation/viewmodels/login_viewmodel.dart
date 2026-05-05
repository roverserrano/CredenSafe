import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_status.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  LoginStatus status = LoginStatus.unauthenticated;
  String? message;

  bool get isLoading => status == LoginStatus.loading;
  String? get errorMessage => status == LoginStatus.error ? message : null;

  Future<bool> signIn({required String email, required String password}) async {
    status = LoginStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await _authRepository.signIn(
        email: email.trim(),
        password: password,
      );
      status = LoginStatus.authenticated;
      message = result.message;
      return true;
    } on AppException catch (error) {
      status = LoginStatus.error;
      message = error.message;
      return false;
    } catch (_) {
      status = LoginStatus.error;
      message = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void markValidating() {
    status = LoginStatus.validating;
    message = null;
    notifyListeners();
  }
}
