# Flutter Event App - Technical Blueprint

A modern Flutter event management application with Supabase backend, Material 3 UI, and Riverpod state management.

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── config/
│   ├── theme/
│   │   ├── app_theme.dart           # Material 3 Theme configuration
│   │   └── colors.dart              # App color palette
│   └── routes/
│       └── app_routes.dart          # Navigation routes
├── data/
│   ├── models/
│   │   ├── user_profile.dart        # UserProfile model
│   │   ├── event.dart               # Event model
│   │   └── app_exception.dart       # Custom exceptions
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication Riverpod providers
│   │   ├── event_provider.dart      # Event Riverpod providers
│   │   ├── profile_provider.dart    # Profile Riverpod providers
│   │   └── image_upload_provider.dart # Image upload providers
│   └── services/
│       ├── auth_service.dart        # Authentication logic
│       ├── event_service.dart       # Event operations
│       ├── storage_service.dart     # Supabase storage operations
│       └── image_picker_service.dart # Image picking logic
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── events/
│   │   │   ├── event_feed_screen.dart
│   │   │   ├── event_details_screen.dart
│   │   │   └── create_event_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── glassmorphic_nav_bar.dart  # Glassmorphic navigation
│       │   ├── custom_app_bar.dart
│       │   └── custom_button.dart
│       ├── event/
│       │   ├── event_card.dart           # Card with Hero animation
│       │   ├── event_form.dart           # Event creation form
│       │   └── event_image_picker.dart
│       └── profile/
│           └── profile_form.dart
└── utils/
    ├── validators.dart    # Input validation
    ├── constants.dart     # App constants
    └── extensions.dart    # Dart extensions
```

## Tech Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Riverpod 2.4.0
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **UI Framework**: Material 3
- **Image Handling**: image_picker, Supabase Storage
- **Date/Time**: intl

## Setup Instructions

### 1. Prerequisites

```bash
flutter --version  # Ensure Flutter 3.0+
flutter pub get    # Install dependencies
```

### 2. Configure Supabase

#### Create Supabase Project

1. Go to [Supabase Console](https://app.supabase.com)
2. Create a new project
3. Get your `URL` and `Anon Key`

#### Update `lib/main.dart`

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 3. Database Setup

#### Create Tables (Run in Supabase SQL Editor)

**Profiles Table**:

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  bio TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Events Table**:

```sql
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(100),
  location VARCHAR(255),
  event_date TIMESTAMP NOT NULL,
  thumbnail_url TEXT,
  image_url TEXT,
  capacity INTEGER,
  attendees_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Event Attendees Table**:

```sql
CREATE TABLE event_attendees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(event_id, user_id)
);
```

### 4. Row Level Security (RLS)

#### Enable RLS on Tables

```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;
```

#### Create RLS Policies

**Profiles Policies**:

```sql
CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

**Events Policies**:

```sql
CREATE POLICY "Everyone can view published events"
  ON events FOR SELECT USING (true);

CREATE POLICY "Users can create events"
  ON events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own events"
  ON events FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own events"
  ON events FOR DELETE
  USING (auth.uid() = user_id);
```

### 5. Storage Setup

1. In Supabase Console, go to **Storage**
2. Create a new bucket named `event-images`
3. Set Public Access to **ON**
4. Add Policy for CRUD operations

### 6. Run the App

```bash
flutter run
```

## Key Features

### 1. Glassmorphic Navigation Bar

- Frosted glass effect with backdrop filter
- Smooth transitions between tabs
- Material 3 color scheme integration

### 2. Event Cards with Hero Animations

- Hero animation transitions to detail page
- Optimized image loading with error handling
- Display event date, location, attendee count

### 3. Form Validation

- Email validation (RFC 5322 compliant)
- Password strength validation (min 8 chars, uppercase, number)
- Event title/description validation
- Location validation
- Custom error messages

### 4. Image Upload Workflow

1. **Pick Image**: Use `ImagePickerService`

   ```dart
   final file = await imagePickerService.pickImage();
   ```

2. **Upload to Storage**: Use `StorageService`

   ```dart
   final url = await storageService.uploadEventImage(imageFile);
   ```

3. **Save URL to Database**: Include in event creation
   ```dart
   {
     'title': 'My Event',
     'thumbnail_url': url,
     // ... other fields
   }
   ```

### 5. Row Level Security Benefits

- **User-owned Data**: Users can only modify their own events
- **Data Privacy**: Automatic filtering at database level
- **Security**: No need for custom auth checks in API calls

## State Management with Riverpod

### Event Providers Example

```dart
// Watch events stream
final events = ref.watch(eventsStreamProvider);

// Create event
ref.watch(createEventProvider(eventData));

// Watch current user profile
final profile = ref.watch(currentUserProfileProvider);
```

## Validators

- `validateEmail(String?)` - RFC 5322 email format
- `validatePassword(String?)` - Min 8 chars, 1 uppercase, 1 number
- `validateFullName(String?)` - Letters only, 2+ chars
- `validateEventTitle(String?)` - 3-100 characters
- `validateDescription(String?)` - 10-500 characters
- `validateLocation(String?)` - 2+ characters

## Material 3 Color Scheme

- **Primary**: #6366F1 (Indigo)
- **Text Primary**: #1F2937 (Dark Gray)
- **Background**: #FFFFFF, #F9FAFB, #F3F4F6

## Building for Production

### Android

```bash
flutter build apk
# or
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

## Performance Optimization

1. **Image Optimization**: Compressed to 1024x1024, 80% quality
2. **Stream Subscriptions**: Real-time updates with Riverpod
3. **Lazy Loading**: Event cards load on demand
4. **Database Indexes**: On user_id, event_date, attendees

## Security Considerations

✅ Row Level Security enforced at database level
✅ Image validation before upload
✅ Input validation on all forms
✅ Secure token storage (Supabase handles)
✅ HTTPS for all API calls

## Future Enhancements

- [ ] Push notifications for event reminders
- [ ] Event filtering and search
- [ ] User ratings and reviews
- [ ] Event sharing to social media
- [ ] Map integration for event locations
- [ ] User messaging system
- [ ] Event calendar view
- [ ] Attendance tracking

## Contributing

1. Follow Flutter best practices
2. Use Riverpod for state management
3. Implement proper error handling
4. Write meaningful commit messages

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please contact the development team.
