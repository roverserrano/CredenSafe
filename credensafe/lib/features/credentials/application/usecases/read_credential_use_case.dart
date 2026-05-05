import '../../../vault/domain/models/vault_unlock_context.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/credential_repository.dart';

class ReadCredentialUseCase {
  const ReadCredentialUseCase(this._repository);

  final CredentialRepository _repository;

  Future<DecryptedCredential> call({
    required VaultUnlockContext unlockContext,
    required String credentialId,
  }) {
    return _repository.readCredential(
      unlockContext: unlockContext,
      credentialId: credentialId,
    );
  }
}
