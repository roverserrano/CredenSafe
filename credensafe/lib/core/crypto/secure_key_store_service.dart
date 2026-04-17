import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageKeys {
  static const cachedVaultKey = 'cached_vault_key';
  static const cachedVaultId = 'cached_vault_id';
  static const biometricEnabled = 'biometric_enabled';
}

class SecureStorageService {
  const SecureStorageService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
