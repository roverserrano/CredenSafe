import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String? get authRedirectUrl {
    final value = dotenv.env['AUTH_REDIRECT_URL']?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static int get appLockTimeoutSeconds =>
      int.tryParse(
        dotenv.env['AUTO_LOCK_SECONDS'] ??
            dotenv.env['APP_LOCK_TIMEOUT_SECONDS'] ??
            '60',
      ) ??
      60;
}
