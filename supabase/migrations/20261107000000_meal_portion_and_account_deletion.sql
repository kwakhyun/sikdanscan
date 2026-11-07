-- Meal portion / photo storage columns and in-app account deletion.
-- Apply after 20260701001000_grant_authenticated_data_api_access.sql.

alter table public.meal_records
  add column if not exists portion numeric(6, 3) not null default 1
    check (portion > 0),
  add column if not exists image_storage_path text;

-- Lets a signed-in user delete their own account from the app
-- (App Store Review Guideline 5.1.1(v)). Rows in profiles, meal_records and
-- food_recognition_results cascade from auth.users. Storage objects are
-- removed by the client through the Storage API before calling this.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  delete from auth.users where id = current_user_id;
end;
$$;

revoke all on function public.delete_my_account() from public;
revoke all on function public.delete_my_account() from anon;
grant execute on function public.delete_my_account() to authenticated;
