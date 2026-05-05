import 'package:credensafe/features/credentials/application/usecases/delete_credential_use_case.dart';
import 'package:credensafe/features/credentials/application/usecases/list_credentials_use_case.dart';
import 'package:credensafe/features/credentials/domain/models/credential_metadata.dart';
import 'package:credensafe/features/credentials/domain/models/decrypted_credential.dart';
import 'package:credensafe/features/credentials/domain/repositories/credential_repository.dart';
import 'package:credensafe/features/credentials/presentation/viewmodels/credential_list_viewmodel.dart';
import 'package:credensafe/features/vault/domain/models/vault_unlock_context.dart';
import 'package:credensafe/features/vault/presentation/viewmodels/session_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_doubles.dart';

void main() {
  test('filters credentials locally by application name', () {
    final repository = _FakeCredentialRepository();
    final session = SessionViewModel(
      authRepository: FakeAuthRepository(),
      vaultRepository: FakeVaultRepository(),
      auditRepository: FakeAuditRepository(),
    );
    final vm =
        CredentialListViewModel(
            listCredentialsUseCase: ListCredentialsUseCase(repository),
            deleteCredentialUseCase: DeleteCredentialUseCase(repository),
            sessionViewModel: session,
          )
          ..credentials = [
            _credential('1', 'GitHub'),
            _credential('2', 'Google'),
            _credential('3', 'Supabase'),
          ];

    vm.updateSearchQuery('git');

    expect(vm.filteredCredentials.map((item) => item.appName), ['GitHub']);
  });
}

CredentialMetadata _credential(String id, String appName) {
  final now = DateTime(2026);
  return CredentialMetadata(
    id: id,
    vaultId: 'vault-1',
    appName: appName,
    appUrl: null,
    category: null,
    accountLabel: null,
    loginHint: null,
    emailHint: null,
    phoneHint: null,
    iconName: null,
    isFavorite: false,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeCredentialRepository implements CredentialRepository {
  @override
  Future<String> createCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) async {
    return 'credential-id';
  }

  @override
  Future<List<CredentialMetadata>> listCredentials({
    required String vaultId,
  }) async {
    return [];
  }

  @override
  Future<DecryptedCredential> readCredential({
    required VaultUnlockContext unlockContext,
    required String credentialId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDeleteCredential({required String credentialId}) async {}

  @override
  Future<void> updateCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) async {}
}
