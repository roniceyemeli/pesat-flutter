-- ============================================================
-- SUPABASE DATABASE SCHEMA - Event Management App
-- ============================================================
-- This schema is designed for the Flutter Event App
-- All tables are properly structured with foreign keys and indexes

-- ============================================================
-- 1. ENABLE REQUIRED EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 2. PROFILES TABLE (Users)
-- ============================================================
-- Linked to Supabase auth.users table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  bio TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add comment for documentation
COMMENT ON TABLE public.profiles IS 'User profile information linked to Supabase auth users';
COMMENT ON COLUMN public.profiles.id IS 'Foreign key reference to auth.users(id)';
COMMENT ON COLUMN public.profiles.full_name IS 'User full name (required)';
COMMENT ON COLUMN public.profiles.bio IS 'User biography (optional)';
COMMENT ON COLUMN public.profiles.profile_image_url IS 'URL to user profile image (optional)';

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_full_name ON public.profiles(full_name);

-- ============================================================
-- 3. EVENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS public.events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT,
  location TEXT,
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  thumbnail_url TEXT,
  image_url TEXT,
  capacity INTEGER,
  attendees_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE public.events IS 'Events created by users';
COMMENT ON COLUMN public.events.id IS 'Unique event identifier (UUID)';
COMMENT ON COLUMN public.events.user_id IS 'Foreign key to profiles.id (event creator)';
COMMENT ON COLUMN public.events.title IS 'Event title (required)';
COMMENT ON COLUMN public.events.description IS 'Event description (required)';
COMMENT ON COLUMN public.events.category IS 'Event category (optional)';
COMMENT ON COLUMN public.events.location IS 'Event location (optional)';
COMMENT ON COLUMN public.events.event_date IS 'Event date and time (required)';
COMMENT ON COLUMN public.events.thumbnail_url IS 'Thumbnail image URL (optional)';
COMMENT ON COLUMN public.events.image_url IS 'Event image URL (optional)';
COMMENT ON COLUMN public.events.capacity IS 'Max attendees (optional)';
COMMENT ON COLUMN public.events.attendees_count IS 'Current number of attendees';

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_events_user_id ON public.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_event_date ON public.events(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_events_category ON public.events(category);
CREATE INDEX IF NOT EXISTS idx_events_location ON public.events(location);
CREATE INDEX IF NOT EXISTS idx_events_created_at ON public.events(created_at DESC);

-- ============================================================
-- 4. EVENT ATTENDEES TABLE (Join Table)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.event_attendees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'attending',
  -- status can be: 'attending', 'interested', 'declined'
  joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(event_id, user_id)
);

-- Add comments
COMMENT ON TABLE public.event_attendees IS 'Tracks which users are attending which events';
COMMENT ON COLUMN public.event_attendees.status IS 'Attendance status: attending, interested, declined';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_event_attendees_event_id ON public.event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user_id ON public.event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_status ON public.event_attendees(status);

-- ============================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_attendees ENABLE ROW LEVEL SECURITY;

-- PROFILES RLS POLICIES
-- Users can view all profiles
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Profiles are deleted with auth user (cascade)
-- No explicit delete policy needed

-- EVENTS RLS POLICIES
-- Anyone can view all events
CREATE POLICY "Events are viewable by everyone" ON public.events
  FOR SELECT USING (true);

-- Users can create events
CREATE POLICY "Users can create events" ON public.events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own events
CREATE POLICY "Users can update their own events" ON public.events
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own events
CREATE POLICY "Users can delete their own events" ON public.events
  FOR DELETE USING (auth.uid() = user_id);

-- EVENT ATTENDEES RLS POLICIES
-- Anyone can view attendee list
CREATE POLICY "Event attendees are viewable by everyone" ON public.event_attendees
  FOR SELECT USING (true);

-- Users can register for events
CREATE POLICY "Users can register for events" ON public.event_attendees
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own attendance
CREATE POLICY "Users can update their own attendance" ON public.event_attendees
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can remove their attendance
CREATE POLICY "Users can remove their attendance" ON public.event_attendees
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- 6. FUNCTIONS FOR AUTOMATIC UPDATES
-- ============================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles updated_at
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for events updated_at
CREATE TRIGGER update_events_updated_at
BEFORE UPDATE ON public.events
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- 7. SAMPLE DATA (Optional - for testing)
-- ============================================================
-- This is commented out but can be used for testing

/*
-- Create test profiles
INSERT INTO public.profiles (id, full_name, bio)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'John Doe', 'Love events and networking'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Jane Smith', 'Event organizer'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Bob Johnson', 'Tech enthusiast')
ON CONFLICT DO NOTHING;

-- Create test events
INSERT INTO public.events (user_id, title, description, category, location, event_date, capacity)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Flutter Meetup', 'Join us for a Flutter discussion', 'Tech', 'New York', now() + interval '7 days', 50),
  ('550e8400-e29b-41d4-a716-446655440002', 'Tech Conference 2026', 'Annual tech conference', 'Tech', 'San Francisco', now() + interval '30 days', 500),
  ('550e8400-e29b-41d4-a716-446655440003', 'Networking Dinner', 'Professional networking event', 'Business', 'Los Angeles', now() + interval '14 days', 100)
ON CONFLICT DO NOTHING;
*/

-- ============================================================
-- 8. CLEANUP / RESET PROCEDURES
-- ============================================================
-- To reset all data (careful!):
-- TRUNCATE TABLE public.event_attendees CASCADE;
-- TRUNCATE TABLE public.events CASCADE;
-- TRUNCATE TABLE public.profiles CASCADE;

-- To drop all tables:
-- DROP TABLE IF EXISTS public.event_attendees;
-- DROP TABLE IF EXISTS public.events;
-- DROP TABLE IF EXISTS public.profiles;
-- DROP FUNCTION IF EXISTS public.update_updated_at_column();

-- ============================================================
-- END OF SCHEMA
-- ============================================================
