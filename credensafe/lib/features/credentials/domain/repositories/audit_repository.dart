import '../models/audit_event.dart';

abstract class AuditRepository {
  Future<void> insertEvent({
    required String userId,
    String? vaultId,
    String? credentialId,
    required String eventType,
    String eventStatus = 'success',
    Map<String, dynamic> metadata = const <String, dynamic>{},
  });

  Future<List<AuditEvent>> listEvents(String userId);
}
