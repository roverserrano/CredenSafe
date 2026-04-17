import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/models/decrypted_credential.dart';
import '../viewmodels/credential_form_viewmodel.dart';

class CredentialFormPage extends StatefulWidget {
  const CredentialFormPage({super.key, this.credentialId});

  final String? credentialId;

  @override
  State<CredentialFormPage> createState() => _CredentialFormPageState();
}

class _CredentialFormPageState extends State<CredentialFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _appUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _labelController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _securityCodeController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _recoveryPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _favorite = false;
  bool _loadingInitial = false;

  @override
  void initState() {
    super.initState();
    if (widget.credentialId != null) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() => _loadingInitial = true);
    final credential = await context
        .read<CredentialFormViewModel>()
        .loadCredential(widget.credentialId!);
    if (credential != null && mounted) {
      _appNameController.text = credential.appName;
      _appUrlController.text = credential.appUrl ?? '';
      _categoryController.text = credential.category ?? '';
      _labelController.text = credential.accountLabel ?? '';
      _emailController.text = credential.email ?? '';
      _usernameController.text = credential.username ?? '';
      _passwordController.text = credential.password ?? '';
      _phoneController.text = credential.phoneNumber ?? '';
      _securityCodeController.text = credential.securityCode ?? '';
      _recoveryEmailController.text = credential.recoveryEmail ?? '';
      _recoveryPhoneController.text = credential.recoveryPhone ?? '';
      _notesController.text = credential.notes ?? '';
      _favorite = credential.isFavorite;
    }
    setState(() => _loadingInitial = false);
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appUrlController.dispose();
    _categoryController.dispose();
    _labelController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _securityCodeController.dispose();
    _recoveryEmailController.dispose();
    _recoveryPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CredentialFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.credentialId == null ? 'Nueva credencial' : 'Editar credencial'),
        actions: [
          IconButton(
            onPressed: () {
              _passwordController.text = vm.generatePassword();
            },
            icon: const Icon(Icons.password),
            tooltip: 'Generar contraseña',
          ),
        ],
      ),
      body: _loadingInitial
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _appNameController,
                            decoration: const InputDecoration(labelText: 'Aplicación / servicio'),
                            validator: (value) => Validators.requiredField(
                              value,
                              fieldName: 'Aplicación',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _appUrlController,
                            decoration: const InputDecoration(labelText: 'URL'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: 'Categoría'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _labelController,
                            decoration: const InputDecoration(labelText: 'Nombre visible de la cuenta'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Correo'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Contraseña'),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Número de teléfono'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _securityCodeController,
                            decoration: const InputDecoration(labelText: 'Código de seguridad'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recoveryEmailController,
                            decoration: const InputDecoration(labelText: 'Correo de recuperación'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recoveryPhoneController,
                            decoration: const InputDecoration(labelText: 'Teléfono de recuperación'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Notas privadas'),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: _favorite,
                            onChanged: (value) => setState(() => _favorite = value),
                            title: const Text('Marcar como favorita'),
                          ),
                          if (vm.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              vm.errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    final ok = await vm.save(
                                      DecryptedCredential(
                                        id: widget.credentialId,
                                        appName: _appNameController.text.trim(),
                                        appUrl: _appUrlController.text.trim().isEmpty
                                            ? null
                                            : _appUrlController.text.trim(),
                                        category: _categoryController.text.trim().isEmpty
                                            ? null
                                            : _categoryController.text.trim(),
                                        accountLabel: _labelController.text.trim().isEmpty
                                            ? null
                                            : _labelController.text.trim(),
                                        email: _emailController.text.trim().isEmpty
                                            ? null
                                            : _emailController.text.trim(),
                                        username: _usernameController.text.trim().isEmpty
                                            ? null
                                            : _usernameController.text.trim(),
                                        password: _passwordController.text,
                                        phoneNumber: _phoneController.text.trim().isEmpty
                                            ? null
                                            : _phoneController.text.trim(),
                                        securityCode: _securityCodeController.text.trim().isEmpty
                                            ? null
                                            : _securityCodeController.text.trim(),
                                        recoveryEmail: _recoveryEmailController.text.trim().isEmpty
                                            ? null
                                            : _recoveryEmailController.text.trim(),
                                        recoveryPhone: _recoveryPhoneController.text.trim().isEmpty
                                            ? null
                                            : _recoveryPhoneController.text.trim(),
                                        notes: _notesController.text.trim().isEmpty
                                            ? null
                                            : _notesController.text.trim(),
                                        isFavorite: _favorite,
                                      ),
                                    );
                                    if (ok && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            child: vm.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Guardar'),
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
