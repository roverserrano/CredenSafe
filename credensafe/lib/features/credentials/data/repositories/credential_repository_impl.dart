import 'dart:convert';

import '../../../../core/crypto/encryption_service.dart';
import '../../../../core/utils/mask_utils.dart';
import '../../../vault/domain/models/vault_unlock_context.dart';
import '../../domain/models/credential_metadata.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/credential_repository.dart';
import '../services/credential_remote_service.dart';

class CredentialRepositoryImpl implements CredentialRepository {
  CredentialRepositoryImpl({
    required CredentialRemoteService remoteService,
    required EncryptionService encryptionService,
  })  : _remoteService = remoteService,
        _encryptionService = encryptionService;

  final CredentialRemoteService _remoteService;
  final EncryptionService _encryptionService;

  @override
  Future<String> createCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) async {
    final metadata = {
      'vault_id': unlockContext.vaultId,
      'app_name': credential.appName,
      'app_url': credential.appUrl,
      'category': credential.category,
      'account_label': credential.accountLabel,
      'login_hint': MaskUtils.maskLogin(credential.username),
      'email_hint': MaskUtils.maskEmail(credential.email),
      'phone_hint': MaskUtils.maskPhone(credential.phoneNumber),
      'icon_name': credential.appName.toLowerCase(),
      'is_favorite': credential.isFavorite,
    };

    final inserted = await _remoteService.insertCredential(metadata);
    final credentialId = inserted['id'] as String;

    final encrypted = await _encryptionService.encryptText(
      plainText: jsonEncode(credential.toSensitiveJson()),
      keyBytes: unlockContext.vaultKey,
      aad: {'credential_id': credentialId},
    );

    await _remoteService.insertCredentialBlob({
      'credential_id': credentialId,
      'payload_encrypted': encrypted.payloadEncrypted,
      'payload_nonce': encrypted.nonceBase64,
      'aad_json': {'credential_id': credentialId},
    });

    return credentialId;
  }

  @override
  Future<List<CredentialMetadata>> listCredentials({required String vaultId}) async {
    final data = await _remoteService.listCredentials(vaultId);
    return data.map(CredentialMetadata.fromMap).toList();
  }

  @override
  Future<DecryptedCredential> readCredential({
    required VaultUnlockContext unlockContext,
    required String credentialId,
  }) async {
    final metadata = await _remoteService.fetchCredential(credentialId);
    final blob = await _remoteService.fetchCredentialBlob(credentialId);
    final decryptedJson = await _encryptionService.decryptText(
      payloadEncrypted: blob['payload_encrypted'] as String,
      nonceBase64: blob['payload_nonce'] as String,
      keyBytes: unlockContext.vaultKey,
      aad: (blob['aad_json'] as Map<String, dynamic>?) ??
          {'credential_id': credentialId},
    );
    final sensitive = jsonDecode(decryptedJson) as Map<String, dynamic>;
    return DecryptedCredential.fromParts(
      id: credentialId,
      metadata: metadata,
      sensitive: sensitive,
    );
  }

  @override
  Future<void> softDeleteCredential({required String credentialId}) {
    return _remoteService.softDeleteCredential(credentialId);
  }

  @override
  Future<void> updateCredential({
    required VaultUnlockContext unlockContext,
    required DecryptedCredential credential,
  }) async {
    final credentialId = credential.id!;
    await _remoteService.updateCredential(credentialId, {
      'app_name': credential.appName,
      'app_url': credential.appUrl,
      'category': credential.category,
      'account_label': credential.accountLabel,
      'login_hint': MaskUtils.maskLogin(credential.username),
      'email_hint': MaskUtils.maskEmail(credential.email),
      'phone_hint': MaskUtils.maskPhone(credential.phoneNumber),
      'is_favorite': credential.isFavorite,
    });

    final encrypted = await _encryptionService.encryptText(
      plainText: jsonEncode(credential.toSensitiveJson()),
      keyBytes: unlockContext.vaultKey,
      aad: {'credential_id': credentialId},
    );

    await _remoteService.updateCredentialBlob(credentialId, {
      'payload_encrypted': encrypted.payloadEncrypted,
      'payload_nonce': encrypted.nonceBase64,
      'aad_json': {'credential_id': credentialId},
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
