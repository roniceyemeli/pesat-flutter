import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:math';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _eventBucket = 'event-images';

  /// Upload event image and return public URL
  Future<String> uploadEventImage(File imageFile) async {
    try {
      final String fileName = _generateFileName();
      final String filePath = 'events/$fileName';

      await _supabase.storage
          .from(_eventBucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl =
          _supabase.storage.from(_eventBucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = _generateFileName();
      final String filePath = 'profiles/$userId/$fileName';

      await _supabase.storage
          .from(_eventBucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String publicUrl =
          _supabase.storage.from(_eventBucket).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.skip(2).join('/');
      
      await _supabase.storage.from(_eventBucket).remove([filePath]);
    } catch (e) {
      rethrow;
    }
  }

  String _generateFileName() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
  }
}
