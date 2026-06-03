# UpMind Full Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the UpMind PWA with all 42 games, chess.com-style leaderboard, onboarding, payment flow, and light mode.

**Architecture:** Single `index.html` PWA. Build a generic game template system where all 42 games share 7 reusable UI patterns (choice, sequence, reaction, grid, numberline, sorting, type). Games become config objects + trial generators. Add 4 features as independent JS blocks. All state in localStorage.

**Tech Stack:** Vanilla HTML/CSS/JS, no frameworks, no build step, localStorage persistence, Service Worker for offline.

---

## File Structure

All changes go into one file: `index.html`. No new files needed (manifest.json, sw.js, icon.svg stay as-is).

**Game framework:** New JS section in index.html:
- `GAME_TEMPLATES` — 7 reusable UI layouts (choice, sequence, reaction, grid, recall, numberline, type)
- `GAMES` array expanded from 3 → 42 entries, each with `{id, name, icon, area, desc, color, template, trials, generateTrial, feedback}`

**Feature sections** (appended in index.html):
- `ONBOARDING` — 4-screen walkover HTML + JS
- `LEADERBOARD` — ELO rating system, simulated players, HTML views
- `PAYMENT` — mock subscription flow HTML + JS
- `LIGHT MODE` — CSS variable swap via theme toggle

---

### Task 1: Game Template Framework

**Files:** Modify `index.html` (add after line 357, replacing GAMES array)

- [ ] **Step 1: Define GAME_TEMPLATES enum and GAMES config objects**

Replace the GAMES array (lines 353-357) with scalable config:

```js
// ── GAME TEMPLATES ──
const TEMPLATES = {
  CHOICE: 'choice',       // N options, pick one
  SEQUENCE: 'sequence',   // Watch sequence, repeat it
  REACTION: 'reaction',   // Tap on stimulus
  GRID: 'grid',           // Find target in grid
  RECALL: 'recall',       // Remember and identify items
  NUMBERLINE: 'numberline', // Drag to estimate position
  TYPE: 'type',           // Type your answer
  SORT: 'sort'            // Sort/classify items
};

const AREA_MAP = { Attention:'attention', Numeracy:'numeracy', Speed:'processing', Memory:'memory', 'Problem-Solving':'problem', Verbal:'verbal' };
```

- [ ] **Step 2: Add trial generators for all 42 games**

Replace the function structure so each game has:
```js
function generateTrial(gameId, difficulty) { /* returns {stimulus, options, correct, template, feedback} */ }
```

For each game template, create a handler:
```js
const GAME_HANDLERS = {
  // CHOICE template handler
  choice: {
    render(stimulus, options) {
      return `<div class="choice-grid">${options.map(o => `<div class="choice-btn" data-value="${o.value}" onclick="submitTrial('${o.value}')">${o.label}</div>`).join('')}</div>`;
    },
    check(response, correct) { return response === correct; }
  },
  // ... etc for each template
};
```

- [ ] **Step 3: Build shared GAME_TEMPLATES CSS**

Add CSS for each template:
```css
/* Choice grid */
.choice-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;width:100%;max-width:300px}
.choice-btn{padding:16px;border-radius:var(--radius-md);background:var(--bg-card);border:1px solid var(--border);font-size:16px;font-weight:600;text-align:center;transition:all 0.1s}
.choice-btn:active{transform:scale(0.95);background:var(--accent-dim)}

/* Sequence display */
.seq-grid{display:flex;gap:8px;flex-wrap:wrap;justify-content:center}
.seq-cell{width:56px;height:56px;border-radius:var(--radius-md);background:var(--bg-card);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:700;transition:all 0.15s}
.seq-cell.active{background:var(--accent-dim);border-color:var(--accent);transform:scale(1.05)}

/* Grid template */
.find-grid{display:grid;gap:4px;justify-content:center}
.find-cell{width:44px;height:44px;border-radius:var(--radius-sm);background:var(--bg-card);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;font-size:14px;cursor:pointer;transition:all 0.1s}
.find-cell:active{transform:scale(0.9)}

/* Recall template */
.recall-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;max-width:280px}
.recall-card{padding:20px 12px;border-radius:var(--radius-md);background:var(--bg-card);border:1px solid var(--border);text-align:center;font-size:14px;cursor:pointer;transition:all 0.15s}
.recall-card.selected{border-color:var(--accent);background:var(--accent-dim)}

/* Number line */
.nl-container{width:100%;max-width:320px;padding:20px 0}
.nl-track{width:100%;height:6px;background:var(--border);border-radius:3px;position:relative;margin:20px 0}
.nl-thumb{width:24px;height:24px;border-radius:50%;background:var(--accent);position:absolute;top:50%;transform:translate(-50%,-50%);cursor:pointer;left:50%}
.nl-labels{display:flex;justify-content:space-between;font-size:11px;color:var(--text-tertiary)}

/* Sort template */
.sort-area{display:flex;gap:12px;width:100%;max-width:320px;min-height:100px}
.sort-zone{flex:1;padding:12px;border:1px dashed var(--border);border-radius:var(--radius-md);display:flex;flex-direction:column;gap:6px}
.sort-zone-label{font-size:10px;color:var(--text-tertiary);text-align:center;text-transform:uppercase}
.sort-item{padding:8px 12px;border-radius:6px;background:var(--accent-dim);border:1px solid rgba(20,184,166,0.2);cursor:pointer;text-align:center;font-size:12px}

/* Type template */
.type-input{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-md);padding:12px 16px;color:var(--text-primary);font-size:20px;font-weight:600;text-align:center;width:200px;font-family:var(--font-sans);outline:none}
.type-input:focus{border-color:var(--accent)}

/* Premium lock */
.premium-lock{text-align:center;padding:40px 20px}
.premium-lock-icon{font-size:48px;margin-bottom:12px;opacity:0.4}
```

- [ ] **Step 4: Refactor game execution pipeline**

Replace `startGame()` to use template system:
```js
function startGame(gameId) {
  const gameDef = GAMES.find(g => g.id === gameId);
  if (!gameDef) return;
  // Check premium
  if (gameDef.premium && !state.data.premium) {
    showPremiumGate(gameDef.name);
    return;
  }

  state.game = { id: gameId, def: gameDef, trials: [], trialIndex: 0, correctCount: 0, startTime: Date.now(), rtValues: [], rtSum: 0 };
  state.signalHistory = [];
  state.gameStartTime = Date.now();
  
  document.querySelector('.game-screen').classList.add('active');
  document.getElementById('game-name-tag').textContent = gameDef.name.toUpperCase();
  
  startSignal();
  state.signalInterval = setInterval(tickSignal, 200);
  nextTrial();
}
```

- [ ] **Step 5: Build generic `nextTrial()` and `submitTrial()` functions**

```js
function nextTrial() {
  if (state.game.trialIndex >= state.game.def.trials) { endGame(); return; }
  const trial = state.game.def.generateTrial(state.game.trialIndex, state.game.difficulty || 1);
  state.game.currentTrial = trial;
  state.game.trialStart = Date.now();
  
  document.getElementById('game-trial-counter').textContent = `${state.game.trialIndex+1}/${state.game.def.trials}`;
  
  const handler = GAME_HANDLERS[trial.template];
  document.getElementById('game-content').innerHTML = handler.render(trial.stimulus, trial.options, trial);
  
  // Special setup for some templates
  if (trial.template === 'sequence') setupSequenceTrial(trial);
  if (trial.template === 'reaction') setupReactionTrial(trial);
  if (trial.template === 'numberline') setupNumberlineTrial(trial);
}

function submitTrial(response) {
  const rt = Date.now() - state.game.trialStart;
  const trial = state.game.currentTrial;
  const correct = GAME_HANDLERS[trial.template].check(response, trial.correct);
  
  if (correct) {
    state.game.correctCount++;
    state.game.rtValues.push(rt);
  }
  state.game.rtSum += rt;
  state.game.trialIndex++;

  const feedback = document.createElement('div');
  feedback.className = 'trial-feedback';
  feedback.textContent = correct ? '✓' : '✗';
  document.getElementById('game-content').appendChild(feedback);
  setTimeout(() => feedback.remove(), 400);
  setTimeout(nextTrial, correct ? 300 : 600);
}
```

---

### Task 2: All 42 Games — Trial Generators

**Files:** Modify `index.html` (add after GAMES array, before game engine)

This is the bulk of the work. Define all 42 games' trial generators. Games using the same template share rendering code.

- [ ] **Step 1: Attention games (Stroop ✓ + 5 new)**

```js
// Flanker Focus — CHOICE template (4 options: left/up/right/down arrows)
// Go/No-Go — REACTION template (press for animals, withhold for objects)
// Context Switcher — CHOICE template (category→item→does it belong?)
// Selective Attention — GRID template (find target letter in matrix)
// Divided Attention — REACTION template (simultaneous visual + audio-style cues)
```

Each gets `{ id, name, icon, area, desc, color, template:'choice'|'reaction'|'grid', trials: 20, generateTrial(idx, diff) { return {stimulus, options, correct, template}; } }`

- [ ] **Step 2: Memory games (7 new)**

```js
// Digit Span — SEQUENCE template (watch numbers, repeat)
// Corsi Blocks — SEQUENCE template (watch block flash sequence, tap back)
// N-Back — CHOICE template (is this same as N steps ago?)
// Paired Associates — RECALL template (remember pairs, match them)
// Word List Recall — TYPE template (type remembered words)
// Picture Recognition — CHOICE template (was this shown before?)
// Spatial Span — SEQUENCE template (watch positions, tap back)
```

- [ ] **Step 3: Numeracy games (Mental Math ✓ + 6 new)**

```js
// Number Line — NUMBERLINE template (estimate position 0-100)
// Estimation — TYPE template (type approximate answer)
// Quantity Comparison — CHOICE template (which group has more?)
// Numerical Estimation — NUMBERLINE template (estimate dot count)
// Arithmetic Verification — CHOICE template (True/False on equation)
// Fraction Comparison — CHOICE template (which fraction is larger?)
```

- [ ] **Step 4: Processing Speed games (Reaction Time ✓ + 6 new)**

```js
// Symbol-Digit — CHOICE template (which number matches this symbol?)
// Pattern Comparison — CHOICE template (same or different?)
// Visual Search — GRID template (find target letter among distractors)
// Letter Comparison — CHOICE template (same string or different?)
// Number Comparison — CHOICE template (same number or different?)
// Simple RT — REACTION template (tap as soon as you see flash)
```

- [ ] **Step 5: Language games (7 new)**

```js
// Synonyms — CHOICE template (which word means the same?)
// Word Scramble — TYPE template (unscramble the letters)
// Analogies — CHOICE template (A:B as C:?)
// Verbal Fluency — TYPE template (type words starting with letter)
// Sentence Completion — CHOICE template (best word for blank)
// Antonyms — CHOICE template (opposite of this word?)
// Word Definition — CHOICE template (which definition is correct?)
```

- [ ] **Step 6: Problem Solving games (7 new)**

```js
// Rule Detection (WCST) — SORT template (sort cards by color/shape/number rule that changes)
// Matrix Reasoning — CHOICE template (what comes next in pattern?)
// Tower of London — custom (drag pegs between posts)
// Category Fluency — TYPE template (type items in category)
// Spatial Planning — GRID template (find shortest path)
// Inhibition — REACTION template (say opposite of what you see)
// Set Shifting — CHOICE template (switch between color/shape rules)
```

- [ ] **Step 7: Executive Function / Premium (1 game)**

```js
// Trail Making — custom (tap alternating numbers and letters in sequence: 1-A-2-B-3-C...)
```

---

### Task 3: Game Selection UI — Domain Groups with 42 Games

**Files:** Modify `index.html` (update `renderGames()`, lines 644-679)

- [ ] **Step 1: Expand game list rendering**

Replace `renderGames()` to show games grouped by cognitive domain with collapsible sections. Each domain section shows a summary card with the skill score. Games show best score + last played date. Premium games show a lock icon.

```js
function renderGames() {
  const ctx = getContext();
  const premium = state.data.premium;
  
  let html = `<div class="context-bar"><span>${ctx.icon} ${ctx.mood}</span></div>`;
  
  // Domain groups
  const domains = [/* Attention, Memory, Numeracy, Processing, Language, Problem-Solving */];
  for (const domain of domains) {
    const domainGames = GAMES.filter(g => g.area === domain.name);
    const areaKey = AREA_MAP[domain.name];
    const skillScore = state.data.skillScores[areaKey] || 50;
    
    html += `<div class="section">
      <div class="domain-header" onclick="toggleDomain('${domain.key}')">
        <span>${domain.icon} ${domain.name}</span>
        <span style="font-family:var(--font-mono);color:${domain.color}">${skillScore}</span>
      </div>
      <div class="domain-games" id="domain-${domain.key}">
        ${domainGames.map(g => renderGameCard(g)).join('')}
      </div>
    </div>`;
  }
  
  document.getElementById('game-list').innerHTML = html;
}
```

- [ ] **Step 2: Update demo data seeding**

Expand lines 1175-1207 to seed demo sessions across all 6 domains (not just attention/numeracy/speed):

```js
const gameNames = ['Stroop Test','Mental Math','Reaction Time','Digit Span','Synonyms','Rule Detection'];
const gameIds = ['stroop','mentalmath','reaction','digit-span','synonyms','rule-detection'];
// ... seed across all 6 areas
```

---

### Task 4: Onboarding Walkthrough

**Files:** Modify `index.html` (add HTML before line 294, JS after init section)

- [ ] **Step 1: Add onboarding HTML**

```html
<div id="onboarding-overlay" class="onboarding-overlay">
  <div class="onboarding-slides" id="onboarding-slides">
    <!-- Slide 1: Brand -->
    <div class="onboarding-slide">
      <div class="onboarding-icon">🧠</div>
      <h2>Measured, not gamified.</h2>
      <p>Upmind tracks your cognitive fitness with honest numbers. No streaks. No badges. No tricks.</p>
    </div>
    <!-- Slide 2: Domains -->
    <div class="onboarding-slide">
      <div class="onboarding-icon">🎯</div>
      <h2>6 Pillars of Cognition</h2>
      <p>Attention · Memory · Numeracy · Processing Speed · Language · Problem Solving</p>
    </div>
    <!-- Slide 3: Scoring -->
    <div class="onboarding-slide">
      <div class="onboarding-icon">📊</div>
      <h2>Transparent Scoring</h2>
      <p>Accuracy × Reaction Time Stability × Speed. Every score shows its math.</p>
    </div>
    <!-- Slide 4: Start -->
    <div class="onboarding-slide">
      <div class="onboarding-icon">⚡</div>
      <h2>8 Minutes a Day</h2>
      <p>Quick drills. Real progress. Start your first session.</p>
      <button class="btn btn-primary btn-onboarding" onclick="dismissOnboarding()">Start Training</button>
    </div>
  </div>
  <div class="onboarding-dots" id="onboarding-dots">
    <span class="dot active"></span><span class="dot"></span><span class="dot"></span><span class="dot"></span>
  </div>
  <button class="onboarding-skip" onclick="dismissOnboarding()">Skip</button>
</div>
```

- [ ] **Step 2: Add onboarding CSS**

```css
.onboarding-overlay{position:fixed;top:0;left:0;right:0;bottom:0;background:var(--bg-primary);z-index:300;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:40px 24px 80px;animation:fadeIn 0.3s ease}
.onboarding-slides{flex:1;display:flex;overflow-x:auto;scroll-snap-type:x mandatory;gap:0;width:100%;-webkit-overflow-scrolling:touch;scrollbar-width:none}
.onboarding-slides::-webkit-scrollbar{display:none}
.onboarding-slide{min-width:100%;scroll-snap-align:start;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:40px 16px}
.onboarding-slide h2{font-size:22px;font-weight:700;margin-bottom:12px}
.onboarding-slide p{font-size:14px;color:var(--text-secondary);line-height:1.6;max-width:300px}
.onboarding-icon{font-size:64px;margin-bottom:24px}
.onboarding-dots{display:flex;gap:8px;margin-bottom:20px}
.onboarding-dots .dot{width:8px;height:8px;border-radius:50%;background:var(--border);transition:all 0.2s}
.onboarding-dots .dot.active{background:var(--accent);width:24px;border-radius:4px}
.onboarding-skip{position:absolute;top:16px;right:20px;font-size:12px;color:var(--text-tertiary)}
.btn-onboarding{margin-top:24px}
```

- [ ] **Step 3: Add initialization check**

In init section (after line 1207), add:
```js
if (!localStorage.getItem('upmind_onboarding')) {
  initOnboarding();
}
```

Dismiss function:
```js
function dismissOnboarding() {
  localStorage.setItem('upmind_onboarding', '1');
  document.getElementById('onboarding-overlay').remove();
}
```

- [ ] **Step 4: Add slide-dot sync**

```js
function initOnboarding() {
  const slides = document.getElementById('onboarding-slides');
  slides.addEventListener('scroll', () => {
    const idx = Math.round(slides.scrollLeft / slides.clientWidth);
    document.querySelectorAll('.onboarding-dots .dot').forEach((d, i) => d.classList.toggle('active', i === idx));
  });
}
```

---

### Task 5: Chess.com-Style Leaderboard

**Files:** Modify `index.html` (add leaderboard view, ELO system, simulated data)

- [ ] **Step 1: Add ELO rating system**

```js
// ── ELO RATING ──
const ELO = {
  k: 32,
  start: 1200,
  expected(a, b) { return 1 / (1 + Math.pow(10, (b - a) / 400)); },
  update(winner, loser) {
    const e = this.expected(winner, loser);
    return { winner: Math.round(winner + this.k * (1 - e)), loser: Math.round(loser + this.k * (0 - (1 - e))) };
  },
  computeDomainRating(domain, sessions) {
    // Start at 1200, update vs synthetic benchmark after each session
    let rating = 1200;
    const domainSessions = sessions.filter(s => s.area === domain);
    for (const s of domainSessions) {
      const benchmark = 1000 + s.score * 5; // benchmark rating = 1000-1500 based on score
      const result = s.score > 60 ? this.update(rating, benchmark) : this.update(benchmark, rating);
      rating = s.score > 60 ? result.winner : result.loser;
    }
    return rating;
  }
};
```

- [ ] **Step 2: Generate simulated players**

```js
function generateSimulatedPlayers(count = 1000) {
  const names = ['Alex K.','Jordan M.','Sam T.','Riley C.','Morgan P.','Casey W.','Taylor R.','Quinn B.','Avery D.','Parker L.'];
  const surnames = ['Chen','Patel','Kim','Singh','Garcia','Lee','Wilson','Brown','Davis','Miller'];
  const players = [];
  for (let i = 0; i < count; i++) {
    const baseRating = 800 + Math.floor(Math.random() * 800); // 800-1600
    const volatility = Math.random() * 200;
    players.push({
      id: i,
      name: `${names[i % names.length]} ${surnames[i % surnames.length]}`,
      rating: Math.round(baseRating + (Math.random() - 0.5) * volatility),
      gamesPlayed: 10 + Math.floor(Math.random() * 200),
      lastActive: Date.now() - Math.floor(Math.random() * 7 * 86400000),
      trend: Math.random() > 0.5 ? 'up' : 'down'
    });
  }
  return players.sort((a, b) => b.rating - a.rating);
}
```

- [ ] **Step 3: Add Leaderboard HTML to views**

```html
<div class="view" id="view-leaderboard">
  <div class="view-title">Leaderboard</div>
  <div class="section">
    <div style="display:flex;gap:6px;margin-bottom:12px">
      <button class="leaderboard-tab active" data-period="today">Today</button>
      <button class="leaderboard-tab" data-period="week">This Week</button>
      <button class="leaderboard-tab" data-period="month">This Month</button>
      <button class="leaderboard-tab" data-period="all">All Time</button>
    </div>
  </div>
  <div class="section">
    <div class="card card-accent-dark" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
      <div>
        <div style="font-size:10px;color:var(--text-tertiary)">Your Rating</div>
        <div style="font-size:28px;font-weight:700;color:var(--accent);font-family:var(--font-mono)" id="lb-my-rating">—</div>
      </div>
      <div style="text-align:right">
        <div style="font-size:10px;color:var(--text-tertiary)">Global Rank</div>
        <div style="font-size:20px;font-weight:700" id="lb-my-rank">#—</div>
      </div>
    </div>
    <div id="lb-domain-pills" style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:12px"></div>
    <div class="card">
      <div id="lb-table"></div>
    </div>
  </div>
</div>
```

- [ ] **Step 4: Add leaderboard CSS**

```css
.leaderboard-tab{padding:6px 14px;border-radius:20px;font-size:11px;font-weight:500;background:var(--bg-card);border:1px solid var(--border);color:var(--text-tertiary);cursor:pointer;transition:all 0.15s}
.leaderboard-tab.active{background:var(--accent-dim);border-color:var(--accent);color:var(--accent)}
.lb-row{display:flex;align-items:center;gap:10px;padding:10px 0;border-bottom:1px solid var(--border);font-size:12px}
.lb-row:last-child{border-bottom:none}
.lb-rank{width:30px;font-family:var(--font-mono);font-size:13px;font-weight:700;color:var(--text-tertiary);text-align:center}
.lb-rank.gold{color:#FFD700}
.lb-rank.silver{color:#C0C0C0}
.lb-rank.bronze{color:#CD7F32}
.lb-avatar{width:28px;height:28px;border-radius:50%;background:var(--bg-card);border:1px solid var(--border);display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:600;flex-shrink:0}
.lb-name{flex:1;font-weight:500}
.lb-rating{font-family:var(--font-mono);font-size:13px;font-weight:600;color:var(--accent)}
.lb-trend{font-size:10px;margin-left:4px}
.lb-games{font-size:10px;color:var(--text-tertiary);text-align:right;min-width:40px}
.lb-domain-pill{padding:4px 10px;border-radius:12px;font-size:10px;font-weight:500;cursor:pointer;transition:all 0.15s}
.lb-domain-pill.active{background:var(--accent-dim);color:var(--accent);border-color:var(--accent)}
```

- [ ] **Step 5: Add nav item and rendering**

Add leaderboard nav item (5th tab) and `renderLeaderboard()` function with period filtering, domain pills, and the ranked table.

---

### Task 6: Payment Flow (Mock)

**Files:** Modify `index.html` (add modal HTML + JS)

- [ ] **Step 1: Add payment modal HTML**

```html
<div class="modal-overlay" id="payment-modal">
  <div class="modal" style="max-width:420px">
    <div style="text-align:center;margin-bottom:16px">
      <div style="font-size:36px;margin-bottom:8px" id="payment-icon">🔓</div>
      <h3 style="font-size:18px">Upgrade to Premium</h3>
      <p style="font-size:12px;color:var(--text-tertiary)">Unlock Executive Function training + detailed insights</p>
    </div>
    <div id="payment-plans" style="display:grid;gap:8px;margin-bottom:16px">
      <div class="payment-plan active" onclick="selectPlan('monthly')">
        <div>
          <div style="font-weight:600">Monthly</div>
          <div style="font-size:11px;color:var(--text-tertiary)">$9.99 / month · Cancel anytime</div>
        </div>
        <div style="font-family:var(--font-mono);font-size:18px;font-weight:700;color:var(--accent)">$9.99</div>
      </div>
      <div class="payment-plan" onclick="selectPlan('yearly')">
        <div>
          <div style="font-weight:600">Annual</div>
          <div style="font-size:11px;color:var(--text-tertiary)">$79.99 / year · Save 33%</div>
        </div>
        <div style="font-family:var(--font-mono);font-size:18px;font-weight:700;color:var(--accent)">$79.99</div>
      </div>
    </div>
    <div id="payment-features" style="margin-bottom:16px">
      <div class="payment-feature">✓ All 42 cognitive drills</div>
      <div class="payment-feature">✓ Executive Function domain (Trail Making)</div>
      <div class="payment-feature">✓ Detailed insight filters & trends</div>
      <div class="payment-feature">✓ Priority support</div>
    </div>
    <button class="btn btn-primary btn-full" onclick="mockPurchase()" id="purchase-btn">
      Subscribe · <span id="purchase-amount">$9.99</span>/mo
    </button>
    <div style="margin-top:12px;text-align:center">
      <div style="display:flex;gap:8px;justify-content:center;margin-bottom:6px">
        <span style="font-size:18px">💳</span><span style="font-size:18px;opacity:0.5">🅰️</span><span style="font-size:18px;opacity:0.5">💲</span>
      </div>
      <button class="btn btn-sm" onclick="closeModal('payment-modal')" style="color:var(--text-tertiary)">Maybe later</button>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Add payment CSS**

```css
.payment-plan{display:flex;justify-content:space-between;align-items:center;padding:14px 16px;border-radius:var(--radius-md);border:1px solid var(--border);cursor:pointer;transition:all 0.15s}
.payment-plan.active{border-color:var(--accent);background:var(--accent-dim)}
.payment-feature{padding:6px 0;font-size:12px;color:var(--text-secondary)}
```

- [ ] **Step 3: Add payment JS**

```js
function showPayment() { showModal('payment-modal'); }
let selectedPlan = 'monthly';

function selectPlan(plan) {
  selectedPlan = plan;
  document.querySelectorAll('.payment-plan').forEach((el, i) => {
    el.classList.toggle('active', (plan === 'monthly' && i === 0) || (plan === 'yearly' && i === 1));
  });
  document.getElementById('purchase-amount').textContent = plan === 'monthly' ? '$9.99' : '$79.99';
  document.getElementById('purchase-btn').innerHTML = `Subscribe · <span id="purchase-amount">${plan === 'monthly' ? '$9.99' : '$79.99'}</span>/${plan === 'monthly' ? 'mo' : 'yr'}`;
}

function mockPurchase() {
  document.getElementById('purchase-btn').textContent = 'Processing…';
  document.getElementById('purchase-btn').disabled = true;
  
  // Mock Apple Pay sheet animation
  setTimeout(() => {
    state.data.premium = true;
    state.data.premiumDate = new Date().toISOString();
    state.data.premiumPlan = selectedPlan;
    Store.save();
    closeModal('payment-modal');
    showPremiumConfirmation();
    renderAll();
  }, 1500);
}

function showPremiumGate(gameName) {
  document.getElementById('payment-icon').textContent = '🔒';
  // Swap to gate mode
  showPayment();
}

function showPremiumConfirmation() {
  // Toast-like confirmation
  const toast = document.createElement('div');
  toast.className = 'premium-toast';
  toast.innerHTML = '🌟 Premium Unlocked · Executive Function now available';
  document.body.appendChild(toast);
  setTimeout(() => toast.classList.add('show'), 100);
  setTimeout(() => toast.remove(), 3000);
}
```

---

### Task 7: Light Mode / Beige Theme

**Files:** Modify `index.html` (CSS variable swap + toggle)

- [ ] **Step 1: Add theme toggle HTML to Profile**

```html
<div class="section" id="theme-section" style="display:none">
  <div class="card">
    <div class="section-title">Appearance</div>
    <div style="display:flex;gap:8px;align-items:center">
      <span style="font-size:12px;color:var(--text-secondary)">Dark</span>
      <label class="toggle">
        <input type="checkbox" id="theme-toggle" onchange="toggleTheme()">
        <span class="toggle-slider"></span>
      </label>
      <span style="font-size:12px;color:var(--text-secondary)">Beige</span>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Add toggle CSS**

```css
.toggle{position:relative;display:inline-block;width:44px;height:24px}
.toggle input{opacity:0;width:0;height:0}
.toggle-slider{position:absolute;cursor:pointer;top:0;left:0;right:0;bottom:0;background:var(--border);border-radius:12px;transition:0.2s}
.toggle-slider::before{content:'';position:absolute;height:18px;width:18px;left:3px;bottom:3px;background:var(--text-primary);border-radius:50%;transition:0.2s}
.toggle input:checked+.toggle-slider{background:var(--accent)}
.toggle input:checked+.toggle-slider::before{transform:translateX(20px)}
```

- [ ] **Step 3: Add theme JS**

```js
function toggleTheme() {
  const isLight = document.getElementById('theme-toggle').checked;
  document.documentElement.setAttribute('data-theme', isLight ? 'light' : 'dark');
  localStorage.setItem('upmind_theme', isLight ? 'light' : 'dark');
}
```

- [ ] **Step 4: Add light theme CSS vars**

```css
[data-theme="light"] {
  --bg-primary: #F5F0E8;
  --bg-card: rgba(0,0,0,0.02);
  --bg-card-hover: rgba(0,0,0,0.04);
  --border: rgba(0,0,0,0.08);
  --border-hover: rgba(0,0,0,0.12);
  --text-primary: #2C2416;
  --text-secondary: #6B6258;
  --text-tertiary: #8A7F72;
  --text-muted: #A89F94;
}
```

- [ ] **Step 5: Load theme on init**

```js
const savedTheme = localStorage.getItem('upmind_theme');
if (savedTheme === 'light') {
  document.documentElement.setAttribute('data-theme', 'light');
  document.getElementById('theme-toggle').checked = true;
}
```

---

### Task 8: Integration & Polish

**Files:** Modify `index.html`

- [ ] **Step 1: Update nav to include leaderboard (5 items)**

Add leaderboard nav item between Games and Insights.

- [ ] **Step 2: Verify all 42 games render in domain groups**

Check that the game selection UI shows all 42 games grouped by domain with correct icons, descriptions, and scores.

- [ ] **Step 3: Verify premium gate appears for Executive Function**

Ensure that non-premium users see the lock icon and tapping any Executive Function game opens the payment modal.

- [ ] **Step 4: Verify leaderboard shows your rating + global ranking**

Check that simulated players load, your domain rating computes, and the table renders correctly.

- [ ] **Step 5: Verify onboarding appears on first visit only**

Check localStorage `upmind_onboarding` flag.

- [ ] **Step 6: Verify light mode persists across refreshes**

Toggle, refresh, confirm theme stays.

- [ ] **Step 7: Verify PWA install + service worker still works**

Test offline loading via SW.

- [ ] **Step 8: Update `renderInsights()` and `renderProfile()` for premium features**

Add premium badge on profile, add insight filters for premium users.
