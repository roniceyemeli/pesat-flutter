# Quick Start Guide - Flutter Event App

## ✅ Installation Complete!

All files have been added to your workspace. Here's what to do next:

## Step 1: Install Dependencies

```bash
cd /home/momonoskay/Documents/pesat-flutter/flutter-event-app
flutter pub get
```

## Step 2: Configure Supabase

### 2.1 Create a Supabase Account

1. Visit [https://supabase.com](https://supabase.com)
2. Create a new project
3. Note your **Project URL** and **Anon Key**

### 2.2 Update Configuration

Edit `lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // ← Replace this
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // ← Replace this
);
```

## Step 3: Setup Database Schema

1. Go to Supabase Console → SQL Editor
2. Copy and run the SQL from `BLUEPRINT.md` section "Database Setup"
3. Enable Row Level Security (RLS) following the guide

## Step 4: Create Storage Bucket

1. Supabase Console → Storage
2. Create bucket named `event-images`
3. Set to Public
4. Enable all CRUD operations

## Step 5: Run the App

```bash
flutter run
```

---

## 📁 What's Included

### Data Layer

- ✅ Models: UserProfile, Event, AppException
- ✅ Services: Auth, Events, Storage, ImagePicker
- ✅ Providers: Riverpod state management

### UI Layer

- ✅ Screens: Auth, Home, Events, Profile
- ✅ Widgets: Event cards with Hero animations
- ✅ Glassmorphic bottom navigation
- ✅ Form validation with custom validators

### Utilities

- ✅ Input validators (email, password, names, events)
- ✅ Date/String extensions
- ✅ App constants and configurations
- ✅ Material 3 theme setup

---

## 🔑 Key Features to Implement

1. **Authentication Flow**

   - [ ] Implement login/signup screens
   - [ ] Wire providers to UI
   - [ ] Add session management

2. **Event Management**

   - [ ] List events in feed
   - [ ] Create new events
   - [ ] Add event details page
   - [ ] Implement join/leave functionality

3. **User Profile**

   - [ ] Display user info
   - [ ] Edit profile form
   - [ ] Upload profile picture

4. **Image Upload**

   - [ ] Implement image picker UI
   - [ ] Upload to Supabase Storage
   - [ ] Save URL to database

5. **Navigation**
   - [ ] Setup router with go_router
   - [ ] Connect screens
   - [ ] Implement deep linking

---

## 📚 File Map

| Feature   | Files                                |
| --------- | ------------------------------------ |
| Models    | `lib/data/models/*.dart`             |
| Services  | `lib/data/services/*.dart`           |
| Providers | `lib/data/providers/*.dart`          |
| Screens   | `lib/presentation/screens/**/*.dart` |
| Widgets   | `lib/presentation/widgets/**/*.dart` |
| Utilities | `lib/utils/*.dart`                   |
| Theme     | `lib/config/theme/*.dart`            |

---

## 🚀 Next Steps

1. **Read BLUEPRINT.md** for complete architecture details
2. **Implement screens** using the provided widgets
3. **Connect providers** to screens with ConsumerWidget
4. **Test with Supabase** using public test account
5. **Add error handling** and loading states

---

## 💡 Code Examples

### Using Riverpod Provider

```dart
final profile = ref.watch(currentUserProfileProvider);
profile.whenData((user) => Text(user.fullName));
```

### Creating Event

```dart
ref.read(createEventProvider(eventData)).whenData((_) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Event created!')),
  );
});
```

### Image Upload

```dart
final imageFile = await ref.read(imagePickerServiceProvider).pickImage();
final url = await ref.read(uploadEventImageProvider(imageFile));
```

---

## ⚠️ Important Notes

- ✅ All Supabase URLs must include schema with `https://`
- ✅ Enable Row Level Security (RLS) before using the app
- ✅ Test storage bucket is public but RLS protects database
- ✅ Image quality is optimized to 80% for performance
- ✅ All forms have built-in validation

---

## 📞 Support

Refer to:

- **Architecture**: See `BLUEPRINT.md`
- **Supabase**: [https://supabase.com/docs](https://supabase.com/docs)
- **Flutter**: [https://flutter.dev/docs](https://flutter.dev/docs)
- **Riverpod**: [https://riverpod.dev](https://riverpod.dev)

Happy coding! 🎉
