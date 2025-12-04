ALTER TABLE user_routes ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT false;

NOTIFY pgrst, 'reload config';
