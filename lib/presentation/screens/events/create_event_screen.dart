import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/event/event_form.dart';
import '../../../data/providers/event_provider.dart';

class CreateEventScreen extends ConsumerWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: EventForm(
        onSubmit: (data) async {
          // Show loading dialog
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            // Create event using provider
            await ref.read(createEventProvider(data).future);

            if (!context.mounted) return;
            // Close loading dialog
            context.pop();
            
            // Invalidate the events stream to trigger refresh
            ref.refresh(eventsStreamProvider);
            ref.refresh(userEventsProvider);
            
            // Navigate back to events
            context.pop();
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully!')),
            );
          } catch (e) {
            if (!context.mounted) return;
            // Close loading dialog
            context.pop();
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating event: $e')),
            );
          }
        },
      ),
    );
  }
}

