# Flutter Event App

## Overview
The Flutter Event App is a modern mobile application designed to facilitate event management and user interaction. Built using Flutter for the frontend, it leverages Supabase for backend services, including authentication, database management, and file storage. The app features a minimalist UI with a focus on user experience, utilizing Material 3 design principles.

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Supabase (Auth, PostgreSQL, Storage)
- **State Management**: Provider or Riverpod

## Features
- User authentication (sign up, login)
- Event creation, viewing, and management
- User profile management
- Image upload functionality
- Modern UI with animations and transitions

## Data Architecture
### Supabase SQL Schema
#### Profiles Table
```sql
CREATE TABLE profiles (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE,
    name TEXT,
    email TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Events Table
```sql
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES profiles(user_id) ON DELETE CASCADE,
    title TEXT,
    description TEXT,
    thumbnail_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## UI/UX Design
### Design Principles
- **Modern and Minimalist**: The app will utilize a clean layout with ample white space and a focus on usability.
- **Material 3**: The design will incorporate Material 3 components for a cohesive look and feel.

### Components
- **Glassmorphic Bottom Navigation Bar**: A visually appealing navigation bar that uses a frosted glass effect to enhance the modern aesthetic.
- **Event Cards**: Each event will be displayed as a card with Hero animations for smooth transitions to the event details page.
- **Forms**: High-quality input validation will be implemented for event creation and profile editing to ensure data integrity.

## Logic & Security
### Row Level Security (RLS)
Row Level Security will be implemented in Supabase to ensure that users can only update or delete events they created. This will be enforced through policies defined in the Supabase dashboard.

### Image Upload Workflow
1. **Image Picker**: Use the `image_picker` package to allow users to select an image from their device.
2. **Upload to Supabase Storage**: The selected image will be uploaded to Supabase Storage.
3. **Save Public URL**: The public URL of the uploaded image will be saved in the events table under the `thumbnail_url` field.

## Folder Structure
The project follows a 'Feature-first' directory structure to ensure scalability and maintainability:
```
flutter-event-app
├── lib
│   ├── main.dart
│   ├── app.dart
│   ├── core
│   │   ├── widgets
│   │   │   └── glassmorphic_bottom_nav.dart
│   │   ├── services
│   │   │   └── supabase_client.dart
│   │   └── utils
│   │       └── validators.dart
│   ├── features
│   │   ├── auth
│   │   │   ├── data
│   │   │   │   └── auth_repository.dart
│   │   │   ├── presentation
│   │   │   │   ├── login_page.dart
│   │   │   │   └── signup_page.dart
│   │   │   └── state
│   │   │       └── auth_provider.dart
│   │   ├── events
│   │   │   ├── data
│   │   │   │   ├── events_repository.dart
│   │   │   │   └── models
│   │   │   │       └── event.dart
│   │   │   ├── presentation
│   │   │   │   ├── feed_page.dart
│   │   │   │   ├── event_card.dart
│   │   │   │   └── event_details_page.dart
│   │   │   └── state
│   │   │       └── events_provider.dart
│   │   └── profile
│   │       ├── data
│   │       │   └── profile_repository.dart
│   │       ├── presentation
│   │       │   └── profile_page.dart
│   │       └── state
│   │           └── profile_provider.dart
│   └── l10n
├── assets
│   ├── images
│   └── fonts
├── test
│   ├── unit
│   └── widget
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── android
├── ios
├── web
└── .gitignore
```

## Getting Started
To get started with the Flutter Event App, clone the repository and run the following commands:

1. Install dependencies:
   ```
   flutter pub get
   ```

2. Run the application:
   ```
   flutter run
   ```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.