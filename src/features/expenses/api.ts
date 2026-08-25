import type { Json, Tables } from '../../types/database';
import { supabase } from '../../lib/supabase';

export type Expense = Tables<'expenses'>;
export type ExpenseSplit = Tables<'expense_splits'>;
export type SplitMethod = 'equal' | 'exact' | 'percentage';
export type ExpenseSplitInput = { user_id: string; amount: number; percentage: number | null };

export type ExpenseInput = {
  groupId: string;
  title: string;
  amount: number;
  category: string;
  paidBy: string;
  expenseDate: string;
  notes: string;
  splitMethod: SplitMethod;
  splits: ExpenseSplitInput[];
};

export async function listExpenses(groupId: string) {
  const { data, error } = await supabase.from('expenses').select('*').eq('group_id', groupId).order('expense_date', { ascending: false }).order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function getExpense(expenseId: string) {
  const { data, error } = await supabase.from('expenses').select('*').eq('id', expenseId).single();
  if (error) throw error;
  return data;
}

export async function getExpenseSplits(expenseId: string) {
  const { data, error } = await supabase.from('expense_splits').select('*').eq('expense_id', expenseId).order('created_at');
  if (error) throw error;
  return data;
}

function rpcInput(input: ExpenseInput) {
  return {
    p_group_id: input.groupId,
    p_title: input.title,
    p_amount: input.amount,
    p_category: input.category,
    p_paid_by: input.paidBy,
    p_expense_date: input.expenseDate,
    p_notes: input.notes || undefined,
    p_split_method: input.splitMethod,
    p_splits: input.splits as unknown as Json,
  };
}

export async function createExpense(input: ExpenseInput) {
  const { data, error } = await supabase.rpc('create_expense', rpcInput(input));
  if (error) throw error;
  return data;
}

export async function updateExpense(expenseId: string, input: ExpenseInput) {
  const { data, error } = await supabase.rpc('update_expense', { ...rpcInput(input), p_expense_id: expenseId });
  if (error) throw error;
  return data;
}

export async function deleteExpense(expenseId: string) {
  const { error } = await supabase.from('expenses').delete().eq('id', expenseId);
  if (error) throw error;
}
