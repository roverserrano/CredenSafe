import '../../../vault/domain/models/vault_unlock_context.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/credential_repository.dart';

class UpdateCredentialUseCase {
  const UpdateCredentialUseCase(this._repository);

  final CredentialRepository _repository;

  Future<void> call({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) {
    return _repository.updateCredential(
      unlockContext: unlockContext,
      credential: credential,
    );
  }
}
