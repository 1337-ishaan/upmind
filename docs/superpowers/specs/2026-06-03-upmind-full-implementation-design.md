# UpMind: Full Implementation Design

## Overview
Complete the UpMind PWA cognitive training app with all 42 games, end-to-end payment flow, chess.com-style global leaderboard, onboarding walkthrough, and light/beige mode toggle.

## Architecture
- Single `index.html` PWA (existing), no framework, no build step
- All data in localStorage
- Service worker for offline caching (existing)
- Game framework pattern: all games share a common `<game-screen>` pattern with reusable components (timed grid, sequence recall, multiple choice, reaction button, number line, sorting grid)

## Components

### 1. Game Framework (shared by all 42 games)
Each game is a JS config object with:
- `id`, `title`, `domain`, `description`, `icon`
- `trialCount`, `timeLimit` (optional), `difficulty` (adaptive)
- `template` (which UI variant to use: `choice`, `sequence`, `grid`, `reaction`, `sort`, `recall`, `numberline`, `verbal`)
- `generateTrial(trialNum, difficulty)` — creates question + correct answer
- `scoreTrial(response, trial)` — returns accuracy + reaction time
- `getFeedback(trial, response)` — optional feedback text
- Scoring engine (existing): `score = accuracy × (0.6 + 0.4 × rtStability) × speedFactor × 100`
- Each game contributes to its domain's skill score (6 domains: attention, memory, numeracy, processing, problem, verbal)

### 2. Leaderboard (chess.com-style)
- **Local rating**: ELO-like rating per domain (starting 1200, K=32)
- **Simulated global leaderboard**: 1000 generated players with realistic score distributions
- **Views**: Today / This Week / This Month / All Time
- **Filters**: By domain, by game
- **Your stats**: Rating, percentile, rank, trend arrow
- **Rating history**: Small sparkline showing last 30 sessions
- Chess.com-style layout: compact table with rank avatar/initial, name, rating, games played, last active

### 3. Payment Flow (mock)
- **Plan selection**: Free vs Premium ($9.99/mo or $79.99/yr)
- **Feature comparison**: Free (all games except Executive Function, basic insights) vs Premium (all games + Executive Function domain, detailed insights, advanced filters)
- **Checkout**: Apple Pay mock (shows payment sheet animation) + Card entry mock (card number, expiry, CVC fields with validation UI)
- **Confirmation**: Thank you screen, premium badge on profile
- **Entirely client-side**: No real API calls, payment marked in localStorage

### 4. Onboarding Walkthrough
- 4 horizontal swipeable screens on first launch
  1. **Brand**: "Measured, not gamified" — your cognitive fitness, tracked honestly
  2. **Domains**: 6 pillars of cognitive health with icons
  3. **Scoring**: Transparent formula — accuracy × speed × consistency
  4. **Start**: "Try your first drill" button
- Dot indicators, skip button, Next/Get Started button
- Shown once (localStorage `onboardingComplete` flag)
- Slides have subtle parallax background effect

### 5. Light Mode (Beige Theme)
- Toggle in Profile view
- CSS custom properties swap:
  - `--bg: #1a1a2e → #F5F0E8` (beige)
  - `--card-bg: #16213e → #FFFFFF`
  - `--text-primary: #e8e8e8 → #2C2416`
  - `--text-secondary: #a0a0b0 → #6B6258`
  - `--border: #2a2a4a → #E0D8CC`
  - Accent stays `--accent: #14B8A6`
  - All charts/grids adjust colors accordingly
- Stored in localStorage `theme` key

## Games (42 total)

### Attention (6)
1. **Stroop Test** ✓ (existing) — name ink color, ignore word
2. **Flanker Focus** — center arrow direction with flanking arrows (congruent/incongruent)
3. **Go/No-Go** — press for animals, don't press for objects
4. **Context Switcher** — respond to category then decide if item fits
5. **Selective Attention** — find target letter in letter grid
6. **Divided Attention** — respond to visual + audio cues simultaneously

### Memory (7)
7. **Digit Span** — repeat number sequence (forward/reverse)
8. **Corsi Blocks** — tap blocks in shown sequence
9. **N-Back** — was this item shown N steps ago?
10. **Paired Associates** — remember which pairs went together
11. **Word List Recall** — remember all words from a list
12. **Picture Recognition** — was this picture shown before?
13. **Spatial Span** — remember positions in a grid

### Numeracy (7)
14. **Mental Math** ✓ (existing) — solve arithmetic problems
15. **Number Line** — estimate position on a number line
16. **Estimation** — approximate the answer (no exact calc)
17. **Quantity Comparison** — which group has more?
18. **Numerical Estimation** — estimate how many dots
19. **Arithmetic Verification** — is this equation correct (quick)?
20. **Fraction Comparison** — which fraction is larger?

### Processing Speed (7)
21. **Reaction Time** ✓ (existing) — tap as fast as possible
22. **Symbol-Digit** — match symbols to numbers
23. **Pattern Comparison** — are these patterns the same?
24. **Visual Search** — find target in a field
25. **Letter Comparison** — are these letter strings same?
26. **Number Comparison** — are these numbers same?
27. **Simple RT** — tap on flash stimulus

### Language (7)
28. **Synonyms** — choose correct synonym
29. **Word Scramble** — unscramble the letters
30. **Analogies** — complete the analogy (A:B::C:?)
31. **Verbal Fluency** — name words from category (FAS test style)
32. **Sentence Completion** — choose best word
33. **Antonyms** — choose opposite
34. **Word Definition** — choose correct definition

### Problem Solving (7)
35. **Rule Detection** (WCST) — sort cards by changing rules
36. **Matrix Reasoning** — what comes next in pattern (Raven's style)
37. **Tower of London** — move pegs from start to target
38. **Category Fluency** — name items in category
39. **Spatial Planning** — navigate shortest path in grid
40. **Inhibition** — say opposite of what you see (reverse strobe)
41. **Set Shifting** — switch between two rule sets

### Executive Function (1 - Premium)
42. **Trail Making** — connect alternating numbers and letters sequence

## Data Flow
- Games → trial results (accuracy, rt) → scoring engine → skill scores (rolling average, last 20 sessions)
- Skill scores → radar chart, weekly bars, history heatmap (existing)
- Rating system → ELO per domain → leaderboard rankings
- Theme preference → CSS variables swap → persisted
- Premium status → localStorage → UI unlocks

## Scoring & Rating
- Per-game: accuracy, reaction time, consistency (RT stability)
- Per-domain skill score: rolling weighted average of last 20 game sessions
- Rating (ELO): starting 1200, K=32, updated after each session vs simulated benchmark
- Leaderboard position: computed from rating vs 1000 simulated player ratings

## Implementation Order
1. Game framework + all 42 games (15-20 at a time, in parallel batches)
2. Onboarding walkthrough
3. Leaderboard (chess.com-style)
4. Payment flow (mock)
5. Light mode toggle
6. Polish + integration testing
