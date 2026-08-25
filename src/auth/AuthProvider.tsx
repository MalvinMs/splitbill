import { createContext, useContext, useEffect, useMemo, useState, type PropsWithChildren } from 'react';
import type { Session } from '@supabase/supabase-js';
import * as Linking from 'expo-linking';
import { supabase } from '../lib/supabase';

type AuthResult = { error: Error | null; message?: string };
type AuthContextValue = {
  session: Session | null;
  isLoading: boolean;
  isPasswordRecovery: boolean;
  signIn: (email: string, password: string) => Promise<AuthResult>;
  signUp: (email: string, password: string, fullName: string) => Promise<AuthResult>;
  resetPassword: (email: string) => Promise<AuthResult>;
  updatePassword: (password: string) => Promise<AuthResult>;
  signOut: () => Promise<AuthResult>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: PropsWithChildren) {
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isPasswordRecovery, setIsPasswordRecovery] = useState(false);

  function getAuthRedirectUrl() {
    // Expo resolves this to an exp:// URL in Expo Go and splitbill:// in a
    // standalone/development build, so the same code works in both modes.
    return Linking.createURL('auth/callback');
  }

  useEffect(() => {
    async function handleAuthCallback(url: string | null) {
      if (!url) return;
      const hash = url.includes('#') ? url.split('#')[1] : '';
      const fragmentParams = new URLSearchParams(hash);
      const accessToken = fragmentParams.get('access_token');
      const refreshToken = fragmentParams.get('refresh_token');
      const type = fragmentParams.get('type') ?? new URL(url).searchParams.get('type');
      if (accessToken && refreshToken) {
        await supabase.auth.setSession({ access_token: accessToken, refresh_token: refreshToken });
        if (type === 'recovery') setIsPasswordRecovery(true);
        return;
      }
      const code = new URL(url).searchParams.get('code');
      if (code) await supabase.auth.exchangeCodeForSession(code);
    }

    const { data: listener } = supabase.auth.onAuthStateChange((event, nextSession) => {
      setSession(nextSession);
      setIsLoading(false);
      if (event === 'PASSWORD_RECOVERY') setIsPasswordRecovery(true);
    });
    Linking.getInitialURL().then(handleAuthCallback);
    const linkingSubscription = Linking.addEventListener('url', ({ url }) => { void handleAuthCallback(url); });
    return () => { listener.subscription.unsubscribe(); linkingSubscription.remove(); };
  }, []);

  const value = useMemo<AuthContextValue>(() => ({
    session,
    isLoading,
    isPasswordRecovery,
    async signIn(email, password) {
      const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
      return { error: error ? new Error(error.message) : null };
    },
    async signUp(email, password, fullName) {
      const { data, error } = await supabase.auth.signUp({ email: email.trim(), password, options: { data: { full_name: fullName.trim() }, emailRedirectTo: getAuthRedirectUrl() } });
      return { error: error ? new Error(error.message) : null, message: data.session ? undefined : 'Check your email to confirm your account before signing in.' };
    },
    async resetPassword(email) {
      const { error } = await supabase.auth.resetPasswordForEmail(email.trim(), { redirectTo: getAuthRedirectUrl() });
      return { error: error ? new Error(error.message) : null, message: 'Password reset instructions were sent if the email exists.' };
    },
    async updatePassword(password) {
      const { error } = await supabase.auth.updateUser({ password });
      if (!error) setIsPasswordRecovery(false);
      return { error: error ? new Error(error.message) : null };
    },
    async signOut() {
      const { error } = await supabase.auth.signOut();
      return { error: error ? new Error(error.message) : null };
    },
  }), [isLoading, isPasswordRecovery, session]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside AuthProvider');
  return context;
}
