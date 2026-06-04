import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { supabase } from '@/lib/supabase';
import type { Construct } from './catalog';
import { CONSTRUCT_ORDER } from './catalog';

const SKILL_DEFAULTS: Record<Construct, number> = {
  attention: 50,
  memory: 50,
  numeracy: 50,
  processing: 50,
  verbal: 50,
  problem: 50,
  executive: 50,
};

export type Session = {
  id?: string;
  gameId: string;
  construct: Construct;
  startedAt: number;
  finishedAt: number;
  score: number;
  rtMedianMs: number;
  rtStddevMs: number;
  accuracy: number;
  drifts: number;
  variant?: string;
  raw?: unknown;
};

type GameState = {
  sessions: Session[];
  skillScores: Record<Construct, number>;
  streakDays: number;
  lastSessionDate: string | null;
  hydrated: boolean;
  hydrate: () => Promise<void>;
  recordSession: (s: Session) => Promise<void>;
  setPremium: (v: boolean) => void;
  reset: () => void;
};

export const useGameStore = create<GameState>()(
  persist(
    (set, get) => ({
      sessions: [],
      skillScores: { ...SKILL_DEFAULTS },
      streakDays: 0,
      lastSessionDate: null,
      hydrated: false,

      hydrate: async () => {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.user) {
          set({ hydrated: true });
          return;
        }
        const { data: sessions } = await supabase
          .from('sessions')
          .select('*')
          .eq('user_id', session.user.id)
          .order('started_at', { ascending: false })
          .limit(200);
        const localSessions = get().sessions;
        const merged = dedupeSessions([
          ...((sessions ?? []).map(rowToSession)),
          ...localSessions,
        ]);
        // Recompute skill scores from merged sessions
        const scores = recomputeSkillScores(merged);
        set({ sessions: merged, skillScores: scores, hydrated: true });
      },

      recordSession: async (s) => {
        // Local first (instant UX), then push to Supabase in background
        const prev = get().sessions;
        const next = [s, ...prev].slice(0, 500);
        const scores = recomputeSkillScores(next);
        const today = new Date().toDateString();
        const last = get().lastSessionDate;
        const streakDays =
          last === today
            ? get().streakDays
            : last === new Date(Date.now() - 86400000).toDateString()
            ? get().streakDays + 1
            : 1;
        set({ sessions: next, skillScores: scores, streakDays, lastSessionDate: today });
        // Push to Supabase if logged in
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          await supabase.from('sessions').insert({
            user_id: session.user.id,
            game_id: s.gameId,
            construct: s.construct,
            started_at: new Date(s.startedAt).toISOString(),
            duration_ms: s.finishedAt - s.startedAt,
            score: s.score,
            rt_median_ms: s.rtMedianMs,
            rt_stddev_ms: s.rtStddevMs,
            accuracy: s.accuracy,
            drifts: s.drifts,
            variant: s.variant ?? null,
            raw: s.raw ?? null,
          });
          // Update skill_scores
          await supabase.from('skill_scores').upsert({
            user_id: session.user.id,
            domain: s.construct,
            score: scores[s.construct],
            sessions_n: next.filter((x) => x.construct === s.construct).length,
            updated_at: new Date().toISOString(),
          });
        }
      },

      setPremium: (v) => {
        // no-op here; auth store handles premium flag
      },

      reset: () => set({
        sessions: [],
        skillScores: { ...SKILL_DEFAULTS },
        streakDays: 0,
        lastSessionDate: null,
      }),
    }),
    {
      name: 'upmind-games',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (s) => ({
        sessions: s.sessions.slice(0, 100),
        skillScores: s.skillScores,
        streakDays: s.streakDays,
        lastSessionDate: s.lastSessionDate,
      }),
    }
  )
);

function dedupeSessions(arr: Session[]): Session[] {
  const seen = new Set<string>();
  const out: Session[] = [];
  for (const s of arr) {
    const k = `${s.gameId}-${s.startedAt}`;
    if (seen.has(k)) continue;
    seen.add(k);
    out.push(s);
  }
  return out.sort((a, b) => b.startedAt - a.startedAt);
}

function rowToSession(row: any): Session {
  return {
    id: row.id,
    gameId: row.game_id,
    construct: row.construct,
    startedAt: new Date(row.started_at).getTime(),
    finishedAt: new Date(row.started_at).getTime() + (row.duration_ms ?? 0),
    score: row.score,
    rtMedianMs: row.rt_median_ms ?? 0,
    rtStddevMs: row.rt_stddev_ms ?? 0,
    accuracy: row.accuracy ?? 0,
    drifts: row.drifts ?? 0,
    variant: row.variant ?? undefined,
    raw: row.raw ?? undefined,
  };
}

function recomputeSkillScores(sessions: Session[]): Record<Construct, number> {
  const scores: Record<Construct, number> = { ...SKILL_DEFAULTS };
  const weekAgo = Date.now() - 7 * 86400000;
  const recent = sessions.filter((s) => s.startedAt > weekAgo);
  for (const domain of CONSTRUCT_ORDER) {
    const domainScores = recent.filter((s) => s.construct === domain).map((s) => s.score).sort((a, b) => a - b);
    if (domainScores.length === 0) continue;
    const mid = Math.floor(domainScores.length / 2);
    scores[domain] = domainScores.length % 2 === 0 ? Math.round((domainScores[mid - 1] + domainScores[mid]) / 2) : domainScores[mid];
  }
  return scores;
}
