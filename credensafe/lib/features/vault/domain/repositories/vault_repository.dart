import '../models/vault.dart';
import '../models/vault_unlock_context.dart';

abstract class VaultRepository {
  Future<Vault?> fetchPrimaryVault(String userId, {bool biometric = false});
  Future<void> createInitialVault({
    required String userId,
    required String masterPassword,
    required String vaultName,
  });
  Future<VaultUnlockContext> unlockVault({
    required Vault vault,
    required String masterPassword,
  });
  Future<bool> canUseBiometricUnlock();
  Future<bool> promptBiometricUnlock();
  Future<void> cacheVaultKey({
    required String vaultId,
    required String vaultKeyBase64,
  });
  Future<String?> readCachedVaultKey(String vaultId);
  Future<void> clearCachedVaultKey();
  Future<void> setBiometricPreference(bool enabled);
}
