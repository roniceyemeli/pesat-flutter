# Quick Supabase Setup Commands

## Copy & Paste SQL Commands

Use these commands directly in Supabase SQL Editor for fastest setup.

---

## Step 1: Copy All Schema at Once

**RECOMMENDED**: Copy all code from `SUPABASE_SCHEMA.sql` and paste into Supabase SQL Editor, then click **Run**.

---

## Step 2: Verify Tables Created

Copy and paste this verification query:

```sql
-- Verify all tables exist
SELECT
  t.tablename as table_name,
  (
    SELECT count(*)
    FROM information_schema.columns
    WHERE table_name = t.tablename
  ) as column_count
FROM pg_tables t
WHERE t.schemaname = 'public'
ORDER BY t.tablename;
```

**Expected output:**

```
table_name        | column_count
event_attendees   | 5
events            | 14
profiles          | 6
```

---

## Step 3: Check RLS is Enabled

```sql
-- Verify RLS is enabled on all tables
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

**Expected output:**

```
schemaname | tablename       | rls_enabled
public     | event_attendees | true
public     | events          | true
public     | profiles        | true
```

---

## Step 4: Check Indexes Created

```sql
-- List all indexes
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

**Expected output** (at least these indexes):

```
tablename       | indexname
event_attendees | idx_event_attendees_event_id
event_attendees | idx_event_attendees_status
event_attendees | idx_event_attendees_user_id
events          | idx_events_category
events          | idx_events_created_at
events          | idx_events_event_date
events          | idx_events_location
events          | idx_events_user_id
profiles        | idx_profiles_created_at
profiles        | idx_profiles_full_name
```

---

## Step 5: Test Create Profile

```sql
-- Create a test profile
-- Note: Replace the UUID with a real auth user ID from your Supabase
INSERT INTO profiles (
  id,
  full_name,
  bio,
  profile_image_url
) VALUES (
  '550e8400-e29b-41d4-a716-446655440001'::uuid,
  'John Doe',
  'A passionate event organizer',
  null
)
ON CONFLICT DO NOTHING;

-- Verify it was created
SELECT * FROM profiles WHERE full_name = 'John Doe';
```

---

## Step 6: Test Create Event

```sql
-- Create a test event
INSERT INTO events (
  user_id,
  title,
  description,
  category,
  location,
  event_date,
  capacity
) VALUES (
  '550e8400-e29b-41d4-a716-446655440001'::uuid,
  'Flutter Meetup 2024',
  'Join us for an exciting Flutter discussion and networking',
  'Technology',
  'San Francisco, CA',
  now() + interval '30 days',
  100
);

-- View the created event
SELECT id, title, event_date, user_id FROM events LIMIT 1;
```

---

## Step 7: Test Create Attendance

```sql
-- Create attendance record
INSERT INTO event_attendees (
  event_id,
  user_id,
  status
) VALUES (
  (SELECT id FROM events LIMIT 1),
  '550e8400-e29b-41d4-a716-446655440001'::uuid,
  'attending'
);

-- View attendees
SELECT e.title, a.user_id, a.status FROM event_attendees a
JOIN events e ON a.event_id = e.id;
```

---

## Step 8: Test RLS Policies

```sql
-- Check all RLS policies
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Expected output**: Multiple policies for each table (SELECT, INSERT, UPDATE, DELETE)

---

## Step 9: View Table Structures

### Profiles Table Structure

```sql
\d public.profiles
```

**Expected columns:**

- id (uuid, primary key)
- full_name (text)
- bio (text, nullable)
- profile_image_url (text, nullable)
- created_at (timestamp)
- updated_at (timestamp)

### Events Table Structure

```sql
\d public.events
```

**Expected columns:**

- id (uuid, primary key)
- user_id (uuid, foreign key)
- title (text)
- description (text)
- category (text, nullable)
- location (text, nullable)
- event_date (timestamp)
- thumbnail_url (text, nullable)
- image_url (text, nullable)
- capacity (integer, nullable)
- attendees_count (integer, default 0)
- created_at (timestamp)
- updated_at (timestamp)

### Event Attendees Table Structure

```sql
\d public.event_attendees
```

**Expected columns:**

- id (uuid, primary key)
- event_id (uuid, foreign key)
- user_id (uuid, foreign key)
- status (text, default 'attending')
- joined_at (timestamp)

---

## Step 10: Check Triggers

```sql
-- View all triggers
SELECT
  trigger_schema,
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
```

**Expected output** (2 triggers):

```
trigger_name               | event_object_table | action_timing
update_events_updated_at   | events             | BEFORE
update_profiles_updated_at | profiles           | BEFORE
```

---

## Complete Data Verification Query

Copy this to see everything at once:

```sql
-- Summary of tables and row counts
SELECT
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  (SELECT count(*) FROM (EXECUTE 'SELECT 1 FROM '||schemaname||'.'||tablename) AS t) as rows
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

---

## Reset Database (If Needed)

### Option 1: Delete All Data (Keep Schema)

```sql
-- Delete all data but keep tables
TRUNCATE TABLE public.event_attendees CASCADE;
TRUNCATE TABLE public.events CASCADE;
TRUNCATE TABLE public.profiles CASCADE;
```

### Option 2: Drop All Tables (Nuclear Option)

```sql
-- WARNING: This deletes everything!
DROP TABLE IF EXISTS public.event_attendees CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

-- Then re-run SUPABASE_SCHEMA.sql to recreate
```

---

## Test with Real Auth User

After authenticating in your Flutter app:

```sql
-- Replace {AUTH_USER_ID} with actual auth.users.id from Supabase
-- You can find this in Authentication → Users

INSERT INTO profiles (id, full_name, bio)
VALUES ('{AUTH_USER_ID}'::uuid, 'Your Real Name', 'Your bio')
ON CONFLICT (id) DO UPDATE SET
  full_name = 'Your Real Name',
  bio = 'Your bio';

-- Verify
SELECT * FROM profiles WHERE id = '{AUTH_USER_ID}'::uuid;
```

---

## Useful Queries for Development

### Find Events by Date Range

```sql
SELECT id, title, event_date, attendees_count
FROM events
WHERE event_date BETWEEN now() AND (now() + interval '30 days')
ORDER BY event_date ASC;
```

### Find User's Events

```sql
SELECT id, title, event_date, attendees_count
FROM events
WHERE user_id = '{USER_ID}'::uuid
ORDER BY created_at DESC;
```

### Find Events User is Attending

```sql
SELECT e.id, e.title, e.event_date, a.status
FROM events e
JOIN event_attendees a ON e.id = a.event_id
WHERE a.user_id = '{USER_ID}'::uuid
ORDER BY e.event_date DESC;
```

### Get Attendee Count for Event

```sql
SELECT COUNT(*) as attendee_count
FROM event_attendees
WHERE event_id = '{EVENT_ID}'::uuid AND status = 'attending';
```

### Get User Profile with Event Count

```sql
SELECT
  p.id,
  p.full_name,
  p.bio,
  COUNT(e.id) as event_count
FROM profiles p
LEFT JOIN events e ON p.id = e.user_id
GROUP BY p.id, p.full_name, p.bio;
```

---

## Performance Monitoring

### Check Slow Queries

```sql
-- View table sizes (largest first)
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Check Index Usage

```sql
-- See which indexes are being used
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as scan_count
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

---

## Common Issues & Solutions

### "Duplicate Key Error"

When inserting test data with same UUID:

```sql
-- Fix: Use INSERT ... ON CONFLICT DO NOTHING
INSERT INTO profiles (id, full_name, bio)
VALUES ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'Test', 'Bio')
ON CONFLICT (id) DO NOTHING;
```

### "Foreign Key Constraint Failed"

When inserting event without valid user_id:

```sql
-- Fix: First ensure user exists in profiles
SELECT EXISTS (SELECT 1 FROM profiles WHERE id = '{USER_ID}'::uuid);

-- If not, insert profile first
INSERT INTO profiles (id, full_name, bio)
VALUES ('{USER_ID}'::uuid, 'User Name', NULL);
```

### "RLS Policy Violated"

When querying as non-authenticated user:

```sql
-- This happens in the app when user is not logged in
-- Solution: Ensure user is authenticated before querying
-- In Flutter: Check currentUserProvider before making queries
```

---

## Quick Copy-Paste Summary

1. Copy all from `SUPABASE_SCHEMA.sql` → Paste in SQL Editor → Click Run ✅
2. Run verification query above ✅
3. Test with sample data ✅
4. Create storage buckets (separate steps) ✅
5. Update Flutter app credentials ✅

---

Last Updated: 2024
For: Flutter Event Management App
