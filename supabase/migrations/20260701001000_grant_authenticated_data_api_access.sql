-- Explicit Data API privileges for projects that disable
-- "Automatically expose new tables" during project creation.

grant usage on schema public to authenticated;

grant select, insert, update, delete
on table public.profiles
to authenticated;

grant select, insert, update, delete
on table public.meal_records
to authenticated;

grant select, insert, delete
on table public.food_recognition_results
to authenticated;
