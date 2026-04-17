class AuditEvent {
  AuditEvent({
    required this.id,
    required this.eventType,
    required this.eventStatus,
    required this.createdAt,
    required this.metadata,
  });

  final int id;
  final String eventType;
  final String eventStatus;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  factory AuditEvent.fromMap(Map<String, dynamic> map) {
    return AuditEvent(
      id: map['id'] as int,
      eventType: map['event_type'] as String,
      eventStatus: map['event_status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      metadata: (map['metadata'] as Map<String, dynamic>?) ??
          const <String, dynamic>{},
    );
  }
}
