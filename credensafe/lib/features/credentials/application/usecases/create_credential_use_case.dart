import '../../../vault/domain/models/vault_unlock_context.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/credential_repository.dart';

class CreateCredentialUseCase {
  const CreateCredentialUseCase(this._repository);

  final CredentialRepository _repository;

  Future<String> call({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) {
    return _repository.createCredential(
      unlockContext: unlockContext,
      credential: credential,
    );
  }
}
