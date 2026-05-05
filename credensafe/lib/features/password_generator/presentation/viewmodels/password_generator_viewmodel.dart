import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/crypto/password_generator_service.dart';
import '../../../../core/utils/clipboard_utils.dart';

class PasswordGeneratorViewModel extends ChangeNotifier {
  PasswordGeneratorViewModel(this._generatorService) {
    generate(locale: 'es');
  }

  final IPasswordGeneratorService _generatorService;

  PasswordPolicy policy = const PasswordPolicy();
  PasswordGeneratorMode mode = PasswordGeneratorMode.random;
  GeneratedPassword? current;
  List<GeneratedPassword> history = [];
  bool isCopied = false;
  int copySecondsRemaining = 0;
  Timer? _copyTimer;

  void setMode(PasswordGeneratorMode value, {required String locale}) {
    mode = value;
    generate(locale: locale);
  }

  void updatePolicy(PasswordPolicy value, {required String locale}) {
    policy = value;
    generate(locale: locale);
  }

  void generate({required String locale}) {
    final generated = switch (mode) {
      PasswordGeneratorMode.random => _generatorService.generate(policy),
      PasswordGeneratorMode.pronounceable => _fromValue(
        _generatorService.generatePronounceablePassword(length: policy.length),
      ),
      PasswordGeneratorMode.memorable => _fromValue(
        _generatorService.generateMemorablePassword(
          wordCount: policy.length >= 24 ? 4 : 3,
          locale: locale,
        ),
      ),
    };
    current = generated;
    history = [generated, ...history].take(20).toList();
    isCopied = false;
    copySecondsRemaining = 0;
    notifyListeners();
  }

  Future<void> copyCurrent() async {
    final value = current?.value;
    if (value == null || value.isEmpty) return;
    await ClipboardUtils.copyWithAutoClear(
      value,
      clearAfter: const Duration(seconds: 30),
    );
    _copyTimer?.cancel();
    isCopied = true;
    copySecondsRemaining = 30;
    notifyListeners();
    _copyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      copySecondsRemaining -= 1;
      if (copySecondsRemaining <= 0) {
        timer.cancel();
        isCopied = false;
        copySecondsRemaining = 0;
      }
      notifyListeners();
    });
  }

  GeneratedPassword _fromValue(String value) {
    final entropy = _generatorService.calculateEntropy(value);
    return GeneratedPassword(
      value: value,
      entropyBits: entropy,
      strength: _strengthForEntropy(entropy),
      generatedAt: DateTime.now(),
    );
  }

  PasswordStrength _strengthForEntropy(double entropy) {
    if (entropy < 28) return PasswordStrength.veryWeak;
    if (entropy < 40) return PasswordStrength.weak;
    if (entropy < 60) return PasswordStrength.fair;
    if (entropy < 80) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }
}
