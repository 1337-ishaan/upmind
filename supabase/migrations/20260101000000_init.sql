-- Upmind Supabase schema
-- Apply via Supabase SQL editor or supabase db push.
-- Requires: Postgres 14+ with pgcrypto for gen_random_uuid.

create extension if not exists pgcrypto;

-- ── users ──
create table if not exists public.users (
  id uuid primary key references auth.users on delete cascade,
  display_name text,
  premium boolean not null default false,
  premium_since timestamptz,
  created_at timestamptz not null default now()
);
alter table public.users enable row level security;
drop policy if exists "users self read" on public.users;
create policy "users self read" on public.users for select using (auth.uid() = id);
drop policy if exists "users self insert" on public.users;
create policy "users self insert" on public.users for insert with check (auth.uid() = id);
drop policy if exists "users self update" on public.users;
create policy "users self update" on public.users for update using (auth.uid() = id);

-- ── sessions ──
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users on delete cascade,
  game_id text not null,
  construct text not null check (construct in ('attention','memory','numeracy','processing','verbal','problem','executive')),
  started_at timestamptz not null,
  duration_ms int not null,
  score int not null check (score between 0 and 100),
  rt_median_ms int,
  rt_stddev_ms int,
  accuracy numeric,
  drifts int not null default 0,
  variant text,
  raw jsonb
);
create index if not exists sessions_user_started_idx on public.sessions (user_id, started_at desc);
alter table public.sessions enable row level security;
drop policy if exists "sessions self read" on public.sessions;
create policy "sessions self read" on public.sessions for select using (auth.uid() = user_id);
drop policy if exists "sessions self insert" on public.sessions;
create policy "sessions self insert" on public.sessions for insert with check (auth.uid() = user_id);

-- ── skill_scores ──
create table if not exists public.skill_scores (
  user_id uuid not null references public.users on delete cascade,
  domain text not null check (domain in ('attention','memory','numeracy','processing','verbal','problem','executive')),
  score int not null check (score between 0 and 100),
  sessions_n int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, domain)
);
alter table public.skill_scores enable row level security;
drop policy if exists "skill_scores self read" on public.skill_scores;
create policy "skill_scores self read" on public.skill_scores for select using (auth.uid() = user_id);
drop policy if exists "skill_scores self write" on public.skill_scores;
create policy "skill_scores self write" on public.skill_scores for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── public leaderboard view ──
create or replace view public.leaderboard as
  select
    u.id,
    u.display_name,
    s.domain,
    s.score as elo,
    rank() over (partition by s.domain order by s.score desc) as rank
  from public.skill_scores s
  join public.users u on u.id = s.user_id;

grant select on public.leaderboard to anon, authenticated;
