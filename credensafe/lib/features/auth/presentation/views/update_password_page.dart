import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../../vault/presentation/viewmodels/session_viewmodel.dart';
import '../viewmodels/auth_form_status.dart';
import '../viewmodels/update_password_viewmodel.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({
    super.key,
    this.isRecoveryFlow = false,
  });

  final bool isRecoveryFlow;

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdatePasswordViewModel>();
    final isSuccess = vm.status == PasswordChangeStatus.success;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRecoveryFlow
            ? 'Nueva contraseña'
            : 'Actualizar contraseña'),
      ),
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
                    const Icon(Icons.password, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Define una contraseña segura',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
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
                        _passwordController.text,
                      ),
                    ),
                    if (vm.message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.message!,
                        style: TextStyle(
                          color: isSuccess
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              vm.markValidating();
                              if (!_formKey.currentState!.validate()) return;
                              final ok = await vm.updatePassword(
                                newPassword: _passwordController.text,
                              );
                              if (!ok || !context.mounted) return;
                              context
                                  .read<SessionViewModel>()
                                  .completePasswordRecovery();
                              if (!widget.isRecoveryFlow) {
                                Navigator.of(context).pop();
                              }
                            },
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Actualizar contraseña'),
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
