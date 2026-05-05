import 'dart:typed_data';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';

class AuthenticateWithBiometricUseCase {
  const AuthenticateWithBiometricUseCase({
    required IBiometricService biometricService,
    required AuditRepository auditRepository,
  }) : _biometricService = biometricService,
       _auditRepository = auditRepository;

  final IBiometricService _biometricService;
  final AuditRepository _auditRepository;

  Future<Uint8List> call({
    required String userId,
    required String vaultId,
  }) async {
    try {
      final vaultKey = await _biometricService.authenticate();
      await _auditRepository.insertEvent(
        userId: userId,
        vaultId: vaultId,
        eventType: 'biometric_unlocked',
      );
      return vaultKey;
    } on BiometricException catch (error) {
      await _auditRepository.insertEvent(
        userId: userId,
        vaultId: vaultId,
        eventType: 'biometric_failed',
        eventStatus: 'failed',
        metadata: {'reason': error.code ?? 'unknown'},
      );
      rethrow;
    } catch (error) {
      await _auditRepository.insertEvent(
        userId: userId,
        vaultId: vaultId,
        eventType: 'biometric_failed',
        eventStatus: 'failed',
        metadata: {'reason': 'unexpected'},
      );
      throw BiometricException.cancelled(error);
    }
  }
}
