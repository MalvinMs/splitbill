-- Allow the creator to add the initial owner membership without querying
-- the RLS-protected groups table through the caller's SELECT policy.
create or replace function private.is_group_creator(
  target_group_id uuid,
  target_user_id uuid default auth.uid()
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select target_user_id is not null and exists (
    select 1
    from public.groups g
    where g.id = target_group_id
      and g.created_by = target_user_id
  );
$$;

revoke execute on function private.is_group_creator(uuid, uuid) from public;
grant usage on schema private to authenticated;
grant execute on function private.is_group_creator(uuid, uuid) to authenticated;

drop policy if exists "Owners can add group members" on public.group_members;

create policy "Owners can add group members"
on public.group_members for insert to authenticated
with check (
  (select private.is_group_owner(group_id))
  or (
    user_id = (select auth.uid())
    and role = 'owner'
    and (select private.is_group_creator(group_id))
  )
);
