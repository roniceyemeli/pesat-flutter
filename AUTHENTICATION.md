# Event App Authentication System

## Overview

The Event App now has a complete authentication system that requires users to register and log in before accessing event pages and profile management.

## Features

### Authentication Flow

1. **Registration (Sign Up)**

   - Users create an account with email, password, and full name
   - Password strength validation (8+ chars, uppercase, numbers)
   - Passwords must match confirmation
   - Account created in Supabase Auth with user profile in database

2. **Login (Sign In)**

   - Email and password-based authentication
   - Automatic session management
   - Persistent login across app sessions

3. **Access Control**

   - Protected routes require authentication
   - Unauthenticated users redirected to login
   - Authenticated users redirected away from login/signup pages

4. **Logout (Sign Out)**
   - Available from Profile page
   - Confirmation dialog for safety
   - Session cleared and user redirected to login

## Protected Pages

After authentication, users can access:

- **Home** (`/home`) - Landing page with quick actions
- **Events** (`/events`) - Browse and discover events
- **Profile** (`/profile`) - Manage user profile and sign out

## Public Pages (Before Authentication)

- **Login** (`/login`) - Sign in with existing account
- **Signup** (`/signup`) - Create new account

## User Interface

### Login Screen

- Email input with validation
- Password input with toggle visibility
- Error messages for failed authentication
- Link to signup for new users
- Loading indicator during authentication

### Signup Screen

- Full name input
- Email input with validation
- Password input with requirements
- Confirm password field
- All inputs validated before submission
- Link to login for existing users

### Profile Screen

- User avatar with initials
- Display full name and bio
- Profile information cards
- Sign out button with confirmation dialog

### Home Screen

- Personalized greeting with user's first name
- Quick action cards for common tasks
- Navigation tips for new users
- Gradient header design

## Authentication Implementation

### Key Files

**Auth Service** (`lib/data/services/auth_service.dart`)

- `signUp()` - Register new user
- `signIn()` - Login existing user
- `signOut()` - Logout user
- `getCurrentUserProfile()` - Fetch user data
- `isAuthenticated()` - Check auth status

**Auth Providers** (`lib/data/providers/auth_provider.dart`)

- `signUpProvider` - Sign up FutureProvider
- `signInProvider` - Sign in FutureProvider
- `signOutProvider` - Sign out FutureProvider
- `currentUserProfileProvider` - Get current user profile

**Auth State Provider** (`lib/data/providers/auth_state_provider.dart`)

- `authStateStreamProvider` - Listen to auth state changes
- `isAuthenticatedProvider` - Check if user authenticated

**Router Configuration** (`lib/main.dart`)

- Redirect logic based on auth state
- Protected route guards
- Automatic navigation based on authentication

## Routing Logic

```
On App Start:
├── Check Authentication Status
│   ├── If Authenticated → Show Home (with navbar)
│   └── If Not Authenticated → Show Login
│
When User at /login or /signup:
├── If Authenticated → Redirect to /home
└── If Not Authenticated → Show page
│
When User at /home, /events, /profile:
├── If Authenticated → Show page with navbar
└── If Not Authenticated → Redirect to /login
```

## Form Validation

### Email Validation

- Required field
- Must contain @ and .
- Valid email format

### Password Validation (Sign Up)

- Minimum 8 characters
- At least one uppercase letter
- At least one number
- Confirmation password must match

### Full Name Validation

- Required field
- Minimum 2 characters
- Only letters and spaces allowed

## Database Schema (Supabase)

### auth.users (Supabase Auth)

- id (UUID) - Primary key
- email - User email
- encrypted_password - Hashed password

### profiles (Custom Table)

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

## Security Features

✅ **Password Hashing** - Supabase handles secure password hashing
✅ **Password Requirements** - Strong password validation
✅ **Session Management** - Automatic token refresh
✅ **HTTPS** - All Supabase communication encrypted
✅ **Protected Routes** - Authentication checks on navigation
✅ **Logout Confirmation** - Prevents accidental logouts

## Error Handling

- Invalid email format error message
- Weak password requirements shown
- Signup failure alerts (e.g., email already exists)
- Login failure alerts (invalid credentials)
- Network error handling
- Graceful error recovery

## Testing the Authentication

### Sign Up Flow

1. Open app → Redirected to login
2. Click "Sign Up" link
3. Enter details:
   - Full Name: John Doe
   - Email: john@example.com
   - Password: StrongPass123
   - Confirm: StrongPass123
4. Click "Create Account"
5. Success message shown
6. Automatically redirected to login

### Login Flow

1. Enter email and password from signup
2. Click "Sign In"
3. Loading indicator appears
4. Redirected to Home screen
5. Navbar appears with Home, Events, Profile tabs

### Logout Flow

1. Navigate to Profile tab
2. Scroll down and click "Sign Out"
3. Confirm in dialog
4. Redirected to login page
5. Session cleared

### Route Protection Test

1. While logged in, try typing `/login` in URL → Redirects to home
2. Logout
3. Try typing `/events` in URL → Redirects to login
4. Login successfully → Redirected to home

## API Integration

All authentication uses Supabase PostgreSQL Auth:

- Base URL: `https://nzwibivhkhszicoacscu.supabase.co`
- API endpoints for sign up, sign in, sign out
- User profiles stored in custom `profiles` table
- Real-time auth state with Supabase streams

## Future Enhancements

Potential improvements:

1. Two-factor authentication (2FA)
2. Social login (Google, GitHub)
3. Password reset functionality
4. Email verification
5. Remember me option
6. Biometric authentication
7. Session timeout handling
8. Account deletion
9. Profile picture upload
10. Update password functionality
