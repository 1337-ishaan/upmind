/**
 * Upmind — game catalog.
 * 42 games across 7 constructs. The `template` field maps each game
 * to one of the 12 trial templates in src/features/games/engine/templates.
 *
 * Mirrors the structure used in the HTML prototype (index.html)
 * so the port is 1:1.
 */

export type Construct =
  | 'attention'
  | 'memory'
  | 'processing'
  | 'numeracy'
  | 'verbal'
  | 'problem'
  | 'executive';

export type GameTemplate =
  | 'CHOICE'
  | 'REACTION'
  | 'SEQUENCE'
  | 'GRID'
  | 'RECALL'
  | 'NUMBERLINE'
  | 'TYPE'
  | 'SORT';

export type GameId =
  | 'stroop'
  | 'flanker'
  | 'gongo'
  | 'conswitch'
  | 'selattn'
  | 'divattn'
  | 'reaction'
  | 'symboldigit'
  | 'canceltask'
  | 'trailnum'
  | 'digitspan'
  | 'corsi'
  | 'nback'
  | 'spatialspan'
  | 'paired'
  | 'wordlist'
  | 'picrecog'
  | 'patterncomp'
  | 'mentalmath'
  | 'numline'
  | 'estimation'
  | 'quantity'
  | 'numestimate'
  | 'arithmeticv'
  | 'fraction'
  | 'synonyms'
  | 'analogies'
  | 'sentence'
  | 'vocab'
  | 'verbfluency'
  | 'category'
  | 'matrix'
  | 'logic'
  | 'mentalrot'
  | 'matchpairs'
  | 'towers'
  | 'trailmix'
  | 'rulefind'
  | 'setshift'
  | 'planning'
  | 'inhibit'
  | 'strooprt'
  | 'lettercomp';

export type GameDef = {
  id: GameId;
  name: string;
  construct: Construct;
  template: GameTemplate;
  trials: number;
  description: string;
  premium?: boolean;
};

export const GAMES: GameDef[] = [
  // ── Attention (7) ──
  { id: 'stroop', name: 'Stroop', construct: 'attention', template: 'CHOICE', trials: 20, description: 'Name the ink color' },
  { id: 'flanker', name: 'Flanker Focus', construct: 'attention', template: 'CHOICE', trials: 20, description: 'Target arrow with distractors' },
  { id: 'gongo', name: 'Go / No-Go', construct: 'attention', template: 'REACTION', trials: 30, description: 'Press for animals only' },
  { id: 'conswitch', name: 'Context Switch', construct: 'attention', template: 'CHOICE', trials: 20, description: 'Switch between rules' },
  { id: 'selattn', name: 'Visual Search', construct: 'attention', template: 'GRID', trials: 16, description: 'Find the target letter' },
  { id: 'divattn', name: 'Divided Attention', construct: 'attention', template: 'REACTION', trials: 24, description: 'Dual-channel task' },
  { id: 'reaction', name: 'Simple Reaction', construct: 'attention', template: 'REACTION', trials: 20, description: 'Tap on signal' },

  // ── Memory (7) ──
  { id: 'digitspan', name: 'Digit Span', construct: 'memory', template: 'SEQUENCE', trials: 14, description: 'Repeat sequences' },
  { id: 'corsi', name: 'Corsi Blocks', construct: 'memory', template: 'SEQUENCE', trials: 14, description: 'Tap blocks in order' },
  { id: 'spatialspan', name: 'Spatial Span', construct: 'memory', template: 'SEQUENCE', trials: 12, description: 'Remember positions' },
  { id: 'paired', name: 'Paired Associate', construct: 'memory', template: 'RECALL', trials: 16, description: 'Recall word pairs' },
  { id: 'wordlist', name: 'Word List', construct: 'memory', template: 'TYPE', trials: 1, description: 'Type remembered words' },
  { id: 'picrecog', name: 'Picture Recognition', construct: 'memory', template: 'CHOICE', trials: 20, description: 'Seen before?' },
  { id: 'nback', name: 'N-Back', construct: 'memory', template: 'CHOICE', trials: 16, description: '2-back match detection' },

  // ── Processing (5) ──
  { id: 'symboldigit', name: 'Symbol-Digit', construct: 'processing', template: 'CHOICE', trials: 24, description: 'Match symbols to digits' },
  { id: 'canceltask', name: 'Cancellation', construct: 'processing', template: 'GRID', trials: 1, description: 'Cross out targets' },
  { id: 'trailnum', name: 'Trail Making A', construct: 'processing', template: 'GRID', trials: 1, description: 'Connect 1→2→3' },
  { id: 'patterncomp', name: 'Pattern Comparison', construct: 'processing', template: 'CHOICE', trials: 20, description: 'Same or different?' },
  { id: 'lettercomp', name: 'Letter Comparison', construct: 'processing', template: 'CHOICE', trials: 20, description: 'Strings identical?' },

  // ── Numeracy (6) ──
  { id: 'mentalmath', name: 'Mental Math', construct: 'numeracy', template: 'CHOICE', trials: 20, description: 'Arithmetic problems' },
  { id: 'numline', name: 'Number Line', construct: 'numeracy', template: 'NUMBERLINE', trials: 16, description: 'Place a number' },
  { id: 'estimation', name: 'Estimation', construct: 'numeracy', template: 'CHOICE', trials: 16, description: 'Approximate product' },
  { id: 'quantity', name: 'Quantity', construct: 'numeracy', template: 'CHOICE', trials: 16, description: 'Which is more?' },
  { id: 'numestimate', name: 'Number Estimate', construct: 'numeracy', template: 'NUMBERLINE', trials: 16, description: 'Estimate count' },
  { id: 'arithmeticv', name: 'Arithmetic Verify', construct: 'numeracy', template: 'CHOICE', trials: 20, description: 'Correct equation?' },
  { id: 'fraction', name: 'Fraction Compare', construct: 'numeracy', template: 'CHOICE', trials: 16, description: 'Larger fraction?' },

  // ── Verbal (6) ──
  { id: 'synonyms', name: 'Synonyms', construct: 'verbal', template: 'CHOICE', trials: 20, description: 'Word meaning match' },
  { id: 'analogies', name: 'Analogies', construct: 'verbal', template: 'CHOICE', trials: 16, description: 'A:B :: C:? pattern' },
  { id: 'sentence', name: 'Sentence Complete', construct: 'verbal', template: 'CHOICE', trials: 16, description: 'Best-fit word' },
  { id: 'vocab', name: 'Vocabulary', construct: 'verbal', template: 'CHOICE', trials: 16, description: 'Define words' },
  { id: 'verbfluency', name: 'Verbal Fluency', construct: 'verbal', template: 'TYPE', trials: 1, description: 'Words starting with letter' },
  { id: 'category', name: 'Category Fluency', construct: 'verbal', template: 'TYPE', trials: 1, description: 'Category members' },

  // ── Problem-Solving (5) ──
  { id: 'matrix', name: 'Matrix Reasoning', construct: 'problem', template: 'CHOICE', trials: 12, description: 'Find the pattern' },
  { id: 'logic', name: 'Logic', construct: 'problem', template: 'CHOICE', trials: 16, description: 'Syllogisms' },
  { id: 'mentalrot', name: 'Mental Rotation', construct: 'problem', template: 'CHOICE', trials: 16, description: 'Rotate shapes' },
  { id: 'matchpairs', name: 'Pattern Match', construct: 'problem', template: 'GRID', trials: 12, description: 'Match the tile' },
  { id: 'towers', name: 'Tower of Hanoi', construct: 'problem', template: 'SORT', trials: 8, description: 'Plan moves' },

  // ── Executive (5, premium) ──
  { id: 'trailmix', name: 'Trail Making B', construct: 'executive', template: 'GRID', trials: 1, description: 'Alternate number/letter', premium: true },
  { id: 'rulefind', name: 'Rule Finding (WCST)', construct: 'executive', template: 'SORT', trials: 24, description: 'Sort by hidden rule', premium: true },
  { id: 'setshift', name: 'Set Shifting', construct: 'executive', template: 'CHOICE', trials: 16, description: 'Switch categories', premium: true },
  { id: 'planning', name: 'Planning (Zoo Map)', construct: 'executive', template: 'GRID', trials: 1, description: 'Plan a route', premium: true },
  { id: 'inhibit', name: 'Inhibition', construct: 'executive', template: 'CHOICE', trials: 16, description: 'Stop the impulse', premium: true },
];

export const CONSTRUCT_LABELS: Record<Construct, string> = {
  attention: 'Attention',
  memory: 'Memory',
  processing: 'Processing',
  numeracy: 'Numeracy',
  verbal: 'Verbal',
  problem: 'Problem-Solving',
  executive: 'Executive Function',
};

export const CONSTRUCT_ORDER: Construct[] = [
  'attention',
  'memory',
  'processing',
  'numeracy',
  'verbal',
  'problem',
  'executive',
];

export function getGame(id: string): GameDef | undefined {
  return GAMES.find((g) => g.id === id);
}
