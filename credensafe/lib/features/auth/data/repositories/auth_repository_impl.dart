import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/auth_operation_result.dart';
import '../../domain/models/auth_session_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_error_mapper.dart';
import '../services/auth_remote_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteService);

  final AuthRemoteService _remoteService;

  @override
  Stream<AppUser?> authStateChanges() {
    return sessionStateChanges().map((event) => event.user);
  }

  @override
  Stream<AuthSessionState> sessionStateChanges() {
    return _remoteService.authStateChanges().map((state) {
      return AuthSessionState(
        event: _mapEvent(state.event),
        user: _mapUser(state.session?.user),
      );
    });
  }

  @override
  AppUser? currentUser() {
    return _mapUser(_remoteService.currentUser());
  }

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteService.signIn(
        email: email,
        password: password,
      );
      final user = _mapUser(response.user);
      return AuthOperationResult(
        status: AuthOperationStatus.authenticated,
        message: 'Sesión iniciada correctamente.',
        user: user,
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> signOut() => _remoteService.signOut();

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteService.signUp(
        email: email,
        password: password,
      );
      final user = _mapUser(response.user);

      if (response.session == null && user != null) {
        return AuthOperationResult(
          status: AuthOperationStatus.confirmationRequired,
          message: 'La cuenta fue creada. Revisa tu correo para confirmarla.',
          user: user,
        );
      }

      if (response.session != null) {
        return AuthOperationResult(
          status: AuthOperationStatus.authenticated,
          message: 'Cuenta creada e inicio de sesión completado.',
          user: user,
        );
      }

      return const AuthOperationResult(
        status: AuthOperationStatus.confirmationRequired,
        message: 'Revisa tu correo para confirmar la cuenta.',
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<AuthOperationResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _remoteService.resetPasswordForEmail(email: email);
      return const AuthOperationResult(
        status: AuthOperationStatus.passwordResetEmailSent,
        message: 'Se envió un correo para restablecer tu contraseña.',
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<AuthOperationResult> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _remoteService.updatePassword(newPassword);
      return const AuthOperationResult(
        status: AuthOperationStatus.passwordUpdated,
        message: 'La contraseña fue actualizada correctamente.',
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<AuthOperationResult> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteService.signIn(email: email, password: currentPassword);
      await _remoteService.updatePassword(newPassword);
      return const AuthOperationResult(
        status: AuthOperationStatus.passwordUpdated,
        message: 'La contraseña fue actualizada correctamente.',
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null || user.email == null) return null;
    return AppUser(id: user.id, email: user.email!);
  }

  AuthSessionEvent _mapEvent(AuthChangeEvent event) {
    return switch (event) {
      AuthChangeEvent.initialSession => AuthSessionEvent.initialSession,
      AuthChangeEvent.signedIn => AuthSessionEvent.signedIn,
      AuthChangeEvent.signedOut => AuthSessionEvent.signedOut,
      AuthChangeEvent.passwordRecovery => AuthSessionEvent.passwordRecovery,
      AuthChangeEvent.userUpdated => AuthSessionEvent.userUpdated,
      AuthChangeEvent.tokenRefreshed => AuthSessionEvent.tokenRefreshed,
      _ => AuthSessionEvent.unknown,
    };
  }
}
