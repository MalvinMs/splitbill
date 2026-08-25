import type { ExpenseSplitInput, SplitMethod } from './api';

function cents(value: number) { return Math.round(value * 100); }
function amountFromCents(value: number) { return Number((value / 100).toFixed(2)); }

export function buildSplits(amount: number, participantIds: string[], method: SplitMethod, values: Record<string, string>): ExpenseSplitInput[] {
  if (!participantIds.length || !Number.isFinite(amount) || amount <= 0) throw new Error('Add at least one participant and a positive amount.');
  const totalCents = cents(amount);
  if (method === 'equal') {
    const base = Math.floor(totalCents / participantIds.length);
    const remainder = totalCents % participantIds.length;
    return participantIds.map((user_id, index) => ({ user_id, amount: amountFromCents(base + (index < remainder ? 1 : 0)), percentage: null }));
  }
  if (method === 'exact') {
    return participantIds.map((user_id) => ({ user_id, amount: amountFromCents(cents(Number(values[user_id] || 0))), percentage: null }));
  }
  const percentages = participantIds.map((user_id) => Number(values[user_id] || 0));
  let assigned = 0;
  return participantIds.map((user_id, index) => {
    const splitCents = index === participantIds.length - 1 ? totalCents - assigned : Math.round(totalCents * percentages[index] / 100);
    assigned += splitCents;
    return { user_id, amount: amountFromCents(splitCents), percentage: percentages[index] };
  });
}

export function splitTotal(splits: ExpenseSplitInput[]) { return Number(splits.reduce((sum, split) => sum + split.amount, 0).toFixed(2)); }
export function percentageTotal(splits: ExpenseSplitInput[]) { return Number(splits.reduce((sum, split) => sum + (split.percentage ?? 0), 0).toFixed(2)); }
