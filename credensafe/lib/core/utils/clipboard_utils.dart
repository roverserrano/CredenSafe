import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardUtils {
  const ClipboardUtils._();

  static Future<void> copyWithAutoClear(
    String value, {
    Duration clearAfter = const Duration(seconds: 20),
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    unawaited(
      Future<void>.delayed(clearAfter, () async {
        final current = await Clipboard.getData('text/plain');
        if (current?.text == value) {
          await Clipboard.setData(const ClipboardData(text: ''));
        }
      }),
    );
  }
}
