import 'package:riverpod/riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return Stream.value(authService.isAuthenticated());
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated()) {
    return null;
  }
  return authService.getCurrentUserProfile();
});

final signUpProvider = FutureProvider.family<String, (String, String, String)>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signUp(
    email: params.$1,
    password: params.$2,
    fullName: params.$3,
  );
});

final signInProvider = FutureProvider.family<String, (String, String)>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signIn(
    email: params.$1,
    password: params.$2,
  );
});

final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  await authService.signOut();
});

final updateProfileProvider = FutureProvider.family<UserProfile, Map<String, dynamic>>((ref, data) async {
  final authService = ref.watch(authServiceProvider);
  return authService.updateUserProfile(data);
});
