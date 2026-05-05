import 'app_user.dart';

enum AuthSessionEvent {
  initialSession,
  signedIn,
  signedOut,
  passwordRecovery,
  userUpdated,
  tokenRefreshed,
  unknown,
}

class AuthSessionState {
  const AuthSessionState({required this.event, this.user});

  final AuthSessionEvent event;
  final AppUser? user;
}
