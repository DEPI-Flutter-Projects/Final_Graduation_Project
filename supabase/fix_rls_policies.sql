-- Enable RLS on user_routes if not already enabled
ALTER TABLE user_routes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can insert their own routes" ON user_routes;
DROP POLICY IF EXISTS "Users can view their own routes" ON user_routes;
DROP POLICY IF EXISTS "Users can update their own routes" ON user_routes;
DROP POLICY IF EXISTS "Users can delete their own routes" ON user_routes;

-- Policy to allow users to insert their own routes
CREATE POLICY "Users can insert their own routes"
ON user_routes FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to view their own routes
CREATE POLICY "Users can view their own routes"
ON user_routes FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy to allow users to update their own routes (CRITICAL FOR FAVORITES)
CREATE POLICY "Users can update their own routes"
ON user_routes FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to delete their own routes
CREATE POLICY "Users can delete their own routes"
ON user_routes FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
