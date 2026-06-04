/**
 * Upmind — trial types and the engine contract.
 * Every game returns a Trial that fits one of these shapes.
 * The GamePlayer dispatches on `template` to render the right UI.
 */

export type Choice = { id: string; label: string; correct: boolean };

export type TrialBase = {
  index: number;
  template:
    | 'CHOICE'
    | 'REACTION'
    | 'SEQUENCE'
    | 'GRID'
    | 'RECALL'
    | 'NUMBERLINE'
    | 'TYPE'
    | 'SORT';
  difficulty: number;
  /** Optional variant tag for dynamism tracking ("flanker-pos-2", "stroop-length", etc). */
  variant?: string;
};

export type ChoiceTrial = TrialBase & {
  template: 'CHOICE' | 'RECALL';
  prompt: string;
  choices: Choice[];
  /** Optional sub-mode (e.g. "forward" | "backward" | "skip" for digit span). */
  mode?: string;
};

export type ReactionTrial = TrialBase & {
  template: 'REACTION';
  prompt: string;
  signal: string;
  /** Whether the user should respond at all (false = withhold trial). */
  shouldPress: boolean;
  /** Minimum ITI in ms before the signal can appear. */
  minDelay: number;
  /** Maximum ITI in ms. */
  maxDelay: number;
  channel?: 'visual' | 'audio' | 'either';
};

export type SequenceTrial = TrialBase & {
  template: 'SEQUENCE';
  /** Items shown one at a time during the study phase. */
  sequence: Array<string | { r: number; c: number; gridSize?: number }>;
  /** The correct recall (in order). For digit span, may be reversed or filtered. */
  answer: string[];
  /** Per-item show time in ms. */
  showMs: number;
  /** Optional prompt for the recall phase ("Repeat the sequence", "Reverse", etc). */
  prompt?: string;
  choices?: string[];
};

export type GridTrial = TrialBase & {
  template: 'GRID';
  prompt: string;
  rows: number;
  cols: number;
  /** Cell labels (string or empty). */
  cells: string[][];
  /** Coordinates of the correct cell. */
  answer: { r: number; c: number };
  /** Optional target letter or shape. */
  target?: string;
};

export type NumberLineTrial = TrialBase & {
  template: 'NUMBERLINE';
  prompt: string;
  min: number;
  max: number;
  target: number;
};

export type TypeTrial = TrialBase & {
  template: 'TYPE';
  prompt: string;
  placeholder?: string;
  /** Acceptable answers, regex source. */
  answerPattern: string;
};

export type SortTrial = TrialBase & {
  template: 'SORT';
  item: string;
  categories: string[];
  answerIndex: number;
};

export type Trial =
  | ChoiceTrial
  | ReactionTrial
  | SequenceTrial
  | GridTrial
  | NumberLineTrial
  | TypeTrial
  | SortTrial;
