import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureKeyValueStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageKeys {
  static const cachedVaultKey = 'cached_vault_key';
  static const cachedVaultId = 'cached_vault_id';
  static const biometricEnabled = 'biometric_enabled';
  static const biometricVaultKey = 'bio_vault_key';
}

class SecureStorageService implements SecureKeyValueStore {
  const SecureStorageService();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
