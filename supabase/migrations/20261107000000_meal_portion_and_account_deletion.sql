-- Meal portion / photo storage columns, last-writer-wins meal sync and
-- in-app account deletion.
-- Apply after 20260701001000_grant_authenticated_data_api_access.sql.

alter table public.meal_records
  add column if not exists portion numeric(6, 3) not null default 1
    check (portion > 0),
  add column if not exists image_storage_path text,
  -- Deletions are kept as tombstones so another device that still has the
  -- meal does not upload it again; an upsert with deleted_at = null (undo,
  -- or an edit made after the deletion) brings it back.
  add column if not exists deleted_at timestamptz,
  -- Server clock of the last write, used by devices to fetch only changes.
  add column if not exists server_updated_at timestamptz not null
    default now();

create index if not exists meal_records_user_server_updated_idx
on public.meal_records (user_id, server_updated_at);

-- Last writer wins by edit time. Devices sync in the background and can
-- retry an older change after a newer one from another device reached the
-- server; the client sends the time of its edit in updated_at, and an update
-- carrying an older edit time is skipped instead of overwriting the newer
-- row. (The shared set_updated_at trigger replaced updated_at with now(),
-- which made every late upload look newest.)
create or replace function public.meal_records_keep_newer()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.updated_at is null then
    new.updated_at = now();
  elsif old.updated_at is not null and new.updated_at < old.updated_at then
    return null;
  end if;
  new.server_updated_at = now();
  return new;
end;
$$;

drop trigger if exists meal_records_set_updated_at on public.meal_records;
drop trigger if exists meal_records_keep_newer on public.meal_records;
create trigger meal_records_keep_newer
before update on public.meal_records
for each row execute function public.meal_records_keep_newer();

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
