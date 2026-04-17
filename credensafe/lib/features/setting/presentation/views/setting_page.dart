import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
