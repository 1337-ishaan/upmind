# Upmind Motion Redesign: "Lucid" Motion System

**Date:** 2025-06-03
**Status:** Draft for review
**Stack target:** Expo SDK 51 + Reanimated 3 + Gesture Handler + Haptics

---

## Part 1: Research Synthesis

### What We Learned from Industry Leaders

| Source | Key Insight | Upmind Application |
|--------|-------------|-------------------|
| Headspace | Breathing animations synced to natural cadence; custom illustration system as brand vehicle | Aurora reacts to depth-of-breath; animated illustrations for cognitive exercises |
| Duolingo | Skeleton morphing between states; character-based micro-interactions; streak celebrations | Skill trees animate on completion; character guides through assessments |
| Apple (WWDC) | Shared element transitions create spatial model; spring physics feel natural | Every screen transition morphs shared elements; no hard cuts |
| Linear | Micro-interactions replace microcopy; motion is the UI layer | Buttons don't say "saved" — they morph into checkmarks with haptic |
| Calm | Minimalist with purpose; parallax depth on scroll | Value slides have layered depth parallax; survey has immersive full-screen |
| Rive | State-machine-driven interactive animations | Animated character/guide that reacts to user input in real-time |

### Current State Problems

| What Exists | Why It Fails | Fix |
|-------------|-------------|-----|
| `Aurora.tsx` — 3 static colored blobs | Zero animation; waste of GPU | Full particle aurora system with organic drift + breath response |
| `WelcomeScreen.tsx` — fade+translateY | Generic; zero "wow"; tells no story | Skeleton morph + kinetic typography + particle reveal |
| `ValueSlidesScreen.tsx` — FlatList slides | Passive consumption; user doesn't *feel* the value | Gesture-driven card flipping; parallax depth; immersive reveals |
| `Button.tsx` — basic scale press | No feedback beyond visual; no brand personality | Morph button (changes shape per state) + haptic layers + ripple |
| `motion` tokens — single bezier curve `0.22/1/0.36/1` | No physics; no spring; no gesture tokens | Complete spring/physics/duration system |
| Screen transitions — none (stack push) | Hard cuts break immersion | Shared element transitions + animated route transitions |

---

## Part 2: The "Lucid" Motion System

### 2.1 Motion Philosophy

> *"Every animation must serve one purpose: make the user feel in control of their own mind."*

Three principles:
1. **Breath as beat** — animations follow natural breathing rhythm (~3s inhale, 3s exhale cycle)
2. **Physics over presets** — spring animations feel alive; no canned bezier curves
3. **Motion as feedback** — every gesture produces a proportional, contextual response

### 2.2 New Motion Tokens

Replace the current flat `motion` object:

```typescript
// src/theme/tokens.ts — new motion system

export const motion = {
  // SPRING PRESETS (for interactive, gesture-driven animations)
  spring: {
    // User-initiated gestures (snappy, feels responsive)
    snappy: { damping: 14, stiffness: 300, mass: 0.5 } as const,
    // Card interactions (feels physical, weighty)
    card: { damping: 20, stiffness: 200, mass: 1 } as const,
    // Page transitions (smooth, deliberate)
    page: { damping: 26, stiffness: 150, mass: 1.2 } as const,
    // The "wobble" — fun micro-interactions (like button morph)
    playful: { damping: 8, stiffness: 200, mass: 0.8 } as const,
    // Breathing (organic, slow, natural)
    breath: { damping: 30, stiffness: 60, mass: 2 } as const,
  },

  // TIMING PRESETS (for ambient/continuous animations)
  duration: {
    micro: 200,    // ripple, press state
    fast: 350,     // button morph, icon switch
    base: 500,     // element enter/exit
    slow: 800,     // screen transitions
    ambient: 3000, // aurora drift, particle cycle
  },

  // STAGGER PRESETS (for list/chunk animations)
  stagger: {
    fast: 60,
    base: 100,
    slow: 150,
  },

  // EASING (only for non-interactive, ambient animations)
  easing: {
    // Use for particles, ambient glow — never for gestures
    calm: [0.22, 1, 0.36, 1] as EasingFunction,
    // For elements that should overshoot slightly then settle
    anticipatory: [0.34, 1.56, 0.64, 1] as EasingFunction,
  },
} as const;
```

### 2.3 The Motion Component Hierarchy

```
Lucid Motion System
├── Ambient Layer (always-on, atmospheric)
│   ├── AuroraParticles — organic drift aurora; reacts to user state like breathe or focus
│   ├── GlowPulse — subtle pulsing on key UI elements (breath-synced)
│   └── FloatEffect — gentle floating for decorative elements (1-2px y-axis, breath cycle)
│
├── Transition Layer (screen-level navigation)
│   ├── SharedElement — image/text morphs between screens (Reanimated 3)
│   ├── RouteTransition — animated route stack (slide + crossfade + scale)
│   └── HeroAnimation — full-screen hero element animates in from previous element
│
├── Interaction Layer (user-initiated feedback)
│   ├── MorphButton — button changes shape/icon per state (idle → loading → success/error)
│   ├── GestureCard — swipeable, tilt-on-pan, spring-back; with haptic snap points
│   ├── PressRipple — expanding ripple on press with haptic light/medium/heavy layers
│   └── ToggleMorph — switches morph shape (checkbox → animated toggle)
│
├── Content Layer (text/media reveals)
│   ├── KineticText — words animate in with variable timing, weight, color
│   ├── StaggerList — items enter sequentially with spring physics
│   ├── CountUp — numbers roll up on appear (for cognitive scores, streaks)
│   └── ParallaxScroll — layered depth on scroll (background moves slower)
│
└── Feedback Layer (system state changes)
    ├── BreathIndicator — subtle UI pulse synced to breathing exercise frequency
    ├── Celebration — particle burst + scale + haptic firework on completion
    └── ProgressMorph — progress bar transforms into completion check
```

---

## Part 3: Screen-by-Screen Motion Design

### Screen 1: Welcome (The Hook)

**Current:** Logo appears → fade-in subtitle → fade-in button → nothing else.

**Proposed:**

```
Sequence (3-second entry):
1. App opens to pure deep navy (#0A0F1C) — no content, just the Aurora alive
2. Aurora wakes: particles drift from center outward in a expanding ring (like a ripple in a pond)
3. 400ms: "Upmind" LOGO morphs in — not fade, but MORPH: particles coalesce into the wordmark, then settle
4. 700ms: Tagline "Master your mind" kinetic-typed — each word animates in with slight spring bounce
   - "Master" → appears with upward velocity, settles
   - "your" → lighter weight, appears floating
   - "mind" → heavier weight, bold, emphasized with a subtle glow pulse behind it
5. 1100ms: Two buttons enter from bottom — not slide but SPROING (spring playful preset)
   - "Begin" → primary morph button
   - "I have a code" → text-only, gentle fade
6. Background Aurora continues to drift — particles subtly attracted toward touch points

Micro-interactions:
- User taps "Begin" → button morphs: turns into a glowing circle, shrinks, screen transitions via shared element
- Long press anywhere → Aurora particles scatter away from touch point (like ripples)
- Shake device → particles reorganize (playful discovery)
```

### Screen 2-4: Value Slides (The Story)

**Current:** FlatList with 3 slides, static content, basic fade-on-scroll.

**Proposed:**

```
⸻ Slide 1: "Understand Your Cognitive Architecture"
⸻ Slide 2: "Train With Precision"
⸻ Slide 3: "See Your Growth"

Interaction Model:
- GESTURE-DRIVEN CARDS — each slide is a 3D card that tilts via gyroscope/pan
- As user scrolls, cards have parallax layers:
  - Layer 1 (deepest): Aurora pattern, moves slow
  - Layer 2 (mid): Illustration/graphic, moves medium
  - Layer 3 (top): Text content, moves with scroll
- On REACHING a slide: content has staggered spring entrance (text → graphic → CTA)
- On LEAVING a slide: current content exits with overshoot, next content pre-warms

Per Slide:

Slide 1 (Understand):
- Background: Aurora shifts to cool blue/teal gradient
- Graphic: Animated brain scan rings — concentric circles pulse with breath rhythm
- Kinetic text: "Understand" appears first, bold. "Your Cognitive Architecture" cascades in word-by-word
- CTA: "Swipe to learn more" — animated hand/arrow that follows user's actual finger position

Slide 2 (Train):
- Background: Aurora shifts to warm amber/teal — "energy" palette
- Graphic: Animated circuit/neural network — lines pulse in sequence like firing neurons
- Kinetic text: "Train" springs in with bounce. "With Precision" — each letter appears slightly staggered
- CTA: A demo/mini-game you can interact with — tap circles that appear (gives a taste of training)
- Micro-interaction: User's taps produce ripple effects on the circles

Slide 3 (Grow):
- Background: Aurora shifts to gold/teal gradient — "achievement" palette
- Graphic: Animated growth chart — a line graph draws itself left-to-right with spring velocity
- Kinetic text: "See" → floating. "Your" → pause. "Growth" → heavy, bold, with sparkle particles
- CTA: Button pulses gently with breath rhythm, inviting the tap
- Micro-interaction: The graph responds to touch — dragging finger along it shows data points

Progress Indicator:
- Current: linear dots (boring)
- Proposed: Animated path — dots are connected by a line that draws itself as user scrolls
  - Each dot pulses when active with breath rhythm
  - Completed dots have a subtle checkmark morph
  - Dot transitions are spring-animated, not crossfade
```

### Screen 5: Survey (The Personalization)

**Current:** Standard multi-step form.

**Proposed:**

```
Format: Full-screen immersive question cards (NOT form fields)

Each question:
1. Background aurora shifts color to match question mood
2. Question text kinetic-types in word-by-word
3. Options enter staggered with spring physics
4. On selection:
   - Selected option: expands slightly, glows, checkmark morphs in
   - Other options: shrink and fade slightly
   - Haptic: medium impact on tap
   - Button at bottom: "Continue" morphs from text link to filled button

Question types:
- "What's your primary goal?" → card grid that fans in from center
- "How often do you experience..." → sliding scale with animated thumb that follows touch with spring
- "Rate your focus" → animated gauge that the user drags (like an analog dial)

Transition between questions:
- AFTER answering: current card collapses (like a paper folding in half)
- NEXT card expands from behind it (like unfolding)
- Aurora shifts during the transition (color lerp over 500ms)
- Progress: a thin line at top animates width with spring — not linear
```

### Screen 6: Briefing (The Reveal)

**Current:** Static results screen.

**Proposed:**

```
This is the "wow" moment — the payoff for completing the survey.

Entry sequence:
1. Screen opens to dark — Aurora goes very dim, almost black
2. 300ms: A single particle of light appears in center
3. 600ms: Particle expands into a ring (like a radar ping)
4. 900ms: Your primary score appears — number COUNT UP from 0 to score with spring velocity
   - Each digit rolls like a slot machine
   - Haptic: light tick per digit
5. 1200ms: Score label fades in below ("Cognitive Focus Score")
6. 1500ms: Supporting metrics cascade in staggered (like a glass filling up)
   - Each metric is a horizontal bar that animates width left-to-right
   - Bars have different colors based on category (focus=teal, memory=purple, etc.)
7. 2000ms: "Your Journey" section — a horizontal timeline of recommended exercises
   - Each module card springs in from the right
   - Cards have different heights based on duration

The Big Reveal:
- The entire briefing is a SHARED ELEMENT — the survey's "focus" section morphs into the briefing's focus score
- Tapping a metric card expands it to full screen with a shared element transition
- The Aurora reflects your primary score — more particles = higher score
```

### Screen 7: Paywall (The Close)

**Current:** Standard subscription options.

**Proposed:**

```
Entry:
1. Content slides in from bottom — NOT a push screen (modal-like)
2. Header: "Unlock Your Potential" — kinetic type with each word having different weight
3. Plan cards: 3 cards with depth (shadow + slight y-offset):
   - Monthly: standard card
   - Annual (highlighted): card is slightly raised, has a pulsing "Best Value" badge
   - Lifetime: card has a subtle shimmer gradient
4. Selecting a plan:
   - Card expands slightly, others shrink
   - "Subscribe" button glows more intensely
   - Price text count-up animation

Micro-interactions:
- "Try 7 days free" — countdown timer animates below ("Your trial starts now" with a morph)
- Tapping "Subscribe" → button morphs through loading → success with haptic firework
- "Restore" → gentle fade-in animation, lives in background

Exit:
- "Maybe later" — text link that when tapped, cards slide down and out with spring, Aurora dims
- No hard cut — ambient exit animation
```

### Screen 8: Auth (The Handoff)

**Current:** Standard email/password form.

**Proposed:**

```
- Ties back to onboarding — not a separate experience
- "Create your account" — kinetic type fades in
- Input fields: each has an animated underline that pulses with breath rhythm
- On typing: underline grows, glow intensifies proportionally
- Email field → when valid, checkmark morphs in subtly
- Password → strength meter is an animated bar that thrums
- "Continue" button shares morph transition with paywall CTA

Social options:
- Apple/Google buttons: have the logo slide in from left on appear
- Tapping social: brief loading state where button turns into a spinner that IS the logo
```

---

## Part 4: New Component Architecture

### 4.1 `AuroraParticles` — The Soul of the App

Replaces the current `Aurora.tsx` static blobs.

```typescript
// Conceptual API:
<AuroraParticles
  density={30}           // number of particles (scales by screen size)
  colorPalette={['#14B8A6', '#0EA5E9', '#8B5CF6']}  // teal, sky, violet
  reactivity="breath"    // 'breath' | 'touch' | 'focus' | 'celebration'
  speed="ambient"        // ambient | calm | alert
/>
```

**Behavior by mode:**
- `breath`: Particles drift in a slow circular pattern synced to 3s inhale/3s exhale. On inhale, particles expand outward. On exhale, contract inward.
- `touch`: Particles are attracted to the user's last touch point. When touched, particles scatter and slowly return.
- `focus`: Particles move toward the center of the screen in a tight formation. Minimal movement — user is concentrating.
- `celebration`: Particles burst outward from a center point with velocity, then slowly settle back.

**Rendering:**
- `react-native-skia` or raw `Canvas` via `@shopify/react-native-skia` for GPU-accelerated particle rendering
- Fallback to `Animated.View` (degraded) on low-end devices
- Each particle has: position (x,y,z), size, opacity, hue, velocity, drift angle
- Update loop: `useAnimatedReaction` on shared values at 60fps

### 4.2 `MorphButton` — The Interaction Hub

Replaces `Button.tsx`.

```typescript
// Conceptual API:
<MorphButton
  variant="primary"      // primary | secondary | ghost
  state="idle"           // idle | loading | success | error
  onPress={handlePress}
  haptic="medium"        // light | medium | heavy | notification | none
>
  Subscribe
</MorphButton>
```

**State transitions:**
1. `idle → loading`: Button width shrinks to circle, content fades out, spinner spins in place
2. `loading → success`: Spinner morphs into checkmark, button briefly expands with spring playful, haptic notification success
3. `loading → error`: Spinner morphs into X, button shakes (left-right spring), haptic notification error
4. `idle → pressed`: Scale to 0.96 with spring snappy, ripple expands from touch point

### 4.3 `KineticText` — Words That Land

```typescript
// Conceptual API:
<KineticText
  text="Master your mind"
  animation="cascade"    // cascade | bounce | float | morph
  weight={['bold', 'regular', 'bold']}  // per-word weight
  color={['#FFF', '#94A3B8', '#FFF']}
  stagger={60}           // ms between words
  onComplete={onIntroDone}
/>
```

**Animation modes:**
- `cascade`: Each word falls from above, bounces once, settles (spring playful)
- `bounce`: Words pop in from below with elastic bounce
- `float`: Words fade in while floating upward gently (breath timing)
- `morph`: Letters assemble from particles (heavy — use sparingly)

### 4.4 `GestureCard` — Touch That Feels

```typescript
// Conceptual API:
<GestureCard
  tiltIntensity={5}      // degrees of tilt on pan
  hapticSnap={true}      // haptic at snap points
  onSwipeLeft={onDismiss}
  onSwipeRight={onAccept}
  layers={[
    <BackgroundLayer />, // parallax layer (slowest)
    <GraphicLayer />,    // illustration layer
    <ContentLayer />,    // text layer (tracks gesture)
  ]}
>
```

**Physics:**
- Pan gesture drives rotation via `useAnimatedStyle` with `transform[{rotateX}]`
- On release: springs back to neutral with `spring.card` preset
- If swipe threshold exceeded: card flies off screen with velocity, haptic snap
- Multitouch: two-finger pinch scales content (e.g., for zooming into a metric)

### 4.5 `SharedElementTransition` — Spatial Navigation

```typescript
// Conceptual API:
// In root layout navigator:
<SharedElement>
  <Stack.Screen name="value-slides" component={ValueSlides} />
  <Stack.Screen name="survey" component={Survey} />
</SharedElement>

// Per-element:
<SharedElement id="focus-score">
  <Text>{score}</Text>
</SharedElement>
```

**Morphing pairs (source → destination):**
- Welcome "Upmind" logo → Briefing "Upmind" logo (position morph)
- Value Slide illustration → Survey question mood graphic (color + position)
- Survey "continue" button → Briefing score number (morphs from circle to number)
- Briefing metric card → Module detail (scale-to-full)

**Implementation note:** Reanimated 3 does not have built-in `sharedTransitionTag` like in newer SDKs. Use custom `useSharedValue` + `useAnimatedStyle` with `withSpring` interpolated across screen mount/unmount. Pattern: measure source element rect on navigation, animate to destination rect.

---

## Part 5: User Flow With Motion Annotations

```
App Open
  │
  ▼
WELCOME (3s ambient entry)
  ├── Aurora wakes (0ms)
  ├── Logo morphs from particles (400ms)
  ├── Tagline kinetic types (700ms)
  ├── Buttons spring in (1100ms)
  │
  ▼ [Tap "Begin"]
  │
BUTTON MORPH → circle → shrink → shared element to...
  │
  ▼
VALUE SLIDES (gesture-driven)
  ├── Slide 1: "Understand" — aurora cool/teal
  │   ├── Parallax layers
  │   ├── Kinetic cascade text
  │   └── Gesture: tilt card on pan
  │
  ├── Slide 2: "Train" — aurora warm/amber
  │   ├── Neural network animation
  │   └── Micro-interaction: tap demo circles
  │
  ├── Slide 3: "Grow" — aurora gold/teal
  │   ├── Self-drawing growth chart
  │   └── Breath-pulsing CTA
  │
  ▼ [Swipe or tap "Continue"]
  │
SLIDE LEFT → fold transition to...
  │
  ▼
SURVEY (immersive question cards)
  ├── Q1: Goal selection cards — fan in from center
  │   └── [Select] → card glow + haptic medium
  │
  ├── Q2: Frequency slider — gauge drag
  │   └── [Select] → card fold → next card unfold
  │
  ├── Q3: Focus rating — analog dial
  │   └── [Select] → card fold → next card unfold
  │
  └── Q4 (n): ... more questions with same pattern
  │
  ▼ [Last question answered]
  │
COLLAPSE → dark → single particle → EXPAND into...
  │
  ▼
BRIEFING (the payoff — 2.5s reveal)
  ├── Score count-up with slot roll digits + haptic ticks
  ├── Metric bars cascade left-to-right
  ├── Journey cards spring in from right
  └── Aurora reflects score density
  │
  ▼ [Tap "Begin your journey"]
  │
BUTTON MORPH → shared element to...
  │
  ▼
PAYWALL (modal slide-up)
  ├── Plan cards with depth (monthly/annual/lifetime)
  ├── Annual highlighted with pulsing badge
  ├── Price count-up on selection
  └── Button morph: idle → loading → success (or error)
  │
  ▼ [Subscribe / Try free]
  │
BUTTON MORPH SUCCESS → shared element to...
  │
  ▼
AUTH (seamless handoff)
  ├── Animated input underlines
  ├── Password strength bar thrums
  └── Social buttons with slide-in logos
  │
  ▼ [Signed in]
  │
  → Main App (full celebration: aurora burst + particles + haptic firework)
```

---

## Part 6: Implementation Roadmap

### Phase 1 (Foundation) — ~2 days
1. Update `motion` tokens with spring/physics system
2. Build `AuroraParticles` with basic ambient drift mode
3. Build `KineticText` with cascade mode
4. Build `MorphButton` with idle→loading→success states

### Phase 2 (Screens) — ~2 days
1. Rewrite `WelcomeScreen` with kinetic text + particle reveal
2. Rewrite `ValueSlidesScreen` with gesture cards + parallax
3. Add shared element transitions between Welcome and ValueSlides

### Phase 3 (Survey + Briefing) — ~2 days
1. Rewrite survey with immersive cards + question transitions
2. Rewrite briefing with count-up + bar animations
3. Add shared element transitions for score morphing

### Phase 4 (Paywall + Auth + Polish) — ~2 days
1. Rewrite paywall with plan selection animations
2. Add celebration/breath/focus aurora modes
3. Haptic pass across all interactions
4. Performance optimization (reduce JS thread load)

---

## Part 7: Performance Considerations

### Reanimated 3 Worklet Strategy
- All animations run on UI thread via `useAnimatedStyle` + `withSpring`
- No `useState` during active animations — use `useSharedValue`
- Gesture handling on UI thread via `Gesture.Pan()` from gesture-handler v2
- Avoid `runOnJS` calls during animation frames (use for haptics only)

### Rendering Budget
- AuroraParticles: max 50 particles on UI thread via Skia Canvas
- Screen transitions: off-screen rendering via `Animated.View` with `position: absolute`
- Parallax: use `Animated.ScrollView` scrollTo with shared scroll value, not re-renders

### Haptic Layer
- Light: button press, dot advance, text completion
- Medium: card snap, option selection, score tick
- Heavy: transaction complete, achievement unlock, onboarding finish
- Notification: error (notificationError), success (notificationSuccess)
