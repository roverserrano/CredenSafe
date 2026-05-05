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
  Future<void> updateBiometricPreference({
    required String userId,
    required bool enabled,
  });
}
