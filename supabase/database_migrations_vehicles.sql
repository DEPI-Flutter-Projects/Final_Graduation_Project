-- Vehicles table
CREATE TABLE IF NOT EXISTS public.vehicles (
  vehicle_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  efficiency NUMERIC NOT NULL, -- km per liter
  fuel_type TEXT NOT NULL CHECK (fuel_type IN ('petrol', 'diesel', 'electric')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Vehicle labels (many-to-many)
CREATE TABLE IF NOT EXISTS public.vehicle_labels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vehicle_id UUID REFERENCES public.vehicles(vehicle_id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Add default_vehicle_id to user_preferences
ALTER TABLE public.user_preferences
  ADD COLUMN IF NOT EXISTS default_vehicle_id UUID REFERENCES public.vehicles(vehicle_id);

-- Enable RLS for new tables
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_labels ENABLE ROW LEVEL SECURITY;

-- Policies for vehicles
CREATE POLICY "Users can select vehicles" ON public.vehicles FOR SELECT USING (TRUE);
CREATE POLICY "Users can insert vehicles" ON public.vehicles FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Users can update own vehicles" ON public.vehicles FOR UPDATE USING (auth.uid() = (SELECT user_id FROM public.user_preferences WHERE default_vehicle_id = vehicles.vehicle_id));

-- Policies for vehicle_labels
CREATE POLICY "Users can select their vehicle labels" ON public.vehicle_labels FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.vehicles v WHERE v.vehicle_id = vehicle_labels.vehicle_id AND EXISTS (SELECT 1 FROM public.user_preferences up WHERE up.user_id = auth.uid() AND up.default_vehicle_id = v.vehicle_id))
);
CREATE POLICY "Users can insert labels for their vehicle" ON public.vehicle_labels FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.vehicles v WHERE v.vehicle_id = NEW.vehicle_id AND EXISTS (SELECT 1 FROM public.user_preferences up WHERE up.user_id = auth.uid() AND up.default_vehicle_id = v.vehicle_id))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_vehicles_name ON public.vehicles(name);
CREATE INDEX IF NOT EXISTS idx_vehicle_labels_vehicle_id ON public.vehicle_labels(vehicle_id);
