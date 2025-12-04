-- Create challenges table
CREATE TABLE IF NOT EXISTS challenges (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  description TEXT NOT NULL,
  xp_reward INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('daily', 'weekly')),
  target_value INTEGER NOT NULL,
  metric TEXT NOT NULL CHECK (metric IN ('trips', 'distance', 'savings', 'streak')),
  icon TEXT DEFAULT 'star'
);

-- Create user_challenges table to track active/completed challenges
CREATE TABLE IF NOT EXISTS user_challenges (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  progress INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  assigned_date DATE DEFAULT CURRENT_DATE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Insert some default challenges
INSERT INTO challenges (description, xp_reward, type, target_value, metric, icon) VALUES
('Complete 3 trips today', 150, 'daily', 3, 'trips', 'commute'),
('Travel 10 km today', 200, 'daily', 10, 'distance', 'directions_walk'),
('Save 50 EGP today', 100, 'daily', 50, 'savings', 'savings'),
('Maintain a 3-day streak', 300, 'weekly', 3, 'streak', 'local_fire_department'),
('Complete 10 trips this week', 500, 'weekly', 10, 'trips', 'commute'),
('Travel 50 km this week', 600, 'weekly', 50, 'distance', 'map');
