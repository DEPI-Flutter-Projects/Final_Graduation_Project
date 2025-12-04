-- Create user_routes table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    start_address TEXT,
    end_address TEXT,
    total_distance_km NUMERIC,
    total_duration_min INTEGER,
    estimated_cost NUMERIC,
    saved_amount NUMERIC DEFAULT 0.0,
    transport_mode TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_routes ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can insert their own routes" ON user_routes;
CREATE POLICY "Users can insert their own routes" ON user_routes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view their own routes" ON user_routes;
CREATE POLICY "Users can view their own routes" ON user_routes
    FOR SELECT USING (auth.uid() = user_id);
