import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> signIn({required String email, required String password}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await _authRepository.signIn(email: email.trim(), password: password);
      return true;
    } catch (error) {
      errorMessage = 'No se pudo iniciar sesión';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
