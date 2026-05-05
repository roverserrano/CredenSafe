import 'package:flutter/foundation.dart';

import '../../application/usecases/delete_credential_use_case.dart';
import '../../application/usecases/list_credentials_use_case.dart';
import '../../domain/models/credential_metadata.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class CredentialListViewModel extends ChangeNotifier {
  CredentialListViewModel({
    required ListCredentialsUseCase listCredentialsUseCase,
    required DeleteCredentialUseCase deleteCredentialUseCase,
    required this.sessionViewModel,
  }) : _listCredentialsUseCase = listCredentialsUseCase,
       _deleteCredentialUseCase = deleteCredentialUseCase;

  final ListCredentialsUseCase _listCredentialsUseCase;
  final DeleteCredentialUseCase _deleteCredentialUseCase;
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
      credentials = await _listCredentialsUseCase(vaultId: vaultId);
    } catch (_) {
      errorMessage = 'No se pudo cargar la lista de credenciales';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String credentialId) async {
    await _deleteCredentialUseCase(credentialId: credentialId);
    credentials.removeWhere((item) => item.id == credentialId);
    notifyListeners();
  }
}
