import { GAMES, getGame, CONSTRUCT_LABELS } from '../src/features/games/catalog';
import { generators } from '../src/features/games/engine/generators';

describe('Game catalog', () => {
  it('has 42 games', () => {
    expect(GAMES).toHaveLength(42);
  });

  it('every game has a generator', () => {
    for (const g of GAMES) {
      expect(generators[g.id]).toBeDefined();
    }
  });

  it('every construct has a label', () => {
    for (const g of GAMES) {
      expect(CONSTRUCT_LABELS[g.construct]).toBeDefined();
    }
  });

  it('getGame finds by id', () => {
    expect(getGame('flanker')?.id).toBe('flanker');
    expect(getGame('nonexistent')).toBeUndefined();
  });
});

describe('Trial generators produce valid trials', () => {
  it('stroop returns a CHOICE trial with choices', () => {
    const t = generators.stroop(0, 1);
    expect(t.template).toBe('CHOICE');
    expect(t.choices.length).toBeGreaterThan(0);
  });

  it('flanker target position varies', () => {
    const positions = new Set<string>();
    for (let i = 0; i < 30; i++) {
      const t = generators.flanker(i, 1);
      positions.add(t.variant ?? '');
    }
    expect(positions.size).toBeGreaterThan(1);
  });

  it('digitspan rotates modes', () => {
    const modes = new Set<string>();
    for (let i = 0; i < 60; i++) {
      const t = generators.digitspan(i, 1);
      modes.add(t.variant);
    }
    expect(modes.size).toBeGreaterThan(1);
  });

  it('corsi produces SEQUENCE trials', () => {
    const t = generators.corsi(0, 1);
    expect(t.template).toBe('SEQUENCE');
    expect(t.sequence.length).toBeGreaterThan(0);
  });

  it('mentalmath rotates between CHOICE and TYPE', () => {
    const templates = new Set<string>();
    for (let i = 0; i < 100; i++) {
      templates.add(generators.mentalmath(i, 1).template);
    }
    expect(templates.has('CHOICE')).toBe(true);
    expect(templates.has('TYPE')).toBe(true);
  });
});
