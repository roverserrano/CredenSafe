import 'package:flutter/foundation.dart';

import '../../../../core/utils/clipboard_utils.dart';
import '../../application/usecases/delete_credential_use_case.dart';
import '../../application/usecases/read_credential_use_case.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialDetailViewModel extends ChangeNotifier {
  CredentialDetailViewModel({
    required ReadCredentialUseCase readCredentialUseCase,
    required DeleteCredentialUseCase deleteCredentialUseCase,
    required AuditRepository auditRepository,
    required this.sessionViewModel,
  }) : _readCredentialUseCase = readCredentialUseCase,
       _deleteCredentialUseCase = deleteCredentialUseCase,
       _auditRepository = auditRepository;

  final ReadCredentialUseCase _readCredentialUseCase;
  final DeleteCredentialUseCase _deleteCredentialUseCase;
  final AuditRepository _auditRepository;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  String? errorMessage;
  DecryptedCredential? credential;

  Future<void> load(String credentialId) async {
    final context = sessionViewModel.unlockedContext;
    final user = sessionViewModel.currentUser;
    if (context == null || user == null) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      credential = await _readCredentialUseCase(
        unlockContext: context,
        credentialId: credentialId,
      );
      await _auditRepository.insertEvent(
        userId: user.id,
        vaultId: context.vaultId,
        credentialId: credentialId,
        eventType: 'credential_viewed',
      );
    } catch (_) {
      errorMessage = 'No se pudo leer la credencial';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> copyPassword() async {
    final user = sessionViewModel.currentUser;
    final context = sessionViewModel.unlockedContext;
    final credentialId = credential?.id;
    final password = credential?.password;
    if (user == null ||
        context == null ||
        credentialId == null ||
        password == null) {
      return;
    }
    await ClipboardUtils.copyWithAutoClear(password);
    await _auditRepository.insertEvent(
      userId: user.id,
      vaultId: context.vaultId,
      credentialId: credentialId,
      eventType: 'credential_password_copied',
    );
  }

  Future<void> deleteCurrent() async {
    final user = sessionViewModel.currentUser;
    final context = sessionViewModel.unlockedContext;
    final credentialId = credential?.id;
    if (user == null || context == null || credentialId == null) return;

    await _deleteCredentialUseCase(credentialId: credentialId);
    await _auditRepository.insertEvent(
      userId: user.id,
      vaultId: context.vaultId,
      credentialId: credentialId,
      eventType: 'credential_deleted',
    );
  }
}
