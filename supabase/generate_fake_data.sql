-- Generate Fake Data for El-Moshwar App

-- 1. Create a dummy user (if not exists)
DO $$
DECLARE
    target_user_id UUID;
    toyota_id UUID;
    hyundai_id UUID;
    kia_id UUID;
    corolla_id UUID;
    elantra_id UUID;
    sportage_id UUID;
BEGIN
    -- Try to get the first user from auth.users. If none, this will fail.
    SELECT id INTO target_user_id FROM auth.users LIMIT 1;

    IF target_user_id IS NULL THEN
        RAISE NOTICE 'No user found in auth.users. Please sign up a user first.';
        RETURN;
    END IF;

    RAISE NOTICE 'Generating data for User ID: %', target_user_id;

    -- 2. Ensure Brands Exist
    INSERT INTO car_brands (name) VALUES ('Toyota'), ('Hyundai'), ('Kia') ON CONFLICT (name) DO NOTHING;
    
    SELECT id INTO toyota_id FROM car_brands WHERE name = 'Toyota';
    SELECT id INTO hyundai_id FROM car_brands WHERE name = 'Hyundai';
    SELECT id INTO kia_id FROM car_brands WHERE name = 'Kia';

    -- 3. Ensure Models Exist
    INSERT INTO car_models (brand_id, name, fuel_type, avg_fuel_consumption) VALUES 
    (toyota_id, 'Corolla', 'Petrol', 8.0),
    (hyundai_id, 'Elantra', 'Petrol', 8.5),
    (kia_id, 'Sportage', 'Petrol', 10.5)
    ON CONFLICT DO NOTHING; -- Note: simple conflict check might not work without unique constraint, but safe for now

    SELECT id INTO corolla_id FROM car_models WHERE brand_id = toyota_id AND name = 'Corolla' LIMIT 1;
    SELECT id INTO elantra_id FROM car_models WHERE brand_id = hyundai_id AND name = 'Elantra' LIMIT 1;
    SELECT id INTO sportage_id FROM car_models WHERE brand_id = kia_id AND name = 'Sportage' LIMIT 1;

    -- 4. Insert Fake Vehicles (using model_id)
    INSERT INTO public.user_vehicles (user_id, model_id, year, license_plate, color, is_default)
    VALUES
    (target_user_id, corolla_id, 2020, 'ABC-123', 'White', true),
    (target_user_id, elantra_id, 2019, 'XYZ-789', 'Silver', false),
    (target_user_id, sportage_id, 2022, 'KIA-001', 'Black', false)
    ON CONFLICT DO NOTHING;

    -- 5. Insert Fake Routes (Past Month)
    
    -- Route 1: Car trip yesterday
    INSERT INTO public.user_routes (
        user_id, 
        start_address, 
        end_address, 
        total_distance_km, 
        total_duration_min, 
        estimated_cost, 
        saved_amount, 
        transport_mode, 
        created_at,
        is_favorite
    ) VALUES (
        target_user_id,
        'Cairo Festival City, New Cairo',
        'Maadi City Center, Maadi',
        15.5,
        35,
        45.0,
        15.0,
        'Car',
        NOW() - INTERVAL '1 day',
        true
    );

    -- Route 2: Metro trip 2 days ago
    INSERT INTO public.user_routes (
        user_id, 
        start_address, 
        end_address, 
        total_distance_km, 
        total_duration_min, 
        estimated_cost, 
        saved_amount, 
        transport_mode, 
        created_at,
        is_favorite
    ) VALUES (
        target_user_id,
        'El Shohada Station',
        'Cairo University Station',
        8.0,
        20,
        10.0,
        40.0,
        'Metro',
        NOW() - INTERVAL '2 days',
        false
    );

    -- Route 3: Microbus trip 3 days ago
    INSERT INTO public.user_routes (
        user_id, 
        start_address, 
        end_address, 
        total_distance_km, 
        total_duration_min, 
        estimated_cost, 
        saved_amount, 
        transport_mode, 
        created_at,
        is_favorite
    ) VALUES (
        target_user_id,
        'Ramses Station',
        'Abbassia',
        5.2,
        25,
        5.0,
        25.0,
        'Microbus',
        NOW() - INTERVAL '3 days',
        false
    );

    -- Route 4: Car trip 1 week ago (Favorite)
    INSERT INTO public.user_routes (
        user_id, 
        start_address, 
        end_address, 
        total_distance_km, 
        total_duration_min, 
        estimated_cost, 
        saved_amount, 
        transport_mode, 
        created_at,
        is_favorite
    ) VALUES (
        target_user_id,
        'Home',
        'Work',
        22.0,
        45,
        60.0,
        0.0,
        'Car',
        NOW() - INTERVAL '7 days',
        true
    );

    -- Route 5: Uber trip 2 weeks ago
    INSERT INTO public.user_routes (
        user_id, 
        start_address, 
        end_address, 
        total_distance_km, 
        total_duration_min, 
        estimated_cost, 
        saved_amount, 
        transport_mode, 
        created_at,
        is_favorite
    ) VALUES (
        target_user_id,
        'Zamalek',
        'Heliopolis',
        18.5,
        40,
        120.0,
        -50.0, -- Negative savings (cost more than usual)
        'Uber',
        NOW() - INTERVAL '14 days',
        false
    );

    RAISE NOTICE 'Fake data generation complete!';
END $$;
