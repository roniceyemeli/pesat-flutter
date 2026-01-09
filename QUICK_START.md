# Quick Start Guide - Event App Authentication

## 🚀 Getting Started

### Before Running the App

Ensure your Supabase project has:

1. **Auth enabled** - Email/Password provider
2. **Database schema** created:

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  bio TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
```

## 📱 App Flow

### First Time User

```
App Launch
    ↓
Check Authentication
    ↓
Not Logged In → Login Screen
    ↓
Click "Sign Up"
    ↓
Enter Details (Name, Email, Password)
    ↓
Create Account
    ↓
Success → Redirected to Login
    ↓
Enter Email & Password
    ↓
Sign In
    ↓
Home Screen (with navbar visible)
```

### Returning User

```
App Launch
    ↓
Check Authentication
    ↓
Still Logged In
    ↓
Home Screen (with navbar visible)
```

## 🔑 Key Features

| Feature  | Location     | Details                                  |
| -------- | ------------ | ---------------------------------------- |
| Sign Up  | `/signup`    | Create new account with email & password |
| Sign In  | `/login`     | Login with existing credentials          |
| Home     | `/home`      | Dashboard with quick actions             |
| Events   | `/events`    | Browse available events                  |
| Profile  | `/profile`   | View profile info & sign out             |
| Sign Out | Profile page | Logout from account                      |

## ✅ Validation Rules

### Email

- Required ✓
- Valid format (user@domain.com) ✓

### Password (Sign Up)

- Minimum 8 characters ✓
- At least one uppercase letter ✓
- At least one number ✓

### Full Name

- Required ✓
- Minimum 2 characters ✓
- Only letters and spaces ✓

## 🔐 Security

- Passwords are hashed by Supabase
- Session tokens auto-managed
- Protected routes enforce authentication
- Logout clears all session data

## 📍 Navigation

### After Login

Use the navbar at the bottom:

- 🏠 **Home** - Main dashboard
- 📅 **Events** - Event listings
- 👤 **Profile** - User profile & settings

### Before Login

Navigation between:

- Login screen
- Sign up screen

## 🐛 Troubleshooting

### "Email already exists"

→ That email is already registered. Use Sign In instead.

### "Invalid password"

→ Password doesn't meet requirements:

- Min 8 characters
- 1 uppercase letter
- 1 number

### "Passwords don't match"

→ Confirm password doesn't match. Re-enter both.

### "Can't access protected pages"

→ You need to log in first. Return to login screen.

## 🔄 Default Test Credentials

To test the app, create an account:

1. Go to Sign Up
2. Enter test details
3. Complete registration
4. Log in with the same credentials

## 📝 File Structure

```
lib/
├── data/
│   ├── providers/
│   │   ├── auth_provider.dart         # Auth providers
│   │   └── auth_state_provider.dart   # Auth state management
│   ├── services/
│   │   └── auth_service.dart          # Supabase auth service
│   └── models/
│       └── user_profile.dart          # User profile model
│
├── presentation/
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart      # Login UI
│       │   └── signup_screen.dart     # Sign up UI
│       ├── home/
│       │   └── home_screen.dart       # Home dashboard
│       ├── events/
│       │   └── event_feed_screen.dart # Events listing
│       └── profile/
│           └── profile_screen.dart    # User profile
│
└── main.dart                          # App entry & routing
```

## 🎯 Next Steps

After login, you can:

1. **Explore Events** - Browse available events
2. **Update Profile** - Add profile picture and bio
3. **Create Events** - Host your own events
4. **Manage Attendance** - Track which events you're attending

## 💡 Tips

- Keep your password secure
- Use a valid email for recovery options
- Your profile appears on your hosted events
- Check the Events page regularly for new listings

## 📞 Support

If you encounter issues:

1. Check Supabase project configuration
2. Verify database schema matches
3. Ensure API credentials are correct
4. Check network connectivity
5. Review validation error messages

---

**Happy event managing! 🎉**
