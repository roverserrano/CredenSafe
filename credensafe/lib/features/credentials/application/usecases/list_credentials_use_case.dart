import '../../domain/models/credential_metadata.dart';
import '../../domain/repositories/credential_repository.dart';

class ListCredentialsUseCase {
  const ListCredentialsUseCase(this._repository);

  final CredentialRepository _repository;

  Future<List<CredentialMetadata>> call({required String vaultId}) {
    return _repository.listCredentials(vaultId: vaultId);
  }
}
