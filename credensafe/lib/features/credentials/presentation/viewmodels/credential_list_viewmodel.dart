import 'package:flutter/foundation.dart';

import '../../domain/models/credential_metadata.dart';
import '../../domain/repositories/credential_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialListViewModel extends ChangeNotifier {
  CredentialListViewModel({
    required CredentialRepository credentialRepository,
    required SessionViewModel sessionViewModel,
  })  : _credentialRepository = credentialRepository,
        sessionViewModel = sessionViewModel;

  final CredentialRepository _credentialRepository;
  SessionViewModel sessionViewModel;

  bool isLoading = false;
  String? errorMessage;
  List<CredentialMetadata> credentials = [];

  Future<void> load() async {
    final vaultId = sessionViewModel.unlockedContext?.vaultId;
    if (vaultId == null) return;
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      credentials = await _credentialRepository.listCredentials(vaultId: vaultId);
    } catch (_) {
      errorMessage = 'No se pudo cargar la lista de credenciales';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String credentialId) async {
    await _credentialRepository.softDeleteCredential(credentialId: credentialId);
    credentials.removeWhere((item) => item.id == credentialId);
    notifyListeners();
  }
}
