-- Database Migrations for El-Moshwar App UI Redesign
-- Run this in Supabase SQL Editor after update_schema.sql

-- =====================================================
-- 1. USER PREFERENCES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- App Preferences
  default_transport_mode TEXT DEFAULT 'Car' CHECK (default_transport_mode IN ('Car', 'Metro', 'Microbus', 'Walk')),
  distance_unit TEXT DEFAULT 'KM' CHECK (distance_unit IN ('KM', 'Miles')),
  currency TEXT DEFAULT 'EGP' CHECK (currency IN ('EGP', 'USD', 'EUR', 'GBP')),
  language TEXT DEFAULT 'English' CHECK (language IN ('English', 'Arabic')),
  dark_mode BOOLEAN DEFAULT false,
  
  -- Notification Settings
  notifications_enabled BOOLEAN DEFAULT true,
  route_alerts BOOLEAN DEFAULT true,
  savings_alerts BOOLEAN DEFAULT true,
  traffic_alerts BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own preferences" ON public.user_preferences;
CREATE POLICY "Users can view own preferences"
  ON public.user_preferences FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own preferences" ON public.user_preferences;
CREATE POLICY "Users can update own preferences"
  ON public.user_preferences FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own preferences" ON public.user_preferences;
CREATE POLICY "Users can insert own preferences"
  ON public.user_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- 2. ENHANCE USER_ROUTES TABLE
-- =====================================================
-- Add new columns to existing user_routes table
ALTER TABLE public.user_routes 
  ADD COLUMN IF NOT EXISTS transport_mode TEXT CHECK (transport_mode IN ('Car', 'Metro', 'Microbus', 'Walk')),
  ADD COLUMN IF NOT EXISTS traffic_status TEXT,
  ADD COLUMN IF NOT EXISTS saved_amount DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS cost DECIMAL(10, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 0;

-- =====================================================
-- 3. ROUTE STOPS TABLE  
-- =====================================================
CREATE TABLE IF NOT EXISTS public.route_stops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  route_id UUID REFERENCES public.user_routes(id) ON DELETE CASCADE,
  location TEXT NOT NULL,
  stop_order INTEGER NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.route_stops ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own route stops" ON public.route_stops;
CREATE POLICY "Users can view own route stops"
  ON public.route_stops FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.user_routes
      WHERE user_routes.id = route_stops.route_id
      AND user_routes.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own route stops" ON public.route_stops;
CREATE POLICY "Users can insert own route stops"
  ON public.route_stops FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_routes
      WHERE user_routes.id = route_stops.route_id
      AND user_routes.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete own route stops" ON public.route_stops;
CREATE POLICY "Users can delete own route stops"
  ON public.route_stops FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.user_routes
      WHERE user_routes.id = route_stops.route_id
      AND user_routes.user_id = auth.uid()
    )
  );

-- =====================================================
-- 4. CREATE INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_route_stops_route_id ON public.route_stops(route_id);
CREATE INDEX IF NOT EXISTS idx_user_routes_transport_mode ON public.user_routes(transport_mode);

-- =====================================================
-- 5. CREATE TRIGGER FOR user_preferences updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_user_preferences_updated_at ON public.user_preferences;
CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 6. SEED DEFAULT PREFERENCES FOR EXISTING USERS
-- =====================================================
-- Insert default preferences for users who don't have any
INSERT INTO public.user_preferences (user_id)
SELECT id FROM auth.users
WHERE id NOT IN (SELECT user_id FROM public.user_preferences)
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
-- If you see this, all migrations ran successfully!
DO $$
BEGIN
  RAISE NOTICE 'El-Moshwar database migrations completed successfully!';
END $$;
