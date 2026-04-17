import 'package:supabase_flutter/supabase_flutter.dart';

class AuditRemoteService {
  AuditRemoteService(this._client);

  final SupabaseClient _client;

  Future<void> insertEvent(Map<String, dynamic> payload) async {
    await _client.from('audit_logs').insert(payload);
  }

  Future<List<Map<String, dynamic>>> listEvents(String userId) async {
    final data = await _client
        .from('audit_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
