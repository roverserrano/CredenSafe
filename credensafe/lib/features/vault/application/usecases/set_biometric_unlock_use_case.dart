import '../../../../core/security/biometric_service.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../domain/models/vault.dart';
import '../../domain/repositories/vault_repository.dart';

class SetBiometricUnlockUseCase {
  const SetBiometricUnlockUseCase({
    required VaultRepository vaultRepository,
    required IBiometricService biometricService,
    required AuditRepository auditRepository,
  }) : _vaultRepository = vaultRepository,
       _biometricService = biometricService,
       _auditRepository = auditRepository;

  final VaultRepository _vaultRepository;
  final IBiometricService _biometricService;
  final AuditRepository _auditRepository;

  Future<BiometricAvailability> checkAvailability() {
    return _biometricService.checkAvailability();
  }

  Future<void> enable({
    required String userId,
    required Vault vault,
    required String masterPassword,
  }) async {
    final unlocked = await _vaultRepository.unlockVault(
      vault: vault,
      masterPassword: masterPassword,
    );
    await _biometricService.enable(vaultKey: unlocked.vaultKey);
    await _vaultRepository.updateBiometricPreference(
      userId: userId,
      enabled: true,
    );
    await _auditRepository.insertEvent(
      userId: userId,
      vaultId: vault.id,
      eventType: 'biometric_enabled',
    );
  }

  Future<void> disable({required String userId, required Vault vault}) async {
    await _biometricService.disable();
    await _vaultRepository.updateBiometricPreference(
      userId: userId,
      enabled: false,
    );
    await _auditRepository.insertEvent(
      userId: userId,
      vaultId: vault.id,
      eventType: 'biometric_disabled',
    );
  }
}
