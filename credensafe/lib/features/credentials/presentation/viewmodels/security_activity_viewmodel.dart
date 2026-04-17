import 'package:flutter/foundation.dart';

import '../../domain/models/audit_event.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';

class SecurityActivityViewModel extends ChangeNotifier {
  SecurityActivityViewModel({
    required AuditRepository auditRepository,
    required SessionViewModel sessionViewModel,
  })  : _auditRepository = auditRepository,
        _sessionViewModel = sessionViewModel;

  final AuditRepository _auditRepository;
  final SessionViewModel _sessionViewModel;

  bool isLoading = false;
  List<AuditEvent> events = [];

  Future<void> load() async {
    final user = _sessionViewModel.currentUser;
    if (user == null) return;
    isLoading = true;
    notifyListeners();
    events = await _auditRepository.listEvents(user.id);
    isLoading = false;
    notifyListeners();
  }
}
