# Database Schema Visual Reference

## Complete Data Model Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUPABASE AUTHENTICATION                      │
│                      (auth.users table)                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ (id)
                           ↓
        ┌──────────────────────────────────┐
        │        PUBLIC.PROFILES           │
        ├──────────────────────────────────┤
        │ PK: id (UUID) ────────────────┐  │
        │    full_name (TEXT, Required) │  │
        │    bio (TEXT, Optional)       │  │
        │    profile_image_url (URL)    │  │
        │    created_at (TIMESTAMP)     │  │
        │    updated_at (TIMESTAMP)     │  │
        └──────────────────────────────────┘
                           │
                   (user_id / FK)
                           │
                           ↓
        ┌──────────────────────────────────┐
        │        PUBLIC.EVENTS            │
        ├──────────────────────────────────┤
        │ PK: id (UUID)                    │
        │ FK: user_id (UUID) ──────────┐   │
        │    title (TEXT, Required)    │   │
        │    description (TEXT, Req)   │   │
        │    category (TEXT)           │   │
        │    location (TEXT)           │   │
        │    event_date (TIMESTAMP)    │   │
        │    thumbnail_url (URL)       │   │
        │    image_url (URL)           │   │
        │    capacity (INTEGER)        │   │
        │    attendees_count (INT)     │   │
        │    created_at (TIMESTAMP)    │   │
        │    updated_at (TIMESTAMP)    │   │
        └──────────────────────────────────┘
                    │
         (event_id) │ (user_id)
                    ↓ ↑
        ┌──────────────────────────────────┐
        │     PUBLIC.EVENT_ATTENDEES      │
        ├──────────────────────────────────┤
        │ PK: id (UUID)                    │
        │ FK: event_id (UUID) ──────────┐  │
        │ FK: user_id (UUID) ───────────┼─→ (links back to profiles)
        │    status (TEXT)               │  │
        │    joined_at (TIMESTAMP)       │  │
        │                                │  │
        │ UNIQUE: (event_id, user_id)    │  │
        └──────────────────────────────────┘
```

---

## Table Schema Details

### PROFILES Table

```
┌─────────────────────────────────────────────────────────┐
│ profiles                                                │
├─────────────────┬───────────┬──────────┬───────────────┤
│ Column          │ Type      │ Nullable │ Notes         │
├─────────────────┼───────────┼──────────┼───────────────┤
│ id              │ UUID      │ ✗        │ PK, FK        │
│ full_name       │ TEXT      │ ✗        │ Required      │
│ bio             │ TEXT      │ ✓        │ Optional      │
│ profile_...url  │ TEXT      │ ✓        │ Image URL     │
│ created_at      │ TIMESTAMP │ ✗        │ Auto          │
│ updated_at      │ TIMESTAMP │ ✗        │ Auto trigger  │
└─────────────────┴───────────┴──────────┴───────────────┘

Indexes:
  • idx_profiles_created_at (for sorting)
  • idx_profiles_full_name (for searching)

RLS Policies:
  • SELECT: Everyone can view profiles
  • INSERT: User can insert own profile
  • UPDATE: User can update own profile
  • DELETE: Cascades with auth.users
```

### EVENTS Table

```
┌─────────────────────────────────────────────────────────┐
│ events                                                  │
├─────────────────┬───────────┬──────────┬───────────────┤
│ Column          │ Type      │ Nullable │ Notes         │
├─────────────────┼───────────┼──────────┼───────────────┤
│ id              │ UUID      │ ✗        │ PK            │
│ user_id         │ UUID      │ ✗        │ FK→profiles   │
│ title           │ TEXT      │ ✗        │ Required      │
│ description     │ TEXT      │ ✗        │ Required      │
│ category        │ TEXT      │ ✓        │ Optional      │
│ location        │ TEXT      │ ✓        │ Optional      │
│ event_date      │ TIMESTAMP │ ✗        │ Required      │
│ thumbnail_url   │ TEXT      │ ✓        │ Image URL     │
│ image_url       │ TEXT      │ ✓        │ Image URL     │
│ capacity        │ INTEGER   │ ✓        │ Optional      │
│ attendees_count │ INTEGER   │ ✗        │ Default: 0    │
│ created_at      │ TIMESTAMP │ ✗        │ Auto          │
│ updated_at      │ TIMESTAMP │ ✗        │ Auto trigger  │
└─────────────────┴───────────┴──────────┴───────────────┘

Indexes:
  • idx_events_user_id (find user's events)
  • idx_events_event_date (sort by date)
  • idx_events_category (filter by category)
  • idx_events_location (filter by location)
  • idx_events_created_at (sort by creation)

RLS Policies:
  • SELECT: Everyone can view events
  • INSERT: User can create events (auto user_id)
  • UPDATE: User can update own events
  • DELETE: User can delete own events
```

### EVENT_ATTENDEES Table

```
┌─────────────────────────────────────────────────────────┐
│ event_attendees                                         │
├─────────────────┬───────────┬──────────┬───────────────┤
│ Column          │ Type      │ Nullable │ Notes         │
├─────────────────┼───────────┼──────────┼───────────────┤
│ id              │ UUID      │ ✗        │ PK            │
│ event_id        │ UUID      │ ✗        │ FK→events     │
│ user_id         │ UUID      │ ✗        │ FK→profiles   │
│ status          │ TEXT      │ ✗        │ See values    │
│ joined_at       │ TIMESTAMP │ ✗        │ Auto          │
└─────────────────┴───────────┴──────────┴───────────────┘

Status Values:
  • 'attending' (default) - User is attending
  • 'interested' - User is interested
  • 'declined' - User declined

Constraints:
  • UNIQUE(event_id, user_id) - One record per user per event

Indexes:
  • idx_event_attendees_event_id (find attendees)
  • idx_event_attendees_user_id (find user's events)
  • idx_event_attendees_status (filter by status)

RLS Policies:
  • SELECT: Everyone can view attendees
  • INSERT: User can register for events
  • UPDATE: User can change own attendance
  • DELETE: User can remove own attendance
```

---

## SQL Data Type Mappings

```
Dart Type          → SQL Type        → Notes
─────────────────────────────────────────────
String             → TEXT            → Variable length
int                → INTEGER         → 32-bit integer
double             → NUMERIC         → Decimal numbers
bool               → BOOLEAN         → true/false
DateTime           → TIMESTAMP       → With timezone
List<String>       → TEXT[] / JSON   → Use JSON for flexibility
UUID               → UUID            → For IDs
```

---

## RLS Policy Matrix

```
TABLE: profiles
┌──────────┬─────────┬──────────┬──────────────────────────┐
│ Operation│ Everyone│ Owner    │ Details                  │
├──────────┼─────────┼──────────┼──────────────────────────┤
│ SELECT   │ ✓ Yes   │ ✓ Yes    │ Public profile discovery │
│ INSERT   │ ✗ No    │ ✓ Own    │ Own profile only         │
│ UPDATE   │ ✗ No    │ ✓ Own    │ Own profile only         │
│ DELETE   │ ✗ No    │ Cascade  │ Via auth.users delete    │
└──────────┴─────────┴──────────┴──────────────────────────┘

TABLE: events
┌──────────┬─────────┬──────────┬──────────────────────────┐
│ Operation│ Everyone│ Creator  │ Details                  │
├──────────┼─────────┼──────────┼──────────────────────────┤
│ SELECT   │ ✓ Yes   │ ✓ Yes    │ Public event feed        │
│ INSERT   │ ✗ No    │ ✓ Yes    │ user_id auto-set         │
│ UPDATE   │ ✗ No    │ ✓ Own    │ Creator only             │
│ DELETE   │ ✗ No    │ ✓ Own    │ Creator only             │
└──────────┴─────────┴──────────┴──────────────────────────┘

TABLE: event_attendees
┌──────────┬─────────┬──────────┬──────────────────────────┐
│ Operation│ Everyone│ Attendee │ Details                  │
├──────────┼─────────┼──────────┼──────────────────────────┤
│ SELECT   │ ✓ Yes   │ ✓ Yes    │ Public attendee list     │
│ INSERT   │ ✗ No    │ ✓ Yes    │ Own registration only    │
│ UPDATE   │ ✗ No    │ ✓ Own    │ Own record only          │
│ DELETE   │ ✗ No    │ ✓ Own    │ Own record only          │
└──────────┴─────────┴──────────┴──────────────────────────┘
```

---

## JSON Serialization Mapping

Your Flutter models use snake_case in JSON, which matches the database:

```
DART MODEL              DATABASE FIELD
─────────────────────────────────────────
UserProfile:
  id                  → id
  fullName           → full_name
  bio                → bio
  profileImageUrl    → profile_image_url
  createdAt          → created_at
  updatedAt          → updated_at

Event:
  id                 → id
  userId             → user_id
  title              → title
  description        → description
  category           → category
  location           → location
  eventDate          → event_date
  thumbnailUrl       → thumbnail_url
  imageUrl           → image_url
  capacity           → capacity
  attendeesCount     → attendees_count
  createdAt          → created_at
  updatedAt          → updated_at
```

---

## Trigger Flow

```
USER UPDATES PROFILE
        │
        ↓
┌──────────────────────────────┐
│ BEFORE UPDATE Trigger Fires  │
│ Function: update_updated...  │
└──────────────────────────────┘
        │
        ↓
SET updated_at = now()
        │
        ↓
DATABASE UPDATED WITH:
  • All changed fields
  • NEW updated_at timestamp
```

---

## Index Performance Impact

```
Query Type                    Index Used         Performance
─────────────────────────────────────────────────────────────
Find events by date range     idx_events_date    Fast ✓
Find user's events            idx_events_user    Fast ✓
Filter by category            idx_events_cat     Fast ✓
Filter by location            idx_events_loc     Fast ✓
Sort by creation date         idx_events_created Fast ✓
Find profile by name          idx_profiles_name  Fast ✓
List attendees for event      idx_event_att_evt  Fast ✓
Find user's registrations     idx_event_att_usr  Fast ✓
```

---

## Storage Bucket Structure

```
SUPABASE STORAGE
├── event-images/
│   ├── {event-id-1}/
│   │   ├── thumbnail.jpg
│   │   ├── full.jpg
│   │   └── gallery/
│   │       ├── image1.jpg
│   │       └── image2.jpg
│   └── {event-id-2}/
│       └── full.jpg
│
└── profile-images/
    ├── {user-id-1}/
    │   └── profile.jpg
    └── {user-id-2}/
        └── profile.jpg
```

---

## Data Flow Diagram

```
MOBILE APP (Flutter)
        │
        ├─→ AuthService.signUp()
        │       │
        │       ↓
        │   auth.users (Supabase Auth)
        │       │
        │       ↓
        │   profiles table (RLS Protected)
        │
        ├─→ EventService.createEvent()
        │       │
        │       ↓
        │   events table (RLS Protected)
        │
        ├─→ EventService.attendEvent()
        │       │
        │       ↓
        │   event_attendees table (RLS Protected)
        │
        └─→ StorageService.uploadImage()
                │
                ↓
            Storage Buckets (Public URL)
                │
                ↓
            Image.network() in Flutter
```

---

## Common Queries Reference

```
// Find user's events
SELECT * FROM events WHERE user_id = auth.uid()

// Find events user is attending
SELECT e.* FROM events e
JOIN event_attendees a ON e.id = a.event_id
WHERE a.user_id = auth.uid()

// Get attendee count for event
SELECT COUNT(*) FROM event_attendees WHERE event_id = ?

// Get all attendees for event
SELECT p.*, a.status FROM event_attendees a
JOIN profiles p ON a.user_id = p.id
WHERE a.event_id = ?

// Get user's profile
SELECT * FROM profiles WHERE id = auth.uid()

// Get events within date range
SELECT * FROM events
WHERE event_date BETWEEN ? AND ?
ORDER BY event_date ASC
```

---

## Row-Level Security Flow

```
APP REQUESTS DATA
        │
        ↓
RLS POLICIES CHECK
        │
        ├─ Is user authenticated? (auth.uid())
        ├─ Does user own the record?
        ├─ Does policy allow operation?
        │
        ↓
DECISION
        │
        ├─ ✓ ALLOWED → Return data
        │
        └─ ✗ DENIED → Error 42501
                     (insufficient privileges)
```

---

## Performance Optimization

```
SLOW QUERY                              OPTIMIZATION
─────────────────────────────────────────────────────────
Full table scan on events               Add index on user_id ✓
Filtering without index                 Add index on field ✓
Sorting large result sets               Add index on order field ✓
Joining without foreign key             Add FK + index ✓
Like searches on names                  Full-text search (future)
```

---

## Cascade Delete Behavior

```
DELETE auth.users[id=X]
        │
        ↓
CASCADE DELETE profiles[id=X]
        │
        ├─→ CASCADE DELETE events[user_id=X]
        │       │
        │       └─→ CASCADE DELETE event_attendees[event_id]
        │
        └─→ CASCADE DELETE event_attendees[user_id=X]
```

---

## Column Size Guidelines

```
Field               Max Size    Typical Use
────────────────────────────────────────────
full_name           100 chars   "John Doe"
bio                 500 chars   Short biography
title               200 chars   "Summer Networking Event"
description         2000 chars  Detailed description
category            50 chars    "Technology", "Business"
location            200 chars   "San Francisco, CA"
URL fields          2000 chars  HTTPS URLs
```

---

This visual reference provides a complete overview of your database structure and relationships!

For more details, see:

- DATABASE_SCHEMA_GUIDE.md (detailed descriptions)
- SUPABASE_SCHEMA.sql (actual SQL)
- SUPABASE_QUICKSTART.md (setup steps)
