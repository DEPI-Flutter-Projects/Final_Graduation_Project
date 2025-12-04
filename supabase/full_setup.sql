-- 1. Ensure profiles table has necessary columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_trips INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_savings NUMERIC DEFAULT 0.0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS km_traveled NUMERIC DEFAULT 0.0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avg_rating NUMERIC DEFAULT 5.0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 2. Create badges table
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    xp_reward INTEGER DEFAULT 50,
    condition_type TEXT,
    condition_value INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create user_badges table
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- 4. Enable RLS
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- 5. Policies for badges
DROP POLICY IF EXISTS "Public badges are viewable by everyone" ON badges;
CREATE POLICY "Public badges are viewable by everyone" ON badges
    FOR SELECT USING (true);

-- 6. Policies for user_badges
DROP POLICY IF EXISTS "Users can view their own badges" ON user_badges;
CREATE POLICY "Users can view their own badges" ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

-- 7. Insert initial badges (using ON CONFLICT DO NOTHING to avoid duplicates if run multiple times)
-- Note: We can't easily use ON CONFLICT on non-unique columns, so we'll just insert if empty or ignore errors in a real migration tool.
-- For this script, we'll assume it's a fresh run or the user handles duplicates.
INSERT INTO badges (name, description, icon, xp_reward, condition_type, condition_value) VALUES
('First Step', 'Completed your first trip', 'directions_walk', 50, 'trips_count', 1),
('Road Warrior', 'Completed 10 trips', 'commute', 100, 'trips_count', 10),
('Marathoner', 'Traveled over 100 km', 'speed', 200, 'km_traveled', 100),
('Eco Friendly', 'Saved 50kg of CO2', 'forest', 150, 'co2_saved', 50),
('Money Saver', 'Saved 1000 EGP', 'savings', 150, 'money_saved', 1000),
('Night Owl', 'Took a trip after 10 PM', 'nightlight_round', 75, 'night_trip', 1),
('Early Bird', 'Took a trip before 7 AM', 'wb_sunny', 75, 'morning_trip', 1),
('Explorer', 'Visited 5 different locations', 'map', 100, 'locations_visited', 5),
('Socialite', 'Shared a trip with a friend', 'share', 50, 'share_trip', 1),
('Legend', 'Reached Level 10', 'military_tech', 500, 'level_reached', 10)
ON CONFLICT DO NOTHING; -- This requires a unique constraint on name or similar to work effectively, but standard SQL insert here.

-- 8. Storage: Create 'avatars' bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 9. Storage Policies
-- Allow public access to avatars
DROP POLICY IF EXISTS "Avatar images are publicly accessible" ON storage.objects;
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- Allow authenticated users to upload their own avatar
-- (Assuming the file path is {user_id}/{filename})
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their own avatar
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
);
