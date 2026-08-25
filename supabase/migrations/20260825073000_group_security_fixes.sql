-- Restrict invite RPCs to signed-in users explicitly. The Data API roles
-- retain their default EXECUTE grants unless each role is revoked directly.
revoke all on function public.preview_group_invite(text) from public, anon, authenticated;
revoke all on function public.join_group_by_invite(text) from public, anon, authenticated;
grant execute on function public.preview_group_invite(text) to authenticated;
grant execute on function public.join_group_by_invite(text) to authenticated;

drop policy if exists "Members can leave groups" on public.group_members;
drop policy if exists "Owners can remove group members" on public.group_members;

create policy "Owners remove or members leave groups"
on public.group_members for delete to authenticated
using (
  (select private.is_group_owner(group_id))
  or (user_id = (select auth.uid()) and role = 'member')
);
