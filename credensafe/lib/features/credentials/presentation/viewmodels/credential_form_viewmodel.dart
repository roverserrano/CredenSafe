import 'package:flutter/foundation.dart';

import '../../../../core/crypto/password_generator_service.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/repositories/credential_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialFormViewModel extends ChangeNotifier {
  CredentialFormViewModel({
    required CredentialRepository credentialRepository,
    required AuditRepository auditRepository,
    required PasswordGeneratorService generatorService,
    required SessionViewModel sessionViewModel,
  })  : _credentialRepository = credentialRepository,
        _auditRepository = auditRepository,
        _generatorService = generatorService,
        sessionViewModel = sessionViewModel;

  final CredentialRepository _credentialRepository;
  final AuditRepository _auditRepository;
  final PasswordGeneratorService _generatorService;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  String? errorMessage;

  String generatePassword() => _generatorService.generate();

  Future<DecryptedCredential?> loadCredential(String credentialId) async {
    final context = sessionViewModel.unlockedContext;
    if (context == null) return null;
    return _credentialRepository.readCredential(
      unlockContext: context,
      credentialId: credentialId,
    );
  }

  Future<bool> save(DecryptedCredential credential) async {
    final context = sessionViewModel.unlockedContext;
    final user = sessionViewModel.currentUser;
    if (context == null || user == null) return false;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (credential.id == null) {
        final id = await _credentialRepository.createCredential(
          unlockContext: context,
          credential: credential,
        );
        await _auditRepository.insertEvent(
          userId: user.id,
          vaultId: context.vaultId,
          credentialId: id,
          eventType: 'credential_created',
          metadata: {'app_name': credential.appName},
        );
      } else {
        await _credentialRepository.updateCredential(
          unlockContext: context,
          credential: credential,
        );
        await _auditRepository.insertEvent(
          userId: user.id,
          vaultId: context.vaultId,
          credentialId: credential.id,
          eventType: 'credential_updated',
          metadata: {'app_name': credential.appName},
        );
      }
      return true;
    } catch (_) {
      errorMessage = 'No se pudo guardar la credencial';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
