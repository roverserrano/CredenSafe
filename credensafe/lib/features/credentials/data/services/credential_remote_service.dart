import 'package:supabase_flutter/supabase_flutter.dart';

class CredentialRemoteService {
  CredentialRemoteService(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> listCredentials(String vaultId) async {
    final data = await _client
        .from('credentials')
        .select()
        .eq('vault_id', vaultId)
        .order('is_favorite', ascending: false)
        .order('app_name');
    return (data as List)
        .cast<Map<String, dynamic>>()
        .where((item) => item['deleted_at'] == null)
        .toList();
  }

  Future<Map<String, dynamic>> insertCredential(
    Map<String, dynamic> metadata,
  ) async {
    return await _client.from('credentials').insert(metadata).select().single();
  }

  Future<void> insertCredentialBlob(Map<String, dynamic> blobPayload) async {
    await _client.from('credential_secret_blobs').insert(blobPayload);
  }

  Future<Map<String, dynamic>> fetchCredential(String credentialId) async {
    return await _client
        .from('credentials')
        .select()
        .eq('id', credentialId)
        .single();
  }

  Future<Map<String, dynamic>> fetchCredentialBlob(String credentialId) async {
    return await _client
        .from('credential_secret_blobs')
        .select()
        .eq('credential_id', credentialId)
        .single();
  }

  Future<void> updateCredential(
    String credentialId,
    Map<String, dynamic> payload,
  ) async {
    await _client.from('credentials').update(payload).eq('id', credentialId);
  }

  Future<void> updateCredentialBlob(
    String credentialId,
    Map<String, dynamic> payload,
  ) async {
    await _client
        .from('credential_secret_blobs')
        .update(payload)
        .eq('credential_id', credentialId);
  }

  Future<void> softDeleteCredential(String credentialId) async {
    await _client
        .from('credentials')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', credentialId);
  }
}
