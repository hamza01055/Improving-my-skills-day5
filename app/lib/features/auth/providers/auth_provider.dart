import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/models/user_model.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState();

  /// Called once from the splash screen.
  Future<void> restoreSession() async {
    final user = await _repo.restoreSession();
    state = user == null
        ? state.copyWith(status: AuthStatus.unauthenticated)
        : state.copyWith(status: AuthStatus.authenticated, user: user);
  }

  Future<void> login(String email, String password) => _run(() async {
        final user = await _repo.login(email: email, password: password);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      });

  Future<void> register(String name, String email, String password) =>
      _run(() async {
        final user = await _repo.register(
          name: name,
          email: email,
          password: password,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      });

  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repo.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await action();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
