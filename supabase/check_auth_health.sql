create table if not exists public.user_preferences (
  user_id uuid references auth.users not null primary key,
  default_transport_mode text default 'Car',
  distance_unit text default 'KM',
  currency text default 'EGP',
  language text default 'English',
  dark_mode boolean default false,
  route_alerts boolean default true,
  savings_alerts boolean default true,
  traffic_alerts boolean default true,
  exchange_rate float default 1.0,
  updated_at timestamptz default now()
);

alter table public.user_preferences enable row level security;

create policy "Users can insert their own preferences"
on public.user_preferences for insert
with check ( auth.uid() = user_id );

create policy "Users can select their own preferences"
on public.user_preferences for select
using ( auth.uid() = user_id );

create policy "Users can update their own preferences"
on public.user_preferences for update
using ( auth.uid() = user_id );

alter table public.user_routes enable row level security;

create policy "Users can insert their own routes"
on public.user_routes for insert
with check ( auth.uid() = user_id );

create policy "Users can select their own routes"
on public.user_routes for select
using ( auth.uid() = user_id );

create policy "Users can update their own routes"
on public.user_routes for update
using ( auth.uid() = user_id );

create policy "Users can delete their own routes"
on public.user_routes for delete
using ( auth.uid() = user_id );

create table if not exists public.fuel_prices (
  type text primary key,
  price float not null,
  updated_at timestamptz default now()
);

alter table public.fuel_prices enable row level security;

create policy "Public read access for fuel prices"
on public.fuel_prices for select
using ( true );

select 'Health check complete. Ensure Redirect URLs are configured in Dashboard.' as status;
