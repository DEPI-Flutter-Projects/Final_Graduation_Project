-- User Vehicles table (linking users to car models)
CREATE TABLE IF NOT EXISTS public.user_vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  model_id UUID REFERENCES public.car_models(id) ON DELETE CASCADE,
  year INTEGER,
  label TEXT,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_vehicles ENABLE ROW LEVEL SECURITY;

-- Policies (Drop first to avoid "already exists" errors)
DROP POLICY IF EXISTS "Users can view own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can view own vehicles" ON public.user_vehicles FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can insert own vehicles" ON public.user_vehicles FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can update own vehicles" ON public.user_vehicles FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own vehicles" ON public.user_vehicles;
CREATE POLICY "Users can delete own vehicles" ON public.user_vehicles FOR DELETE USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_vehicles_user_id ON public.user_vehicles(user_id);
