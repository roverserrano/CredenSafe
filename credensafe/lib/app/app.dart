import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/views/forgot_password_page.dart';
import '../features/auth/presentation/views/login_page.dart';
import '../features/auth/presentation/views/register_page.dart';
import '../features/auth/presentation/views/update_password_page.dart';
import '../features/credentials/presentation/views/credential_form_page.dart';
import '../features/credentials/presentation/views/credential_list_page.dart';
import '../features/credentials/presentation/views/security_activity_page.dart';
import '../features/setting/presentation/views/setting_page.dart';
import '../features/vault/presentation/viewmodels/session_viewmodel.dart';
import '../features/vault/presentation/views/unlock_vault_page.dart';
import '../features/vault/presentation/views/vault_list_page.dart';
import 'di.dart';
import 'routes.dart';

class CredenSafeApp extends StatelessWidget {
  const CredenSafeApp({super.key, this.configurationError});

  final Object? configurationError;

  @override
  Widget build(BuildContext context) {
    if (configurationError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CredenSafe',
        theme: _buildTheme(),
        home: ConfigurationErrorPage(error: configurationError!),
      );
    }

    return AppProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CredenSafe',
        theme: _buildTheme(),
        home: const LifecycleLockWrapper(child: CredenSafeRoot()),
      ),
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class CredenSafeRoot extends StatelessWidget {
  const CredenSafeRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    if (session.isInitializing) {
      return const SplashPage();
    }

    if (!session.isAuthenticated) {
      return const LoginPage();
    }

    if (session.passwordRecoveryPending) {
      return const UpdatePasswordPage(isRecoveryFlow: true);
    }

    if (!session.hasVault) {
      return const VaultSetupPage();
    }

    if (!session.isVaultUnlocked) {
      return const UnlockVaultPage();
    }

    return const CredentialListPage();
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person, size: 72),
            SizedBox(height: 16),
            Text('CredenSafe'),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ConfigurationErrorPage extends StatelessWidget {
  const ConfigurationErrorPage({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Configuración incompleta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Copia .env.example como .env y configura SUPABASE_URL y '
                    'SUPABASE_ANON_KEY. No uses service_role en Flutter.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppNavigator {
  const AppNavigator._();

  static Future<void> toRegister(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  static Future<void> toForgotPassword(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  static Future<void> toUpdatePassword(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpdatePasswordPage()),
    );
  }

  static Future<void> toCredentialForm(
    BuildContext context, {
    String? credentialId,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CredentialFormPage(credentialId: credentialId),
      ),
    );
  }

  static Future<void> toSecurityActivity(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SecurityActivityPage()),
    );
  }

  static Future<void> toSettings(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }
}
