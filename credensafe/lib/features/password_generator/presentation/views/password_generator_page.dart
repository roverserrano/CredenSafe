import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/crypto/password_generator_service.dart';
import '../viewmodels/password_generator_viewmodel.dart';

class PasswordGeneratorPage extends StatelessWidget {
  const PasswordGeneratorPage({super.key, this.selectionMode = false});

  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PasswordGeneratorViewModel>();
    final locale = Localizations.localeOf(context).languageCode;
    final text = _GeneratorText.forLocale(locale);
    final current = vm.current;

    return Scaffold(
      appBar: AppBar(title: Text(text.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<PasswordGeneratorMode>(
                      segments: [
                        ButtonSegment(
                          value: PasswordGeneratorMode.random,
                          icon: const Icon(Icons.shuffle),
                          label: Text(text.random),
                        ),
                        ButtonSegment(
                          value: PasswordGeneratorMode.pronounceable,
                          icon: const Icon(Icons.record_voice_over),
                          label: Text(text.pronounceable),
                        ),
                        ButtonSegment(
                          value: PasswordGeneratorMode.memorable,
                          icon: const Icon(Icons.menu_book),
                          label: Text(text.memorable),
                        ),
                      ],
                      selected: {vm.mode},
                      onSelectionChanged: (selected) {
                        vm.setMode(selected.first, locale: locale);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (current != null)
                      _GeneratedPasswordCard(
                        password: current,
                        text: text,
                        isCopied: vm.isCopied,
                        copySecondsRemaining: vm.copySecondsRemaining,
                        memorable: vm.mode == PasswordGeneratorMode.memorable,
                        onCopy: vm.copyCurrent,
                        onUse: selectionMode
                            ? () => Navigator.pop(context, current.value)
                            : null,
                      ),
                    const SizedBox(height: 16),
                    _PolicyPanel(
                      policy: vm.policy,
                      mode: vm.mode,
                      text: text,
                      onChanged: (policy) =>
                          vm.updatePolicy(policy, locale: locale),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => vm.generate(locale: locale),
                      icon: const Icon(Icons.refresh),
                      label: Text(text.generate),
                    ),
                    if (vm.history.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        text.history,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...vm.history.map(
                        (item) => Card(
                          child: ListTile(
                            title: Text(
                              item.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(text.strengthLabel(item.strength)),
                            trailing: IconButton(
                              tooltip: text.use,
                              icon: const Icon(Icons.north_west),
                              onPressed: selectionMode
                                  ? () => Navigator.pop(context, item.value)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedPasswordCard extends StatelessWidget {
  const _GeneratedPasswordCard({
    required this.password,
    required this.text,
    required this.isCopied,
    required this.copySecondsRemaining,
    required this.memorable,
    required this.onCopy,
    this.onUse,
  });

  final GeneratedPassword password;
  final _GeneratorText text;
  final bool isCopied;
  final int copySecondsRemaining;
  final bool memorable;
  final VoidCallback onCopy;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final color = _strengthColor(context, password.strength);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: memorable
                  ? password.value
                        .split('-')
                        .map((word) => Chip(label: Text(word)))
                        .toList()
                  : [
                      SelectableText(
                        password.value,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (password.entropyBits / 100).clamp(0, 1),
                minHeight: 8,
                color: color,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${text.entropy}: ${password.entropyBits.toStringAsFixed(1)} bits · ${text.strengthLabel(password.strength)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy),
                  label: Text(
                    isCopied
                        ? '${text.copied} ${copySecondsRemaining}s'
                        : text.copy,
                  ),
                ),
                if (onUse != null)
                  OutlinedButton.icon(
                    onPressed: onUse,
                    icon: const Icon(Icons.check),
                    label: Text(text.use),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _strengthColor(BuildContext context, PasswordStrength strength) {
    return switch (strength) {
      PasswordStrength.veryWeak => Colors.red.shade700,
      PasswordStrength.weak => Colors.deepOrange.shade700,
      PasswordStrength.fair => Colors.amber.shade800,
      PasswordStrength.strong => Colors.lightGreen.shade700,
      PasswordStrength.veryStrong => Colors.green.shade700,
    };
  }
}

class _PolicyPanel extends StatelessWidget {
  const _PolicyPanel({
    required this.policy,
    required this.mode,
    required this.text,
    required this.onChanged,
  });

  final PasswordPolicy policy;
  final PasswordGeneratorMode mode;
  final _GeneratorText text;
  final ValueChanged<PasswordPolicy> onChanged;

  @override
  Widget build(BuildContext context) {
    final lengthController = TextEditingController(
      text: policy.length.toString(),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text.settings, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: policy.length.toDouble(),
                    min: 8,
                    max: 128,
                    divisions: 120,
                    label: policy.length.toString(),
                    onChanged: (value) =>
                        onChanged(policy.copyWith(length: value.round())),
                  ),
                ),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: lengthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: text.length),
                    onSubmitted: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null) return;
                      onChanged(policy.copyWith(length: parsed.clamp(8, 128)));
                    },
                  ),
                ),
              ],
            ),
            if (mode == PasswordGeneratorMode.random) ...[
              const SizedBox(height: 8),
              _PolicySwitch(
                title: text.uppercase,
                value: policy.uppercase,
                onChanged: (value) =>
                    onChanged(policy.copyWith(uppercase: value)),
              ),
              _PolicySwitch(
                title: text.lowercase,
                value: policy.lowercase,
                onChanged: (value) =>
                    onChanged(policy.copyWith(lowercase: value)),
              ),
              _PolicySwitch(
                title: text.digits,
                value: policy.digits,
                onChanged: (value) => onChanged(policy.copyWith(digits: value)),
              ),
              _PolicySwitch(
                title: text.symbols,
                value: policy.symbols,
                onChanged: (value) =>
                    onChanged(policy.copyWith(symbols: value)),
              ),
              _PolicySwitch(
                title: text.avoidAmbiguous,
                value: policy.avoidAmbiguous,
                onChanged: (value) =>
                    onChanged(policy.copyWith(avoidAmbiguous: value)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PolicySwitch extends StatelessWidget {
  const _PolicySwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _GeneratorText {
  const _GeneratorText._({
    required this.title,
    required this.random,
    required this.pronounceable,
    required this.memorable,
    required this.entropy,
    required this.copy,
    required this.copied,
    required this.use,
    required this.settings,
    required this.length,
    required this.uppercase,
    required this.lowercase,
    required this.digits,
    required this.symbols,
    required this.avoidAmbiguous,
    required this.generate,
    required this.history,
  });

  final String title;
  final String random;
  final String pronounceable;
  final String memorable;
  final String entropy;
  final String copy;
  final String copied;
  final String use;
  final String settings;
  final String length;
  final String uppercase;
  final String lowercase;
  final String digits;
  final String symbols;
  final String avoidAmbiguous;
  final String generate;
  final String history;

  static _GeneratorText forLocale(String locale) {
    if (locale.toLowerCase().startsWith('en')) return _en;
    return _es;
  }

  String strengthLabel(PasswordStrength strength) {
    return switch (strength) {
      PasswordStrength.veryWeak => this == _en ? 'very weak' : 'muy débil',
      PasswordStrength.weak => this == _en ? 'weak' : 'débil',
      PasswordStrength.fair => this == _en ? 'fair' : 'aceptable',
      PasswordStrength.strong => this == _en ? 'strong' : 'fuerte',
      PasswordStrength.veryStrong => this == _en ? 'very strong' : 'muy fuerte',
    };
  }

  static const _es = _GeneratorText._(
    title: 'Generador',
    random: 'Aleatoria',
    pronounceable: 'Pronunciable',
    memorable: 'Memorable',
    entropy: 'Entropía',
    copy: 'Copiar',
    copied: 'Copiado',
    use: 'Usar',
    settings: 'Reglas',
    length: 'Largo',
    uppercase: 'Mayúsculas',
    lowercase: 'Minúsculas',
    digits: 'Números',
    symbols: 'Símbolos',
    avoidAmbiguous: 'Evitar caracteres ambiguos',
    generate: 'Generar contraseña',
    history: 'Historial de esta sesión',
  );

  static const _en = _GeneratorText._(
    title: 'Generator',
    random: 'Random',
    pronounceable: 'Pronounceable',
    memorable: 'Memorable',
    entropy: 'Entropy',
    copy: 'Copy',
    copied: 'Copied',
    use: 'Use',
    settings: 'Rules',
    length: 'Length',
    uppercase: 'Uppercase',
    lowercase: 'Lowercase',
    digits: 'Numbers',
    symbols: 'Symbols',
    avoidAmbiguous: 'Avoid ambiguous characters',
    generate: 'Generate password',
    history: 'Session history',
  );
}
