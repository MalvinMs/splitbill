-- SplitBill initial database schema.
-- Monetary values are numeric(20,2) for predictable arithmetic across currencies.

create schema if not exists private;

create type public.group_role as enum ('owner', 'member');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  full_name text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_length check (username is null or char_length(username) between 3 and 32),
  constraint profiles_username_format check (username is null or username ~ '^[a-zA-Z0-9_]+$')
);

create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  image_url text,
  currency text not null default 'IDR',
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint groups_name_length check (char_length(trim(name)) between 1 and 100),
  constraint groups_currency_format check (currency ~ '^[A-Z]{3}$')
);

create table public.group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.group_role not null default 'member',
  joined_at timestamptz not null default now(),
  unique (group_id, user_id)
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  title text not null,
  amount numeric(20,2) not null,
  category text not null default 'Other',
  paid_by uuid not null references public.profiles(id) on delete restrict,
  expense_date date not null default current_date,
  notes text,
  receipt_url text,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expenses_title_length check (char_length(trim(title)) between 1 and 100),
  constraint expenses_amount_positive check (amount > 0),
  constraint expenses_category check (category in ('Food', 'Transportation', 'Accommodation', 'Shopping', 'Entertainment', 'Utilities', 'Groceries', 'Other'))
);

create table public.expense_splits (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid not null references public.expenses(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete restrict,
  amount numeric(20,2) not null,
  percentage numeric(7,4),
  created_at timestamptz not null default now(),
  unique (expense_id, user_id),
  constraint expense_splits_amount_positive check (amount > 0),
  constraint expense_splits_percentage_range check (percentage is null or (percentage >= 0 and percentage <= 100))
);

create table public.settlements (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  from_user uuid not null references public.profiles(id) on delete restrict,
  to_user uuid not null references public.profiles(id) on delete restrict,
  amount numeric(20,2) not null,
  notes text,
  settled_at timestamptz not null default now(),
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint settlements_amount_positive check (amount > 0),
  constraint settlements_different_users check (from_user <> to_user)
);

create table public.group_invites (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  code text not null unique,
  created_by uuid not null references public.profiles(id) on delete restrict,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  constraint group_invites_code_format check (code ~ '^[A-Z0-9]{8,32}$')
);

create table public.activities (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete restrict,
  type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index group_members_user_id_idx on public.group_members(user_id);
create index expenses_group_date_idx on public.expenses(group_id, expense_date desc, created_at desc);
create index expenses_paid_by_idx on public.expenses(paid_by);
create index expense_splits_expense_id_idx on public.expense_splits(expense_id);
create index expense_splits_user_id_idx on public.expense_splits(user_id);
create index settlements_group_date_idx on public.settlements(group_id, settled_at desc);
create index group_invites_group_id_idx on public.group_invites(group_id);
create index group_invites_expires_at_idx on public.group_invites(expires_at);
create index activities_group_date_idx on public.activities(group_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
create trigger groups_set_updated_at before update on public.groups
for each row execute function public.set_updated_at();
create trigger expenses_set_updated_at before update on public.expenses
for each row execute function public.set_updated_at();

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

revoke execute on function private.handle_new_user() from public;
revoke execute on function public.set_updated_at() from public;

-- These SECURITY DEFINER helpers only answer narrow membership questions.
-- They avoid recursive RLS checks when policies need to inspect group_members.
create or replace function private.is_group_member(target_group_id uuid, target_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select target_user_id is not null and exists (
    select 1 from public.group_members gm
    where gm.group_id = target_group_id and gm.user_id = target_user_id
  );
$$;

create or replace function private.is_group_owner(target_group_id uuid, target_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select target_user_id is not null and exists (
    select 1 from public.group_members gm
    where gm.group_id = target_group_id and gm.user_id = target_user_id and gm.role = 'owner'
  );
$$;

create or replace function private.can_view_profile(target_profile_id uuid, target_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select target_user_id is not null and (
    target_profile_id = target_user_id or exists (
      select 1
      from public.group_members viewer_membership
      join public.group_members profile_membership
        on profile_membership.group_id = viewer_membership.group_id
      where viewer_membership.user_id = target_user_id
        and profile_membership.user_id = target_profile_id
    )
  );
$$;

create or replace function private.is_expense_in_group(target_expense_id uuid, target_group_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1 from public.expenses e
    where e.id = target_expense_id and e.group_id = target_group_id
  );
$$;

revoke execute on function private.is_group_member(uuid, uuid) from public;
revoke execute on function private.is_group_owner(uuid, uuid) from public;
revoke execute on function private.can_view_profile(uuid, uuid) from public;
revoke execute on function private.is_expense_in_group(uuid, uuid) from public;
grant usage on schema private to authenticated;
grant execute on function private.is_group_member(uuid, uuid) to authenticated;
grant execute on function private.is_group_owner(uuid, uuid) to authenticated;
grant execute on function private.can_view_profile(uuid, uuid) to authenticated;
grant execute on function private.is_expense_in_group(uuid, uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.expenses enable row level security;
alter table public.expense_splits enable row level security;
alter table public.settlements enable row level security;
alter table public.group_invites enable row level security;
alter table public.activities enable row level security;

create policy "Profiles are visible to self and shared group members"
on public.profiles for select to authenticated
using ((select private.can_view_profile(id)));
create policy "Users can create their own profile"
on public.profiles for insert to authenticated
with check ((select auth.uid()) = id);
create policy "Users can update their own profile"
on public.profiles for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy "Members can view groups"
on public.groups for select to authenticated
using ((select private.is_group_member(id)));
create policy "Users can create groups"
on public.groups for insert to authenticated
with check ((select auth.uid()) = created_by);
create policy "Owners can update groups"
on public.groups for update to authenticated
using ((select private.is_group_owner(id)))
with check ((select private.is_group_owner(id)));
create policy "Owners can delete groups"
on public.groups for delete to authenticated
using ((select private.is_group_owner(id)));

create policy "Members can view group memberships"
on public.group_members for select to authenticated
using ((select private.is_group_member(group_id)));
create policy "Owners can add group members"
on public.group_members for insert to authenticated
with check (
  (select private.is_group_owner(group_id))
  or exists (
    select 1 from public.groups g
    where g.id = group_id and g.created_by = (select auth.uid())
      and user_id = (select auth.uid()) and role = 'owner'
  )
);
create policy "Owners can update group memberships"
on public.group_members for update to authenticated
using ((select private.is_group_owner(group_id)))
with check ((select private.is_group_owner(group_id)));
create policy "Owners can remove group members"
on public.group_members for delete to authenticated
using ((select private.is_group_owner(group_id)));

create policy "Members can view expenses"
on public.expenses for select to authenticated
using ((select private.is_group_member(group_id)));
create policy "Members can create expenses"
on public.expenses for insert to authenticated
with check (
  (select private.is_group_member(group_id))
  and created_by = (select auth.uid())
  and (select private.is_group_member(group_id, paid_by))
);
create policy "Creators and owners can update expenses"
on public.expenses for update to authenticated
using ((created_by = (select auth.uid())) or (select private.is_group_owner(group_id)))
with check ((select private.is_group_member(group_id)) and (created_by = (select auth.uid()) or (select private.is_group_owner(group_id))));
create policy "Creators and owners can delete expenses"
on public.expenses for delete to authenticated
using ((created_by = (select auth.uid())) or (select private.is_group_owner(group_id)));

create policy "Members can view expense splits"
on public.expense_splits for select to authenticated
using (exists (select 1 from public.expenses e where e.id = expense_id and (select private.is_group_member(e.group_id))));
create policy "Members can create expense splits"
on public.expense_splits for insert to authenticated
with check (exists (
  select 1 from public.expenses e
  where e.id = expense_id
    and (select private.is_group_member(e.group_id))
    and (select private.is_group_member(e.group_id, user_id))
));
create policy "Expense creators and owners can update splits"
on public.expense_splits for update to authenticated
using (exists (select 1 from public.expenses e where e.id = expense_id and ((e.created_by = (select auth.uid())) or (select private.is_group_owner(e.group_id)))))
with check (exists (select 1 from public.expenses e where e.id = expense_id and ((e.created_by = (select auth.uid())) or (select private.is_group_owner(e.group_id)))));
create policy "Expense creators and owners can delete splits"
on public.expense_splits for delete to authenticated
using (exists (select 1 from public.expenses e where e.id = expense_id and ((e.created_by = (select auth.uid())) or (select private.is_group_owner(e.group_id)))));

create policy "Members can view settlements"
on public.settlements for select to authenticated
using ((select private.is_group_member(group_id)));
create policy "Users can create settlements they initiate"
on public.settlements for insert to authenticated
with check (
  created_by = (select auth.uid())
  and from_user = (select auth.uid())
  and (select private.is_group_member(group_id, from_user))
  and (select private.is_group_member(group_id, to_user))
);
create policy "Creators and owners can update settlements"
on public.settlements for update to authenticated
using ((created_by = (select auth.uid())) or (select private.is_group_owner(group_id)))
with check ((created_by = (select auth.uid())) or (select private.is_group_owner(group_id)));
create policy "Creators and owners can delete settlements"
on public.settlements for delete to authenticated
using ((created_by = (select auth.uid())) or (select private.is_group_owner(group_id)));

create policy "Members can view group invites"
on public.group_invites for select to authenticated
using ((select private.is_group_member(group_id)));
create policy "Owners can create group invites"
on public.group_invites for insert to authenticated
with check ((select private.is_group_owner(group_id)) and created_by = (select auth.uid()));
create policy "Owners can update group invites"
on public.group_invites for update to authenticated
using ((select private.is_group_owner(group_id)))
with check ((select private.is_group_owner(group_id)));
create policy "Owners can delete group invites"
on public.group_invites for delete to authenticated
using ((select private.is_group_owner(group_id)));

create policy "Members can view activities"
on public.activities for select to authenticated
using ((select private.is_group_member(group_id)));
create policy "Members can create activities for themselves"
on public.activities for insert to authenticated
with check ((select private.is_group_member(group_id)) and user_id = (select auth.uid()));

insert into storage.buckets (id, name, public)
values ('expense-receipts', 'expense-receipts', false)
on conflict (id) do update set public = false;

create policy "Members can read expense receipts"
on storage.objects for select to authenticated
using (
  bucket_id = 'expense-receipts'
  and (select private.is_group_member(((storage.foldername(name))[1])::uuid))
  and (select private.is_expense_in_group(((storage.foldername(name))[2])::uuid, ((storage.foldername(name))[1])::uuid))
);
create policy "Members can upload expense receipts"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'expense-receipts'
  and (select private.is_group_member(((storage.foldername(name))[1])::uuid))
  and (select private.is_expense_in_group(((storage.foldername(name))[2])::uuid, ((storage.foldername(name))[1])::uuid))
);
create policy "Members can update expense receipts"
on storage.objects for update to authenticated
using (
  bucket_id = 'expense-receipts'
  and (select private.is_group_member(((storage.foldername(name))[1])::uuid))
)
with check (
  bucket_id = 'expense-receipts'
  and (select private.is_group_member(((storage.foldername(name))[1])::uuid))
);
create policy "Members can delete expense receipts"
on storage.objects for delete to authenticated
using (
  bucket_id = 'expense-receipts'
  and (select private.is_group_member(((storage.foldername(name))[1])::uuid))
);

alter publication supabase_realtime add table public.expenses;
alter publication supabase_realtime add table public.expense_splits;
alter publication supabase_realtime add table public.settlements;
alter publication supabase_realtime add table public.group_members;
