class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class AppAuthException extends AppException {
  const AppAuthException(super.message, {super.code, super.cause});
}

class VaultException extends AppException {
  const VaultException(super.message, {super.code, super.cause});
}

class CredentialException extends AppException {
  const CredentialException(super.message, {super.code, super.cause});
}

class CryptoException extends AppException {
  const CryptoException(super.message, {super.code, super.cause});
}

class BiometricException extends AppException {
  const BiometricException(super.message, {super.code, super.cause});

  factory BiometricException.notAvailable([Object? cause]) {
    return BiometricException(
      'La biometría no está disponible en este dispositivo.',
      code: 'biometric_not_available',
      cause: cause,
    );
  }

  factory BiometricException.notEnrolled([Object? cause]) {
    return BiometricException(
      'Registra tu huella o Face ID en los ajustes del dispositivo.',
      code: 'biometric_not_enrolled',
      cause: cause,
    );
  }

  factory BiometricException.notSupported([Object? cause]) {
    return BiometricException(
      'Este dispositivo no soporta desbloqueo biométrico.',
      code: 'biometric_not_supported',
      cause: cause,
    );
  }

  factory BiometricException.cancelled([Object? cause]) {
    return BiometricException(
      'La autenticación biométrica fue cancelada.',
      code: 'biometric_cancelled',
      cause: cause,
    );
  }

  factory BiometricException.missingVaultKey([Object? cause]) {
    return BiometricException(
      'No hay una clave segura almacenada para este dispositivo.',
      code: 'biometric_missing_vault_key',
      cause: cause,
    );
  }

  factory BiometricException.lockedOut([Object? cause]) {
    return BiometricException(
      'Demasiados intentos fallidos. Usa tu contraseña maestra o intenta más tarde.',
      code: 'biometric_locked_out',
      cause: cause,
    );
  }

  factory BiometricException.configurationRequired([Object? cause]) {
    return BiometricException(
      'La autenticación biométrica necesita configuración adicional en Android.',
      code: 'biometric_configuration_required',
      cause: cause,
    );
  }
}
