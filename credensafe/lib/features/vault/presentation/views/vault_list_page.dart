import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../viewmodels/vault_list_viewmodel.dart';

class VaultSetupPage extends StatefulWidget {
  const VaultSetupPage({super.key});

  @override
  State<VaultSetupPage> createState() => _VaultSetupPageState();
}

class _VaultSetupPageState extends State<VaultSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _vaultNameController = TextEditingController(text: 'Bóveda principal');
  final _masterPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _vaultNameController.dispose();
    _masterPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VaultSetupViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar bóveda')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crea tu bóveda maestra',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta contraseña protege tus credenciales y no se envía en texto plano a Supabase.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _vaultNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la bóveda',
                      ),
                      validator: (value) => Validators.requiredField(
                        value,
                        fieldName: 'Nombre de la bóveda',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _masterPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña maestra',
                      ),
                      validator: Validators.masterPassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña maestra',
                      ),
                      validator: (value) {
                        if (value != _masterPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await vm.createInitialVault(
                                masterPassword: _masterPasswordController.text,
                                vaultName: _vaultNameController.text,
                              );
                            },
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear bóveda'),
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
