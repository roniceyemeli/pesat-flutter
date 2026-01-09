# Supabase Configuration Quick Start

## Complete Setup Checklist

This checklist ensures your Supabase backend is properly configured for the Flutter Event Management App.

---

## ✅ Phase 1: Database Schema (URGENT)

- [ ] **1a. Access Supabase Dashboard**

  - Go to https://supabase.com
  - Log in to your project
  - Click **SQL Editor** in sidebar

- [ ] **1b. Run Database Schema Script**

  - Open file: `SUPABASE_SCHEMA.sql`
  - Copy all SQL code
  - Paste into SQL Editor
  - Click **Run** button
  - Wait for "Success" message

- [ ] **1c. Verify Database Created**
  - Click **Table Editor** in sidebar
  - Verify these tables exist:
    - `profiles` (with 6 columns)
    - `events` (with 14 columns)
    - `event_attendees` (with 4 columns)

**Expected Result**: All tables created with proper relationships and indexes ✅

---

## ✅ Phase 2: Storage Buckets

- [ ] **2a. Create event-images Bucket**

  - Click **Storage** in sidebar
  - Click **Create a new bucket**
  - Name: `event-images`
  - Visibility: **Public**
  - Click **Create bucket**

- [ ] **2b. Create profile-images Bucket**

  - Click **Create a new bucket**
  - Name: `profile-images`
  - Visibility: **Public**
  - Click **Create bucket**

- [ ] **2c. Configure RLS Policies**
  - For each bucket:
    - Click bucket name
    - Click **Policies** tab
    - Click **New Policy**
    - Select **Policy Templates** → **For public buckets**
    - Click **Review** → **Save policy**

**Expected Result**: Two public buckets with read/write policies ✅

---

## ✅ Phase 3: Authentication Verification

- [ ] **3a. Check Authentication Settings**

  - Click **Authentication** in sidebar
  - Click **Providers** tab
  - Verify **Email** is enabled (should be default)

- [ ] **3b. Configure Email (Optional)**

  - Click **Email** provider
  - Use default Supabase email or configure SMTP
  - Note: Default works for development

- [ ] **3c. Check CORS Settings (If Needed)**
  - Click **Settings** → **API**
  - Verify your app domain is allowed
  - For Flutter apps: usually auto-configured

**Expected Result**: Email authentication ready ✅

---

## ✅ Phase 4: Environment Variables

- [ ] **4a. Get Supabase Credentials**
  - Click **Settings** → **API**
  - Copy **Project URL**
  - Copy **anon public** API key
- [ ] **4b. Update Flutter App**
  - Open `lib/main.dart`
  - Find Supabase initialization section
  - Replace placeholders with your credentials:
    ```dart
    await Supabase.initialize(
      url: 'YOUR_PROJECT_URL',
      anonKey: 'YOUR_ANON_KEY',
    );
    ```

**Expected Result**: App can connect to your Supabase project ✅

---

## ✅ Phase 5: Security Configuration

- [ ] **5a. Verify Row-Level Security (RLS)**

  - Click **Table Editor**
  - For each table (profiles, events, event_attendees):
    - Click table name
    - Click **RLS** button
    - Verify it shows "RLS is ON" (if not, click to enable)

- [ ] **5b. Review RLS Policies**
  - For each table, click **Policies** tab
  - Verify policies are present:
    - `profiles`: 3 policies (SELECT, UPDATE, INSERT)
    - `events`: 4 policies (SELECT, INSERT, UPDATE, DELETE)
    - `event_attendees`: 4 policies (SELECT, INSERT, UPDATE, DELETE)

**Expected Result**: All tables protected with RLS policies ✅

---

## ✅ Phase 6: Testing (In Supabase Dashboard)

### Test 1: Insert Data

```sql
-- Test inserting a profile (use a test UUID)
INSERT INTO profiles (id, full_name, bio)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'Test User', 'Test bio');

-- Verify it was inserted
SELECT * FROM profiles WHERE full_name = 'Test User';
```

### Test 2: Query Events

```sql
-- View all events
SELECT id, title, user_id, event_date, attendees_count FROM events;

-- Should return empty initially
```

### Test 3: Check Indexes

```sql
-- Verify all indexes exist
SELECT indexname, tablename FROM pg_indexes WHERE schemaname = 'public';
```

**Expected Result**: All queries execute successfully ✅

---

## ✅ Phase 7: Prepare for Flutter Testing

- [ ] **7a. Clean Flutter Build**

  ```bash
  flutter clean
  flutter pub get
  ```

- [ ] **7b. Test Authentication Flow**

  - Run app in emulator/device
  - Click **Sign Up**
  - Enter test credentials
  - Should create auth user and profile
  - Should redirect to Home screen

- [ ] **7c. Test Database Operations**

  - Click **Create Event** (if available)
  - Fill form and submit
  - Check Supabase Table Editor
  - New event should appear in `events` table

- [ ] **7d. Test Image Upload (Optional)**
  - Upload profile or event image
  - Check Supabase Storage
  - Image should appear in bucket

**Expected Result**: Full app flow working with Supabase ✅

---

## ⚠️ Important Notes

### User Creation Flow

1. User signs up via app → Supabase auth.users table updated
2. App automatically creates record in `profiles` table
3. This linking is done via the AuthService.updateUserProfile() method
4. The `profiles.id` is a FK to `auth.users.id`

### Event Creation Flow

1. User creates event in app
2. EventService.createEvent() is called
3. `user_id` is automatically set to `auth.uid()` (current user)
4. Event is stored in `events` table
5. `attendees_count` defaults to 0

### Attendance Tracking

1. User clicks "Attend" on an event
2. Record inserted into `event_attendees` table
3. Status defaults to 'attending'
4. UNIQUE constraint prevents double registration

---

## 📝 Configuration Summary

| Component           | Status     | Details                 |
| ------------------- | ---------- | ----------------------- |
| **Database Tables** | ⏳ Pending | Run SUPABASE_SCHEMA.sql |
| **Profiles Table**  | ⏳ Pending | Links to auth.users     |
| **Events Table**    | ⏳ Pending | Main event storage      |
| **Attendees Table** | ⏳ Pending | Attendance tracking     |
| **RLS Policies**    | ⏳ Pending | Security policies       |
| **Storage Buckets** | ⏳ Pending | Image storage           |
| **Auth Provider**   | ✅ Ready   | Email auth enabled      |
| **Flutter Config**  | ⏳ Pending | Update credentials      |

---

## 🔍 Verification Checklist (At Each Phase)

After each phase, run these SQL queries to verify:

```sql
-- Phase 1 Verification
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name IN ('profiles', 'events', 'event_attendees');

-- Phase 2 Verification
SELECT name FROM storage.buckets WHERE name IN ('event-images', 'profile-images');

-- Phase 5 Verification
SELECT schemaname, tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' AND tablename IN ('profiles', 'events', 'event_attendees');

-- Phase 6 Verification
SELECT * FROM profiles LIMIT 1;
SELECT * FROM events LIMIT 1;
```

---

## 🆘 Troubleshooting

### "Table Already Exists" Error

- Tables might already exist from previous setup
- Replace the SCHEMA_SQL to check if tables are working
- Or drop and recreate: `DROP TABLE IF EXISTS event_attendees, events, profiles;`

### "Permission Denied" Error

- RLS policies might be too restrictive
- Verify auth.uid() is available
- Check if policies need adjustment for your use case

### "Foreign Key Constraint Failed"

- User must exist in auth.users before adding to profiles
- Check that user_id exists in profiles before creating events
- Ensure data types match (all should be UUID)

### Images Not Uploading

- Check bucket visibility is "Public"
- Verify RLS policies are set to "For public buckets"
- Check file size (max 5MB)
- Verify MIME type is correct (JPEG/PNG)

---

## 📚 Additional Resources

- **Supabase Docs**: https://supabase.com/docs
- **Flutter Supabase**: https://supabase.com/docs/guides/auth/native-mobile-app
- **Database Schema**: See `DATABASE_SCHEMA_GUIDE.md`
- **Storage Setup**: See `STORAGE_SETUP.md`
- **SQL Script**: See `SUPABASE_SCHEMA.sql`

---

## 📋 Next Steps

1. **Immediate (URGENT)**:

   - [ ] Run `SUPABASE_SCHEMA.sql` in SQL Editor
   - [ ] Verify all 3 tables are created
   - [ ] Check RLS policies are enabled

2. **Short-term**:

   - [ ] Create storage buckets
   - [ ] Update Flutter app with Supabase credentials
   - [ ] Test signup/login flow

3. **Medium-term**:

   - [ ] Create and upload events
   - [ ] Test attendance tracking
   - [ ] Implement image uploads

4. **Long-term**:
   - [ ] Performance optimization
   - [ ] Add search/filtering
   - [ ] Implement notifications
   - [ ] Production deployment

---

**Setup Status**: Ready to begin Phase 1 ✅

**Estimated Time**:

- Phase 1: 5 minutes
- Phase 2: 5 minutes
- Phase 3: 2 minutes
- Phase 4: 5 minutes
- Phase 5: 3 minutes
- Phase 6: 10 minutes
- **Total: ~30 minutes for complete setup**

---

Last Updated: 2024
For: Flutter Event Management App - Supabase Backend
