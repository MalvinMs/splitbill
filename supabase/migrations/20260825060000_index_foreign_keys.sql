-- Cover foreign keys used by membership, activity, expense, invite, and
-- settlement lookups. These indexes address Supabase performance advisories.
create index activities_user_id_idx on public.activities(user_id);
create index expenses_created_by_idx on public.expenses(created_by);
create index group_invites_created_by_idx on public.group_invites(created_by);
create index groups_created_by_idx on public.groups(created_by);
create index settlements_created_by_idx on public.settlements(created_by);
create index settlements_from_user_idx on public.settlements(from_user);
create index settlements_to_user_idx on public.settlements(to_user);
