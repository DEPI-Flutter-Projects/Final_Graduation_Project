-- Fix missing is_favorite column
ALTER TABLE user_routes ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT false;

-- Force schema cache reload to ensure PostgREST sees the new column
NOTIFY pgrst, 'reload config';
