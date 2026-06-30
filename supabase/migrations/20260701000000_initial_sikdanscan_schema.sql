-- SikdanScan initial Supabase schema.
-- Apply this migration in a Supabase project before enabling remote sync.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  age integer not null default 0 check (age >= 0),
  height numeric(6, 2) not null default 0 check (height >= 0),
  starting_weight numeric(6, 2),
  current_weight numeric(6, 2) not null default 0 check (current_weight >= 0),
  target_weight numeric(6, 2) not null default 0 check (target_weight >= 0),
  gender text not null default 'female',
  daily_calorie_goal integer not null default 0 check (daily_calorie_goal >= 0),
  daily_water_goal_ml integer not null default 0 check (daily_water_goal_ml >= 0),
  daily_step_goal integer not null default 0 check (daily_step_goal >= 0),
  wellness_goal text not null default 'balanced',
  activity_level text not null default 'moderate',
  onboarding_completed boolean not null default false,
  avatar_image_path text,
  target_date timestamptz,
  onboarded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;

create policy "profiles_select_own"
on public.profiles for select
using (auth.uid() = id);

create policy "profiles_insert_own"
on public.profiles for insert
with check (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "profiles_delete_own"
on public.profiles for delete
using (auth.uid() = id);

create table if not exists public.meal_records (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  date timestamptz not null,
  meal_type text not null default 'breakfast',
  name text not null,
  calories integer not null default 0 check (calories >= 0),
  carbs numeric(8, 2) not null default 0 check (carbs >= 0),
  protein numeric(8, 2) not null default 0 check (protein >= 0),
  fat numeric(8, 2) not null default 0 check (fat >= 0),
  image_url text,
  serving_size text,
  is_ai_recognized boolean not null default false,
  recognition_confidence numeric(5, 4) check (
    recognition_confidence is null or
    (recognition_confidence >= 0 and recognition_confidence <= 1)
  ),
  memo text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create index if not exists meal_records_user_date_idx
on public.meal_records (user_id, date desc);

create trigger meal_records_set_updated_at
before update on public.meal_records
for each row execute function public.set_updated_at();

alter table public.meal_records enable row level security;

create policy "meal_records_select_own"
on public.meal_records for select
using (auth.uid() = user_id);

create policy "meal_records_insert_own"
on public.meal_records for insert
with check (auth.uid() = user_id);

create policy "meal_records_update_own"
on public.meal_records for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "meal_records_delete_own"
on public.meal_records for delete
using (auth.uid() = user_id);

create table if not exists public.food_recognition_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_record_id text,
  image_path text,
  summary text not null default '',
  confidence numeric(5, 4) not null default 0 check (confidence >= 0 and confidence <= 1),
  needs_review boolean not null default true,
  warning text,
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists food_recognition_results_user_created_idx
on public.food_recognition_results (user_id, created_at desc);

alter table public.food_recognition_results enable row level security;

create policy "food_recognition_results_select_own"
on public.food_recognition_results for select
using (auth.uid() = user_id);

create policy "food_recognition_results_insert_own"
on public.food_recognition_results for insert
with check (auth.uid() = user_id);

create policy "food_recognition_results_delete_own"
on public.food_recognition_results for delete
using (auth.uid() = user_id);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('meal-images', 'meal-images', false, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('avatars', 'avatars', false, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "meal_images_select_own_folder"
on storage.objects for select
using (
  bucket_id = 'meal-images' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "meal_images_insert_own_folder"
on storage.objects for insert
with check (
  bucket_id = 'meal-images' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "meal_images_update_own_folder"
on storage.objects for update
using (
  bucket_id = 'meal-images' and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'meal-images' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "meal_images_delete_own_folder"
on storage.objects for delete
using (
  bucket_id = 'meal-images' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "avatars_select_own_folder"
on storage.objects for select
using (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "avatars_insert_own_folder"
on storage.objects for insert
with check (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "avatars_update_own_folder"
on storage.objects for update
using (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "avatars_delete_own_folder"
on storage.objects for delete
using (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);
