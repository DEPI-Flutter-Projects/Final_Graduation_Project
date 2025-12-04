-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES TABLE
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique,
  current_vehicle_id uuid, -- references user_vehicles(id) but nullable initially
  total_savings_egp numeric default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- USER VEHICLES TABLE
create table public.user_vehicles (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  car_brand text not null,
  car_model text not null,
  manufacture_year int not null,
  avg_consumption numeric not null, -- Liters per 100km
  fuel_type int not null, -- 80, 92, or 95
  nickname text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS POLICIES (Row Level Security)
alter table public.profiles enable row level security;
alter table public.user_vehicles enable row level security;

-- Profiles: Public read, Self update
create policy "Public profiles are viewable by everyone."
  on public.profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on public.profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on public.profiles for update
  using ( auth.uid() = id );

-- Vehicles: Private (Self only)
create policy "Users can view own vehicles."
  on public.user_vehicles for select
  using ( auth.uid() = user_id );

create policy "Users can insert own vehicles."
  on public.user_vehicles for insert
  with check ( auth.uid() = user_id );

create policy "Users can update own vehicles."
  on public.user_vehicles for update
  using ( auth.uid() = user_id );

create policy "Users can delete own vehicles."
  on public.user_vehicles for delete
  using ( auth.uid() = user_id );

-- Function to handle new user signup (Trigger)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data->>'username');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
