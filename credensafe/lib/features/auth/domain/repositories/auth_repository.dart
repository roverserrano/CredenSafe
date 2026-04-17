import '../models/app_user.dart';
import '../models/auth_operation_result.dart';
import '../models/auth_session_state.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Stream<AuthSessionState> sessionStateChanges();
  AppUser? currentUser();
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  });
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
  });
  Future<AuthOperationResult> sendPasswordResetEmail({required String email});
  Future<AuthOperationResult> updatePassword({required String newPassword});
  Future<AuthOperationResult> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  });
  Future<void> signOut();
}
