import 'package:riverpod/riverpod.dart';
import '../models/event.dart';
import '../services/event_service.dart';

final eventServiceProvider = Provider((ref) => EventService());

final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getEventsStream();
});

final eventDetailsProvider = FutureProvider.family<Event, String>((ref, eventId) async {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getEventById(eventId);
});

final userEventsProvider = StreamProvider<List<Event>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getUserEventsStream();
});

final createEventProvider = FutureProvider.family<Event, Map<String, dynamic>>((ref, data) async {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.createEvent(data);
});

final updateEventProvider = FutureProvider.family<Event, (String, Map<String, dynamic>)>((ref, params) async {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.updateEvent(params.$1, params.$2);
});

final deleteEventProvider = FutureProvider.family<void, String>((ref, eventId) async {
  final eventService = ref.watch(eventServiceProvider);
  await eventService.deleteEvent(eventId);
});
