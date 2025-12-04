-- Clear existing badges to remove duplicates and old data
DELETE FROM user_badges;
DELETE FROM badges;

-- Add requirements column if it doesn't exist
ALTER TABLE badges ADD COLUMN IF NOT EXISTS requirements JSONB DEFAULT '{}'::jsonb;

-- Insert new creative badges
INSERT INTO badges (name, description, icon, xp_reward, requirements) VALUES
('Rookie Driver', 'Complete your first trip with El-Moshwar', 'directions_car', 50, '{"trips": 1}'),
('Road Warrior', 'Complete 10 trips using the app', 'commute', 200, '{"trips": 10}'),
('Marathoner', 'Travel a total of 100 km', 'speed', 500, '{"km": 100}'),
('Penny Pincher', 'Save over 100 EGP in transportation costs', 'savings', 300, '{"savings": 100}'),
('Eco Hero', 'Contribute to saving 10kg of CO2', 'forest', 400, '{"co2": 10}'),
('Night Rider', 'Complete a trip after 10 PM', 'nightlight_round', 150, '{"time": "22:00"}'),
('Early Bird', 'Complete a trip before 7 AM', 'wb_sunny', 150, '{"time": "07:00"}'),
('Explorer', 'Visit 5 different locations', 'map', 250, '{"locations": 5}'),
('Social Butterfly', 'Share the app with a friend', 'share', 100, '{"share": 1}'),
('Master Planner', 'Save 5 different routes', 'alt_route', 200, '{"saved_routes": 5}'),
('Legend', 'Reach Level 10', 'military_tech', 1000, '{"level": 10}');
