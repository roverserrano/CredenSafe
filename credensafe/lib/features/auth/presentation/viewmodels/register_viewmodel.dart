import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> signUp({required String email, required String password}) async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      await _authRepository.signUp(email: email.trim(), password: password);
      successMessage =
          'Cuenta creada. Revisa tu correo si activaste confirmación por email.';
      return true;
    } catch (error) {
      errorMessage = 'No se pudo registrar la cuenta';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
