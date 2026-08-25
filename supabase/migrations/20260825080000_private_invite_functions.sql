-- Keep privilege-bypassing invite lookups in the non-exposed private schema.
-- Public RPC names remain invoker functions so the Data API has no public
-- SECURITY DEFINER endpoint.

create or replace function private.preview_group_invite(p_code text)
returns table (group_id uuid, group_name text, expires_at timestamptz)
language plpgsql
security definer
set search_path = ''
stable
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  return query
  select i.group_id, g.name, i.expires_at
  from public.group_invites i
  join public.groups g on g.id = i.group_id
  where i.code = upper(trim(p_code)) and i.expires_at > now();
end;
$$;

create or replace function private.join_group_by_invite(p_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_group_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  select i.group_id into target_group_id
  from public.group_invites i
  where i.code = upper(trim(p_code)) and i.expires_at > now();
  if target_group_id is null then
    raise exception 'This invite link is invalid or expired' using errcode = '22023';
  end if;
  insert into public.group_members (group_id, user_id, role)
  values (target_group_id, auth.uid(), 'member')
  on conflict (group_id, user_id) do nothing;
  return target_group_id;
end;
$$;

create or replace function public.preview_group_invite(p_code text)
returns table (group_id uuid, group_name text, expires_at timestamptz)
language sql
security invoker
set search_path = public, private
stable
as $$
  select * from private.preview_group_invite(p_code);
$$;

create or replace function public.join_group_by_invite(p_code text)
returns uuid
language sql
security invoker
set search_path = public, private
as $$
  select private.join_group_by_invite(p_code);
$$;

revoke all on function private.preview_group_invite(text) from public;
revoke all on function private.join_group_by_invite(text) from public;
grant usage on schema private to authenticated;
grant execute on function private.preview_group_invite(text) to authenticated;
grant execute on function private.join_group_by_invite(text) to authenticated;
