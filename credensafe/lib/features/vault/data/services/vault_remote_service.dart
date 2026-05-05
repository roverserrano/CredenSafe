import 'package:supabase_flutter/supabase_flutter.dart';

class VaultRemoteService {
  VaultRemoteService(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> fetchPrimaryVault(String userId) async {
    return await _client
        .from('vaults')
        .select()
        .eq('owner_id', userId)
        .order('created_at')
        .limit(1)
        .maybeSingle();
  }

  Future<void> createVault(Map<String, dynamic> payload) async {
    await _client.from('vaults').insert(payload);
  }

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> payload,
  ) async {
    await _client.from('profiles').upsert({'id': userId, ...payload});
  }
}
