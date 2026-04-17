import '../../domain/models/audit_event.dart';
import '../../domain/repositories/audit_repository.dart';
import '../services/audit_remote_service.dart';

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._remoteService);

  final AuditRemoteService _remoteService;

  @override
  Future<void> insertEvent({
    required String userId,
    String? vaultId,
    String? credentialId,
    required String eventType,
    String eventStatus = 'success',
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    if (userId.isEmpty) return;

    await _remoteService.insertEvent({
      'user_id': userId,
      'vault_id': vaultId,
      'credential_id': credentialId,
      'event_type': eventType,
      'event_status': eventStatus,
      'metadata': metadata,
    });
  }

  @override
  Future<List<AuditEvent>> listEvents(String userId) async {
    final data = await _remoteService.listEvents(userId);
    return data.map(AuditEvent.fromMap).toList();
  }
}
