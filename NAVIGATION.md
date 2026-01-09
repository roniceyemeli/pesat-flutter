# Event App Navigation System

## Overview

The Event App now features a complete bottom navigation system with a glassmorphic navbar that facilitates seamless navigation between the main pages.

## Navigation Structure

### Pages

1. **Home** (`/home`) - Landing page with welcome message
2. **Events** (`/events`) - Event feed to browse and discover events
3. **Profile** (`/profile`) - User profile management

### Navigation Bar Features

- **Glassmorphic Design**: Modern, frosted glass effect with blur background
- **Active State Indication**: Visual feedback showing the currently active page
- **Icon + Label**: Each navigation item has an icon and label
- **Persistent**: The navbar remains visible across all main pages
- **Responsive**: Adapts to different screen sizes

## Technical Implementation

### Components

#### ShellScreen (`lib/presentation/screens/shell_screen.dart`)

- Wrapper component that manages navigation state
- Tracks the current selected tab
- Coordinates navigation via GoRouter
- Provides the GlassmorphicNavBar to all child routes

#### GlassmorphicNavBar (`lib/presentation/widgets/common/glassmorphic_nav_bar.dart`)

- Reusable bottom navigation bar with glassmorphic styling
- Customizable items via `NavigationItem` class
- Smooth transitions between tabs
- Color-coded active/inactive states

#### GoRouter Configuration (`lib/main.dart`)

- Uses `ShellRoute` for nested routing
- Main routes wrapped within shell for persistent navbar
- Supports future nested navigation

### Routing Architecture

```
App
├── ShellRoute (with navbar)
│   ├── /home → HomeScreen
│   ├── /events → EventFeedScreen
│   └── /profile → ProfileScreen
├── /login → LoginScreen (no navbar)
└── /signup → SignupScreen (no navbar)
```

## Usage

### Navigation Examples

**From any screen with navbar:**

```dart
context.go('/home');      // Navigate to home
context.go('/events');    // Navigate to events
context.go('/profile');   // Navigate to profile
```

**From login/signup screens:**

```dart
context.go('/home');      // Enter app (shows navbar)
```

## Styling

### Colors

- **Primary Color**: `#6366F1` (Indigo)
- **Active State**: Indigo with 20% opacity background
- **Inactive State**: Grey (shade 600)
- **Border**: Indigo with 50% opacity when active

### Theme Integration

- Uses Material3 design system
- Transparent app bars for clean look
- Consistent with AppTheme configuration

## Future Enhancements

Potential improvements to the navigation system:

1. Add animation transitions between pages
2. Implement page caching to preserve scroll position
3. Add badges for notifications
4. Create sub-routes for event details
5. Implement back button handling
6. Add navigation history tracking

## File Structure

```
lib/
├── main.dart                          # GoRouter setup with ShellRoute
├── presentation/
│   ├── screens/
│   │   ├── shell_screen.dart          # Navigation wrapper
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── events/
│   │   │   ├── event_feed_screen.dart
│   │   │   ├── create_event_screen.dart
│   │   │   └── event_details_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── auth/
│   │       ├── login_screen.dart
│   │       └── signup_screen.dart
│   └── widgets/
│       └── common/
│           └── glassmorphic_nav_bar.dart
```

## Testing Navigation

To test the navbar:

1. Run the app: `flutter run`
2. You'll start at the Home page with the navbar visible
3. Tap each navbar item to navigate:
   - Home icon → Home page
   - Event icon → Events page
   - Person icon → Profile page
4. The active icon highlights in indigo
5. Navigate to login/signup screens to see navbar hidden
