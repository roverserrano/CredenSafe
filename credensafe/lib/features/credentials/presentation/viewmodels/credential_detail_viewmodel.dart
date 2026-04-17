import 'package:flutter/foundation.dart';

import '../../../../core/utils/clipboard_utils.dart';
import '../../domain/models/decrypted_credential.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/repositories/credential_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialDetailViewModel extends ChangeNotifier {
  CredentialDetailViewModel({
    required CredentialRepository credentialRepository,
    required AuditRepository auditRepository,
    required this.sessionViewModel,
  })  : _credentialRepository = credentialRepository,
        _auditRepository = auditRepository;

  final CredentialRepository _credentialRepository;
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
      credential = await _credentialRepository.readCredential(
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
    if (user == null || context == null || credentialId == null || password == null) {
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

    await _credentialRepository.softDeleteCredential(credentialId: credentialId);
    await _auditRepository.insertEvent(
      userId: user.id,
      vaultId: context.vaultId,
      credentialId: credentialId,
      eventType: 'credential_deleted',
    );
  }
}
