import 'dart:async';
import 'dart:typed_data';

import 'package:credensafe/core/crypto/secure_key_store_service.dart';
import 'package:credensafe/core/security/biometric_service.dart';
import 'package:credensafe/features/auth/domain/models/app_user.dart';
import 'package:credensafe/features/auth/domain/models/auth_operation_result.dart';
import 'package:credensafe/features/auth/domain/models/auth_session_state.dart';
import 'package:credensafe/features/auth/domain/repositories/auth_repository.dart';
import 'package:credensafe/features/credentials/domain/models/audit_event.dart';
import 'package:credensafe/features/credentials/domain/repositories/audit_repository.dart';
import 'package:credensafe/features/vault/domain/models/vault.dart';
import 'package:credensafe/features/vault/domain/models/vault_unlock_context.dart';
import 'package:credensafe/features/vault/domain/repositories/vault_repository.dart';
import 'package:local_auth/local_auth.dart';

final testUser = AppUser(id: 'user-1', email: 'user@example.com');

Vault testVault({bool biometric = false}) {
  return Vault(
    id: 'vault-1',
    ownerId: testUser.id,
    name: 'Boveda principal',
    vaultKeyEnvelope: 'envelope',
    vaultKeyEnvelopeNonce: 'nonce',
    kdfAlgorithm: 'argon2id',
    kdfSalt: 'salt',
    kdfMemoryKiB: 1,
    kdfIterations: 1,
    kdfParallelism: 1,
    cipherAlgorithm: 'xchacha20-poly1305',
    isBiometricEnabled: biometric,
  );
}

class MemorySecureStore implements SecureKeyValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    values.clear();
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class FakeLocalAuthenticator implements LocalAuthenticator {
  FakeLocalAuthenticator({
    this.supported = true,
    this.canCheck = true,
    this.availableBiometrics = const [BiometricType.fingerprint],
    this.approved = true,
  });

  bool supported;
  bool canCheck;
  List<BiometricType> availableBiometrics;
  bool approved;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required AuthenticationOptions options,
  }) async {
    return approved;
  }

  @override
  Future<bool> canCheckBiometrics() async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return availableBiometrics;
  }

  @override
  Future<bool> isDeviceSupported() async => supported;
}

class FakeBiometricService implements IBiometricService {
  FakeBiometricService({
    this.availability = BiometricAvailability.available,
    Uint8List? vaultKey,
  }) : vaultKey = vaultKey ?? Uint8List.fromList([1, 2, 3, 4]);

  BiometricAvailability availability;
  Uint8List vaultKey;
  bool enabled = false;
  bool disableCalled = false;

  @override
  Future<Uint8List> authenticate() async => vaultKey;

  @override
  Future<BiometricAvailability> checkAvailability() async => availability;

  @override
  Future<void> disable() async {
    disableCalled = true;
    enabled = false;
  }

  @override
  Future<void> enable({required Uint8List vaultKey}) async {
    this.vaultKey = vaultKey;
    enabled = true;
  }

  @override
  Future<bool> isEnabled() async => enabled;
}

class FakeAuditRepository implements AuditRepository {
  final events = <Map<String, dynamic>>[];

  @override
  Future<void> insertEvent({
    required String userId,
    String? vaultId,
    String? credentialId,
    required String eventType,
    String eventStatus = 'success',
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    events.add({
      'user_id': userId,
      'vault_id': vaultId,
      'credential_id': credentialId,
      'event_type': eventType,
      'event_status': eventStatus,
      'metadata': metadata,
    });
  }

  @override
  Future<List<AuditEvent>> listEvents(String userId) async => [];
}

class FakeVaultRepository implements VaultRepository {
  FakeVaultRepository({
    Vault? vault,
    VaultUnlockContext? unlockContext,
    this.unlockError,
    this.fetchError,
  }) : vault = vault ?? testVault(),
       unlockContext =
           unlockContext ??
           VaultUnlockContext(
             vaultId: 'vault-1',
             vaultKey: Uint8List.fromList([1, 2, 3, 4]),
           );

  Vault? vault;
  VaultUnlockContext unlockContext;
  Object? unlockError;
  Object? fetchError;
  bool biometricPreference = false;

  @override
  Future<void> createInitialVault({
    required String userId,
    required String masterPassword,
    required String vaultName,
  }) async {}

  @override
  Future<Vault?> fetchPrimaryVault(String userId, {bool biometric = false}) {
    final error = fetchError;
    if (error != null) throw error;
    return Future.value(vault);
  }

  @override
  Future<VaultUnlockContext> unlockVault({
    required Vault vault,
    required String masterPassword,
  }) async {
    final error = unlockError;
    if (error != null) throw error;
    return unlockContext;
  }

  @override
  Future<void> updateBiometricPreference({
    required String userId,
    required bool enabled,
  }) async {
    biometricPreference = enabled;
    vault = testVault(biometric: enabled);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? user}) : user = user ?? testUser;

  AppUser? user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(user);

  AuthOperationResult currentResult(String message) {
    return AuthOperationResult(
      status: AuthOperationStatus.authenticated,
      message: message,
      user: user,
    );
  }

  @override
  AppUser? currentUser() => user;

  @override
  Future<AuthOperationResult> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    return currentResult('Password changed');
  }

  @override
  Future<AuthOperationResult> sendPasswordResetEmail({
    required String email,
  }) async {
    return currentResult('Email sent');
  }

  @override
  Future<AuthOperationResult> resendSignupConfirmation({
    required String email,
  }) async {
    return const AuthOperationResult(
      status: AuthOperationStatus.confirmationEmailResent,
      message: 'Confirmation resent',
    );
  }

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    return currentResult('Signed in');
  }

  @override
  Future<void> signOut() async {
    user = null;
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
  }) async {
    return currentResult('Signed up');
  }

  @override
  Stream<AuthSessionState> sessionStateChanges() {
    return Stream.value(
      AuthSessionState(event: AuthSessionEvent.initialSession, user: user),
    );
  }

  @override
  Future<AuthOperationResult> updatePassword({
    required String newPassword,
  }) async {
    return currentResult('Password updated');
  }
}
