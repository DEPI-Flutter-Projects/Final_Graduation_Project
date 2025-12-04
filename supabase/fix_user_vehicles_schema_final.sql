-- Fix user_vehicles schema to match app requirements

DO $$
BEGIN
    -- 1. Add model_id if it doesn't exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'model_id'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN model_id UUID REFERENCES car_models(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added model_id column to user_vehicles';
    END IF;

    -- 2. Add label if it doesn't exist
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'label'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN label TEXT;
        RAISE NOTICE 'Added label column to user_vehicles';
    END IF;

    -- 3. Add other potentially missing columns just in case
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'year'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN year INTEGER;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'license_plate'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN license_plate TEXT;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'color'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN color TEXT;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'is_default'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN is_default BOOLEAN DEFAULT false;
    END IF;

    -- 5. Handle legacy columns (car_brand, car_model) - Make them nullable if they exist
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'car_brand'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN car_brand DROP NOT NULL;
        RAISE NOTICE 'Made car_brand nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'car_model'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN car_model DROP NOT NULL;
        RAISE NOTICE 'Made car_model nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'manufacture_year'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN manufacture_year DROP NOT NULL;
        RAISE NOTICE 'Made manufacture_year nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'avg_consumption'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN avg_consumption DROP NOT NULL;
        RAISE NOTICE 'Made avg_consumption nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'fuel_type'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN fuel_type DROP NOT NULL;
        RAISE NOTICE 'Made fuel_type nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'transmission'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN transmission DROP NOT NULL;
        RAISE NOTICE 'Made transmission nullable';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'engine_capacity'
    ) THEN
        ALTER TABLE user_vehicles ALTER COLUMN engine_capacity DROP NOT NULL;
        RAISE NOTICE 'Made engine_capacity nullable';
    END IF;

    -- 4. Reload schema cache
    NOTIFY pgrst, 'reload config';
END $$;
