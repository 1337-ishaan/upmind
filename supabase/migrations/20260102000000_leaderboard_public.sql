-- Make the public leaderboard view readable for everyone.
--
-- Root cause: public.leaderboard is a regular view (security_invoker=false by
-- default in Postgres 15+, but here we explicitly want the view owner to read
-- the underlying tables). The view joins public.skill_scores and public.users,
-- both of which have RLS policies that restrict SELECT to auth.uid() = user_id.
-- When any user queries the view, the underlying table reads are evaluated
-- against the *invoking* user's RLS, so each user only ever sees their own
-- row in the view — leaderboard is effectively empty.
--
-- Fix (simplest reliable approach): add a public SELECT policy on
-- public.skill_scores. Scores and display_name are intended to be public on a
-- leaderboard. We also add a public SELECT policy on public.users so the view
-- can resolve display_name for any player. The users table only holds
-- id, display_name, premium, premium_since, created_at — premium is a
-- non-sensitive product fact and id is already leaked via auth.
--
-- The existing "self read"/"self write" policies remain for write paths and
-- are unaffected (this migration only adds permissive SELECT policies; we use
-- OR-style policy names so they coexist with the existing ones).

drop policy if exists "skill_scores public read" on public.skill_scores;
create policy "skill_scores public read" on public.skill_scores
  for select
  to anon, authenticated
  using (true);

drop policy if exists "users public read" on public.users;
create policy "users public read" on public.users
  for select
  to anon, authenticated
  using (true);

-- Recreate the view with explicit settings to lock in the security model.
-- security_invoker = false means the underlying table reads run as the view
-- owner (postgres), which bypasses RLS — but we also expose the tables
-- publicly above, so behavior is consistent whether the view is queried by an
-- anon user, an authenticated user, or the view owner.
drop view if exists public.leaderboard;
create view public.leaderboard
  with (security_invoker = false) as
  select
    u.id,
    u.display_name,
    s.domain,
    s.score as elo,
    rank() over (partition by s.domain order by s.score desc) as rank
  from public.skill_scores s
  join public.users u on u.id = s.user_id;

grant select on public.leaderboard to anon, authenticated;
