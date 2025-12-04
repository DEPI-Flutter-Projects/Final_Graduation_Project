-- Add columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS xp INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_spin_date TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_activity_date TIMESTAMPTZ;

-- Create badges table
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    xp_reward INTEGER NOT NULL,
    category TEXT NOT NULL, -- 'savings', 'distance', 'trips', 'eco', 'time', 'streak'
    requirement_value INTEGER NOT NULL, -- The value needed to unlock (e.g. 100 km)
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

-- Insert 50 Badges
INSERT INTO badges (name, description, icon, xp_reward, category, requirement_value) VALUES
-- Trips
('First Step', 'Complete your first trip', 'directions_walk', 50, 'trips', 1),
('Commuter', 'Complete 10 trips', 'commute', 100, 'trips', 10),
('Regular', 'Complete 50 trips', 'directions_bus', 500, 'trips', 50),
('Veteran', 'Complete 100 trips', 'airport_shuttle', 1000, 'trips', 100),
('Legendary Traveler', 'Complete 500 trips', 'flight', 5000, 'trips', 500),

-- Distance (KM)
('Neighborhood Explorer', 'Travel 10 km', 'map', 50, 'distance', 10),
('City Roamer', 'Travel 50 km', 'location_on', 150, 'distance', 50),
('Marathoner', 'Travel 100 km', 'directions_run', 300, 'distance', 100),
('Road Warrior', 'Travel 500 km', 'add_road', 1000, 'distance', 500),
('Globetrotter', 'Travel 1000 km', 'public', 2500, 'distance', 1000),
('Moon Walker', 'Travel 10,000 km', 'rocket_launch', 10000, 'distance', 10000),

-- Savings (Money)
('Penny Pincher', 'Save 50 EGP', 'savings', 50, 'savings', 50),
('Thrifty', 'Save 200 EGP', 'account_balance_wallet', 150, 'savings', 200),
('Smart Saver', 'Save 500 EGP', 'attach_money', 400, 'savings', 500),
('Wealth Builder', 'Save 1000 EGP', 'currency_exchange', 1000, 'savings', 1000),
('Financial Guru', 'Save 5000 EGP', 'diamond', 5000, 'savings', 5000),

-- Eco (CO2 Saved - assuming 1kg ~ 1 unit for simplicity in requirement)
('Green Starter', 'Save 5 kg of CO2', 'eco', 50, 'eco', 5),
('Eco Friend', 'Save 20 kg of CO2', 'recycling', 150, 'eco', 20),
('Nature Lover', 'Save 50 kg of CO2', 'forest', 400, 'eco', 50),
('Planet Protector', 'Save 100 kg of CO2', 'public', 1000, 'eco', 100),
('Climate Hero', 'Save 500 kg of CO2', 'wb_sunny', 5000, 'eco', 500),

-- Streaks (Days in a row)
('Weekend Warrior', 'Use app 2 days in a row', 'calendar_view_week', 50, 'streak', 2),
('Consistent', 'Use app 3 days in a row', 'repeat', 100, 'streak', 3),
('Dedicated', 'Use app 7 days in a row', 'event_available', 500, 'streak', 7),
('Unstoppable', 'Use app 30 days in a row', 'calendar_month', 2000, 'streak', 30),

-- Time (Specific times - handled by logic, requirement_value is hour)
('Early Bird', 'Complete a trip before 7 AM', 'wb_twilight', 100, 'time', 7),
('Night Owl', 'Complete a trip after 10 PM', 'nights_stay', 100, 'time', 22),
('Lunch Rush', 'Complete a trip between 12 PM and 2 PM', 'restaurant', 50, 'time', 12),

-- Transport Modes (Count)
('Metro Master', 'Use Metro 10 times', 'train', 200, 'mode_metro', 10),
('Bus Boss', 'Use Bus 10 times', 'directions_bus', 200, 'mode_bus', 10),
('Walking Wonder', 'Walk 10 times', 'directions_walk', 200, 'mode_walk', 10),
('Microbus Maestro', 'Use Microbus 10 times', 'airport_shuttle', 200, 'mode_microbus', 10),

-- Random Fun
('Social Butterfly', 'Share a trip', 'share', 50, 'social', 1),
('Planner', 'Save 5 routes', 'bookmark', 100, 'planning', 5),
('Explorer', 'Visit 5 different areas', 'explore', 150, 'exploration', 5),
('Reviewer', 'Rate 5 trips', 'star', 100, 'rating', 5),
('Critic', 'Rate 20 trips', 'stars', 500, 'rating', 20),

-- High Value
('Jackpot', 'Win 1000 XP from Spin Wheel', 'casino', 100, 'luck', 1000),
('Millionaire', 'Save 10,000 EGP total', 'monetization_on', 10000, 'savings', 10000),
('Astronaut', 'Travel 50,000 km', 'satellite_alt', 20000, 'distance', 50000),
('Guardian', 'Save 1000 kg CO2', 'shield', 10000, 'eco', 1000),
('Immortal', 'Use app 365 days in a row', 'infinity', 50000, 'streak', 365),

-- Fillers to reach 50
('Baby Steps', 'Travel 1 km', 'footprint', 10, 'distance', 1),
('Double Digits', 'Save 10 EGP', 'money', 20, 'savings', 10),
('Triple Threat', 'Use 3 different modes', 'layers', 150, 'variety', 3),
('Speedster', 'Complete a trip < 10 mins', 'timer', 50, 'speed', 10),
('Long Haul', 'Complete a trip > 1 hour', 'timelapse', 100, 'endurance', 60),
('Rain or Shine', 'Trip in bad weather (simulated)', 'thunderstorm', 200, 'weather', 1),
('Safe Driver', 'No hard braking (simulated)', 'health_and_safety', 100, 'safety', 1),
('Navigator Pro', 'Use route optimizer 10 times', 'alt_route', 150, 'usage', 10),
('Feedback Loop', 'Submit feedback', 'feedback', 50, 'community', 1),
('Supporter', 'View About page', 'info', 10, 'community', 1);
