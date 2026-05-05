import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../crypto/secure_key_store_service.dart';
import '../errors/app_exceptions.dart';

const biometricReason = 'Confirma tu identidad para acceder a tu bóveda';

enum BiometricAvailability {
  available,
  notAvailable,
  notEnrolled,
  notSupported,
}

abstract class IBiometricService {
  Future<BiometricAvailability> checkAvailability();
  Future<void> enable({required Uint8List vaultKey});
  Future<void> disable();
  Future<Uint8List> authenticate();
  Future<bool> isEnabled();
}

abstract class LocalAuthenticator {
  Future<bool> canCheckBiometrics();
  Future<bool> isDeviceSupported();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  });
}

class LocalAuthAdapter implements LocalAuthenticator {
  LocalAuthAdapter([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> canCheckBiometrics() => _auth.canCheckBiometrics;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _auth.getAvailableBiometrics();
  }

  @override
  Future<bool> isDeviceSupported() => _auth.isDeviceSupported();

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  }) {
    return _auth.authenticate(
      localizedReason: localizedReason,
      options: options,
    );
  }
}

class BiometricService implements IBiometricService {
  BiometricService({
    required SecureKeyValueStore storage,
    LocalAuthenticator? authenticator,
  }) : _storage = storage,
       _authenticator = authenticator ?? LocalAuthAdapter();

  final SecureKeyValueStore _storage;
  final LocalAuthenticator _authenticator;

  @override
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final isSupported = await _authenticator.isDeviceSupported();
      if (!isSupported) return BiometricAvailability.notSupported;

      final availableBiometrics = await _authenticator.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) {
        return BiometricAvailability.available;
      }

      final canCheck = await _authenticator.canCheckBiometrics();
      return canCheck
          ? BiometricAvailability.notAvailable
          : BiometricAvailability.notEnrolled;
    } on PlatformException catch (error) {
      return _availabilityFromPlatformException(error);
    }
  }

  @override
  Future<void> enable({required Uint8List vaultKey}) async {
    final availability = await checkAvailability();
    _throwIfUnavailable(availability);

    final vaultKeyBase64 = base64Encode(vaultKey);
    await _storage.write(SecureStorageKeys.biometricVaultKey, vaultKeyBase64);
    await _storage.write(SecureStorageKeys.biometricEnabled, 'true');
  }

  @override
  Future<void> disable() async {
    await _storage.delete(SecureStorageKeys.biometricVaultKey);
    await _storage.delete(SecureStorageKeys.cachedVaultKey);
    await _storage.delete(SecureStorageKeys.cachedVaultId);
    await _storage.write(SecureStorageKeys.biometricEnabled, 'false');
  }

  @override
  Future<Uint8List> authenticate() async {
    final availability = await checkAvailability();
    _throwIfUnavailable(availability);

    try {
      final approved = await _authenticator.authenticate(
        localizedReason: biometricReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (!approved) throw BiometricException.cancelled();

      final vaultKeyBase64 =
          await _storage.read(SecureStorageKeys.biometricVaultKey) ??
          await _storage.read(SecureStorageKeys.cachedVaultKey);
      if (vaultKeyBase64 == null) {
        throw BiometricException.missingVaultKey();
      }

      return Uint8List.fromList(base64Decode(vaultKeyBase64));
    } on BiometricException {
      rethrow;
    } on FormatException catch (error) {
      throw BiometricException.missingVaultKey(error);
    } on PlatformException catch (error) {
      throw _exceptionFromPlatformException(error);
    }
  }

  @override
  Future<bool> isEnabled() async {
    final enabled = await _storage.read(SecureStorageKeys.biometricEnabled);
    final vaultKey =
        await _storage.read(SecureStorageKeys.biometricVaultKey) ??
        await _storage.read(SecureStorageKeys.cachedVaultKey);
    return enabled == 'true' && vaultKey != null;
  }

  BiometricAvailability _availabilityFromPlatformException(
    PlatformException error,
  ) {
    final code = error.code.toLowerCase();
    if (code.contains('notenrolled') || code.contains('not_enrolled')) {
      return BiometricAvailability.notEnrolled;
    }
    if (code.contains('notavailable') || code.contains('not_available')) {
      return BiometricAvailability.notAvailable;
    }
    if (code.contains('nothardware') ||
        code.contains('no_hardware') ||
        code.contains('notsupported') ||
        code.contains('not_supported')) {
      return BiometricAvailability.notSupported;
    }
    return BiometricAvailability.notAvailable;
  }

  BiometricException _exceptionFromPlatformException(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('notenrolled') ||
        code.contains('not_enrolled') ||
        code.contains('passcodenotset') ||
        code.contains('passcode_not_set')) {
      return BiometricException.notEnrolled(error);
    }
    if (code.contains('lockedout') || code.contains('locked_out')) {
      return BiometricException.lockedOut(error);
    }
    if (code.contains('notavailable') ||
        code.contains('not_available') ||
        code.contains('nothardware') ||
        code.contains('no_hardware') ||
        code.contains('notsupported') ||
        code.contains('not_supported')) {
      return BiometricException.notAvailable(error);
    }
    if (code.contains('fragment') || code.contains('activity')) {
      return BiometricException.configurationRequired(error);
    }
    if (code.contains('cancel') || code.contains('user')) {
      return BiometricException.cancelled(error);
    }
    return BiometricException(
      'No se pudo iniciar la autenticación biométrica. Usa tu contraseña maestra.',
      code: 'biometric_platform_error',
      cause: error,
    );
  }

  void _throwIfUnavailable(BiometricAvailability availability) {
    switch (availability) {
      case BiometricAvailability.available:
        return;
      case BiometricAvailability.notAvailable:
        throw BiometricException.notAvailable();
      case BiometricAvailability.notEnrolled:
        throw BiometricException.notEnrolled();
      case BiometricAvailability.notSupported:
        throw BiometricException.notSupported();
    }
  }
}
