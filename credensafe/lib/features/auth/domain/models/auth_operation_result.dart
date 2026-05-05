import 'app_user.dart';

enum AuthOperationStatus {
  authenticated,
  confirmationRequired,
  confirmationEmailResent,
  passwordResetEmailSent,
  passwordUpdated,
}

class AuthOperationResult {
  const AuthOperationResult({
    required this.status,
    required this.message,
    this.user,
  });

  final AuthOperationStatus status;
  final String message;
  final AppUser? user;

  bool get isAuthenticated => status == AuthOperationStatus.authenticated;
}
