-- Transaction-safe group creation and authenticated invite workflows.

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
  new_group_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  insert into public.groups (name, description, image_url, currency, created_by)
  values (p_name, p_description, p_image_url, p_currency, auth.uid())
  returning id into new_group_id;

  insert into public.group_members (group_id, user_id, role)
  values (new_group_id, auth.uid(), 'owner');

  return new_group_id;
end;
$$;

create or replace function public.create_group_invite(
  p_group_id uuid,
  p_expires_at timestamptz default (now() + interval '7 days')
)
returns text
language plpgsql
security invoker
set search_path = public
as $$
declare
  invite_code text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.group_members
    where group_id = p_group_id and user_id = auth.uid() and role = 'owner'
  ) then
    raise exception 'Only the group owner can create invites' using errcode = '42501';
  end if;

  loop
    invite_code := upper(substring(replace(gen_random_uuid()::text, '-', '') from 1 for 8));
    begin
      insert into public.group_invites (group_id, code, created_by, expires_at)
      values (p_group_id, invite_code, auth.uid(), p_expires_at);
      return invite_code;
    exception when unique_violation then
      -- Extremely unlikely collision: generate another code.
      null;
    end;
  end loop;
end;
$$;

create or replace function public.preview_group_invite(p_code text)
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
  where i.code = upper(trim(p_code))
    and i.expires_at > now();
end;
$$;

create or replace function public.join_group_by_invite(p_code text)
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
  where i.code = upper(trim(p_code))
    and i.expires_at > now();

  if target_group_id is null then
    raise exception 'This invite link is invalid or expired' using errcode = '22023';
  end if;

  insert into public.group_members (group_id, user_id, role)
  values (target_group_id, auth.uid(), 'member')
  on conflict (group_id, user_id) do nothing;

  return target_group_id;
end;
$$;

revoke execute on function public.create_group(text, text, text, text) from public;
revoke execute on function public.create_group_invite(uuid, timestamptz) from public;
revoke execute on function public.preview_group_invite(text) from public;
revoke execute on function public.join_group_by_invite(text) from public;
grant execute on function public.create_group(text, text, text, text) to authenticated;
grant execute on function public.create_group_invite(uuid, timestamptz) to authenticated;
grant execute on function public.preview_group_invite(text) to authenticated;
grant execute on function public.join_group_by_invite(text) to authenticated;

create policy "Members can leave groups"
on public.group_members for delete to authenticated
using (user_id = (select auth.uid()) and role = 'member');
