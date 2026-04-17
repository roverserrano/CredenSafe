import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/viewmodels/auth_form_status.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final sessionVm = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile.adaptive(
              value: sessionVm.biometricEnabled,
              onChanged: vm.isLoading
                  ? null
                  : (value) => vm.setBiometricEnabled(value),
              title: const Text('Desbloqueo biométrico'),
              subtitle: const Text(
                'Guarda una clave de bóveda protegida por almacenamiento seguro del dispositivo.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Bloquear bóveda'),
              onTap: () {
                sessionVm.lockVault();
                Navigator.of(context).pop();
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Cambiar contraseña de cuenta'),
              subtitle: const Text('Actualiza la contraseña de Supabase Auth.'),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => ChangePasswordDialog(viewModel: vm),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await sessionVm.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final isSuccess = vm.passwordStatus == PasswordChangeStatus.success;

        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        }),
                        icon: Icon(_obscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    validator: Validators.requiredPassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _obscureNew = !_obscureNew;
                        }),
                        icon: Icon(
                          _obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        }),
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _newController.text,
                    ),
                  ),
                  if (vm.passwordMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.passwordMessage!,
                      style: TextStyle(
                        color: isSuccess
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  vm.isChangingPassword ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: vm.isChangingPassword
                  ? null
                  : () async {
                      vm.markPasswordValidating();
                      if (!_formKey.currentState!.validate()) return;
                      final ok = await vm.changePassword(
                        currentPassword: _currentController.text,
                        newPassword: _newController.text,
                      );
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: vm.isChangingPassword
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
