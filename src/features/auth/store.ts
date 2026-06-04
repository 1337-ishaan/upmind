import { Session, User } from '@supabase/supabase-js';
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '@/lib/supabase';

type AuthState = {
  session: Session | null;
  user: User | null;
  premium: boolean;
  loading: boolean;
  hydrated: boolean;
  hydrate: () => Promise<void>;
  signIn: (email: string, password: string) => Promise<{ error: string | null }>;
  signUp: (email: string, password: string, displayName: string) => Promise<{ error: string | null }>;
  signOut: () => Promise<void>;
  setPremium: (v: boolean) => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      session: null,
      user: null,
      premium: false,
      loading: false,
      hydrated: false,

      hydrate: async () => {
        set({ loading: true });
        const { data } = await supabase.auth.getSession();
        const session = data.session ?? null;
        let premium = false;
        if (session?.user) {
          const { data: profile } = await supabase
            .from('users')
            .select('premium')
            .eq('id', session.user.id)
            .single();
          premium = profile?.premium ?? false;
        }
        set({
          session,
          user: session?.user ?? null,
          premium,
          loading: false,
          hydrated: true,
        });
      },

      signIn: async (email, password) => {
        set({ loading: true });
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) {
          set({ loading: false });
          return { error: error.message };
        }
        set({ session: data.session, user: data.user, loading: false });
        await get().hydrate();
        return { error: null };
      },

      signUp: async (email, password, displayName) => {
        set({ loading: true });
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: { data: { display_name: displayName } },
        });
        if (error) {
          set({ loading: false });
          return { error: error.message };
        }
        if (data.user) {
          await supabase.from('users').insert({
            id: data.user.id,
            display_name: displayName,
            premium: false,
          });
        }
        set({ session: data.session, user: data.user, loading: false });
        return { error: null };
      },

      signOut: async () => {
        await supabase.auth.signOut();
        set({ session: null, user: null, premium: false });
      },

      setPremium: (v) => {
        set({ premium: v });
        if (get().user) {
          supabase.from('users').update({ premium: v, premium_since: v ? new Date().toISOString() : null }).eq('id', get().user!.id);
        }
      },
    }),
    {
      name: 'upmind-auth',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (s) => ({ session: s.session, user: s.user, premium: s.premium, hydrated: s.hydrated }),
    }
  )
);
