import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exceptions.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static AppException map(Object error) {
    if (error is AppException) return error;
    if (error is SocketException) {
      return AppException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
        code: 'network_error',
      );
    }
    if (error is AuthException) {
      return AppException(_messageForAuthException(error), code: error.statusCode);
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('socket') ||
        raw.contains('connection') ||
        raw.contains('network') ||
        raw.contains('failed host lookup')) {
      return AppException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
        code: 'network_error',
      );
    }

    return AppException(
      'Ocurrió un error inesperado. Intenta nuevamente.',
      code: 'unexpected_auth_error',
    );
  }

  static String _messageForAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already')) {
      return 'El correo ya está registrado.';
    }
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'Las credenciales son incorrectas.';
    }
    if (message.contains('email not confirmed') ||
        message.contains('not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    if (message.contains('password') &&
        (message.contains('weak') ||
            message.contains('short') ||
            message.contains('length'))) {
      return 'La contraseña no cumple los requisitos de seguridad.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos e intenta de nuevo.';
    }
    if (message.contains('user not found')) {
      return 'No existe una cuenta con ese correo.';
    }

    return error.message.isNotEmpty
        ? error.message
        : 'No se pudo completar la operación de autenticación.';
  }
}
