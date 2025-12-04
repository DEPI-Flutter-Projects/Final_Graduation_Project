-- Add label column to user_vehicles
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'label'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN label TEXT;
    END IF;
END $$;

-- Add year_start and year_end to car_models
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'car_models'
        AND column_name = 'year_start'
    ) THEN
        ALTER TABLE car_models ADD COLUMN year_start INTEGER DEFAULT 2000;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'car_models'
        AND column_name = 'year_end'
    ) THEN
        ALTER TABLE car_models ADD COLUMN year_end INTEGER DEFAULT 2025;
    END IF;
END $$;
