-- Create badges table
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL, -- Material Icon name or asset path
    xp_reward INTEGER DEFAULT 50,
    condition_type TEXT, -- e.g., 'trips_count', 'km_traveled'
    condition_value INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_badges table
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    badge_id UUID REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- Enable RLS
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- Policies for badges (Public read)
CREATE POLICY "Public badges are viewable by everyone" ON badges
    FOR SELECT USING (true);

-- Policies for user_badges (Users can see their own badges)
CREATE POLICY "Users can view their own badges" ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

-- Insert some initial badges
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
('Legend', 'Reached Level 10', 'military_tech', 500, 'level_reached', 10);
