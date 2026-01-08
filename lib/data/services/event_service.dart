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
        .map((event) => event.map((e) => Event.fromJson(e)).toList());
  }

  /// Get user's events
  Stream<List<Event>> getUserEventsStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', _supabase.auth.currentUser!.id)
        .order('event_date', ascending: false)
        .map((event) => event.map((e) => Event.fromJson(e)).toList());
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
    final response = await _supabase
        .from(_table)
        .insert({
          ...data,
          'user_id': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

    return Event.fromJson(response);
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
