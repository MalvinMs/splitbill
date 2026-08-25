-- INSERT ... RETURNING also requires the new row to pass the table's
-- SELECT policy. A new group is not visible to its creator until the owner
-- membership is inserted, so generate the id before the INSERT instead.
create or replace function public.create_group(
  p_name text,
  p_description text default null,
  p_image_url text default null,
  p_currency text default 'IDR'
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  actor_id uuid := auth.uid();
  new_group_id uuid := gen_random_uuid();
begin
  if actor_id is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  insert into public.groups (id, name, description, image_url, currency, created_by)
  values (new_group_id, p_name, p_description, p_image_url, p_currency, actor_id);

  insert into public.group_members (group_id, user_id, role)
  values (new_group_id, actor_id, 'owner');

  return new_group_id;
end;
$$;
