import '../../domain/repositories/credential_repository.dart';

class DeleteCredentialUseCase {
  const DeleteCredentialUseCase(this._repository);

  final CredentialRepository _repository;

  Future<void> call({required String credentialId}) {
    return _repository.softDeleteCredential(credentialId: credentialId);
  }
}
