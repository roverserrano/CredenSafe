import 'package:flutter/foundation.dart';

import '../../../../core/crypto/password_generator_service.dart';
import '../../application/usecases/create_credential_use_case.dart';
import '../../application/usecases/read_credential_use_case.dart';
import '../../application/usecases/update_credential_use_case.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialFormViewModel extends ChangeNotifier {
  CredentialFormViewModel({
    required CreateCredentialUseCase createCredentialUseCase,
    required ReadCredentialUseCase readCredentialUseCase,
    required UpdateCredentialUseCase updateCredentialUseCase,
    required AuditRepository auditRepository,
    required PasswordGeneratorService generatorService,
    required this.sessionViewModel,
  }) : _createCredentialUseCase = createCredentialUseCase,
       _readCredentialUseCase = readCredentialUseCase,
       _updateCredentialUseCase = updateCredentialUseCase,
       _auditRepository = auditRepository,
       _generatorService = generatorService;

  final CreateCredentialUseCase _createCredentialUseCase;
  final ReadCredentialUseCase _readCredentialUseCase;
  final UpdateCredentialUseCase _updateCredentialUseCase;
  final AuditRepository _auditRepository;
  final PasswordGeneratorService _generatorService;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  String? errorMessage;

  String generatePassword() => _generatorService.generate();

  Future<DecryptedCredential?> loadCredential(String credentialId) async {
    final context = sessionViewModel.unlockedContext;
    if (context == null) return null;
    return _readCredentialUseCase(
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
        final id = await _createCredentialUseCase(
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
        await _updateCredentialUseCase(
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
