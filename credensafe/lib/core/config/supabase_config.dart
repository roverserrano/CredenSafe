import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static int get appLockTimeoutSeconds =>
      int.tryParse(dotenv.env['APP_LOCK_TIMEOUT_SECONDS'] ?? '60') ?? 60;
}
