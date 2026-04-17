import 'package:local_auth/local_auth.dart';

class BiometricGateService {
  const BiometricGateService();

  Future<bool> canUseBiometrics() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();
    return canCheck && isSupported;
  }

  Future<bool> authenticate({
    String reason = 'Autentícate para continuar en CredenSafe',
  }) async {
    final auth = LocalAuthentication();
    return auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
  }
}
