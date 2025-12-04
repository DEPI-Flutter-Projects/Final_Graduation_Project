-- Create car_brands table
CREATE TABLE IF NOT EXISTS car_brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create car_models table
CREATE TABLE IF NOT EXISTS car_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES car_brands(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    fuel_type TEXT DEFAULT 'Petrol', -- Petrol, Diesel, Electric, Hybrid, CNG
    avg_fuel_consumption NUMERIC DEFAULT 10.0, -- L/100km or equivalent
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_vehicles table
CREATE TABLE IF NOT EXISTS user_vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    model_id UUID REFERENCES car_models(id) ON DELETE CASCADE,
    year INTEGER,
    license_plate TEXT,
    color TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE car_brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE car_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_vehicles ENABLE ROW LEVEL SECURITY;

-- Policies
-- Public read access for brands and models
CREATE POLICY "Public brands are viewable by everyone" ON car_brands FOR SELECT USING (true);
CREATE POLICY "Public models are viewable by everyone" ON car_models FOR SELECT USING (true);

-- Users can manage their own vehicles
CREATE POLICY "Users can view their own vehicles" ON user_vehicles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own vehicles" ON user_vehicles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own vehicles" ON user_vehicles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own vehicles" ON user_vehicles FOR DELETE USING (auth.uid() = user_id);

-- Insert some initial data
INSERT INTO car_brands (name) VALUES 
('Toyota'), ('Hyundai'), ('Kia'), ('Nissan'), ('Renault'), ('Chevrolet'), ('Fiat'), ('Mercedes'), ('BMW')
ON CONFLICT (name) DO NOTHING;

-- Insert some models (This is a simplified list, in reality you'd fetch brand IDs first)
-- We use a DO block to insert models dynamically based on brand names
DO $$
DECLARE
    toyota_id UUID;
    hyundai_id UUID;
    kia_id UUID;
    nissan_id UUID;
    renault_id UUID;
BEGIN
    SELECT id INTO toyota_id FROM car_brands WHERE name = 'Toyota';
    SELECT id INTO hyundai_id FROM car_brands WHERE name = 'Hyundai';
    SELECT id INTO kia_id FROM car_brands WHERE name = 'Kia';
    SELECT id INTO nissan_id FROM car_brands WHERE name = 'Nissan';
    SELECT id INTO renault_id FROM car_brands WHERE name = 'Renault';

    INSERT INTO car_models (brand_id, name, fuel_type, avg_fuel_consumption) VALUES
    (toyota_id, 'Corolla', 'Petrol', 8.0),
    (toyota_id, 'Yaris', 'Petrol', 6.5),
    (hyundai_id, 'Elantra', 'Petrol', 8.5),
    (hyundai_id, 'Tucson', 'Petrol', 10.5),
    (kia_id, 'Sportage', 'Petrol', 10.5),
    (kia_id, 'Cerato', 'Petrol', 8.5),
    (nissan_id, 'Sunny', 'Petrol', 7.5),
    (renault_id, 'Logan', 'Petrol', 7.5),
    (renault_id, 'Duster', 'Petrol', 9.0)
    ON CONFLICT DO NOTHING; -- Note: conflict check on ID won't work here easily without unique constraint on name+brand, but this is just init script
END $$;
