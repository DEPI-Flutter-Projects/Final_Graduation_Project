-- Fix user_routes table schema
-- Add missing columns if they don't exist

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'start_address') THEN
        ALTER TABLE user_routes ADD COLUMN start_address TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'end_address') THEN
        ALTER TABLE user_routes ADD COLUMN end_address TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'transport_mode') THEN
        ALTER TABLE user_routes ADD COLUMN transport_mode TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'total_distance_km') THEN
        ALTER TABLE user_routes ADD COLUMN total_distance_km NUMERIC;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'total_duration_min') THEN
        ALTER TABLE user_routes ADD COLUMN total_duration_min INTEGER;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'estimated_cost') THEN
        ALTER TABLE user_routes ADD COLUMN estimated_cost NUMERIC;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_routes' AND column_name = 'saved_amount') THEN
        ALTER TABLE user_routes ADD COLUMN saved_amount NUMERIC DEFAULT 0.0;
    END IF;
END $$;

-- Force schema cache reload
NOTIFY pgrst, 'reload config';
