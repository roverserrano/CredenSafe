import 'dart:convert';

import '../../../../core/crypto/biometric_gate_service.dart';
import '../../../../core/crypto/encryption_service.dart';
import '../../../../core/crypto/key_derivation_service.dart';
import '../../../../core/crypto/secure_storage_service.dart';
import '../../domain/models/vault.dart';
import '../../domain/models/vault_unlock_context.dart';
import '../../domain/repositories/vault_repository.dart';
import '../services/vault_remote_service.dart';

class VaultRepositoryImpl implements VaultRepository {
  VaultRepositoryImpl({
    required VaultRemoteService remoteService,
    required EncryptionService encryptionService,
    required KeyDerivationService keyDerivationService,
    required SecureStorageService storageService,
    required BiometricGateService biometricGateService,
  })  : _remoteService = remoteService,
        _encryptionService = encryptionService,
        _keyDerivationService = keyDerivationService,
        _storageService = storageService,
        _biometricGateService = biometricGateService;

  final VaultRemoteService _remoteService;
  final EncryptionService _encryptionService;
  final KeyDerivationService _keyDerivationService;
  final SecureStorageService _storageService;
  final BiometricGateService _biometricGateService;

  @override
  Future<Vault?> fetchPrimaryVault(String userId, {bool biometric = false}) async {
    final vault = await _remoteService.fetchPrimaryVault(userId);
    if (vault == null) return null;

    final profile = await _remoteService.fetchProfile(userId);
    return Vault.fromMap(
      vault,
      biometric: (profile?['is_biometric_enabled'] as bool?) ?? biometric,
    );
  }

  @override
  Future<void> createInitialVault({
    required String userId,
    required String masterPassword,
    required String vaultName,
  }) async {
    final derived = await _keyDerivationService.deriveNewKey(
      password: masterPassword,
    );
    final vaultKey = _encryptionService.randomKey();
    final envelope = await _encryptionService.encryptText(
      plainText: base64Encode(vaultKey),
      keyBytes: derived.keyBytes,
      aad: {'purpose': 'vault_key_envelope'},
    );

    await _remoteService.createVault({
      'owner_id': userId,
      'name': vaultName,
      'vault_key_envelope': envelope.payloadEncrypted,
      'vault_key_envelope_nonce': envelope.nonceBase64,
      'kdf_algorithm': 'argon2id',
      'kdf_salt': derived.saltBase64,
      'kdf_memory_kib': derived.memoryKiB,
      'kdf_iterations': derived.iterations,
      'kdf_parallelism': derived.parallelism,
      'cipher_algorithm': 'xchacha20-poly1305',
    });
  }

  @override
  Future<VaultUnlockContext> unlockVault({
    required Vault vault,
    required String masterPassword,
  }) async {
    final derivedKey = await _keyDerivationService.deriveExistingKey(
      password: masterPassword,
      saltBase64: vault.kdfSalt,
      memoryKiB: vault.kdfMemoryKiB,
      iterations: vault.kdfIterations,
      parallelism: vault.kdfParallelism,
    );

    final vaultKeyBase64 = await _encryptionService.decryptText(
      payloadEncrypted: vault.vaultKeyEnvelope,
      nonceBase64: vault.vaultKeyEnvelopeNonce,
      keyBytes: derivedKey,
      aad: {'purpose': 'vault_key_envelope'},
    );

    return VaultUnlockContext(
      vaultId: vault.id,
      vaultKey: base64Decode(vaultKeyBase64),
    );
  }

  @override
  Future<bool> canUseBiometricUnlock() =>
      _biometricGateService.canUseBiometrics();

  @override
  Future<bool> promptBiometricUnlock() =>
      _biometricGateService.authenticate(
        reason: 'Autentícate para desbloquear tu bóveda en CredenSafe',
      );

  @override
  Future<void> cacheVaultKey({
    required String vaultId,
    required String vaultKeyBase64,
  }) async {
    await _storageService.write(SecureStorageKeys.cachedVaultId, vaultId);
    await _storageService.write(SecureStorageKeys.cachedVaultKey, vaultKeyBase64);
  }

  @override
  Future<void> clearCachedVaultKey() async {
    await _storageService.delete(SecureStorageKeys.cachedVaultId);
    await _storageService.delete(SecureStorageKeys.cachedVaultKey);
  }

  @override
  Future<String?> readCachedVaultKey(String vaultId) async {
    final enabled = await _storageService.read(SecureStorageKeys.biometricEnabled);
    if (enabled != 'true') return null;
    final cachedVaultId = await _storageService.read(SecureStorageKeys.cachedVaultId);
    if (cachedVaultId != vaultId) return null;
    return _storageService.read(SecureStorageKeys.cachedVaultKey);
  }

  @override
  Future<void> setBiometricPreference(bool enabled) async {
    await _storageService.write(
      SecureStorageKeys.biometricEnabled,
      enabled.toString(),
    );
  }
}
