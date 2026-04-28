import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  AuthState({
    this.isAuthenticated = false, 
    this.isLoading = false, 
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated, 
    bool? isLoading, 
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _repository.getToken();
    
    if (token != null) {
      final localUser = await _repository.getLocalUser();
      state = state.copyWith(
        isAuthenticated: true, 
        user: localUser,
      );

      try {
        final userData = await _repository.getMe();
        await _repository.saveUserLocally(userData);
        state = state.copyWith(user: userData);
      } catch (e) {
        if (e.toString().contains('401') || e.toString().contains('User not found')) {
          await logout();
        }
      }
    } else {
      state = state.copyWith(isAuthenticated: false, user: null);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      
      // The user object might be directly in response or under 'user' key
      final userData = response['user'] ?? response;
      
      if (userData != null && userData is Map) {
        await _repository.saveUserLocally(Map<String, dynamic>.from(userData));
      }
      
      state = state.copyWith(
        isAuthenticated: true, 
        isLoading: false, 
        user: userData != null ? Map<String, dynamic>.from(userData) : null,
        error: null,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      
      final userData = response['user'] ?? response;
      
      if (userData != null && userData is Map) {
        await _repository.saveUserLocally(Map<String, dynamic>.from(userData));
      }
      
      state = state.copyWith(
        isAuthenticated: true, 
        isLoading: false, 
        user: userData != null ? Map<String, dynamic>.from(userData) : null,
        error: null,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(isAuthenticated: false, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
