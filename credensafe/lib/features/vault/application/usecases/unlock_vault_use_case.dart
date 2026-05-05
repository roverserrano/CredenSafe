import '../../../../core/errors/app_exceptions.dart';
import '../../domain/models/vault.dart';
import '../../domain/models/vault_unlock_context.dart';
import '../../domain/repositories/vault_repository.dart';

class UnlockVaultUseCase {
  const UnlockVaultUseCase(this._repository);

  final VaultRepository _repository;

  Future<VaultUnlockContext> call({
    required Vault vault,
    required String masterPassword,
  }) async {
    try {
      return await _repository.unlockVault(
        vault: vault,
        masterPassword: masterPassword,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw VaultException(
        'Contraseña maestra incorrecta o bóveda inválida.',
        code: 'vault_unlock_failed',
        cause: error,
      );
    }
  }
}
