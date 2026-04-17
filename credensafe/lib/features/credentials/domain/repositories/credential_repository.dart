import '../../../vault/domain/models/vault_unlock_context.dart';
import '../models/credential_metadata.dart';
import '../models/decrypted_credential.dart';

abstract class CredentialRepository {
  Future<List<CredentialMetadata>> listCredentials({
    required String vaultId,
  });
  Future<String> createCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  });
  Future<void> updateCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  });
  Future<DecryptedCredential> readCredential({
    required VaultUnlockContext unlockContext,
    required String credentialId,
  });
  Future<void> softDeleteCredential({required String credentialId});
}
