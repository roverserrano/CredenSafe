import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/crypto/biometric_gate_service.dart';
import '../core/crypto/encryption_service.dart';
import '../core/crypto/key_derivation_service.dart';
import '../core/crypto/password_generator_service.dart';
import '../core/crypto/secure_key_store_service.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/services/auth_remote_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/viewmodels/forgot_password_viewmodel.dart';
import '../features/auth/presentation/viewmodels/login_viewmodel.dart';
import '../features/auth/presentation/viewmodels/register_viewmodel.dart';
import '../features/auth/presentation/viewmodels/update_password_viewmodel.dart';
import '../features/credentials/data/repositories/audit_repository_impl.dart';
import '../features/credentials/data/repositories/credential_repository_impl.dart';
import '../features/credentials/data/services/audit_remote_service.dart';
import '../features/credentials/data/services/credential_remote_service.dart';
import '../features/credentials/domain/repositories/audit_repository.dart';
import '../features/credentials/domain/repositories/credential_repository.dart';
import '../features/credentials/presentation/viewmodels/credential_detail_viewmodel.dart';
import '../features/credentials/presentation/viewmodels/credential_form_viewmodel.dart';
import '../features/credentials/presentation/viewmodels/credential_list_viewmodel.dart';
import '../features/credentials/presentation/viewmodels/security_activity_viewmodel.dart';
import '../features/setting/presentation/viewmodels/settings_viewmodel.dart';
import '../features/vault/data/repositories/vault_repository_impl.dart';
import '../features/vault/data/services/vault_remote_service.dart';
import '../features/vault/domain/repositories/vault_repository.dart';
import '../features/vault/presentation/viewmodels/session_viewmodel.dart';
import '../features/vault/presentation/viewmodels/unlock_vault_viewmodel.dart';
import '../features/vault/presentation/viewmodels/vault_list_viewmodel.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: Supabase.instance.client),
        Provider(create: (_) => const SecureStorageService()),
        Provider(create: (_) => const BiometricGateService()),
        Provider(create: (_) => const KeyDerivationService()),
        Provider(create: (_) => const EncryptionService()),
        Provider(create: (_) => const PasswordGeneratorService()),
        Provider(
          create: (context) => AuthRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) => VaultRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) =>
              CredentialRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) => AuditRemoteService(context.read<SupabaseClient>()),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteService>(),
          ),
        ),
        Provider<VaultRepository>(
          create: (context) => VaultRepositoryImpl(
            remoteService: context.read<VaultRemoteService>(),
            encryptionService: context.read<EncryptionService>(),
            keyDerivationService: context.read<KeyDerivationService>(),
            storageService: context.read<SecureStorageService>(),
            biometricGateService: context.read<BiometricGateService>(),
          ),
        ),
        Provider<CredentialRepository>(
          create: (context) => CredentialRepositoryImpl(
            remoteService: context.read<CredentialRemoteService>(),
            encryptionService: context.read<EncryptionService>(),
          ),
        ),
        Provider<AuditRepository>(
          create: (context) => AuditRepositoryImpl(
            context.read<AuditRemoteService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SessionViewModel(
            authRepository: context.read<AuthRepository>(),
            vaultRepository: context.read<VaultRepository>(),
            auditRepository: context.read<AuditRepository>(),
            client: context.read<SupabaseClient>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RegisterViewModel(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ForgotPasswordViewModel(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UpdatePasswordViewModel(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProxyProvider<SessionViewModel, VaultSetupViewModel>(
          create: (context) => VaultSetupViewModel(
            vaultRepository: context.read<VaultRepository>(),
            auditRepository: context.read<AuditRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, UnlockVaultViewModel>(
          create: (context) => UnlockVaultViewModel(
            vaultRepository: context.read<VaultRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
            auditRepository: context.read<AuditRepository>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, CredentialListViewModel>(
          create: (context) => CredentialListViewModel(
            credentialRepository: context.read<CredentialRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, CredentialFormViewModel>(
          create: (context) => CredentialFormViewModel(
            credentialRepository: context.read<CredentialRepository>(),
            auditRepository: context.read<AuditRepository>(),
            generatorService: context.read<PasswordGeneratorService>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, CredentialDetailViewModel>(
          create: (context) => CredentialDetailViewModel(
            credentialRepository: context.read<CredentialRepository>(),
            auditRepository: context.read<AuditRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, SettingsViewModel>(
          create: (context) => SettingsViewModel(
            sessionViewModel: context.read<SessionViewModel>(),
            auditRepository: context.read<AuditRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProvider(
          create: (context) => SecurityActivityViewModel(
            auditRepository: context.read<AuditRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
