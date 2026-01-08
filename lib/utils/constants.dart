class AppConstants {
  // App Info
  static const String appName = 'Event App';
  static const String appVersion = '1.0.0';

  // API & URLs
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Supabase Tables
  static const String profilesTable = 'profiles';
  static const String eventsTable = 'events';
  static const String attendeesTable = 'event_attendees';

  // Storage Buckets
  static const String eventImagesBucket = 'event-images';

  // Durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration responseTimeout = Duration(seconds: 30);

  // Image Limits
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;

  // Pagination
  static const int pageSize = 20;

  // Event Categories
  static const List<String> eventCategories = [
    'Tech',
    'Sports',
    'Music',
    'Food',
    'Art',
    'Business',
    'Education',
    'Health',
    'Entertainment',
    'Other'
  ];
}
