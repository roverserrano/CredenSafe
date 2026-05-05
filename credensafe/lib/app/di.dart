import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/crypto/encryption_service.dart';
import '../core/crypto/crypto_service.dart';
import '../core/crypto/key_derivation_service.dart';
import '../core/crypto/password_generator_service.dart';
import '../core/crypto/secure_key_store_service.dart';
import '../core/security/biometric_service.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/services/auth_remote_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/viewmodels/forgot_password_viewmodel.dart';
import '../features/auth/presentation/viewmodels/login_viewmodel.dart';
import '../features/auth/presentation/viewmodels/register_viewmodel.dart';
import '../features/auth/presentation/viewmodels/update_password_viewmodel.dart';
import '../features/credentials/application/usecases/create_credential_use_case.dart';
import '../features/credentials/application/usecases/delete_credential_use_case.dart';
import '../features/credentials/application/usecases/list_credentials_use_case.dart';
import '../features/credentials/application/usecases/read_credential_use_case.dart';
import '../features/credentials/application/usecases/update_credential_use_case.dart';
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
import '../features/vault/application/usecases/authenticate_with_biometric_use_case.dart';
import '../features/vault/application/usecases/set_biometric_unlock_use_case.dart';
import '../features/vault/application/usecases/unlock_vault_use_case.dart';
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
        Provider(create: (_) => const KeyDerivationService()),
        Provider<ICryptoService>(create: (_) => const EncryptionService()),
        Provider(create: (_) => const PasswordGeneratorService()),
        Provider<IBiometricService>(
          create: (context) =>
              BiometricService(storage: context.read<SecureStorageService>()),
        ),
        Provider(
          create: (context) =>
              AuthRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) =>
              VaultRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) =>
              CredentialRemoteService(context.read<SupabaseClient>()),
        ),
        Provider(
          create: (context) =>
              AuditRemoteService(context.read<SupabaseClient>()),
        ),
        Provider<AuthRepository>(
          create: (context) =>
              AuthRepositoryImpl(context.read<AuthRemoteService>()),
        ),
        Provider<VaultRepository>(
          create: (context) => VaultRepositoryImpl(
            remoteService: context.read<VaultRemoteService>(),
            encryptionService: context.read<ICryptoService>(),
            keyDerivationService: context.read<KeyDerivationService>(),
          ),
        ),
        Provider<CredentialRepository>(
          create: (context) => CredentialRepositoryImpl(
            remoteService: context.read<CredentialRemoteService>(),
            encryptionService: context.read<ICryptoService>(),
          ),
        ),
        Provider<AuditRepository>(
          create: (context) =>
              AuditRepositoryImpl(context.read<AuditRemoteService>()),
        ),
        Provider(
          create: (context) =>
              UnlockVaultUseCase(context.read<VaultRepository>()),
        ),
        Provider(
          create: (context) => AuthenticateWithBiometricUseCase(
            biometricService: context.read<IBiometricService>(),
            auditRepository: context.read<AuditRepository>(),
          ),
        ),
        Provider(
          create: (context) => SetBiometricUnlockUseCase(
            vaultRepository: context.read<VaultRepository>(),
            biometricService: context.read<IBiometricService>(),
            auditRepository: context.read<AuditRepository>(),
          ),
        ),
        Provider(
          create: (context) =>
              ListCredentialsUseCase(context.read<CredentialRepository>()),
        ),
        Provider(
          create: (context) =>
              CreateCredentialUseCase(context.read<CredentialRepository>()),
        ),
        Provider(
          create: (context) =>
              ReadCredentialUseCase(context.read<CredentialRepository>()),
        ),
        Provider(
          create: (context) =>
              UpdateCredentialUseCase(context.read<CredentialRepository>()),
        ),
        Provider(
          create: (context) =>
              DeleteCredentialUseCase(context.read<CredentialRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SessionViewModel(
            authRepository: context.read<AuthRepository>(),
            vaultRepository: context.read<VaultRepository>(),
            auditRepository: context.read<AuditRepository>(),
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RegisterViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ForgotPasswordViewModel(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              UpdatePasswordViewModel(context.read<AuthRepository>()),
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
            unlockVaultUseCase: context.read<UnlockVaultUseCase>(),
            authenticateWithBiometricUseCase: context
                .read<AuthenticateWithBiometricUseCase>(),
            sessionViewModel: context.read<SessionViewModel>(),
            auditRepository: context.read<AuditRepository>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, CredentialListViewModel>(
          create: (context) => CredentialListViewModel(
            listCredentialsUseCase: context.read<ListCredentialsUseCase>(),
            deleteCredentialUseCase: context.read<DeleteCredentialUseCase>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, CredentialFormViewModel>(
          create: (context) => CredentialFormViewModel(
            createCredentialUseCase: context.read<CreateCredentialUseCase>(),
            readCredentialUseCase: context.read<ReadCredentialUseCase>(),
            updateCredentialUseCase: context.read<UpdateCredentialUseCase>(),
            auditRepository: context.read<AuditRepository>(),
            generatorService: context.read<PasswordGeneratorService>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<
          SessionViewModel,
          CredentialDetailViewModel
        >(
          create: (context) => CredentialDetailViewModel(
            readCredentialUseCase: context.read<ReadCredentialUseCase>(),
            deleteCredentialUseCase: context.read<DeleteCredentialUseCase>(),
            auditRepository: context.read<AuditRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),
          update: (_, sessionVm, current) =>
              current!..sessionViewModel = sessionVm,
        ),
        ChangeNotifierProxyProvider<SessionViewModel, SettingsViewModel>(
          create: (context) => SettingsViewModel(
            sessionViewModel: context.read<SessionViewModel>(),
            setBiometricUnlockUseCase: context
                .read<SetBiometricUnlockUseCase>(),
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
