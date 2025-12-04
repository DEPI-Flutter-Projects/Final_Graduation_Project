-- 1. Update Profiles Table with Stats
alter table public.profiles 
add column if not exists total_trips int default 0,
add column if not exists total_savings float default 0,
add column if not exists km_traveled float default 0,
add column if not exists avg_rating float default 5.0,
add column if not exists level int default 1,
add column if not exists current_xp int default 0,
add column if not exists next_level_xp int default 100;

-- 2. Create Achievements Table (Global Definitions)
create table if not exists public.achievements (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text not null,
  icon_name text not null, -- Flutter icon name
  color_hex text not null,
  xp_reward int default 10,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Achievements (Public Read)
alter table public.achievements enable row level security;
create policy "Achievements are viewable by everyone." on public.achievements for select using (true);


-- 3. Create User Achievements (Unlock status)
create table if not exists public.user_achievements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  achievement_id uuid references public.achievements(id) on delete cascade not null,
  unlocked_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, achievement_id)
);

-- Enable RLS for User Achievements
alter table public.user_achievements enable row level security;
create policy "Users can view own achievements" on public.user_achievements for select using (auth.uid() = user_id);


-- 4. Create User Routes (History)
create table if not exists public.user_routes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  from_location text not null,
  to_location text not null,
  distance_km float not null,
  transport_mode text not null, -- 'Car', 'Metro', 'Microbus'
  cost float not null,
  duration_minutes int not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for User Routes
alter table public.user_routes enable row level security;
create policy "Users can view own routes" on public.user_routes for select using (auth.uid() = user_id);
create policy "Users can insert own routes" on public.user_routes for insert with check (auth.uid() = user_id);


-- 5. Create User Vehicles (Garage)
create table if not exists public.user_vehicles (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  model_id uuid references public.car_models(id) on delete cascade not null,
  year int not null,
  label text default 'My Car', -- 'Work', 'Family', 'Personal'
  is_default boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for User Vehicles
alter table public.user_vehicles enable row level security;
create policy "Users can view own vehicles" on public.user_vehicles for select using (auth.uid() = user_id);
create policy "Users can insert own vehicles" on public.user_vehicles for insert with check (auth.uid() = user_id);
create policy "Users can update own vehicles" on public.user_vehicles for update using (auth.uid() = user_id);
create policy "Users can delete own vehicles" on public.user_vehicles for delete using (auth.uid() = user_id);


-- 6. Seed Achievements (Example Data)
insert into public.achievements (title, description, icon_name, color_hex) values
('First Journey', 'Completed your first calculated route', 'map', '2196F3'),
('Money Saver', 'Saved over 100 EGP', 'savings', 'FF9800'),
('Eco Warrior', 'Chose public transport 10 times', 'eco', '4CAF50'),
('Route Master', 'Optimized 5 multi-stop routes', 'alt_route', '9E9E9E'),
('Social Traveler', 'Share 10 routes with friends', 'people', '9E9E9E'),
('Weekly Planner', 'Plan routes for 7 consecutive days', 'calendar_today', '9E9E9E')
on conflict do nothing;
