# Upmind

Premium executive-function cognitive training app. Built with Expo + React Native + TypeScript.

> See `PRD.md` for the product spec and `.cursor/rules/upmind-team.mdc` for the squad workflow.

## Status (overnight build)

| Screen | Status |
| --- | --- |
| Welcome | ✅ built, premium-styled |
| Value slides (3 cards) | ✅ built, social proof |
| Survey (7–8 questions) | ⏳ next iteration |
| The Briefing mini-game | ⏳ next iteration |
| Paywall | ⏳ next iteration |
| Auth (Google + Email) | ⏳ stub routes, full impl next iteration |
| Tests (Jest + Maestro) | ✅ scaffold + Welcome snapshot + onboarding flow |

## Stack

- **Expo SDK 51** with `expo-router` file-based routing
- **React Native 0.74** + **Reanimated 3** for calm motion
- **TypeScript** strict mode
- **Supabase** auth + data (wired in `src/lib/supabase.ts`, env-driven)
- **Jest** + `@testing-library/react-native` for unit/snapshot
- **Maestro** for E2E (`/Users/ishaanparmar/Desktop/projects/upmind/.maestro`)

## Design system

Single source of truth in `src/theme/tokens.ts`.

- Background `#0A0F1C`, elevated `#0F172A`
- Teal accent `#14B8A6` (with `#5EEAD4` soft variant)
- Headspace-style calm motion (480–520ms ease cubic)

## Run it

```bash
npm install
npm run start          # Expo dev server
npm run ios            # iOS simulator
npm run android        # Android emulator
npm run typecheck      # tsc --noEmit
npm test               # jest
npm run test:maestro   # E2E (requires a built app + Maestro CLI)
```

## Layout

```
app/                  # expo-router routes
  index.tsx           # → Welcome
  onboarding/         # value, survey, briefing, paywall
  auth/               # sign-in, sign-up
src/
  components/         # Button, Screen, ProgressDots, Aurora
  screens/            # full screen bodies
  state/              # onboarding store (lightweight zustand shim)
  theme/              # tokens + index
  lib/                # supabase client, etc.
.maestro/             # E2E flows
__tests__/            # jest unit + snapshot
```

## Security

- **Do not commit secrets.** `.gitignore` excludes `.env*.local`.
- The original `mcp.json` shipped with a real GitHub PAT + Firecrawl key in plaintext. **Rotate both** and move to env vars before any push to a public repo.
