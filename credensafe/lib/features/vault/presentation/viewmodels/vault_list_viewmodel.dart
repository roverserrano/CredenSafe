import 'package:flutter/foundation.dart';

import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../domain/repositories/vault_repository.dart';
import 'session_viewmodel.dart';

class VaultSetupViewModel extends ChangeNotifier {
  VaultSetupViewModel({
    required VaultRepository vaultRepository,
    required AuditRepository auditRepository,
    required this.sessionViewModel,
  })  : _vaultRepository = vaultRepository,
        _auditRepository = auditRepository;

  final VaultRepository _vaultRepository;
  final AuditRepository _auditRepository;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> createInitialVault({
    required String masterPassword,
    required String vaultName,
  }) async {
    final user = sessionViewModel.currentUser;
    if (user == null) return false;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _vaultRepository.createInitialVault(
        userId: user.id,
        masterPassword: masterPassword,
        vaultName: vaultName,
      );

      await _auditRepository.insertEvent(
        userId: user.id,
        eventType: 'vault_created',
        eventStatus: 'success',
        metadata: {'vault_name': vaultName},
      );

      await sessionViewModel.refreshVault();
      return true;
    } catch (_) {
      errorMessage = 'No se pudo crear la bóveda';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
