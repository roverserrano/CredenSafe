import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/models/app_user.dart';
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
    required SupabaseClient client,
  })  : _authRepository = authRepository,
        _vaultRepository = vaultRepository,
        _auditRepository = auditRepository,
        _client = client;

  final AuthRepository _authRepository;
  final VaultRepository _vaultRepository;
  final AuditRepository _auditRepository;
  final SupabaseClient _client;

  StreamSubscription<AppUser?>? _authSubscription;

  bool isInitializing = true;
  AppUser? currentUser;
  Vault? currentVault;
  VaultUnlockContext? unlockedContext;

  bool get isAuthenticated => currentUser != null;
  bool get hasVault => currentVault != null;
  bool get isVaultUnlocked => unlockedContext != null;
  bool get biometricEnabled => currentVault?.isBiometricEnabled ?? false;

  Future<void> initialize() async {
    currentUser = _authRepository.currentUser();
    await _bootstrap();
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges().listen((user) async {
      currentUser = user;
      unlockedContext = null;
      await _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    isInitializing = true;
    notifyListeners();
    if (currentUser != null) {
      currentVault = await _vaultRepository.fetchPrimaryVault(currentUser!.id);
    } else {
      currentVault = null;
    }
    isInitializing = false;
    notifyListeners();
  }

  Future<void> refreshVault() async {
    if (currentUser == null) return;
    currentVault = await _vaultRepository.fetchPrimaryVault(currentUser!.id);
    notifyListeners();
  }

  Future<void> unlockWithMasterPassword(String masterPassword) async {
    if (currentVault == null) return;
    unlockedContext = await _vaultRepository.unlockVault(
      vault: currentVault!,
      masterPassword: masterPassword,
    );
    notifyListeners();
  }

  Future<bool> tryBiometricUnlock() async {
    if (currentVault == null) return false;
    final cached = await _vaultRepository.readCachedVaultKey(currentVault!.id);
    if (cached == null) return false;
    unlockedContext = VaultUnlockContext(
      vaultId: currentVault!.id,
      vaultKey: base64Decode(cached),
    );
    notifyListeners();
    return true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (currentUser == null || currentVault == null) return;
    await _vaultRepository.setBiometricPreference(enabled);
    await _client.from('profiles').upsert({
      'id': currentUser!.id,
      'is_biometric_enabled': enabled,
    });

    if (enabled && unlockedContext != null) {
      await _vaultRepository.cacheVaultKey(
        vaultId: currentVault!.id,
        vaultKeyBase64: base64Encode(unlockedContext!.vaultKey),
      );
    }

    if (!enabled) {
      await _vaultRepository.clearCachedVaultKey();
    }

    currentVault = Vault(
      id: currentVault!.id,
      ownerId: currentVault!.ownerId,
      name: currentVault!.name,
      vaultKeyEnvelope: currentVault!.vaultKeyEnvelope,
      vaultKeyEnvelopeNonce: currentVault!.vaultKeyEnvelopeNonce,
      kdfAlgorithm: currentVault!.kdfAlgorithm,
      kdfSalt: currentVault!.kdfSalt,
      kdfMemoryKiB: currentVault!.kdfMemoryKiB,
      kdfIterations: currentVault!.kdfIterations,
      kdfParallelism: currentVault!.kdfParallelism,
      cipherAlgorithm: currentVault!.cipherAlgorithm,
      isBiometricEnabled: enabled,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    lockVault();
    await _vaultRepository.clearCachedVaultKey();
    await _authRepository.signOut();
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
