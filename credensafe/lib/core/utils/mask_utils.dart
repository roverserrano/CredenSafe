class MaskUtils {
  const MaskUtils._();

  static String maskEmail(String? input) {
    if (input == null || input.isEmpty || !input.contains('@')) return '';
    final parts = input.split('@');
    final name = parts.first;
    final domain = parts.last;
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  static String maskPhone(String? input) {
    if (input == null || input.isEmpty) return '';
    final normalized = input.replaceAll(RegExp(r'\s+'), '');
    if (normalized.length <= 2) return '**';
    return '${normalized.substring(0, 2)}******${normalized.substring(normalized.length - 2)}';
  }

  static String maskLogin(String? input) {
    if (input == null || input.isEmpty) return '';
    if (input.length <= 3) return '${input[0]}**';
    return '${input.substring(0, 3)}***';
  }
}
