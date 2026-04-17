class Validators {
  const Validators._();

  static String? requiredField(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? masterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña maestra es obligatoria';
    }
    if (value.length < 12) {
      return 'Debe tener al menos 12 caracteres';
    }
    return null;
  }
}
