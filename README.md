# Upmind

The honest cognitive-fitness app — an 8-minute daily drill across six mental skills (attention, memory, processing speed, problem-solving, numeracy, language). Real per-skill metrics, never a fake brain-age.

## What's here
- **`index.html`** — marketing landing page ("Instrument Calm" light design: Fraunces / Hanken Grotesk / Spline Mono; blue = action, green = signal).
- **`onboarding.html`** — interactive onboarding prototype (~26 screens) built on the high-converting intro → climax → conclusion → paywall structure: name personalization, a computed "refocus cost" stat, a real 40-second attention drill that measures a focus baseline, signature commitment pact, and a trial-timeline paywall.
- **`assets/brain.png`** — brain region-map illustration used on the landing page.

## Run locally
Static site — no build step.
```bash
python3 -m http.server 8910
# landing:    http://localhost:8910/
# onboarding: http://localhost:8910/onboarding.html
```

## Live
- Landing: https://site-cyan-one.vercel.app
- Onboarding: https://site-cyan-one.vercel.app/onboarding.html
