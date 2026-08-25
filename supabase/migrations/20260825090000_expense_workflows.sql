-- Transaction-safe expense creation and editing for all supported split methods.

create or replace function public.create_expense(
  p_group_id uuid,
  p_title text,
  p_amount numeric,
  p_category text default 'Other',
  p_paid_by uuid default null,
  p_expense_date date default current_date,
  p_notes text default null,
  p_splits jsonb default '[]'::jsonb,
  p_split_method text default 'equal'
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  new_expense_id uuid;
  split_total numeric;
  percentage_total numeric;
  normalized_method text := lower(trim(coalesce(p_split_method, 'equal')));
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  if not (select private.is_group_member(p_group_id)) then
    raise exception 'You must be a group member to add an expense' using errcode = '42501';
  end if;
  if not (select private.is_group_member(p_group_id, p_paid_by)) then
    raise exception 'The payer must be a member of this group' using errcode = '22023';
  end if;
  if normalized_method not in ('equal', 'exact', 'percentage') then
    raise exception 'Unsupported split method' using errcode = '22023';
  end if;
  if jsonb_typeof(p_splits) <> 'array' or jsonb_array_length(p_splits) < 1 then
    raise exception 'At least one participant is required' using errcode = '22023';
  end if;
  if exists (
    select 1
    from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)
    where s.user_id is null or s.amount is null or s.amount <= 0
      or (normalized_method = 'percentage' and (s.percentage is null or s.percentage < 0 or s.percentage > 100))
  ) then
    raise exception 'Every participant must have a positive split amount' using errcode = '22023';
  end if;
  if (select count(*) from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric))
     <> (select count(distinct s.user_id) from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)) then
    raise exception 'A participant can only appear once' using errcode = '22023';
  end if;
  if exists (
    select 1
    from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)
    where not (select private.is_group_member(p_group_id, s.user_id))
  ) then
    raise exception 'Every participant must be a member of this group' using errcode = '22023';
  end if;

  select coalesce(sum(s.amount), 0), coalesce(sum(s.percentage), 0)
    into split_total, percentage_total
  from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric);

  if p_amount is null or p_amount <= 0 then
    raise exception 'Amount must be greater than zero' using errcode = '22023';
  end if;
  if abs(split_total - p_amount) > 0.01 then
    raise exception 'Split total must equal the expense amount' using errcode = '22023';
  end if;
  if normalized_method = 'percentage' and abs(percentage_total - 100) > 0.01 then
    raise exception 'Percentages must total 100' using errcode = '22023';
  end if;

  insert into public.expenses (group_id, title, amount, category, paid_by, expense_date, notes, created_by)
  values (p_group_id, p_title, p_amount, coalesce(p_category, 'Other'), p_paid_by, coalesce(p_expense_date, current_date), nullif(trim(p_notes), ''), auth.uid())
  returning id into new_expense_id;

  insert into public.expense_splits (expense_id, user_id, amount, percentage)
  select new_expense_id, s.user_id, s.amount, s.percentage
  from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric);

  insert into public.activities (group_id, user_id, type, entity_id, metadata)
  values (p_group_id, auth.uid(), 'expense_created', new_expense_id, jsonb_build_object('title', p_title, 'amount', p_amount));

  return new_expense_id;
end;
$$;

create or replace function public.update_expense(
  p_expense_id uuid,
  p_title text,
  p_amount numeric,
  p_category text default 'Other',
  p_paid_by uuid default null,
  p_expense_date date default current_date,
  p_notes text default null,
  p_splits jsonb default '[]'::jsonb,
  p_split_method text default 'equal'
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  existing_group_id uuid;
  existing_creator uuid;
  split_total numeric;
  percentage_total numeric;
  normalized_method text := lower(trim(coalesce(p_split_method, 'equal')));
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  select e.group_id, e.created_by into existing_group_id, existing_creator
  from public.expenses e where e.id = p_expense_id;
  if existing_group_id is null then
    raise exception 'Expense not found' using errcode = 'P0002';
  end if;
  if existing_creator <> auth.uid() and not (select private.is_group_owner(existing_group_id)) then
    raise exception 'You do not have permission to edit this expense' using errcode = '42501';
  end if;
  if not (select private.is_group_member(existing_group_id, p_paid_by)) then
    raise exception 'The payer must be a member of this group' using errcode = '22023';
  end if;
  if normalized_method not in ('equal', 'exact', 'percentage') then
    raise exception 'Unsupported split method' using errcode = '22023';
  end if;
  if jsonb_typeof(p_splits) <> 'array' or jsonb_array_length(p_splits) < 1 then
    raise exception 'At least one participant is required' using errcode = '22023';
  end if;
  if exists (
    select 1 from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)
    where s.user_id is null or s.amount is null or s.amount <= 0
      or (normalized_method = 'percentage' and (s.percentage is null or s.percentage < 0 or s.percentage > 100))
  ) then
    raise exception 'Every participant must have a positive split amount' using errcode = '22023';
  end if;
  if (select count(*) from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric))
     <> (select count(distinct s.user_id) from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)) then
    raise exception 'A participant can only appear once' using errcode = '22023';
  end if;
  if exists (
    select 1 from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric)
    where not (select private.is_group_member(existing_group_id, s.user_id))
  ) then
    raise exception 'Every participant must be a member of this group' using errcode = '22023';
  end if;
  select coalesce(sum(s.amount), 0), coalesce(sum(s.percentage), 0)
    into split_total, percentage_total
  from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric);
  if p_amount is null or p_amount <= 0 or abs(split_total - p_amount) > 0.01 then
    raise exception 'Split total must equal the expense amount' using errcode = '22023';
  end if;
  if normalized_method = 'percentage' and abs(percentage_total - 100) > 0.01 then
    raise exception 'Percentages must total 100' using errcode = '22023';
  end if;

  update public.expenses
  set title = p_title, amount = p_amount, category = coalesce(p_category, 'Other'), paid_by = p_paid_by,
      expense_date = coalesce(p_expense_date, current_date), notes = nullif(trim(p_notes), '')
  where id = p_expense_id;

  delete from public.expense_splits where expense_id = p_expense_id;
  insert into public.expense_splits (expense_id, user_id, amount, percentage)
  select p_expense_id, s.user_id, s.amount, s.percentage
  from jsonb_to_recordset(p_splits) as s(user_id uuid, amount numeric, percentage numeric);
  insert into public.activities (group_id, user_id, type, entity_id, metadata)
  values (existing_group_id, auth.uid(), 'expense_updated', p_expense_id, jsonb_build_object('title', p_title, 'amount', p_amount));
  return p_expense_id;
end;
$$;

revoke execute on function public.create_expense(uuid, text, numeric, text, uuid, date, text, jsonb, text) from public, anon;
revoke execute on function public.update_expense(uuid, text, numeric, text, uuid, date, text, jsonb, text) from public, anon;
grant execute on function public.create_expense(uuid, text, numeric, text, uuid, date, text, jsonb, text) to authenticated;
grant execute on function public.update_expense(uuid, text, numeric, text, uuid, date, text, jsonb, text) to authenticated;
