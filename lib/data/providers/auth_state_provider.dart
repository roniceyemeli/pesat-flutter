import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final supabase = Supabase.instance.client;
  return supabase.auth.onAuthStateChange.map((event) {
    return AuthState(
      isAuthenticated: event.session != null,
      user: event.session?.user,
    );
  });
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateStreamProvider.future);
  return state.isAuthenticated;
});

class AuthState {
  final bool isAuthenticated;
  final User? user;

  AuthState({
    required this.isAuthenticated,
    this.user,
  });
}
