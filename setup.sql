-- PostgreSQL tutorial: https://supabase.com/docs/guides/database/tables#resources

-- Create a table for public profiles
create table profiles (
  id uuid references auth.users not null primary key,
  email text unique not null,
  display_name text,
  biography text
);
-- Set up Row Level Security (RLS)
-- See https://supabase.com/docs/guides/auth/row-level-security for more details.
alter table profiles
  enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create type continent as enum ('North America', 'South America', 'Europe', 'Africa', 'Asia', 'Australia', 'Antarctica');
create type ocean as enum ('Pacific', 'Atlantic', 'Indian', 'Arctic', 'Southern');
create type kingdom as enum ('Animalia', 'Plantae', 'Fungi', 'Protista', 'Archaea', 'Bacteria');

-- Create a table for species
create table species (
  id int generated by default as identity primary key,
  scientific_name text unique not null,
  common_name text,
  total_population int,
  continents continent[],
  oceans ocean[],
  kingdom kingdom not null,
  description text,
  author uuid not null references profiles
);
-- Set up Row Level Security (RLS)
alter table species
  enable row level security;

create policy "Species are viewable by everyone." on species
  for select using (true);

create policy "Users can insert their own species." on species
  for insert with check (auth.uid() = author);

create policy "Users can update their created species." on species
  for update using (auth.uid() = author);
