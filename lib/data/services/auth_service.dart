import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'profiles';

  /// Sign up with email and password
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Create profile
        await _supabase.from(_table).insert({
          'id': res.user!.id,
          'full_name': fullName,
        });
      }

      return res.user!.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return res.user!.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<UserProfile> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from(_table)
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from(_table)
          .update({...data, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
