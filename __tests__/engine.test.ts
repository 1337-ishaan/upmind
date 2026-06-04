import { Engine, createEngine } from '../src/features/games/engine/engine';

describe('Game engine', () => {
  it('runs a full game session', () => {
    const finished: any[] = [];
    const engine = createEngine('flanker', {
      onFinish: (r) => finished.push(r),
    });
    engine.start();
    const totalTrials = engine.state.game.trials;
    for (let i = 0; i < totalTrials; i++) {
      const answer = engine.state.trials[i].choices.find((c) => c.correct)?.id ?? '';
      engine.answer(answer);
    }
    expect(finished).toHaveLength(1);
    const result = finished[0];
    expect(result.gameId).toBe('flanker');
    expect(result.score).toBe(100);
    expect(result.drifts).toBe(0);
  });

  it('flags impossible RTs as drift', () => {
    const records: any[] = [];
    const engine = createEngine('flanker', {
      onAnswer: (a) => records.push(a),
    });
    engine.start();
    // answer immediately — should drift
    engine.answer(engine.state.trials[0].choices.find((c) => c.correct)?.id ?? '');
    expect(records[0].drift).toBe(true);
  });

  it('produces a score in 0-100', () => {
    let result: any;
    const engine = createEngine('stroop', { onFinish: (r) => (result = r) });
    engine.start();
    // Mix correct and wrong
    for (let i = 0; i < engine.state.game.trials; i++) {
      const c = engine.state.trials[i].choices.find((c) => c.correct)?.id ?? 'wrong';
      engine.answer(i % 3 === 0 ? 'wrong' : c);
    }
    expect(result.score).toBeGreaterThanOrEqual(0);
    expect(result.score).toBeLessThanOrEqual(100);
  });
});
