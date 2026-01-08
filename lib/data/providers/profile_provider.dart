import 'package:riverpod/riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

final profileServiceProvider = Provider((ref) => AuthService());

final userProfileProvider = FutureProvider.family<UserProfile, String>((ref, userId) async {
  final authService = ref.watch(profileServiceProvider);
  return authService.getCurrentUserProfile();
});
