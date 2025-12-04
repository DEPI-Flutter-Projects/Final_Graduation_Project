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
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.user_preferences enable row level security;

create policy "Users can view their own preferences" on public.user_preferences
  for select using (auth.uid() = user_id);

create policy "Users can update their own preferences" on public.user_preferences
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own preferences" on public.user_preferences
  for update using (auth.uid() = user_id);
