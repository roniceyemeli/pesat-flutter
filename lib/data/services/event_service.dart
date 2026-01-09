import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _table = 'events';

  /// Get all events as stream
  Stream<List<Event>> getEventsStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('event_date', ascending: false)
        .map((event) => event.map((e) => Event.fromJson(e)).toList())
        .handleError((error) {
          print('Error loading events: $error');
          return <Event>[];
        });
  }

  /// Get user's events
  Stream<List<Event>> getUserEventsStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('event_date', ascending: false)
        .map((event) => event.map((e) => Event.fromJson(e)).toList())
        .handleError((error) {
          print('Error loading user events: $error');
          return <Event>[];
        });
  }

  /// Get event by ID
  Future<Event> getEventById(String eventId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', eventId)
        .single();

    return Event.fromJson(response);
  }

  /// Create event
  Future<Event> createEvent(Map<String, dynamic> data) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Verify user profile exists before creating event
      try {
        final profileExists = await _supabase
            .from('profiles')
            .select('id')
            .eq('id', userId)
            .single();
      } catch (e) {
        // Profile doesn't exist, create it
        print('Profile not found for user $userId, creating one...');
        await _supabase.from('profiles').insert({
          'id': userId,
          'full_name': _supabase.auth.currentUser?.email?.split('@')[0] ?? 'User',
        });
      }
      
      final response = await _supabase
          .from(_table)
          .insert({
            ...data,
            'user_id': userId,
          })
          .select()
          .single();

      return Event.fromJson(response);
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Update event
  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    final response = await _supabase
        .from(_table)
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', eventId)
        .select()
        .single();

    return Event.fromJson(response);
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from(_table).delete().eq('id', eventId);
  }
}
