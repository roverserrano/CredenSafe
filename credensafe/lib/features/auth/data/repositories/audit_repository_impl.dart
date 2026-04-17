import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_remote_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteService);

  final AuthRemoteService _remoteService;

  @override
  Stream<AppUser?> authStateChanges() {
    return _remoteService.authStateChanges().map((event) {
      final user = event.session?.user;
      if (user == null || user.email == null) return null;
      return AppUser(id: user.id, email: user.email!);
    });
  }

  @override
  AppUser? currentUser() {
    final user = _remoteService.currentUser();
    if (user == null || user.email == null) return null;
    return AppUser(id: user.id, email: user.email!);
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _remoteService.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _remoteService.signOut();

  @override
  Future<void> signUp({required String email, required String password}) {
    return _remoteService.signUp(email: email, password: password);
  }
}
