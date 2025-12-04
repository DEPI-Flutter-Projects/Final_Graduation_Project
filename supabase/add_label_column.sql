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
