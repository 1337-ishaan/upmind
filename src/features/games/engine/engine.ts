/**
 * Upmind — game engine core.
 * Manages trial state, RT, drift detection, and the trial lifecycle.
 * One session = one game + N trials. The GamePlayer screen is a thin
 * UI shell that calls into the engine.
 */

import { GameDef, getGame } from '../catalog';
import { Trial } from './types';
import { generators } from './generators';

export type AnswerRecord = {
  trialIndex: number;
  rtMs: number;
  correct: boolean;
  /** User's raw response (for reanalysis). */
  response: unknown;
  /** True if this trial was flagged as anti-cheat drift. */
  drift: boolean;
};

export type SessionResult = {
  gameId: string;
  construct: string;
  startedAt: number;
  finishedAt: number;
  trials: Trial[];
  answers: AnswerRecord[];
  score: number;
  rtMedianMs: number;
  rtStddevMs: number;
  accuracy: number;
  drifts: number;
};

export type EngineState = {
  game: GameDef;
  difficulty: number;
  trials: Trial[];
  answers: AnswerRecord[];
  currentIndex: number;
  startTime: number;
  trialStart: number;
  isFinished: boolean;
  isStarted: boolean;
  drifts: number;
};

export type EngineListeners = {
  onTrial: (trial: Trial, index: number) => void;
  onAnswer: (record: AnswerRecord) => void;
  onFinish: (result: SessionResult) => void;
};

const RT_IMPOSSIBLE_FLOOR_MS = 100;

export class Engine {
  state: EngineState;
  listeners: Partial<EngineListeners>;

  constructor(game: GameDef, listeners: Partial<EngineListeners> = {}) {
    this.state = {
      game,
      difficulty: 1,
      trials: [],
      answers: [],
      currentIndex: 0,
      startTime: 0,
      trialStart: 0,
      isFinished: false,
      isStarted: false,
      drifts: 0,
    };
    this.listeners = listeners;
  }

  start() {
    const generator = generators[this.state.game.id];
    if (!generator) throw new Error(`No generator for game: ${this.state.game.id}`);
    const trials: Trial[] = [];
    for (let i = 0; i < this.state.game.trials; i++) {
      trials.push(generator(i, this.state.difficulty));
    }
    this.state.trials = trials;
    this.state.isStarted = true;
    this.state.startTime = Date.now();
    this.nextTrial();
  }

  private nextTrial() {
    if (this.state.currentIndex >= this.state.trials.length) {
      this.finish();
      return;
    }
    const trial = this.state.trials[this.state.currentIndex];
    this.state.trialStart = Date.now();
    this.listeners.onTrial?.(trial, this.state.currentIndex);
  }

  /** Returns true if correct. */
  answer(response: unknown): { correct: boolean; drift: boolean } {
    if (this.state.isFinished || !this.state.isStarted) {
      return { correct: false, drift: false };
    }
    const trial = this.state.trials[this.state.currentIndex];
    const rtMs = Date.now() - this.state.trialStart;
    const correct = this.isCorrect(trial, response);
    const drift = this.detectDrift(rtMs, response);

    if (drift) this.state.drifts++;

    const record: AnswerRecord = {
      trialIndex: this.state.currentIndex,
      rtMs,
      correct,
      response,
      drift,
    };
    this.state.answers.push(record);
    this.listeners.onAnswer?.(record);

    this.state.currentIndex++;
    this.nextTrial();
    return { correct, drift };
  }

  /** User exited the game before completing it. We discard partial data. */
  abort() {
    this.state.isFinished = true;
  }

  private isCorrect(trial: Trial, response: unknown): boolean {
    switch (trial.template) {
      case 'CHOICE':
      case 'RECALL': {
        const t = trial;
        const choice = t.choices.find((c) => c.id === response);
        return !!choice?.correct;
      }
      case 'REACTION': {
        const t = trial;
        return Boolean(response) === t.shouldPress;
      }
      case 'SEQUENCE': {
        const t = trial;
        const user = Array.isArray(response) ? (response as string[]) : [];
        if (user.length !== t.answer.length) return false;
        return user.every((v, i) => v === t.answer[i]);
      }
      case 'GRID': {
        const t = trial;
        if (!response || typeof response !== 'object') return false;
        const r = response as { r: number; c: number };
        return r.r === t.answer.r && r.c === t.answer.c;
      }
      case 'NUMBERLINE': {
        const t = trial;
        const user = typeof response === 'number' ? response : 0;
        return Math.abs(user - t.target) <= (t.max - t.min) * 0.05;
      }
      case 'TYPE': {
        const t = trial;
        const user = typeof response === 'string' ? response.trim().toLowerCase() : '';
        try {
          return new RegExp(t.answerPattern, 'i').test(user);
        } catch {
          return false;
        }
      }
      case 'SORT': {
        const t = trial;
        return response === t.answerIndex;
      }
    }
  }

  private detectDrift(rtMs: number, response: unknown): boolean {
    // RT below impossible-human floor
    if (rtMs < RT_IMPOSSIBLE_FLOOR_MS) return true;
    // Repeated exact RT (suspicious)
    const last = this.state.answers[this.state.answers.length - 1];
    if (last && last.rtMs === rtMs && JSON.stringify(last.response) === JSON.stringify(response)) {
      return true;
    }
    return false;
  }

  private finish() {
    this.state.isFinished = true;
    const finishedAt = Date.now();
    const correct = this.state.answers.filter((a) => a.correct).length;
    const score = Math.round((correct / this.state.answers.length) * 100);
    const rts = this.state.answers.map((a) => a.rtMs).sort((a, b) => a - b);
    const median = rts.length ? rts[Math.floor(rts.length / 2)] : 0;
    const mean = rts.length ? rts.reduce((a, b) => a + b, 0) / rts.length : 0;
    const variance = rts.length
      ? rts.reduce((acc, v) => acc + (v - mean) ** 2, 0) / rts.length
      : 0;
    const stddev = Math.sqrt(variance);

    const result: SessionResult = {
      gameId: this.state.game.id,
      construct: this.state.game.construct,
      startedAt: this.state.startTime,
      finishedAt,
      trials: this.state.trials,
      answers: this.state.answers,
      score,
      rtMedianMs: median,
      rtStddevMs: Math.round(stddev),
      accuracy: correct / Math.max(1, this.state.answers.length),
      drifts: this.state.drifts,
    };
    this.listeners.onFinish?.(result);
  }
}

export function createEngine(gameId: string, listeners?: Partial<EngineListeners>): Engine {
  const game = getGame(gameId);
  if (!game) throw new Error(`Unknown game: ${gameId}`);
  return new Engine(game, listeners);
}
