import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../viewmodels/credential_detail_viewmodel.dart';

class CredentialDetailPage extends StatefulWidget {
  const CredentialDetailPage({super.key, required this.credentialId});

  final String credentialId;

  @override
  State<CredentialDetailPage> createState() => _CredentialDetailPageState();
}

class _CredentialDetailPageState extends State<CredentialDetailPage> {
  bool _showPassword = false;
  bool _showSecurityCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CredentialDetailViewModel>().load(widget.credentialId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CredentialDetailViewModel>();
    final credential = vm.credential;

    return Scaffold(
      appBar: AppBar(
        title: Text(credential?.appName ?? 'Detalle'),
        actions: [
          IconButton(
            onPressed: credential == null
                ? null
                : () async {
                    await AppNavigator.toCredentialForm(
                      context,
                      credentialId: credential.id,
                    );
                    if (context.mounted) {
                      await vm.load(widget.credentialId);
                    }
                  },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : credential == null
          ? const Center(child: Text('No se pudo cargar la credencial'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field('Aplicación', credential.appName),
                _field('URL', credential.appUrl),
                _field('Categoría', credential.category),
                _field('Cuenta', credential.accountLabel),
                _field('Correo', credential.email),
                _field('Usuario', credential.username),
                _secureField(
                  label: 'Contraseña',
                  value: credential.password,
                  isVisible: _showPassword,
                  onToggle: () =>
                      setState(() => _showPassword = !_showPassword),
                  onCopy: vm.copyPassword,
                ),
                _field('Número de teléfono', credential.phoneNumber),
                _secureField(
                  label: 'Código de seguridad',
                  value: credential.securityCode,
                  isVisible: _showSecurityCode,
                  onToggle: () =>
                      setState(() => _showSecurityCode = !_showSecurityCode),
                ),
                _field('Correo de recuperación', credential.recoveryEmail),
                _field('Teléfono de recuperación', credential.recoveryPhone),
                _field('Notas privadas', credential.notes),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () async {
                    await vm.deleteCurrent();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Eliminar credencial'),
                ),
              ],
            ),
    );
  }

  Widget _field(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }

  Widget _secureField({
    required String label,
    required String? value,
    required bool isVisible,
    required VoidCallback onToggle,
    VoidCallback? onCopy,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(isVisible ? value : '••••••••••••'),
        trailing: Wrap(
          spacing: 8,
          children: [
            if (onCopy != null)
              IconButton(onPressed: onCopy, icon: const Icon(Icons.copy)),
            IconButton(
              onPressed: onToggle,
              icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
            ),
          ],
        ),
      ),
    );
  }
}
