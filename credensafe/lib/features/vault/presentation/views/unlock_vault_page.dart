import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../viewmodels/session_viewmodel.dart';
import '../viewmodels/unlock_vault_viewmodel.dart';

class UnlockVaultPage extends StatefulWidget {
  const UnlockVaultPage({super.key});

  @override
  State<UnlockVaultPage> createState() => _UnlockVaultPageState();
}

class _UnlockVaultPageState extends State<UnlockVaultPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UnlockVaultViewModel>();
    final sessionVm = context.watch<SessionViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.security, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      sessionVm.currentVault?.name ?? 'Bóveda',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Desbloquea tu bóveda para acceder a las credenciales.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña maestra',
                      ),
                      validator: Validators.masterPassword,
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await vm.unlockWithPassword(_controller.text);
                            },
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Desbloquear'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: vm.isBiometricLoading
                          ? null
                          : () async {
                              await vm.unlockWithBiometrics();
                            },
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Usar biometría'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => sessionVm.signOut(),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
