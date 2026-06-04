/**
 * Upmind — trial generators for all 42 games.
 * Ported 1:1 from index.html (TRIAL_GENERATORS) but with the new typed
 * Trial shape and V1-V5 dynamism (target position, response set,
 * rule semantics, cadence, feedback) preserved.
 *
 * Each generator receives (index, difficulty, engine) and returns a Trial.
 */

import type { Trial, Choice, ChoiceTrial, ReactionTrial, SequenceTrial, GridTrial, NumberLineTrial, TypeTrial, SortTrial } from './types';
import type { Engine } from './engine';

const INK_HEX: Record<string, string> = {
  Red: '#EF4444',
  Green: '#22C55E',
  Blue: '#2F6FED',
  Amber: '#F59E0B',
  Indigo: '#6366F1',
};
const INK_NAMES = ['Red', 'Green', 'Blue', 'Amber', 'Indigo'];

// ── ATTENTION ─────────────────────────────────────────────────

const stroop = (i: number, d: number): ChoiceTrial => {
  // V3 dynamism: ink / length / even-odd rule rotation
  const wi = Math.floor(Math.random() * 5);
  const ii = (wi + Math.floor(1 + Math.random() * 4)) % 5;
  const a = INK_NAMES[ii].toLowerCase();
  const cs: string[] = [a];
  while (cs.length < 3) {
    const c = INK_NAMES[Math.floor(Math.random() * 5)].toLowerCase();
    if (!cs.includes(c)) cs.push(c);
  }
  cs.sort(() => Math.random() - 0.5);
  const roll = Math.random();
  const mode = roll < 0.55 ? 'ink' : roll < 0.78 ? 'length' : 'even';
  let prompt: string;
  let choices: Choice[];
  let correct: string;

  if (mode === 'ink') {
    prompt = `Name the <strong>ink color</strong> of: <span style="color:${INK_HEX[INK_NAMES[ii]]}">${INK_NAMES[wi]}</span>`;
    correct = a;
    choices = cs.map((c) => ({ id: c, label: c, correct: c === a }));
  } else if (mode === 'length') {
    const word = INK_NAMES[wi];
    const len = word.length;
    const options = [len];
    while (options.length < 3) {
      const x = len + Math.floor(Math.random() * 3) - 1;
      if (x > 0 && !options.includes(x)) options.push(x);
    }
    options.sort(() => Math.random() - 0.5);
    correct = String(len);
    prompt = `How many letters in: <span style="color:${INK_HEX[INK_NAMES[ii]]}">${word}</span>?`;
    choices = options.map((n) => ({ id: String(n), label: String(n), correct: String(n) === correct }));
  } else {
    const word = INK_NAMES[wi];
    const isEven = word.length % 2 === 0;
    correct = isEven ? 'Yes' : 'No';
    prompt = `Letter count of <span style="color:${INK_HEX[INK_NAMES[ii]]}">${word}</span> is <strong>even</strong>?`;
    choices = [
      { id: 'Yes', label: 'Yes', correct: isEven },
      { id: 'No', label: 'No', correct: !isEven },
    ];
  }
  return { index: i, template: 'CHOICE', difficulty: d, prompt, choices, variant: `stroop-${mode}` };
};

const flanker = (i: number, d: number): ChoiceTrial => {
  // V1 dynamism: target position random within 3 or 5 arrows
  const dirs = ['←', '→'] as const;
  const t = dirs[Math.random() < 0.5 ? 0 : 1];
  const f = dirs[Math.floor(Math.random() * 2)];
  const congruent = Math.random() < 0.5;
  const count = Math.random() < 0.4 ? 3 : 5;
  const targetPos = Math.floor(Math.random() * count);
  let display = '';
  for (let k = 0; k < count; k++) {
    display += k === targetPos ? t : congruent ? t : f;
  }
  const correctId = t === '←' ? 'left' : 'right';
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `Target arrow direction: <div style="font-size:32px;letter-spacing:8px;margin-top:8px">${display}</div>`,
    choices: [
      { id: 'left', label: '←', correct: correctId === 'left' },
      { id: 'right', label: '→', correct: correctId === 'right' },
    ],
    variant: `flanker-pos-${targetPos + 1}-of-${count}`,
  };
};

const gongo = (i: number, d: number): ReactionTrial => {
  const items: Array<{ l: string; a: 0 | 1 }> = [
    { l: 'Dog', a: 1 },
    { l: 'Cat', a: 1 },
    { l: 'Bird', a: 1 },
    { l: 'Fish', a: 1 },
    { l: 'Chair', a: 0 },
    { l: 'Table', a: 0 },
    { l: 'Car', a: 0 },
    { l: 'Book', a: 0 },
  ];
  const chosen = items[Math.floor(Math.random() * items.length)];
  return {
    index: i,
    template: 'REACTION',
    difficulty: d,
    prompt: 'Press for animals. Hold for objects.',
    signal: chosen.l,
    shouldPress: chosen.a === 1,
    minDelay: 1000,
    maxDelay: 2000,
  };
};

const conswitch = (i: number, d: number): ChoiceTrial => {
  const rules = [
    { q: 'Is it even?', fn: (n: number) => n % 2 === 0 },
    { q: 'Is it greater than 50?', fn: (n: number) => n > 50 },
    { q: 'Is it a multiple of 5?', fn: (n: number) => n % 5 === 0 },
    { q: 'Is it a multiple of 3?', fn: (n: number) => n % 3 === 0 },
  ];
  const rule = rules[Math.floor(Math.random() * rules.length)];
  const n = Math.floor(Math.random() * 100) + 1;
  const ans = rule.fn(n) ? 'Yes' : 'No';
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `${rule.q}<div style="font-size:36px;margin-top:8px;font-weight:700">${n}</div>`,
    choices: [
      { id: 'Yes', label: 'Yes', correct: ans === 'Yes' },
      { id: 'No', label: 'No', correct: ans === 'No' },
    ],
  };
};

const selattn = (i: number, d: number): GridTrial => {
  const size = 5 + Math.floor(d);
  const target = String.fromCharCode(65 + Math.floor(Math.random() * 3));
  const distractor = String.fromCharCode(65 + 3 + Math.floor(Math.random() * 3));
  let rTarget = Math.floor(Math.random() * size);
  let cTarget = Math.floor(Math.random() * size);
  // V1 dynamism: 30% of targets in the peripheral ring
  const peripheral = Math.random() < 0.3;
  if (peripheral) {
    const ring = Math.floor(Math.random() * 4);
    if (ring === 0) rTarget = 0;
    else if (ring === 1) rTarget = size - 1;
    else if (ring === 2) cTarget = 0;
    else cTarget = size - 1;
  }
  const cells: string[][] = Array.from({ length: size }, () =>
    Array.from({ length: size }, () => distractor)
  );
  cells[rTarget][cTarget] = target;
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: `Find the <strong>${target}</strong> in the grid.`,
    rows: size,
    cols: size,
    cells,
    answer: { r: rTarget, c: cTarget },
    target,
    variant: peripheral ? `selattn-peripheral` : `selattn-central`,
  };
};

const divattn = (i: number, d: number): ReactionTrial => {
  // V5 dynamism: 30% single-channel
  const mode = Math.random();
  if (mode < 0.15) {
    return {
      index: i,
      template: 'REACTION',
      difficulty: d,
      prompt: 'Tap on visual only (audio ignored).',
      signal: 'GO!',
      shouldPress: true,
      minDelay: 1000,
      maxDelay: 2500,
      channel: 'visual',
    };
  }
  if (mode < 0.3) {
    return {
      index: i,
      template: 'REACTION',
      difficulty: d,
      prompt: 'Tap on audio cue only.',
      signal: '🔊 TONE',
      shouldPress: true,
      minDelay: 1000,
      maxDelay: 2500,
      channel: 'audio',
    };
  }
  return {
    index: i,
    template: 'REACTION',
    difficulty: d,
    prompt: 'Dual channel: tap on signal.',
    signal: 'GO!',
    shouldPress: true,
    minDelay: 1000,
    maxDelay: 2500,
  };
};

const reaction = (i: number, d: number): ReactionTrial => {
  // V2 dynamism: 70% green flash / 20% color match / 10% withhold
  const mode = Math.random();
  if (mode < 0.1) {
    return {
      index: i,
      template: 'REACTION',
      difficulty: d,
      prompt: 'Wait for the signal. (No signal will appear.)',
      signal: '',
      shouldPress: false,
      minDelay: 1500,
      maxDelay: 3000,
    };
  }
  if (mode < 0.3) {
    const color = ['red', 'green', 'amber', 'blue'][Math.floor(Math.random() * 4)];
    return {
      index: i,
      template: 'REACTION',
      difficulty: d,
      prompt: `Tap when you see ${color.toUpperCase()}.`,
      signal: color,
      shouldPress: true,
      minDelay: 1200,
      maxDelay: 3000,
    };
  }
  return {
    index: i,
    template: 'REACTION',
    difficulty: d,
    prompt: 'Tap as soon as the screen flashes.',
    signal: 'TAP!',
    shouldPress: true,
    minDelay: 1000,
    maxDelay: 3500,
  };
};

const symboldigit = (i: number, d: number): ChoiceTrial => {
  const map: Record<string, number> = { '△': 1, '○': 2, '□': 3, '☆': 4, '◇': 5 };
  const keys = Object.keys(map);
  const q = keys[Math.floor(Math.random() * keys.length)];
  const a = map[q];
  const cs = [a];
  while (cs.length < 4) {
    const c = Math.floor(Math.random() * 5) + 1;
    if (!cs.includes(c)) cs.push(c);
  }
  cs.sort(() => Math.random() - 0.5);
  const legend = Object.entries(map).map(([s, n]) => `${s}=${n}`).join('  ');
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:48px;line-height:1">${q}</div><div style="font-size:11px;color:#94A3B8;margin-top:6px">${legend}</div>`,
    choices: cs.map((c) => ({ id: String(c), label: String(c), correct: c === a })),
  };
};

const canceltask = (i: number, d: number): GridTrial => {
  // V2 dynamism: target symbol rotates per session
  const symbols = ['★', '◉', '▲', '●'];
  const target = symbols[Math.floor(Math.random() * symbols.length)];
  const distractor = symbols.filter((s) => s !== target)[Math.floor(Math.random() * 3)];
  const size = 5 + Math.floor(d);
  const cells: string[][] = Array.from({ length: size }, () =>
    Array.from({ length: size }, () => distractor)
  );
  // Place 4-7 targets
  const numTargets = 4 + Math.floor(Math.random() * 4);
  const used = new Set<string>();
  while (used.size < numTargets) {
    const r = Math.floor(Math.random() * size);
    const c = Math.floor(Math.random() * size);
    const k = `${r},${c}`;
    if (!used.has(k)) {
      used.add(k);
      cells[r][c] = target;
    }
  }
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: `Tap every <strong>${target}</strong> you see.`,
    rows: size,
    cols: size,
    cells,
    answer: { r: 0, c: 0 }, // grid games use multi-cell answer via tap-all-targets; answer is just one
    variant: `cancel-${target}`,
  };
};

const trailnum = (i: number, d: number): GridTrial => {
  const size = 5 + Math.floor(d);
  const numItems = Math.min(8, 4 + Math.floor(d));
  // Place 1..numItems in random cells
  const cells: string[][] = Array.from({ length: size }, () =>
    Array.from({ length: size }, () => '')
  );
  const placed: Array<{ r: number; c: number; n: number }> = [];
  const used = new Set<string>();
  for (let n = 1; n <= numItems; n++) {
    let r: number, c: number, k: string;
    do {
      r = Math.floor(Math.random() * size);
      c = Math.floor(Math.random() * size);
      k = `${r},${c}`;
    } while (used.has(k));
    used.add(k);
    cells[r][c] = String(n);
    placed.push({ r, c, n });
  }
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: `Tap <strong>${placed[0]?.n ?? 1}</strong>, then the next, in order.`,
    rows: size,
    cols: size,
    cells,
    answer: placed[0] ?? { r: 0, c: 0 },
  };
};

const patterncomp = (i: number, d: number): ChoiceTrial => {
  // V2 dynamism: 20% 3-grid odd-one-out
  const same = Math.random() < 0.7;
  const a = Math.random() < 0.5;
  const b = Math.random() < 0.5;
  const c = Math.random() < 0.5;
  const d2 = Math.random() < 0.5;
  const e = Math.random() < 0.5;
  const f = Math.random() < 0.5;
  const g = Math.random() < 0.5;
  const h = Math.random() < 0.5;
  const grid = (v: boolean) => (v ? '■' : '□');
  if (Math.random() < 0.2) {
    return {
      index: i,
      template: 'CHOICE',
      difficulty: d,
      prompt: `<div style="font-size:18px">${grid(a)}${grid(b)}${grid(c)}${grid(d2)}</div><div>vs</div><div style="font-size:18px">${grid(!a)}${grid(!b)}${grid(!c)}${grid(!d2)}</div><div style="font-size:18px">${grid(a)}${grid(b)}${grid(c)}${grid(!d2)}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Which is the odd one out?</div>`,
      choices: [
        { id: 'A', label: 'A', correct: true },
        { id: 'B', label: 'B', correct: false },
        { id: 'C', label: 'C', correct: false },
      ],
    };
  }
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:18px">${grid(a)}${grid(b)}${grid(c)}${grid(d2)}</div><div>vs</div><div style="font-size:18px">${same ? grid(a) : grid(!e)}${same ? grid(b) : grid(!f)}${same ? grid(c) : grid(g)}${same ? grid(d2) : grid(h)}</div>`,
    choices: [
      { id: 'Same', label: 'Same', correct: same },
      { id: 'Different', label: 'Different', correct: !same },
    ],
  };
};

const lettercomp = (i: number, d: number): ChoiceTrial => {
  // V2 dynamism: 30% same/diff / 40% count / 30% which-differs
  const mode = Math.random();
  const len = 4 + Math.floor(Math.random() * 4);
  const s1 = Array.from({ length: len }, () => String.fromCharCode(65 + Math.floor(Math.random() * 26))).join('');
  if (mode < 0.3) {
    const same = Math.random() < 0.5;
    const s2 = same ? s1 : s1.slice(0, -1) + String.fromCharCode(65 + Math.floor(Math.random() * 26));
    return {
      index: i,
      template: 'CHOICE',
      difficulty: d,
      prompt: `<div style="font-family:monospace;font-size:20px;letter-spacing:4px">${s1}</div><div style="font-family:monospace;font-size:20px;letter-spacing:4px;color:#94A3B8">${s2}</div>`,
      choices: [
        { id: 'Same', label: 'Same', correct: same },
        { id: 'Different', label: 'Different', correct: !same },
      ],
    };
  }
  if (mode < 0.7) {
    // count
    const diffCount = Math.floor(Math.random() * 3) + 1;
    const s2 = s1.split('');
    for (let k = 0; k < diffCount; k++) {
      const idx = Math.floor(Math.random() * s2.length);
      s2[idx] = String.fromCharCode(65 + Math.floor(Math.random() * 26));
    }
    return {
      index: i,
      template: 'CHOICE',
      difficulty: d,
      prompt: `<div style="font-family:monospace;font-size:20px;letter-spacing:4px">${s1}</div><div style="font-family:monospace;font-size:20px;letter-spacing:4px;color:#94A3B8">${s2.join('')}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">How many positions differ?</div>`,
      choices: ['0', '1', '2', '3+'].map((n) => ({ id: n, label: n, correct: n === String(diffCount) })),
    };
  }
  // which-differs
  const diffIdx = Math.floor(Math.random() * len);
  const s2 = s1.split('');
  s2[diffIdx] = String.fromCharCode(65 + Math.floor(Math.random() * 26));
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-family:monospace;font-size:20px;letter-spacing:4px">${s1}</div><div style="font-family:monospace;font-size:20px;letter-spacing:4px;color:#94A3B8">${s2.join('')}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Which position differs?</div>`,
    choices: Array.from({ length: len }, (_, k) => ({ id: String(k), label: `Pos ${k + 1}`, correct: k === diffIdx })),
  };
};

// ── MEMORY ─────────────────────────────────────────────────

const digitspan = (i: number, d: number): SequenceTrial => {
  // V3 dynamism: forward / backward / skip-every-other
  const len = Math.min(3 + Math.floor(d), 9);
  const seq = Array.from({ length: len }, () => Math.floor(Math.random() * 10));
  const mode = Math.random() < 0.55 ? 'forward' : Math.random() < 0.5 ? 'backward' : 'skip';
  let answer: number[];
  if (mode === 'backward') answer = seq.slice().reverse();
  else if (mode === 'skip') answer = seq.filter((_, k) => k % 2 === 0);
  else answer = seq.slice();
  const prompt =
    mode === 'forward'
      ? 'Repeat the sequence'
      : mode === 'backward'
      ? 'Repeat in <strong>reverse</strong> order'
      : 'Repeat every other digit (1st, 3rd, 5th…)';
  return {
    index: i,
    template: 'SEQUENCE',
    difficulty: d,
    sequence: seq.map(String),
    answer: answer.map(String),
    showMs: 1100,
    prompt,
    choices: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    variant: `digitspan-${mode}`,
  };
};

const corsi = (i: number, d: number): SequenceTrial => {
  // V1 dynamism: grid 6/9/12/16 cells
  const sizes: Array<{ n: number; side: number }> = [
    { n: 6, side: 3 },
    { n: 9, side: 3 },
    { n: 12, side: 4 },
    { n: 16, side: 4 },
  ];
  const sz = sizes[Math.floor(Math.random() * sizes.length)];
  const len = Math.min(3 + Math.floor(d), Math.floor(sz.n * 0.7));
  const seq: Array<{ r: number; c: number; gridSize: number }> = [];
  const used = new Set<string>();
  while (seq.length < len) {
    const r = Math.floor(Math.random() * sz.side);
    const c = Math.floor(Math.random() * sz.side);
    const k = `${r},${c}`;
    if (!used.has(k)) {
      used.add(k);
      seq.push({ r, c, gridSize: sz.side });
    }
  }
  return {
    index: i,
    template: 'SEQUENCE',
    difficulty: d,
    sequence: seq,
    answer: seq.map((p) => `${p.r},${p.c}`),
    showMs: 950,
    prompt: 'Tap the blocks in the order they lit up',
    variant: `corsi-grid-${sz.n}`,
  };
};

const spatialspan = (i: number, d: number): SequenceTrial => {
  // V1 dynamism: grid 4x4/5x5/6x6
  const sides = [4, 5, 6];
  const side = sides[Math.floor(Math.random() * sides.length)];
  const len = Math.min(3 + Math.floor(d), Math.floor((side * side) / 2));
  const seq: Array<{ r: number; c: number; gridSize: number }> = [];
  const used = new Set<string>();
  while (seq.length < len) {
    const r = Math.floor(Math.random() * side);
    const c = Math.floor(Math.random() * side);
    const k = `${r},${c}`;
    if (!used.has(k)) {
      used.add(k);
      seq.push({ r, c, gridSize: side });
    }
  }
  return {
    index: i,
    template: 'SEQUENCE',
    difficulty: d,
    sequence: seq,
    answer: seq.map((p) => `${p.r},${p.c}`),
    showMs: 950,
    prompt: 'Tap positions in the order shown',
    variant: `spatialspan-${side}x${side}`,
  };
};

const paired = (i: number, d: number): ChoiceTrial => {
  const pairs: Array<[string, string]> = [
    ['Key', 'Door'],
    ['Sun', 'Moon'],
    ['Tree', 'Leaf'],
    ['Cup', 'Plate'],
    ['Fish', 'Water'],
    ['Star', 'Sky'],
    ['Book', 'Page'],
    ['Hand', 'Glove'],
  ];
  const p = pairs[Math.floor(Math.random() * pairs.length)];
  const distractor = pairs[(Math.floor(Math.random() * pairs.length) + 1) % pairs.length][1];
  // V3 dynamism: sometimes "longest shown"
  const mode = Math.random() < 0.2 ? 'longest' : 'direct';
  const prompt =
    mode === 'longest' ? `Which word was paired with <strong>${p[0]}</strong> the longest?` : `What pairs with <strong>${p[0]}</strong>?`;
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt,
    choices: [
      { id: p[1], label: p[1], correct: true },
      { id: distractor, label: distractor, correct: false },
    ],
  };
};

const wordlist = (i: number, d: number): TypeTrial => {
  const words = ['Apple', 'Table', 'River', 'Moon', 'Garden', 'Bridge', 'Cloud', 'Ladder', 'Forest', 'Window'];
  return {
    index: i,
    template: 'TYPE',
    difficulty: d,
    prompt: `Type all the words you can remember:<br><strong style="font-size:18px">${words.join(', ')}</strong>`,
    placeholder: 'apple, table, …',
    answerPattern: `(${words.map((w) => w).join('|')})`,
  };
};

const picrecog = (i: number, d: number): ChoiceTrial => {
  const items = ['🏠 House', '🌳 Tree', '🚗 Car', '✈️ Plane', '🐕 Dog', '🐱 Cat', '🎸 Guitar', '📚 Books'];
  const q = items[Math.floor(Math.random() * items.length)];
  const wasShown = Math.random() < 0.5;
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:36px">${q}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Was this shown earlier?</div>`,
    choices: [
      { id: 'Yes', label: 'Yes', correct: wasShown },
      { id: 'No', label: 'No', correct: !wasShown },
    ],
  };
};

const nback = (i: number, d: number): ChoiceTrial => {
  const n = Math.floor(d) + 1;
  const letters = 'BCDFGHJKLMNPQRSTVWZ';
  const items = Array.from({ length: 12 + n }, () => letters[Math.floor(Math.random() * letters.length)]);
  const matchIdx = Math.floor(Math.random() * (items.length - n));
  const isMatch = Math.random() < 0.5;
  let q: string;
  let ans: string;
  if (isMatch) {
    items[matchIdx + n] = items[matchIdx];
    q = items[matchIdx + n];
    ans = 'Yes';
  } else {
    const idx = Math.floor(Math.random() * items.length);
    while (items[idx] === items[Math.max(0, idx - n)]) {
      items[idx] = letters[Math.floor(Math.random() * letters.length)];
    }
    q = items[idx];
    ans = 'No';
  }
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:48px;font-weight:700">${q}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Was this shown ${n} steps ago?</div>`,
    choices: [
      { id: 'Yes', label: 'Yes', correct: ans === 'Yes' },
      { id: 'No', label: 'No', correct: ans === 'No' },
    ],
  };
};

// ── NUMERACY ──────────────────────────────────────────────

const mentalmath = (i: number, d: number): ChoiceTrial | TypeTrial => {
  // V2 dynamism: 60% 3-choice / 30% 4-choice / 10% keypad
  const ops = ['+', '-', '×'] as const;
  const op = ops[Math.floor(Math.random() * 3)];
  let a: number, b: number, ans: number;
  if (op === '+') {
    a = Math.floor(Math.random() * 50) + 10;
    b = Math.floor(Math.random() * 50) + 10;
    ans = a + b;
  } else if (op === '-') {
    a = Math.floor(Math.random() * 50) + 30;
    b = Math.floor(Math.random() * a) + 5;
    ans = a - b;
  } else {
    a = Math.floor(Math.random() * 12) + 2;
    b = Math.floor(Math.random() * 10) + 2;
    ans = a * b;
  }
  const mode = Math.random();
  if (mode < 0.1) {
    return {
      index: i,
      template: 'TYPE',
      difficulty: d,
      prompt: `<div style="font-size:32px;font-weight:700">${a} ${op} ${b}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Type the answer</div>`,
      placeholder: 'type answer…',
      answerPattern: `^\\s*${ans}\\s*$`,
    };
  }
  const cs: number[] = [ans];
  const numChoices = mode < 0.7 ? 3 : 4;
  while (cs.length < numChoices) {
    const delta = Math.max(1, Math.round(ans * 0.15));
    const c = ans + (Math.floor(Math.random() * delta * 2) - delta);
    if (c >= 0 && !cs.includes(c)) cs.push(c);
  }
  cs.sort(() => Math.random() - 0.5);
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:32px;font-weight:700">${a} ${op} ${b}</div>`,
    choices: cs.map((c) => ({ id: String(c), label: String(c), correct: c === ans })),
  };
};

const numline = (i: number, d: number): NumberLineTrial => {
  const t = Math.floor(Math.random() * 100) + 1;
  return {
    index: i,
    template: 'NUMBERLINE',
    difficulty: d,
    prompt: `Where is <strong>${t}</strong> on the line?`,
    min: 0,
    max: 100,
    target: t,
  };
};

const estimation = (i: number, d: number): ChoiceTrial => {
  const total = Math.floor(Math.random() * 500) + 50;
  const items = Math.floor(Math.random() * 10) + 3;
  const perItem = Math.round(total / items);
  const distractors = [
    total + Math.floor(Math.random() * 20) + 5,
    total - Math.floor(Math.random() * 20) - 5,
    Math.floor(total * 1.5),
  ];
  const choices = [total, ...distractors].sort(() => Math.random() - 0.5);
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `About how much is <strong>${perItem} × ${items}</strong>?`,
    choices: choices.map((c) => ({ id: String(c), label: String(c), correct: c === total })),
  };
};

const quantity = (i: number, d: number): ChoiceTrial => {
  const a = Math.floor(Math.random() * 40) + 5;
  const b = a + Math.floor(Math.random() * 15) - 7;
  const qa = '●'.repeat(a);
  const qb = '●'.repeat(Math.max(1, b));
  const corr = a > b;
  const choices: Choice[] = [
    { id: 'Left', label: '◀', correct: corr },
    { id: 'Equal', label: '=', correct: a === b },
    { id: 'Right', label: '▶', correct: !corr && a !== b },
  ];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div>${qa}</div><div>${qb}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Which has more?</div>`,
    choices,
  };
};

const numestimate = (i: number, d: number): NumberLineTrial => {
  return {
    index: i,
    template: 'NUMBERLINE',
    difficulty: d,
    prompt: `<div style="font-size:36px">${'⬤'.repeat(Math.floor(Math.random() * 18) + 3)}</div><div style="font-size:14px;color:#94A3B8;margin-top:6px">How many dots?</div>`,
    min: 0,
    max: 20,
    target: Math.floor(Math.random() * 15) + 5,
  };
};

const arithmeticv = (i: number, d: number): ChoiceTrial => {
  const a = Math.floor(Math.random() * 20) + 1;
  const b = Math.floor(Math.random() * 20) + 1;
  const ans = a + b;
  const correct = Math.random() < 0.5;
  const display = correct ? `${a}+${b}=${ans}` : `${a}+${b}=${ans + Math.floor(Math.random() * 3) + 1}`;
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:32px;font-weight:700">${display}</div>`,
    choices: [
      { id: 'Correct', label: 'Correct', correct },
      { id: 'Incorrect', label: 'Incorrect', correct: !correct },
    ],
  };
};

const fraction = (i: number, d: number): ChoiceTrial => {
  const a: [number, number] = [Math.floor(Math.random() * 8) + 2, Math.floor(Math.random() * 9) + 2];
  let b: [number, number] = [Math.floor(Math.random() * 8) + 2, Math.floor(Math.random() * 9) + 2];
  while (a[0] / a[1] === b[0] / b[1]) {
    b = [Math.floor(Math.random() * 8) + 2, Math.floor(Math.random() * 9) + 2];
  }
  const bigger = a[0] / a[1] > b[0] / b[1] ? 'First' : 'Second';
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:24px;font-weight:600">${a[0]}/${a[1]} vs ${b[0]}/${b[1]}</div><div style="font-size:12px;color:#94A3B8;margin-top:6px">Which is larger?</div>`,
    choices: [
      { id: 'First', label: `${a[0]}/${a[1]}`, correct: bigger === 'First' },
      { id: 'Second', label: `${b[0]}/${b[1]}`, correct: bigger === 'Second' },
    ],
  };
};

// ── VERBAL ────────────────────────────────────────────────

const synonyms = (i: number, d: number): ChoiceTrial => {
  const pairs: Array<[string, string]> = [
    ['Happy', 'Joyful'],
    ['Big', 'Large'],
    ['Fast', 'Quick'],
    ['Smart', 'Intelligent'],
    ['Brave', 'Courageous'],
    ['Quiet', 'Silent'],
    ['Rich', 'Wealthy'],
    ['Strong', 'Powerful'],
  ];
  const p = pairs[Math.floor(Math.random() * pairs.length)];
  const distractor = pairs[(Math.floor(Math.random() * pairs.length) + 1) % pairs.length][1];
  const correctId = p[1];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `Synonym for <strong>${p[0]}</strong>?`,
    choices: [
      { id: correctId, label: p[1], correct: true },
      { id: distractor, label: distractor, correct: false },
      { id: 'Unrelated', label: 'Unrelated', correct: false },
    ],
  };
};

const analogies = (i: number, d: number): ChoiceTrial => {
  const items: Array<[string, string]> = [
    ['Hand:Glove', 'Sock'],
    ['Bird:Feathers', 'Scales'],
    ['Day:Sun', 'Moon'],
    ['Doctor:Hospital', 'School'],
    ['Kitten:Cat', 'Dog'],
    ['Up:Down', 'Right'],
  ];
  const p = items[Math.floor(Math.random() * items.length)];
  const distractor = items[(Math.floor(Math.random() * items.length) + 1) % items.length][1];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<strong>${p[0].split(':')[0]}</strong> is to <strong>${p[0].split(':')[1]}</strong> as <strong>${p[1].split(':')[0]}</strong> is to…`,
    choices: [
      { id: p[1], label: p[1], correct: true },
      { id: distractor, label: distractor, correct: false },
      { id: 'Shoe', label: 'Shoe', correct: false },
    ],
  };
};

const sentence = (i: number, d: number): ChoiceTrial => {
  const items: Array<[string, string, string, string]> = [
    ['The sky is ___ today.', 'Cloudy', 'Red', 'Loud'],
    ['I ___ my teeth every morning.', 'Brush', 'Eat', 'Read'],
    ['She ___ to music every day.', 'Listens', 'Eats', 'Runs'],
    ['The opposite of hot is ___.', 'Cold', 'Warm', 'Fast'],
  ];
  const p = items[Math.floor(Math.random() * items.length)];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:16px">${p[0]}</div>`,
    choices: [
      { id: p[1], label: p[1], correct: true },
      { id: p[2], label: p[2], correct: false },
      { id: p[3], label: p[3], correct: false },
    ],
  };
};

const vocab = (i: number, d: number): ChoiceTrial => {
  const items: Array<[string, string, string, string]> = [
    ['Ephemeral', 'Lasting a short time', 'Permanent', 'Flowing'],
    ['Ubiquitous', 'Found everywhere', 'Rare', 'Hidden'],
    ['Benevolent', 'Kind and generous', 'Cruel', 'Indifferent'],
    ['Pragmatic', 'Practical', 'Idealistic', 'Theoretical'],
  ];
  const p = items[Math.floor(Math.random() * items.length)];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `What does <strong>${p[0]}</strong> mean?`,
    choices: [
      { id: p[1], label: p[1], correct: true },
      { id: p[2], label: p[2], correct: false },
      { id: p[3], label: p[3], correct: false },
    ],
  };
};

const verbfluency = (i: number, d: number): TypeTrial => {
  const letter = String.fromCharCode(65 + Math.floor(Math.random() * 26));
  return {
    index: i,
    template: 'TYPE',
    difficulty: d,
    prompt: `Type as many words as you can starting with <strong style="font-size:36px;color:#14B8A6">${letter}</strong>`,
    placeholder: 'apple ant arrow…',
    answerPattern: '.+', // any non-empty
  };
};

const category = (i: number, d: number): TypeTrial => {
  const cats = ['Fruits', 'Countries', 'Animals', 'Sports', 'Colors'];
  const c = cats[Math.floor(Math.random() * cats.length)];
  return {
    index: i,
    template: 'TYPE',
    difficulty: d,
    prompt: `Name as many <strong>${c}</strong> as you can`,
    placeholder: 'apple banana cherry…',
    answerPattern: '.+',
  };
};

// ── PROBLEM-SOLVING ──────────────────────────────────────

const matrix = (i: number, d: number): ChoiceTrial => {
  const patterns = ['△○□☆', 'A B C D', '⏫⏬⏹⏺'];
  const p = patterns[Math.floor(Math.random() * patterns.length)];
  const chars = p.split('');
  const target = chars[Math.floor(Math.random() * chars.length)];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:18px;letter-spacing:6px">${chars.join(' ')}</div><div style="font-size:24px;margin-top:8px">Which comes next?</div>`,
    choices: chars.map((c) => ({ id: c, label: c, correct: c === target })),
  };
};

const logic = (i: number, d: number): ChoiceTrial => {
  const items: Array<[string, string, string, string]> = [
    ['All mammals are warm-blooded. Whales are mammals. Therefore, whales ___?', 'are warm-blooded', 'are cold-blooded', 'cannot be determined'],
    ['If A > B and B > C, then A ___ C.', '>', '<', '='],
    ['No cats are dogs. All dogs are mammals. Therefore, no cats ___ mammals.', 'are', 'are not', 'cannot be determined'],
  ];
  const p = items[Math.floor(Math.random() * items.length)];
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:14px">${p[0]}</div>`,
    choices: [
      { id: p[1], label: p[1], correct: true },
      { id: p[2], label: p[2], correct: false },
      { id: p[3], label: p[3], correct: false },
    ],
  };
};

const mentalrot = (i: number, d: number): ChoiceTrial => {
  const shape = ['◐', '◑', '◒', '◓'][Math.floor(Math.random() * 4)];
  const target = shape;
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:48px">${shape}</div><div style="font-size:14px;color:#94A3B8">Which is the same after rotation?</div>`,
    choices: [
      { id: target, label: target, correct: true },
      { id: 'mirror', label: '◑', correct: false },
      { id: 'flip', label: '◓', correct: false },
    ],
  };
};

const matchpairs = (i: number, d: number): GridTrial => {
  const size = 4 + Math.floor(d);
  const cells: string[][] = Array.from({ length: size }, () => Array.from({ length: size }, () => ''));
  // Place a target tile; user taps the same pattern elsewhere
  const patterns = ['◐', '◑', '◒', '◓', '◆', '●', '▲', '■'];
  const target = patterns[Math.floor(Math.random() * patterns.length)];
  const r1 = Math.floor(Math.random() * size);
  const c1 = Math.floor(Math.random() * size);
  cells[r1][c1] = target;
  let r2: number, c2: number;
  do {
    r2 = Math.floor(Math.random() * size);
    c2 = Math.floor(Math.random() * size);
  } while (r2 === r1 && c2 === c1);
  cells[r2][c2] = target;
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: `Tap the matching <strong>${target}</strong>`,
    rows: size,
    cols: size,
    cells,
    answer: { r: r2, c: c2 },
  };
};

const towers = (i: number, d: number): SortTrial => {
  const moves = Math.min(2 + Math.floor(d), 5);
  const pegs = ['A', 'B', 'C'] as const;
  const seq = Array.from({ length: moves }, () => pegs[Math.floor(Math.random() * 3)]);
  // Just a "what's the next move" prompt
  return {
    index: i,
    template: 'SORT',
    difficulty: d,
    item: 'Move from peg ' + (seq[0] ?? 'A'),
    categories: ['peg A', 'peg B', 'peg C'],
    answerIndex: Math.max(0, pegs.indexOf(seq[0] ?? 'A')),
  };
};

// ── EXECUTIVE ────────────────────────────────────────────

const trailmix = (i: number, d: number): GridTrial => {
  // V1 dynamism: numbers 1-25, sometimes pure-num block
  const size = 5 + Math.floor(d);
  const numItems = Math.min(8, 4 + Math.floor(d));
  const cells: string[][] = Array.from({ length: size }, () => Array.from({ length: size }, () => ''));
  const placed: Array<{ r: number; c: number; v: string }> = [];
  const used = new Set<string>();
  for (let n = 1; n <= numItems; n++) {
    let r: number, c: number, k: string;
    do {
      r = Math.floor(Math.random() * size);
      c = Math.floor(Math.random() * size);
      k = `${r},${c}`;
    } while (used.has(k));
    used.add(k);
    cells[r][c] = String(n);
    placed.push({ r, c, v: String(n) });
  }
  for (let n = 0; n < numItems; n++) {
    const letter = String.fromCharCode(65 + n);
    let r: number, c: number, k: string;
    do {
      r = Math.floor(Math.random() * size);
      c = Math.floor(Math.random() * size);
      k = `${r},${c}`;
    } while (used.has(k));
    used.add(k);
    cells[r][c] = letter;
    placed.push({ r, c, v: letter });
  }
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: `Alternate: 1→A→2→B→3→C… tap the next item.`,
    rows: size,
    cols: size,
    cells,
    answer: placed[0] ?? { r: 0, c: 0 },
  };
};

const rulefind = (i: number, d: number): SortTrial => {
  const rules: Array<[string, (n: number) => boolean, string]> = [
    ['Even numbers', (n) => n % 2 === 0, 'Odd numbers'],
    ['Numbers > 50', (n) => n > 50, 'Numbers ≤ 50'],
    ['Multiples of 3', (n) => n % 3 === 0, 'Not multiples of 3'],
  ];
  const r = rules[Math.floor(Math.random() * rules.length)];
  const n = Math.floor(Math.random() * 100) + 1;
  return {
    index: i,
    template: 'SORT',
    difficulty: d,
    item: `${n}`,
    categories: [r[0], r[2]],
    answerIndex: r[1](n) ? 0 : 1,
  };
};

const setshift = (i: number, d: number): ChoiceTrial => {
  const rules: Array<[string, (l: string) => boolean]> = [
    ['Is it a vowel?', (l) => /^[AEIOU]$/.test(l)],
    ['Is it in the first half of the alphabet?', (l) => l <= 'M'],
    ['Is it a letter in "CODE"?', (l) => 'CODE'.includes(l)],
  ];
  const r = rules[Math.floor(Math.random() * rules.length)];
  const l = String.fromCharCode(65 + Math.floor(Math.random() * 26));
  const ans = r[1](l) ? 'Yes' : 'No';
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `<div style="font-size:48px;font-weight:700">${l}</div><div style="font-size:14px;color:#94A3B8;margin-top:6px">${r[0]}</div>`,
    choices: [
      { id: 'Yes', label: 'Yes', correct: ans === 'Yes' },
      { id: 'No', label: 'No', correct: ans === 'No' },
    ],
  };
};

const planning = (i: number, d: number): GridTrial => {
  const size = 4 + Math.floor(d);
  const cells: string[][] = Array.from({ length: size }, () => Array.from({ length: size }, () => ''));
  cells[0][0] = 'S';
  cells[size - 1][size - 1] = 'E';
  // Place 2-3 obstacles
  const numObs = 2 + Math.floor(Math.random() * 2);
  const used = new Set<string>(['0,0', `${size - 1},${size - 1}`]);
  for (let k = 0; k < numObs; k++) {
    let r: number, c: number, key: string;
    do {
      r = Math.floor(Math.random() * size);
      c = Math.floor(Math.random() * size);
      key = `${r},${c}`;
    } while (used.has(key));
    used.add(key);
    cells[r][c] = '▓';
  }
  return {
    index: i,
    template: 'GRID',
    difficulty: d,
    prompt: 'Plan a route from S to E',
    rows: size,
    cols: size,
    cells,
    answer: { r: size - 1, c: size - 1 },
  };
};

const inhibit = (i: number, d: number): ChoiceTrial => {
  const directions = ['Up', 'Down', 'Left', 'Right'] as const;
  const d2 = directions[Math.floor(Math.random() * 4)];
  const opposite = { Up: 'Down', Down: 'Up', Left: 'Right', Right: 'Left' } as const;
  return {
    index: i,
    template: 'CHOICE',
    difficulty: d,
    prompt: `Arrow: <strong>${d2}</strong>. Tap the <strong>opposite</strong>.`,
    choices: directions.map((dir) => ({ id: dir, label: dir, correct: dir === opposite[d2] })),
  };
};

// ── EXPORTS ──────────────────────────────────────────────

export const generators: Record<string, (i: number, d: number) => Trial> = {
  // attention
  stroop, flanker, gongo, conswitch, selattn, divattn, reaction, symboldigit, canceltask, trailnum, patterncomp, lettercomp,
  // memory
  digitspan, corsi, spatialspan, paired, wordlist, picrecog, nback,
  // numeracy
  mentalmath, numline, estimation, quantity, numestimate, arithmeticv, fraction,
  // verbal
  synonyms, analogies, sentence, vocab, verbfluency, category,
  // problem
  matrix, logic, mentalrot, matchpairs, towers,
  // executive
  trailmix, rulefind, setshift, planning, inhibit,
};
