DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_vehicles'
        AND column_name = 'is_default'
    ) THEN
        ALTER TABLE user_vehicles ADD COLUMN is_default BOOLEAN DEFAULT false;
    END IF;
END $$;
