import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/security/biometric_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/viewmodels/auth_form_status.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadBiometricAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final sessionVm = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.shouldShowBiometricOption)
            Card(
              child: SwitchListTile.adaptive(
                value: sessionVm.biometricEnabled,
                onChanged: vm.isLoading
                    ? null
                    : (value) =>
                          _onBiometricChanged(context, vm, enabled: value),
                title: const Text('Desbloqueo biométrico'),
                subtitle: Text(_biometricSubtitle(vm)),
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

  String _biometricSubtitle(SettingsViewModel vm) {
    if (vm.securityMessage != null) return vm.securityMessage!;
    return switch (vm.biometricAvailability) {
      BiometricAvailability.notEnrolled =>
        'Registra tu huella o Face ID en los ajustes del dispositivo.',
      BiometricAvailability.notAvailable =>
        'Biometría no disponible por ahora. Puedes usar tu contraseña maestra.',
      BiometricAvailability.notSupported =>
        'Este dispositivo no soporta desbloqueo biométrico.',
      _ =>
        'Guarda una clave de bóveda protegida por almacenamiento seguro del dispositivo.',
    };
  }

  Future<void> _onBiometricChanged(
    BuildContext context,
    SettingsViewModel vm, {
    required bool enabled,
  }) async {
    if (enabled) {
      final masterPassword = await showDialog<String>(
        context: context,
        builder: (_) => const MasterPasswordDialog(),
      );
      if (masterPassword == null || !context.mounted) return;
      await vm.setBiometricEnabled(true, masterPassword: masterPassword);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DisableBiometricDialog(),
    );
    if (confirmed == true) {
      await vm.setBiometricEnabled(false);
    }
  }
}

class MasterPasswordDialog extends StatefulWidget {
  const MasterPasswordDialog({super.key});

  @override
  State<MasterPasswordDialog> createState() => _MasterPasswordDialogState();
}

class _MasterPasswordDialogState extends State<MasterPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar identidad'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Contraseña maestra',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: Validators.masterPassword,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _controller.text);
          },
          child: const Text('Activar'),
        ),
      ],
    );
  }
}

class DisableBiometricDialog extends StatelessWidget {
  const DisableBiometricDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Desactivar desbloqueo biométrico'),
      content: const Text(
        'Tendrás que usar tu contraseña maestra para desbloquear la bóveda.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Desactivar'),
        ),
      ],
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
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
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
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        Validators.confirmPassword(value, _newController.text),
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
              onPressed: vm.isChangingPassword
                  ? null
                  : () => Navigator.pop(context),
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
