import type { Tables } from '../../types/database';
import { supabase } from '../../lib/supabase';

export type Group = Tables<'groups'>;
export type GroupMemberView = Tables<'group_members'> & { profiles: Pick<Tables<'profiles'>, 'id' | 'full_name' | 'username' | 'avatar_url'> | null };
export type InvitePreview = { group_id: string; group_name: string; expires_at: string };

export async function listGroups() {
  const { data, error } = await supabase.from('groups').select('*').order('updated_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function getGroup(groupId: string) {
  const { data, error } = await supabase.from('groups').select('*').eq('id', groupId).single();
  if (error) throw error;
  return data;
}

export async function getGroupMembers(groupId: string) {
  const { data, error } = await supabase.from('group_members').select('id, group_id, user_id, role, joined_at, profiles(id, full_name, username, avatar_url)').eq('group_id', groupId).order('joined_at');
  if (error) throw error;
  return data as unknown as GroupMemberView[];
}

export async function createGroup(input: { name: string; description: string; currency: string }) {
  const { data, error } = await supabase.rpc('create_group', { p_name: input.name, p_description: input.description || undefined, p_currency: input.currency });
  if (error) throw error;
  return data;
}

export async function updateGroup(groupId: string, input: { name: string; description: string; currency: string }) {
  const { data, error } = await supabase.from('groups').update({ name: input.name, description: input.description || null, currency: input.currency }).eq('id', groupId).select().single();
  if (error) throw error;
  return data;
}

export async function deleteGroup(groupId: string) {
  const { error } = await supabase.from('groups').delete().eq('id', groupId);
  if (error) throw error;
}

export async function createInvite(groupId: string) {
  const { data, error } = await supabase.rpc('create_group_invite', { p_group_id: groupId });
  if (error) throw error;
  return data;
}

export async function previewInvite(code: string) {
  const { data, error } = await supabase.rpc('preview_group_invite', { p_code: code.trim().toUpperCase() });
  if (error) throw error;
  return (data?.[0] ?? null) as InvitePreview | null;
}

export async function joinGroup(code: string) {
  const { data, error } = await supabase.rpc('join_group_by_invite', { p_code: code.trim().toUpperCase() });
  if (error) throw error;
  return data;
}

export async function removeMember(memberId: string) {
  const { error } = await supabase.from('group_members').delete().eq('id', memberId);
  if (error) throw error;
}
