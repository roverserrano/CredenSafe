import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../auth/domain/models/app_user.dart';
import '../../../auth/domain/models/auth_session_state.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../credentials/domain/repositories/audit_repository.dart';
import '../../domain/models/vault.dart';
import '../../domain/models/vault_unlock_context.dart';
import '../../domain/repositories/vault_repository.dart';

class SessionViewModel extends ChangeNotifier {
  SessionViewModel({
    required AuthRepository authRepository,
    required VaultRepository vaultRepository,
    required AuditRepository auditRepository,
  }) : _authRepository = authRepository,
       _vaultRepository = vaultRepository,
       _auditRepository = auditRepository;

  final AuthRepository _authRepository;
  final VaultRepository _vaultRepository;
  final AuditRepository _auditRepository;

  StreamSubscription<AuthSessionState>? _authSubscription;

  bool isInitializing = true;
  AppUser? currentUser;
  Vault? currentVault;
  VaultUnlockContext? unlockedContext;
  bool passwordRecoveryPending = false;
  String? sessionErrorMessage;

  bool get isAuthenticated => currentUser != null;
  bool get hasVault => currentVault != null;
  bool get isVaultUnlocked => unlockedContext != null;
  bool get biometricEnabled => currentVault?.isBiometricEnabled ?? false;

  Future<void> initialize() async {
    try {
      currentUser = _authRepository.currentUser();
      await _bootstrap();
    } catch (error) {
      _setSessionError(error);
    }

    _authSubscription?.cancel();
    _authSubscription = _authRepository.sessionStateChanges().listen((
      state,
    ) async {
      try {
        currentUser = state.user;
        unlockedContext = null;
        if (state.event == AuthSessionEvent.passwordRecovery) {
          passwordRecoveryPending = true;
        }
        await _bootstrap();
      } catch (error) {
        _setSessionError(error);
      }
    }, onError: _setSessionError);
  }

  Future<void> _bootstrap() async {
    isInitializing = true;
    sessionErrorMessage = null;
    notifyListeners();
    try {
      if (currentUser != null) {
        currentVault = await _vaultRepository.fetchPrimaryVault(
          currentUser!.id,
        );
      } else {
        currentVault = null;
      }
    } catch (error) {
      currentVault = null;
      unlockedContext = null;
      sessionErrorMessage = _messageForSessionError(error);
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> retryInitialization() => _bootstrap();

  void clearSessionError() {
    sessionErrorMessage = null;
    notifyListeners();
  }

  Future<void> refreshVault() async {
    if (currentUser == null) return;
    try {
      currentVault = await _vaultRepository.fetchPrimaryVault(currentUser!.id);
      sessionErrorMessage = null;
      notifyListeners();
    } catch (error) {
      _setSessionError(error);
      rethrow;
    }
  }

  Future<void> unlockWithMasterPassword(String masterPassword) async {
    if (currentVault == null) return;
    unlockedContext = await _vaultRepository.unlockVault(
      vault: currentVault!,
      masterPassword: masterPassword,
    );
    notifyListeners();
  }

  void unlockWithVaultKey(Uint8List vaultKey) {
    if (currentVault == null) return;
    unlockedContext = VaultUnlockContext(
      vaultId: currentVault!.id,
      vaultKey: vaultKey,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    lockVault();
    passwordRecoveryPending = false;
    await _authRepository.signOut();
  }

  void completePasswordRecovery() {
    passwordRecoveryPending = false;
    notifyListeners();
  }

  void lockVault() {
    unlockedContext = null;
    notifyListeners();
  }

  Future<void> registerAudit({
    required String eventType,
    String eventStatus = 'success',
    Map<String, dynamic>? metadata,
    String? credentialId,
  }) async {
    if (currentUser == null) return;
    await _auditRepository.insertEvent(
      userId: currentUser!.id,
      vaultId: currentVault?.id,
      credentialId: credentialId,
      eventType: eventType,
      eventStatus: eventStatus,
      metadata: metadata ?? const <String, dynamic>{},
    );
  }

  void _setSessionError(Object error) {
    isInitializing = false;
    currentVault = null;
    unlockedContext = null;
    sessionErrorMessage = _messageForSessionError(error);
    notifyListeners();
  }

  String _messageForSessionError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('socket') ||
        raw.contains('failed host lookup') ||
        raw.contains('network') ||
        raw.contains('connection') ||
        raw.contains('authretryablefetchexception')) {
      return 'No se pudo conectar con Supabase. Revisa tu conexión a internet o DNS y vuelve a intentar.';
    }
    return 'No se pudo cargar tu sesión. Intenta nuevamente.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
