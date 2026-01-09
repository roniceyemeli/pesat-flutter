import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme/app_theme.dart';
import 'data/providers/auth_state_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/events/event_feed_screen.dart';
import 'presentation/screens/events/create_event_screen.dart';
import 'presentation/screens/events/event_details_screen.dart';
import 'presentation/screens/events/edit_event_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://nzwibivhkhszicoacscu.supabase.co',
    anonKey: 'sb_secret_6ecvmxXU1qjEsZwsSf839Q_puynHSo4',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateStreamProvider);

    return authStateAsync.when(
      loading: () => MaterialApp(
        title: 'Event App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        title: 'Event App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
      data: (authState) {
        final router = GoRouter(
          initialLocation: authState.isAuthenticated ? '/home' : '/login',
          redirect: (context, state) {
            final isAuthenticated = authState.isAuthenticated;
            final isLoggingIn = state.matchedLocation == '/login';
            final isSigningUp = state.matchedLocation == '/signup';

            // Redirect unauthenticated users to login
            if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
              return '/login';
            }

            // Redirect authenticated users away from login/signup
            if (isAuthenticated && (isLoggingIn || isSigningUp)) {
              return '/home';
            }

            return null; // No redirect needed
          },
          routes: [
            ShellRoute(
              builder: (context, state, child) {
                return ShellScreen(
                  location: state.matchedLocation,
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: '/events',
                  builder: (context, state) => const EventFeedScreen(),
                ),
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (context, state) => const SignupScreen(),
            ),
            GoRoute(
              path: '/create-event',
              builder: (context, state) => const CreateEventScreen(),
            ),
            GoRoute(
              path: '/event-details/:eventId',
              builder: (context, state) {
                final eventId = state.pathParameters['eventId']!;
                return EventDetailsScreen(eventId: eventId);
              },
            ),
            GoRoute(
              path: '/edit-event/:eventId',
              builder: (context, state) {
                final eventId = state.pathParameters['eventId']!;
                return EditEventScreen(eventId: eventId);
              },
            ),
          ],
          errorBuilder: (context, state) => Scaffold(
            body: Center(
              child: Text('Error: ${state.error}'),
            ),
          ),
        );

        return MaterialApp.router(
          title: 'Event App',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
