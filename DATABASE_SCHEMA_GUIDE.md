# Supabase Database Schema Setup Guide

## Overview

This guide explains how to properly set up your Supabase database schema for the Flutter Event Management App.

## Database Structure

### Tables

#### 1. **profiles** (User Profiles)

- Linked to Supabase auth.users via `id` (foreign key)
- Stores user profile information
- Auto-timestamps with triggers

| Column            | Type      | Nullable | Purpose                        |
| ----------------- | --------- | -------- | ------------------------------ |
| id                | UUID      | No       | References auth.users(id) - PK |
| full_name         | TEXT      | No       | User's full name               |
| bio               | TEXT      | Yes      | User biography                 |
| profile_image_url | TEXT      | Yes      | URL to profile image           |
| created_at        | TIMESTAMP | No       | Record creation time           |
| updated_at        | TIMESTAMP | No       | Last update time               |

**Indexes:**

- `idx_profiles_created_at` - For sorting by creation date
- `idx_profiles_full_name` - For searching by name

---

#### 2. **events** (User Events)

- Main event table
- Foreign key to profiles.id (the event creator)
- Tracks event metadata and attendance

| Column          | Type      | Nullable | Purpose                               |
| --------------- | --------- | -------- | ------------------------------------- |
| id              | UUID      | No       | Event ID - PK                         |
| user_id         | UUID      | No       | Event creator (FK to profiles)        |
| title           | TEXT      | No       | Event title                           |
| description     | TEXT      | No       | Event description                     |
| category        | TEXT      | Yes      | Event category (Tech, Business, etc.) |
| location        | TEXT      | Yes      | Event location                        |
| event_date      | TIMESTAMP | No       | When the event occurs                 |
| thumbnail_url   | TEXT      | Yes      | Thumbnail image URL                   |
| image_url       | TEXT      | Yes      | Full event image URL                  |
| capacity        | INTEGER   | Yes      | Max attendees                         |
| attendees_count | INTEGER   | No       | Current attendee count                |
| created_at      | TIMESTAMP | No       | Record creation time                  |
| updated_at      | TIMESTAMP | No       | Last update time                      |

**Indexes:**

- `idx_events_user_id` - To find events by creator
- `idx_events_event_date` - To sort by date
- `idx_events_category` - To filter by category
- `idx_events_location` - To filter by location
- `idx_events_created_at` - To sort by creation date

---

#### 3. **event_attendees** (Attendance Tracking)

- Junction table linking users to events
- Tracks attendance status
- Ensures unique user-event combinations

| Column    | Type      | Nullable | Purpose                               |
| --------- | --------- | -------- | ------------------------------------- |
| id        | UUID      | No       | Record ID - PK                        |
| event_id  | UUID      | No       | Event reference (FK to events)        |
| user_id   | UUID      | No       | User reference (FK to profiles)       |
| status    | TEXT      | No       | 'attending', 'interested', 'declined' |
| joined_at | TIMESTAMP | No       | When user joined                      |

**Indexes:**

- `idx_event_attendees_event_id` - To find attendees for an event
- `idx_event_attendees_user_id` - To find events user attends
- `idx_event_attendees_status` - To filter by status

**Constraint:**

- UNIQUE(event_id, user_id) - Prevents duplicate attendance records

---

## Row-Level Security (RLS)

All tables have Row-Level Security enabled to protect user data.

### profiles RLS Policies

1. **SELECT**: Profiles are viewable by everyone (public profile discovery)
2. **UPDATE**: Users can only update their own profile
3. **INSERT**: Users can only insert their own profile
4. **DELETE**: Automatically handled via cascade delete from auth.users

### events RLS Policies

1. **SELECT**: All events are viewable by everyone (public event feed)
2. **INSERT**: Users can create events (sets user_id = current user)
3. **UPDATE**: Users can only update their own events
4. **DELETE**: Users can only delete their own events

### event_attendees RLS Policies

1. **SELECT**: Attendee lists are viewable by everyone
2. **INSERT**: Users can register for events (sets user_id = current user)
3. **UPDATE**: Users can only update their own attendance records
4. **DELETE**: Users can only remove their own attendance

---

## Automatic Triggers

### update_updated_at_column()

A trigger function that automatically updates the `updated_at` timestamp whenever a record is modified.

**Applied to:**

- profiles table (trigger: `update_profiles_updated_at`)
- events table (trigger: `update_events_updated_at`)

---

## Setup Instructions

### Step 1: Access Supabase SQL Editor

1. Go to [https://supabase.com](https://supabase.com)
2. Log in to your project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Apply the Schema

1. Open the `SUPABASE_SCHEMA.sql` file
2. Copy all the SQL code
3. Paste it into the Supabase SQL Editor
4. Click **Run** button

The schema will:

- ✅ Create all tables
- ✅ Set up relationships and constraints
- ✅ Create performance indexes
- ✅ Enable Row-Level Security
- ✅ Create automatic update triggers

### Step 3: Verify Setup

Run these verification queries in Supabase SQL Editor:

```sql
-- Check if tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Check profiles table structure
\d public.profiles

-- Check events table structure
\d public.events

-- Check RLS is enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Check indexes
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public';
```

---

## Data Flow

### User Registration & Profile Creation

1. User signs up via `AuthService.signUp(email, password, fullName)`
2. Supabase automatically creates auth.users entry
3. App calls `AuthService.updateUserProfile()` to create profiles entry
4. New UUID in profiles links to auth.users.id

### Event Creation

1. User creates event via `EventService.createEvent(eventData)`
2. App automatically sets `user_id = auth.uid()` (current user)
3. Event is stored with all metadata
4. `attendees_count` defaults to 0

### Event Attendance

1. User clicks "Attend" on event
2. App inserts into event_attendees with user_id and event_id
3. `status` can be: 'attending', 'interested', or 'declined'
4. UNIQUE constraint prevents duplicate registrations
5. App can query attendee count from event_attendees

---

## Important Notes

### Security

- All user data is protected by RLS policies
- Users cannot see or modify other users' data
- Column-level security not implemented (can be added if needed)

### Performance

- All foreign key columns are indexed
- Event date and creation date indexed for sorting
- Category and location indexed for filtering
- Status indexed for filtering attendance

### Constraints

- **Cascade Delete**: Deleting a user deletes all their profiles, events, and attendance records
- **Unique Attendees**: Each user can only have one attendance record per event
- **Required Fields**: title, description, event_date, full_name are required

---

## Reset Database (If Needed)

To completely reset the database:

```sql
-- Disable constraints temporarily
ALTER TABLE IF EXISTS public.event_attendees DISABLE TRIGGER ALL;
ALTER TABLE IF EXISTS public.events DISABLE TRIGGER ALL;
ALTER TABLE IF EXISTS public.profiles DISABLE TRIGGER ALL;

-- Delete all data
TRUNCATE TABLE public.event_attendees CASCADE;
TRUNCATE TABLE public.events CASCADE;
TRUNCATE TABLE public.profiles CASCADE;

-- Re-enable constraints
ALTER TABLE IF EXISTS public.event_attendees ENABLE TRIGGER ALL;
ALTER TABLE IF EXISTS public.events ENABLE TRIGGER ALL;
ALTER TABLE IF EXISTS public.profiles ENABLE TRIGGER ALL;
```

Or to drop and recreate everything (nuclear option):

```sql
-- Drop all tables (will remove all data)
DROP TABLE IF EXISTS public.event_attendees;
DROP TABLE IF EXISTS public.events;
DROP TABLE IF EXISTS public.profiles;
DROP FUNCTION IF EXISTS public.update_updated_at_column();

-- Then re-run the SUPABASE_SCHEMA.sql file
```

---

## Testing the Schema

### 1. Test Profile Creation

```sql
-- Test viewing a profile (assuming user with id exists)
SELECT * FROM profiles LIMIT 1;
```

### 2. Test Event Creation

```sql
-- View all events
SELECT id, title, user_id, event_date, attendees_count
FROM events
ORDER BY event_date DESC;
```

### 3. Test Attendance Tracking

```sql
-- View attendees for an event
SELECT e.title, a.user_id, a.status, a.joined_at
FROM event_attendees a
JOIN events e ON a.event_id = e.id
ORDER BY a.joined_at DESC;
```

---

## Troubleshooting

### Tables Not Created?

- Check for SQL errors in the editor output
- Make sure you're in the correct database
- Verify Supabase project is active

### RLS Blocking Queries?

- RLS policies are enabled by default
- Verify auth.uid() is working properly
- Check policy definitions in Table Editor

### Slow Queries?

- Verify indexes are created: `SELECT * FROM pg_indexes WHERE schemaname = 'public';`
- Check query execution plans
- Consider adding more indexes for frequently filtered columns

### Foreign Key Errors?

- Ensure profiles table exists before inserting into events
- When deleting events, event_attendees cascade deletes automatically
- Check data types match exactly (all IDs should be UUID)

---

## Next Steps

1. ✅ Run SUPABASE_SCHEMA.sql in SQL Editor
2. ✅ Verify tables are created
3. ✅ Test RLS policies with sample data
4. ✅ Configure storage buckets for event images (see STORAGE_SETUP.md)
5. ✅ Run app to test database integration

---

Generated: 2024
For: Flutter Event Management App
