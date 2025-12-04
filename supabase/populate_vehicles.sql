-- Create car_brands table
CREATE TABLE IF NOT EXISTS public.car_brands (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create car_models table
CREATE TABLE IF NOT EXISTS public.car_models (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    brand_id UUID REFERENCES public.car_brands(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    year_start INTEGER,
    year_end INTEGER,
    fuel_type TEXT DEFAULT 'Petrol', -- Petrol, Diesel, Electric, Hybrid
    avg_fuel_consumption FLOAT, -- Liters per 100km
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(brand_id, name, year_start, year_end)
);

-- Enable RLS
ALTER TABLE public.car_brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.car_models ENABLE ROW LEVEL SECURITY;

-- Drop policies if they exist to avoid errors on re-run
DROP POLICY IF EXISTS "Car brands are viewable by everyone" ON public.car_brands;
DROP POLICY IF EXISTS "Car models are viewable by everyone" ON public.car_models;

-- Create policies (readable by everyone, writable only by service role/admin if needed)
CREATE POLICY "Car brands are viewable by everyone" ON public.car_brands FOR SELECT USING (true);
CREATE POLICY "Car models are viewable by everyone" ON public.car_models FOR SELECT USING (true);

-- Insert Brands (Comprehensive List)
INSERT INTO public.car_brands (name) VALUES 
-- Japanese
('Toyota'), ('Nissan'), ('Honda'), ('Mitsubishi'), ('Suzuki'), ('Mazda'), ('Subaru'), ('Lexus'), ('Daihatsu'), ('Isuzu'),
-- Korean
('Hyundai'), ('Kia'), ('SsangYong'), ('Daewoo'),
-- European (German)
('Mercedes-Benz'), ('BMW'), ('Audi'), ('Volkswagen'), ('Opel'), ('Porsche'),
-- European (French)
('Renault'), ('Peugeot'), ('Citroen'), ('DS'),
-- European (Italian)
('Fiat'), ('Alfa Romeo'), ('Maserati'), ('Ferrari'), ('Lamborghini'),
-- European (Other)
('Skoda'), ('Seat'), ('Volvo'), ('Land Rover'), ('Jaguar'), ('Mini'), ('Aston Martin'), ('Bentley'), ('Lada'),
-- American
('Chevrolet'), ('Ford'), ('Jeep'), ('Chrysler'), ('Dodge'), ('Tesla'),
-- Chinese
('Chery'), ('MG'), ('BYD'), ('Geely'), ('Brilliance'), ('JAC'), ('Changan'), ('Haval'), ('Jetour'), ('Bestune'), ('Baic'), ('DFSK'), ('Zotye'), ('Speranza'), ('Great Wall'), ('Faw'), ('Soueast'), ('Proton')
ON CONFLICT (name) DO NOTHING;

-- Insert Models (using a DO block to look up brand IDs)
DO $$
DECLARE
    -- Japanese
    toyota_id UUID; nissan_id UUID; honda_id UUID; mitsubishi_id UUID; suzuki_id UUID; mazda_id UUID; subaru_id UUID; lexus_id UUID; daihatsu_id UUID; isuzu_id UUID;
    -- Korean
    hyundai_id UUID; kia_id UUID; ssangyong_id UUID; daewoo_id UUID;
    -- German
    mercedes_id UUID; bmw_id UUID; audi_id UUID; vw_id UUID; opel_id UUID; porsche_id UUID;
    -- French
    renault_id UUID; peugeot_id UUID; citroen_id UUID; ds_id UUID;
    -- Italian
    fiat_id UUID; alfa_id UUID;
    -- Other Euro
    skoda_id UUID; seat_id UUID; volvo_id UUID; landrover_id UUID; jaguar_id UUID; mini_id UUID; lada_id UUID;
    -- American
    chevrolet_id UUID; ford_id UUID; jeep_id UUID; chrysler_id UUID; dodge_id UUID; tesla_id UUID;
    -- Chinese
    chery_id UUID; mg_id UUID; byd_id UUID; geely_id UUID; brilliance_id UUID; jac_id UUID; changan_id UUID; haval_id UUID; jetour_id UUID; bestune_id UUID; baic_id UUID; dfsk_id UUID; zotye_id UUID; speranza_id UUID; greatwall_id UUID; proton_id UUID;
BEGIN
    -- Fetch IDs
    SELECT id INTO toyota_id FROM public.car_brands WHERE name = 'Toyota';
    SELECT id INTO nissan_id FROM public.car_brands WHERE name = 'Nissan';
    SELECT id INTO honda_id FROM public.car_brands WHERE name = 'Honda';
    SELECT id INTO mitsubishi_id FROM public.car_brands WHERE name = 'Mitsubishi';
    SELECT id INTO suzuki_id FROM public.car_brands WHERE name = 'Suzuki';
    SELECT id INTO mazda_id FROM public.car_brands WHERE name = 'Mazda';
    SELECT id INTO subaru_id FROM public.car_brands WHERE name = 'Subaru';
    SELECT id INTO lexus_id FROM public.car_brands WHERE name = 'Lexus';
    SELECT id INTO daihatsu_id FROM public.car_brands WHERE name = 'Daihatsu';
    SELECT id INTO isuzu_id FROM public.car_brands WHERE name = 'Isuzu';

    SELECT id INTO hyundai_id FROM public.car_brands WHERE name = 'Hyundai';
    SELECT id INTO kia_id FROM public.car_brands WHERE name = 'Kia';
    SELECT id INTO ssangyong_id FROM public.car_brands WHERE name = 'SsangYong';
    SELECT id INTO daewoo_id FROM public.car_brands WHERE name = 'Daewoo';

    SELECT id INTO mercedes_id FROM public.car_brands WHERE name = 'Mercedes-Benz';
    SELECT id INTO bmw_id FROM public.car_brands WHERE name = 'BMW';
    SELECT id INTO audi_id FROM public.car_brands WHERE name = 'Audi';
    SELECT id INTO vw_id FROM public.car_brands WHERE name = 'Volkswagen';
    SELECT id INTO opel_id FROM public.car_brands WHERE name = 'Opel';
    SELECT id INTO porsche_id FROM public.car_brands WHERE name = 'Porsche';

    SELECT id INTO renault_id FROM public.car_brands WHERE name = 'Renault';
    SELECT id INTO peugeot_id FROM public.car_brands WHERE name = 'Peugeot';
    SELECT id INTO citroen_id FROM public.car_brands WHERE name = 'Citroen';
    SELECT id INTO ds_id FROM public.car_brands WHERE name = 'DS';

    SELECT id INTO fiat_id FROM public.car_brands WHERE name = 'Fiat';
    SELECT id INTO alfa_id FROM public.car_brands WHERE name = 'Alfa Romeo';

    SELECT id INTO skoda_id FROM public.car_brands WHERE name = 'Skoda';
    SELECT id INTO seat_id FROM public.car_brands WHERE name = 'Seat';
    SELECT id INTO volvo_id FROM public.car_brands WHERE name = 'Volvo';
    SELECT id INTO landrover_id FROM public.car_brands WHERE name = 'Land Rover';
    SELECT id INTO jaguar_id FROM public.car_brands WHERE name = 'Jaguar';
    SELECT id INTO mini_id FROM public.car_brands WHERE name = 'Mini';
    SELECT id INTO lada_id FROM public.car_brands WHERE name = 'Lada';

    SELECT id INTO chevrolet_id FROM public.car_brands WHERE name = 'Chevrolet';
    SELECT id INTO ford_id FROM public.car_brands WHERE name = 'Ford';
    SELECT id INTO jeep_id FROM public.car_brands WHERE name = 'Jeep';
    SELECT id INTO chrysler_id FROM public.car_brands WHERE name = 'Chrysler';
    SELECT id INTO dodge_id FROM public.car_brands WHERE name = 'Dodge';
    SELECT id INTO tesla_id FROM public.car_brands WHERE name = 'Tesla';

    SELECT id INTO chery_id FROM public.car_brands WHERE name = 'Chery';
    SELECT id INTO mg_id FROM public.car_brands WHERE name = 'MG';
    SELECT id INTO byd_id FROM public.car_brands WHERE name = 'BYD';
    SELECT id INTO geely_id FROM public.car_brands WHERE name = 'Geely';
    SELECT id INTO brilliance_id FROM public.car_brands WHERE name = 'Brilliance';
    SELECT id INTO jac_id FROM public.car_brands WHERE name = 'JAC';
    SELECT id INTO changan_id FROM public.car_brands WHERE name = 'Changan';
    SELECT id INTO haval_id FROM public.car_brands WHERE name = 'Haval';
    SELECT id INTO jetour_id FROM public.car_brands WHERE name = 'Jetour';
    SELECT id INTO bestune_id FROM public.car_brands WHERE name = 'Bestune';
    SELECT id INTO baic_id FROM public.car_brands WHERE name = 'Baic';
    SELECT id INTO dfsk_id FROM public.car_brands WHERE name = 'DFSK';
    SELECT id INTO zotye_id FROM public.car_brands WHERE name = 'Zotye';
    SELECT id INTO speranza_id FROM public.car_brands WHERE name = 'Speranza';
    SELECT id INTO greatwall_id FROM public.car_brands WHERE name = 'Great Wall';
    SELECT id INTO proton_id FROM public.car_brands WHERE name = 'Proton';


    -- ==========================================
    -- JAPANESE
    -- ==========================================
    -- Toyota
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (toyota_id, 'Corolla', 1995, 2025, 7.0),
    (toyota_id, 'Yaris', 2006, 2025, 5.5),
    (toyota_id, 'Yaris Sedan', 2006, 2015, 6.0),
    (toyota_id, 'Belta', 2022, 2025, 5.1),
    (toyota_id, 'Rumion', 2022, 2025, 6.2),
    (toyota_id, 'Fortuner', 2012, 2025, 10.5),
    (toyota_id, 'Land Cruiser', 1995, 2025, 13.0),
    (toyota_id, 'Prado', 2005, 2025, 11.5),
    (toyota_id, 'C-HR', 2017, 2023, 5.9),
    (toyota_id, 'Rush', 2018, 2023, 6.6),
    (toyota_id, 'Avanza', 2006, 2015, 7.5),
    (toyota_id, 'Camry', 1995, 2020, 8.5),
    (toyota_id, 'Echo', 2000, 2005, 5.5),
    (toyota_id, 'Tercel', 1995, 1999, 6.5),
    (toyota_id, 'Starlet', 1995, 1999, 6.0),
    (toyota_id, 'Hiace', 1995, 2025, 9.0),
    (toyota_id, 'Hilux', 1995, 2025, 8.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Nissan
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (nissan_id, 'Sunny', 1995, 2025, 7.2),
    (nissan_id, 'Sentra', 2014, 2025, 8.0),
    (nissan_id, 'Qashqai', 2012, 2025, 6.5),
    (nissan_id, 'Juke', 2011, 2025, 6.3),
    (nissan_id, 'Tiida', 2006, 2013, 7.2),
    (nissan_id, 'X-Trail', 2002, 2025, 8.5),
    (nissan_id, 'Patrol', 1995, 2025, 14.0),
    (nissan_id, 'Murano', 2005, 2015, 10.5),
    (nissan_id, 'Pathfinder', 1998, 2015, 11.0),
    (nissan_id, 'Livina', 2008, 2012, 7.0),
    (nissan_id, 'Bluebird', 1995, 2000, 8.0),
    (nissan_id, 'Maxima', 1995, 2005, 9.5),
    (nissan_id, 'Pickup', 1995, 2025, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Honda
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (honda_id, 'Civic', 1995, 2025, 7.0),
    (honda_id, 'City', 2004, 2025, 6.5),
    (honda_id, 'Accord', 1995, 2025, 8.5),
    (honda_id, 'CR-V', 1998, 2025, 8.5),
    (honda_id, 'HR-V', 2019, 2025, 6.5),
    (honda_id, 'Jazz', 2002, 2015, 6.0),
    (honda_id, 'Pilot', 2008, 2015, 11.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Mitsubishi
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (mitsubishi_id, 'Lancer', 1995, 2018, 7.6),
    (mitsubishi_id, 'Pajero', 1995, 2020, 12.0),
    (mitsubishi_id, 'Eclipse Cross', 2018, 2025, 7.5),
    (mitsubishi_id, 'Xpander', 2019, 2025, 7.2),
    (mitsubishi_id, 'Attrage', 2014, 2025, 5.5),
    (mitsubishi_id, 'Mirage', 2014, 2025, 5.2),
    (mitsubishi_id, 'Galant', 1995, 2005, 9.0),
    (mitsubishi_id, 'Outlander', 2005, 2015, 9.5),
    (mitsubishi_id, 'Grandis', 2005, 2010, 9.5),
    (mitsubishi_id, 'Colt', 1995, 2000, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Suzuki
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (suzuki_id, 'Swift', 1995, 2025, 5.8),
    (suzuki_id, 'Alto', 2005, 2025, 4.5),
    (suzuki_id, 'Maruti', 1995, 2010, 5.0),
    (suzuki_id, 'Ciaz', 2015, 2025, 5.4),
    (suzuki_id, 'Ertiga', 2015, 2025, 6.6),
    (suzuki_id, 'Dzire', 2018, 2025, 5.0),
    (suzuki_id, 'Baleno', 2016, 2025, 5.2),
    (suzuki_id, 'S-Presso', 2020, 2025, 4.6),
    (suzuki_id, 'Celerio', 2015, 2025, 4.3),
    (suzuki_id, 'Vitara', 1998, 2025, 7.5),
    (suzuki_id, 'Grand Vitara', 2005, 2025, 8.5),
    (suzuki_id, 'Jimny', 2023, 2025, 7.0),
    (suzuki_id, 'SX4', 2008, 2014, 7.2),
    (suzuki_id, 'Van', 1995, 2025, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Mazda
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (mazda_id, '3', 2005, 2025, 7.0),
    (mazda_id, '323', 1995, 2003, 7.5),
    (mazda_id, '6', 2005, 2015, 8.0),
    (mazda_id, '626', 1995, 2002, 8.5),
    (mazda_id, 'CX-3', 2018, 2023, 6.5),
    (mazda_id, 'CX-5', 2018, 2023, 7.5),
    (mazda_id, 'CX-9', 2018, 2023, 9.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Subaru
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (subaru_id, 'Impreza', 2000, 2020, 8.0),
    (subaru_id, 'XV', 2012, 2025, 7.5),
    (subaru_id, 'Forester', 2015, 2025, 8.5),
    (subaru_id, 'Legacy', 2000, 2010, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Daihatsu
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (daihatsu_id, 'Charade', 1995, 2000, 6.0),
    (daihatsu_id, 'Terios', 1998, 2015, 7.5),
    (daihatsu_id, 'Sirion', 2000, 2010, 6.0),
    (daihatsu_id, 'Grand Terios', 2008, 2015, 8.0),
    (daihatsu_id, 'Materia', 2007, 2011, 7.0),
    (daihatsu_id, 'Mira', 1998, 2005, 5.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- KOREAN
    -- ==========================================
    -- Hyundai
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (hyundai_id, 'Verna', 2004, 2019, 7.5),
    (hyundai_id, 'Accent', 1995, 2010, 7.0),
    (hyundai_id, 'Accent RB', 2011, 2025, 6.8),
    (hyundai_id, 'Accent HCI', 2018, 2023, 6.6),
    (hyundai_id, 'Elantra', 1995, 2006, 7.5),
    (hyundai_id, 'Elantra HD', 2007, 2025, 7.2),
    (hyundai_id, 'Elantra MD', 2012, 2016, 7.0),
    (hyundai_id, 'Elantra AD', 2017, 2020, 6.9),
    (hyundai_id, 'Elantra CN7', 2021, 2025, 6.9),
    (hyundai_id, 'Tucson', 2005, 2025, 8.5),
    (hyundai_id, 'Creta', 2016, 2025, 7.1),
    (hyundai_id, 'Matrix', 2001, 2011, 8.5),
    (hyundai_id, 'Getz', 2003, 2011, 6.5),
    (hyundai_id, 'i10', 2008, 2025, 5.9),
    (hyundai_id, 'Grand i10', 2014, 2020, 6.0),
    (hyundai_id, 'i20', 2009, 2025, 6.2),
    (hyundai_id, 'i30', 2009, 2015, 7.0),
    (hyundai_id, 'ix35', 2010, 2016, 8.2),
    (hyundai_id, 'Sonata', 1995, 2020, 9.0),
    (hyundai_id, 'Excel', 1995, 1999, 8.0),
    (hyundai_id, 'Atos', 1998, 2008, 6.0),
    (hyundai_id, 'Santa Fe', 2006, 2020, 10.5),
    (hyundai_id, 'H1', 2008, 2020, 10.0),
    (hyundai_id, 'Bayon', 2022, 2025, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Kia
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (kia_id, 'Cerato', 2004, 2025, 7.2),
    (kia_id, 'Sportage', 2011, 2025, 8.0),
    (kia_id, 'Picanto', 2004, 2025, 5.5),
    (kia_id, 'Rio', 2001, 2020, 6.5),
    (kia_id, 'Carens', 2003, 2015, 8.5),
    (kia_id, 'Soul', 2010, 2020, 7.5),
    (kia_id, 'Sorento', 2005, 2025, 10.5),
    (kia_id, 'Carnival', 2000, 2020, 11.0),
    (kia_id, 'Spectra', 2001, 2005, 8.0),
    (kia_id, 'Pride', 1995, 2000, 6.5),
    (kia_id, 'Saipa', 1995, 2010, 6.0), -- Often listed under Kia/Pride
    (kia_id, 'Xceed', 2021, 2025, 6.5),
    (kia_id, 'Ceed', 2015, 2020, 6.8) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Daewoo
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (daewoo_id, 'Lanos', 1997, 2008, 7.9),
    (daewoo_id, 'Nubira', 1997, 2008, 8.5),
    (daewoo_id, 'Leganza', 1997, 2002, 9.5),
    (daewoo_id, 'Matiz', 1998, 2005, 6.4),
    (daewoo_id, 'Espero', 1995, 1999, 9.0),
    (daewoo_id, 'Tico', 1995, 2000, 5.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- EUROPEAN (German)
    -- ==========================================
    -- Mercedes-Benz
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (mercedes_id, 'C 180', 1995, 2025, 7.5),
    (mercedes_id, 'C 200', 1995, 2025, 7.8),
    (mercedes_id, 'E 200', 1995, 2025, 8.2),
    (mercedes_id, 'E 240', 1998, 2005, 10.0),
    (mercedes_id, 'E 300', 2010, 2025, 8.5),
    (mercedes_id, 'S 320', 1995, 2005, 11.5),
    (mercedes_id, 'S 400', 2014, 2025, 9.0),
    (mercedes_id, 'S 500', 1995, 2025, 12.0),
    (mercedes_id, 'A 180', 2013, 2025, 6.0),
    (mercedes_id, 'A 200', 2013, 2025, 6.2),
    (mercedes_id, 'B 180', 2012, 2025, 6.5),
    (mercedes_id, 'CLA 180', 2014, 2025, 6.2),
    (mercedes_id, 'CLA 200', 2014, 2025, 6.5),
    (mercedes_id, 'GLA 200', 2015, 2025, 7.0),
    (mercedes_id, 'GLC 200', 2016, 2025, 8.0),
    (mercedes_id, 'GLC 300', 2016, 2025, 8.5),
    (mercedes_id, 'E 180', 2017, 2025, 7.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- BMW
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (bmw_id, '316i', 1995, 2015, 7.5),
    (bmw_id, '318i', 1995, 2025, 7.2),
    (bmw_id, '320i', 1995, 2025, 7.0),
    (bmw_id, '328i', 1995, 2015, 8.5),
    (bmw_id, '330i', 2000, 2025, 8.0),
    (bmw_id, '520i', 1995, 2025, 8.0),
    (bmw_id, '523i', 1996, 2010, 9.0),
    (bmw_id, '525i', 1995, 2010, 9.5),
    (bmw_id, '528i', 1996, 2016, 9.0),
    (bmw_id, '530i', 2000, 2025, 8.5),
    (bmw_id, '740i', 1995, 2025, 11.0),
    (bmw_id, 'X1', 2010, 2025, 7.5),
    (bmw_id, 'X3', 2004, 2025, 8.5),
    (bmw_id, 'X5', 2000, 2025, 10.5),
    (bmw_id, 'X6', 2008, 2025, 11.0),
    (bmw_id, '116i', 2005, 2015, 6.5),
    (bmw_id, '118i', 2005, 2025, 6.2),
    (bmw_id, '218i', 2015, 2025, 6.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Volkswagen
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (vw_id, 'Golf 4', 1998, 2004, 7.8),
    (vw_id, 'Golf 5', 2004, 2009, 7.5),
    (vw_id, 'Golf 6', 2009, 2013, 7.0),
    (vw_id, 'Golf 7', 2013, 2020, 6.5),
    (vw_id, 'Golf 8', 2021, 2025, 6.2),
    (vw_id, 'Polo', 1995, 2025, 6.0),
    (vw_id, 'Passat', 1997, 2025, 7.8),
    (vw_id, 'Jetta', 2006, 2018, 7.5),
    (vw_id, 'Bora', 1999, 2005, 8.0),
    (vw_id, 'Tiguan', 2008, 2025, 8.5),
    (vw_id, 'Touareg', 2004, 2025, 11.0),
    (vw_id, 'Scirocco', 2009, 2016, 7.5),
    (vw_id, 'CC', 2009, 2017, 8.0),
    (vw_id, 'T-Roc', 2020, 2025, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Opel
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (opel_id, 'Vectra', 1996, 2008, 8.5),
    (opel_id, 'Astra', 1999, 2022, 7.0),
    (opel_id, 'Corsa', 1995, 2025, 5.5),
    (opel_id, 'Insignia', 2009, 2020, 7.8),
    (opel_id, 'Mokka', 2014, 2025, 6.0),
    (opel_id, 'Crossland', 2018, 2025, 6.2),
    (opel_id, 'Grandland', 2018, 2025, 7.0),
    (opel_id, 'Meriva', 2004, 2015, 7.0),
    (opel_id, 'Zafira', 2000, 2014, 8.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- EUROPEAN (French)
    -- ==========================================
    -- Renault
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (renault_id, 'Logan', 2009, 2025, 6.8),
    (renault_id, 'Sandero', 2010, 2025, 6.8),
    (renault_id, 'Stepway', 2012, 2025, 7.2),
    (renault_id, 'Megane', 1998, 2025, 7.5),
    (renault_id, 'Fluence', 2010, 2017, 7.5),
    (renault_id, 'Clio', 2000, 2015, 6.0),
    (renault_id, 'Duster', 2011, 2025, 7.8),
    (renault_id, 'Kadjar', 2016, 2022, 6.5),
    (renault_id, 'Captur', 2014, 2025, 6.2),
    (renault_id, 'Symbol', 2009, 2013, 6.5),
    (renault_id, 'Rainbow', 1997, 2000, 7.5),
    (renault_id, 'Austral', 2023, 2025, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Peugeot
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (peugeot_id, '301', 2013, 2025, 6.5),
    (peugeot_id, '508', 2012, 2025, 7.5),
    (peugeot_id, '3008', 2010, 2025, 7.5),
    (peugeot_id, '5008', 2011, 2025, 7.8),
    (peugeot_id, '2008', 2014, 2025, 6.5),
    (peugeot_id, '405', 1995, 2005, 8.5),
    (peugeot_id, '406', 1997, 2004, 8.5),
    (peugeot_id, '307', 2002, 2008, 7.5),
    (peugeot_id, '308', 2009, 2015, 7.2),
    (peugeot_id, '206', 2000, 2009, 6.5),
    (peugeot_id, '207', 2007, 2012, 6.8),
    (peugeot_id, '208', 2013, 2020, 6.2) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Citroen
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (citroen_id, 'C3', 2003, 2025, 6.0),
    (citroen_id, 'C4', 2005, 2025, 7.0),
    (citroen_id, 'C5', 2002, 2018, 8.0),
    (citroen_id, 'C-Elysee', 2013, 2025, 6.5),
    (citroen_id, 'C3 Aircross', 2018, 2025, 6.5),
    (citroen_id, 'C4 Picasso', 2008, 2018, 7.5),
    (citroen_id, 'C5 Aircross', 2019, 2025, 7.2),
    (citroen_id, 'Xsara', 1998, 2004, 7.5),
    (citroen_id, 'AX', 1995, 1998, 5.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- EUROPEAN (Italian & Other)
    -- ==========================================
    -- Fiat
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (fiat_id, '128', 1995, 2006, 6.7),
    (fiat_id, 'Shahin', 1995, 2009, 8.5),
    (fiat_id, 'Uno', 1995, 2002, 6.0),
    (fiat_id, 'Punto', 1995, 2015, 6.5),
    (fiat_id, 'Siena', 2000, 2008, 7.2),
    (fiat_id, 'Albea', 2003, 2010, 7.0),
    (fiat_id, 'Linea', 2008, 2016, 7.2),
    (fiat_id, 'Tipo', 2016, 2025, 6.3),
    (fiat_id, '500', 2008, 2025, 5.8),
    (fiat_id, '500X', 2016, 2023, 7.0),
    (fiat_id, 'Palio', 1998, 2006, 7.0),
    (fiat_id, 'Tempra', 1995, 2000, 8.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Skoda
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (skoda_id, 'Octavia A4', 1998, 2009, 7.5),
    (skoda_id, 'Octavia A5', 2005, 2013, 7.2),
    (skoda_id, 'Octavia A7', 2014, 2020, 6.5),
    (skoda_id, 'Octavia A8', 2021, 2025, 6.0),
    (skoda_id, 'Fabia', 2001, 2015, 6.5),
    (skoda_id, 'Rapid', 2013, 2019, 6.8),
    (skoda_id, 'Superb', 2005, 2025, 7.8),
    (skoda_id, 'Yeti', 2010, 2017, 7.5),
    (skoda_id, 'Kodiaq', 2017, 2025, 7.2),
    (skoda_id, 'Karoq', 2018, 2025, 6.8),
    (skoda_id, 'Kamiq', 2020, 2025, 6.2),
    (skoda_id, 'Felicia', 1995, 2001, 7.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Seat
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (seat_id, 'Ibiza', 1995, 2025, 6.5),
    (seat_id, 'Leon', 2000, 2025, 7.0),
    (seat_id, 'Toledo', 2000, 2018, 7.5),
    (seat_id, 'Ateca', 2017, 2025, 7.2),
    (seat_id, 'Arona', 2018, 2025, 6.5),
    (seat_id, 'Tarraco', 2019, 2025, 7.8),
    (seat_id, 'Cordoba', 1998, 2009, 7.2) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Lada
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (lada_id, '2107', 1995, 2012, 9.0),
    (lada_id, '2105', 1995, 2005, 9.0),
    (lada_id, '2110', 2005, 2010, 8.0),
    (lada_id, 'Granta', 2015, 2025, 7.2),
    (lada_id, 'Largus', 2018, 2022, 8.5),
    (lada_id, 'Samara', 1995, 2005, 8.0),
    (lada_id, 'Niva', 1995, 2015, 11.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- AMERICAN
    -- ==========================================
    -- Chevrolet
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (chevrolet_id, 'Lanos', 2009, 2020, 7.9),
    (chevrolet_id, 'Aveo', 2004, 2018, 7.2),
    (chevrolet_id, 'Optra', 2005, 2025, 7.3),
    (chevrolet_id, 'Cruze', 2010, 2017, 8.0),
    (chevrolet_id, 'Captiva', 2007, 2025, 8.4),
    (chevrolet_id, 'Spark', 2008, 2015, 5.5),
    (chevrolet_id, 'Sonic', 2012, 2015, 7.0),
    (chevrolet_id, 'Equinox', 2018, 2021, 8.0),
    (chevrolet_id, 'Malibu', 2019, 2021, 7.5),
    (chevrolet_id, 'Blazer', 1995, 2005, 13.0),
    (chevrolet_id, 'N300', 2012, 2025, 8.0),
    (chevrolet_id, 'TFR Pickup', 1995, 2025, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Jeep
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (jeep_id, 'Cherokee', 1995, 2001, 14.0),
    (jeep_id, 'Liberty', 2002, 2007, 13.0),
    (jeep_id, 'Grand Cherokee', 1995, 2025, 12.5),
    (jeep_id, 'Renegade', 2016, 2025, 7.5),
    (jeep_id, 'Wrangler', 1995, 2025, 13.5),
    (jeep_id, 'Compass', 2018, 2025, 8.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Ford
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (ford_id, 'Focus', 2000, 2020, 7.5),
    (ford_id, 'Fiesta', 2000, 2018, 6.5),
    (ford_id, 'Mondeo', 1998, 2015, 8.5),
    (ford_id, 'Fusion', 2014, 2018, 8.0),
    (ford_id, 'Kuga', 2014, 2020, 8.5),
    (ford_id, 'EcoSport', 2014, 2022, 7.2),
    (ford_id, 'Escort', 1995, 2000, 7.5),
    (ford_id, 'Expedition', 2000, 2020, 14.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- CHINESE
    -- ==========================================
    -- Chery / Speranza
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (speranza_id, 'A113', 2007, 2014, 6.5),
    (speranza_id, 'A516', 2006, 2013, 8.0),
    (speranza_id, 'A620', 2007, 2012, 8.5),
    (speranza_id, 'Tiggo', 2008, 2015, 8.2),
    (speranza_id, 'M11', 2010, 2014, 7.5),
    (speranza_id, 'M12', 2010, 2014, 7.5),
    (chery_id, 'Arrizo 5', 2016, 2025, 7.0),
    (chery_id, 'Tiggo 3', 2016, 2025, 7.9),
    (chery_id, 'Tiggo 4', 2019, 2025, 7.5),
    (chery_id, 'Tiggo 7', 2019, 2025, 7.4),
    (chery_id, 'Tiggo 8', 2020, 2025, 7.8),
    (chery_id, 'Envy', 2013, 2018, 6.8) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- MG
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (mg_id, 'MG 5', 2020, 2025, 5.8),
    (mg_id, 'MG 6', 2019, 2025, 6.8),
    (mg_id, 'MG ZS', 2019, 2025, 6.3),
    (mg_id, 'MG RX5', 2018, 2025, 7.5),
    (mg_id, 'MG HS', 2020, 2025, 7.8),
    (mg_id, 'MG 3', 2012, 2016, 6.5),
    (mg_id, 'MG 350', 2012, 2016, 7.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- BYD
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (byd_id, 'F3', 2006, 2025, 6.3),
    (byd_id, 'L3', 2015, 2022, 6.5),
    (byd_id, 'S5', 2018, 2020, 8.0),
    (byd_id, 'F0', 2010, 2015, 5.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Geely
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (geely_id, 'Emgrand 7', 2013, 2019, 8.0),
    (geely_id, 'Emgrand X7', 2015, 2019, 9.0),
    (geely_id, 'Pandino', 2010, 2015, 6.5),
    (geely_id, 'MK', 2008, 2012, 7.0),
    (geely_id, 'Coolray', 2021, 2025, 6.6),
    (geely_id, 'Okavango', 2021, 2025, 7.8),
    (geely_id, 'GX3 Pro', 2023, 2025, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Brilliance
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (brilliance_id, 'Galena', 2006, 2012, 9.5),
    (brilliance_id, 'Splendor', 2008, 2012, 8.5),
    (brilliance_id, 'FRV', 2009, 2015, 7.5),
    (brilliance_id, 'FSV', 2010, 2015, 7.5),
    (brilliance_id, 'V5', 2013, 2018, 8.0),
    (brilliance_id, 'V6', 2018, 2020, 8.2) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- JAC
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (jac_id, 'J7', 2020, 2025, 7.0),
    (jac_id, 'JS3', 2020, 2025, 6.5),
    (jac_id, 'JS4', 2020, 2025, 7.2),
    (jac_id, 'S2', 2016, 2020, 6.5),
    (jac_id, 'S3', 2015, 2020, 7.0),
    (jac_id, 'B15', 2011, 2014, 7.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Proton
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (proton_id, 'Gen-2', 2006, 2016, 7.5),
    (proton_id, 'Persona', 2009, 2016, 7.5),
    (proton_id, 'Saga', 2010, 2025, 6.5),
    (proton_id, 'Waja', 2005, 2010, 8.0),
    (proton_id, 'Exora', 2019, 2022, 8.5),
    (proton_id, 'Preve', 2019, 2020, 7.8) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- ==========================================
    -- MISSING BRANDS (Volvo, Zotye, etc.)
    -- ==========================================

    -- Volvo
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (volvo_id, 'S60', 2000, 2025, 7.5),
    (volvo_id, 'S80', 1998, 2016, 8.5),
    (volvo_id, 'S90', 2016, 2025, 7.2),
    (volvo_id, 'XC40', 2017, 2025, 7.0),
    (volvo_id, 'XC60', 2008, 2025, 8.0),
    (volvo_id, 'XC90', 2002, 2025, 9.5),
    (volvo_id, 'V60', 2010, 2025, 7.5),
    (volvo_id, 'V40', 2012, 2019, 6.5),
    (volvo_id, '240', 1995, 1993, 10.0), -- Classic
    (volvo_id, '740', 1995, 1992, 11.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING; -- Classic

    -- Zotye
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (zotye_id, 'T600', 2013, 2020, 8.5),
    (zotye_id, 'SR7', 2016, 2020, 7.5),
    (zotye_id, 'SR9', 2017, 2020, 8.0),
    (zotye_id, 'Z100', 2013, 2018, 5.5),
    (zotye_id, 'Z300', 2012, 2018, 7.0),
    (zotye_id, 'T300', 2017, 2021, 7.2),
    (zotye_id, 'Explosion', 2008, 2013, 6.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- SsangYong
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (ssangyong_id, 'Tivoli', 2015, 2025, 7.2),
    (ssangyong_id, 'XLV', 2016, 2025, 7.5),
    (ssangyong_id, 'Korando', 1995, 2025, 8.5),
    (ssangyong_id, 'Musso', 1995, 2005, 10.0),
    (ssangyong_id, 'Rexton', 2001, 2025, 9.5),
    (ssangyong_id, 'Kyron', 2005, 2014, 9.0),
    (ssangyong_id, 'Actyon', 2005, 2018, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Land Rover
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (landrover_id, 'Range Rover', 1995, 2025, 12.5),
    (landrover_id, 'Range Rover Sport', 2005, 2025, 11.5),
    (landrover_id, 'Range Rover Evoque', 2011, 2025, 8.5),
    (landrover_id, 'Range Rover Velar', 2017, 2025, 9.0),
    (landrover_id, 'Discovery', 1995, 2025, 11.0),
    (landrover_id, 'Discovery Sport', 2014, 2025, 8.5),
    (landrover_id, 'Defender', 1995, 2025, 11.5),
    (landrover_id, 'Freelander', 1997, 2014, 9.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Jaguar
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (jaguar_id, 'XF', 2007, 2025, 8.5),
    (jaguar_id, 'XJ', 1995, 2019, 10.5),
    (jaguar_id, 'XE', 2015, 2025, 7.5),
    (jaguar_id, 'F-Pace', 2016, 2025, 8.5),
    (jaguar_id, 'E-Pace', 2017, 2025, 8.0),
    (jaguar_id, 'F-Type', 2013, 2025, 11.0),
    (jaguar_id, 'S-Type', 1999, 2008, 10.0),
    (jaguar_id, 'X-Type', 2001, 2009, 9.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Mini
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (mini_id, 'Cooper', 2001, 2025, 6.5),
    (mini_id, 'Cooper S', 2001, 2025, 7.5),
    (mini_id, 'Countryman', 2010, 2025, 7.0),
    (mini_id, 'Clubman', 2007, 2025, 6.8),
    (mini_id, 'Paceman', 2012, 2016, 7.2) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Chrysler
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (chrysler_id, '300C', 2004, 2023, 11.0),
    (chrysler_id, 'Pacifica', 2003, 2025, 10.5),
    (chrysler_id, 'Voyager', 1995, 2020, 11.0),
    (chrysler_id, 'PT Cruiser', 2000, 2010, 9.5),
    (chrysler_id, 'Sebring', 1995, 2010, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Dodge
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (dodge_id, 'Charger', 2005, 2025, 12.0),
    (dodge_id, 'Challenger', 2008, 2025, 13.0),
    (dodge_id, 'Durango', 1997, 2025, 13.5),
    (dodge_id, 'Dart', 2012, 2016, 8.0),
    (dodge_id, 'Ram', 1995, 2025, 15.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Tesla
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (tesla_id, 'Model S', 2012, 2025, 0.0),
    (tesla_id, 'Model 3', 2017, 2025, 0.0),
    (tesla_id, 'Model X', 2015, 2025, 0.0),
    (tesla_id, 'Model Y', 2020, 2025, 0.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Changan
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (changan_id, 'CS15', 2016, 2025, 6.5),
    (changan_id, 'CS35', 2012, 2025, 7.0),
    (changan_id, 'CS35 Plus', 2018, 2025, 7.2),
    (changan_id, 'CS55', 2017, 2025, 7.5),
    (changan_id, 'CS55 Plus', 2019, 2025, 7.6),
    (changan_id, 'CS75', 2013, 2025, 8.0),
    (changan_id, 'CS75 Plus', 2019, 2025, 8.2),
    (changan_id, 'CS85', 2019, 2025, 8.5),
    (changan_id, 'CS95', 2017, 2025, 10.0),
    (changan_id, 'Eado', 2012, 2025, 7.0),
    (changan_id, 'Alsvin', 2009, 2025, 6.5),
    (changan_id, 'Uni-T', 2020, 2025, 7.5),
    (changan_id, 'Uni-K', 2020, 2025, 8.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Haval
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (haval_id, 'H6', 2011, 2025, 8.5),
    (haval_id, 'Jolion', 2020, 2025, 7.5),
    (haval_id, 'H2', 2014, 2021, 8.0),
    (haval_id, 'H9', 2014, 2025, 11.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Jetour
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (jetour_id, 'X70', 2018, 2025, 8.0),
    (jetour_id, 'X70 Plus', 2020, 2025, 8.2),
    (jetour_id, 'X90', 2019, 2025, 8.5),
    (jetour_id, 'X95', 2019, 2025, 9.0),
    (jetour_id, 'Dashing', 2022, 2025, 7.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Bestune
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (bestune_id, 'T33', 2019, 2025, 7.0),
    (bestune_id, 'T55', 2021, 2025, 7.2),
    (bestune_id, 'T77', 2018, 2025, 7.5),
    (bestune_id, 'B70', 2006, 2025, 7.8) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Baic
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (baic_id, 'X3', 2016, 2025, 7.0),
    (baic_id, 'X5', 2016, 2025, 7.5),
    (baic_id, 'X7', 2020, 2025, 8.0),
    (baic_id, 'BJ40', 2013, 2025, 11.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- DFSK
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (dfsk_id, 'Glory 330', 2014, 2025, 7.5),
    (dfsk_id, 'Glory 580', 2016, 2025, 8.0),
    (dfsk_id, 'Glory Eagle 580', 2018, 2025, 8.2),
    (dfsk_id, 'Glory IX5', 2018, 2025, 8.5) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

    -- Great Wall
    INSERT INTO public.car_models (brand_id, name, year_start, year_end, avg_fuel_consumption) VALUES
    (greatwall_id, 'Peri', 2008, 2010, 6.0),
    (greatwall_id, 'Hover', 2005, 2015, 10.0),
    (greatwall_id, 'C30', 2010, 2016, 7.0),
    (greatwall_id, 'Wingle 5', 2010, 2025, 9.0) ON CONFLICT (brand_id, name, year_start, year_end) DO NOTHING;

END $$;
