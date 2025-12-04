-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 0. CLEANUP (Use with caution! This deletes existing data to ensure a fresh start)
drop table if exists public.maintenance_records cascade;
drop table if exists public.emergency_services cascade;
drop table if exists public.fuel_prices cascade;
drop table if exists public.vehicles cascade;
drop table if exists public.profiles cascade;

-- 1. PROFILES TABLE
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- 2. VEHICLES TABLE
create table public.vehicles (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  brand text not null,
  model text not null,
  year int not null,
  fuel_type text not null, -- 'Petrol 80', 'Petrol 92', 'Petrol 95', 'Diesel', 'CNG'
  avg_consumption float not null, -- Liters per 100km
  nickname text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.vehicles enable row level security;

create policy "Users can view their own vehicles."
  on vehicles for select
  using ( auth.uid() = user_id );

create policy "Users can insert their own vehicles."
  on vehicles for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own vehicles."
  on vehicles for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own vehicles."
  on vehicles for delete
  using ( auth.uid() = user_id );

-- 3. FUEL PRICES TABLE (Global Data)
create table public.fuel_prices (
  id serial primary key,
  type text unique not null,
  price float not null, -- EGP per Liter
  last_updated timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.fuel_prices enable row level security;

create policy "Fuel prices are viewable by everyone."
  on fuel_prices for select
  using ( true );

-- 4. EMERGENCY SERVICES TABLE (Global Data)
create table public.emergency_services (
  id serial primary key,
  name text not null,
  number text not null,
  icon_name text not null, -- Maps to Flutter Icons (e.g., 'medical_services')
  color_hex text not null, -- Hex color code (e.g., 'F44336')
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.emergency_services enable row level security;

create policy "Emergency services are viewable by everyone."
  on emergency_services for select
  using ( true );

-- 5. MAINTENANCE RECORDS TABLE
create table public.maintenance_records (
  id uuid default uuid_generate_v4() primary key,
  vehicle_id uuid references public.vehicles(id) on delete cascade not null,
  service_type text not null, -- 'Oil Change', 'Tire Rotation', etc.
  cost float not null,
  date date not null,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.maintenance_records enable row level security;

create policy "Users can view their own maintenance records."
  on maintenance_records for select
  using ( exists ( select 1 from vehicles where id = maintenance_records.vehicle_id and user_id = auth.uid() ) );

create policy "Users can insert their own maintenance records."
  on maintenance_records for insert
  with check ( exists ( select 1 from vehicles where id = vehicle_id and user_id = auth.uid() ) );

create policy "Users can update their own maintenance records."
  on maintenance_records for update
  using ( exists ( select 1 from vehicles where id = maintenance_records.vehicle_id and user_id = auth.uid() ) );

create policy "Users can delete their own maintenance records."
  on maintenance_records for delete
  using ( exists ( select 1 from vehicles where id = maintenance_records.vehicle_id and user_id = auth.uid() ) );


-- SEED DATA --

-- Seed Fuel Prices (Nov 2025 Data)
insert into public.fuel_prices (type, price) values
  ('Petrol 80', 17.75),
  ('Petrol 92', 19.25),
  ('Petrol 95', 21.00),
  ('Diesel', 17.50),
  ('CNG', 10.00)
on conflict (type) do update set price = excluded.price, last_updated = now();

-- Seed Emergency Services
insert into public.emergency_services (name, number, icon_name, color_hex) values
  ('Ambulance', '123', 'medical_services', 'F44336'), -- Red
  ('Police', '122', 'local_police', '2196F3'), -- Blue
  ('Fire Dept', '180', 'fire_truck', 'FF9800'), -- Orange
  ('Roadside Assist', '12345', 'car_repair', '4CAF50'), -- Green
  ('Electricity Emergency', '121', 'electric_bolt', 'FFC107'), -- Amber
  ('Natural Gas Emergency', '129', 'gas_meter', '00BCD4') -- Cyan
on conflict do nothing;

-- Function to handle new user signup (automatically create profile)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
