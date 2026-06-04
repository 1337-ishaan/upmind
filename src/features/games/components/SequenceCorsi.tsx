import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, radii, spacing, type } from '@/theme';
import type { SequenceTrial } from '../engine/types';

type Props = { trial: SequenceTrial; onAnswer: (r: unknown) => void };

/**
 * SequenceCorsi — used for Corsi, Spatial Span, and other position-memory
 * games. Shows positions one at a time, then accepts a tap-recall.
 */
export function SequenceCorsi({ trial, onAnswer }: Props) {
  const [phase, setPhase] = useState<'show' | 'recall'>('show');
  const [showIndex, setShowIndex] = useState(0);
  const [picks, setPicks] = useState<string[]>([]);

  // Determine grid size from the first item if present
  const first = trial.sequence[0];
  const gridSize = (typeof first === 'object' && first !== null && 'gridSize' in first ? first.gridSize : 4) ?? 4;

  useEffect(() => {
    setPhase('show');
    setShowIndex(0);
    setPicks([]);
  }, [trial]);

  useEffect(() => {
    if (phase !== 'show') return;
    if (showIndex >= trial.sequence.length) {
      setPhase('recall');
      return;
    }
    const t = setTimeout(() => setShowIndex((i) => i + 1), trial.showMs);
    return () => clearTimeout(t);
  }, [showIndex, phase, trial]);

  const currentItem = trial.sequence[showIndex];
  const targetR = typeof currentItem === 'object' && currentItem !== null ? currentItem.r : 0;
  const targetC = typeof currentItem === 'object' && currentItem !== null ? currentItem.c : 0;
  const active = phase === 'show' && showIndex < trial.sequence.length;

  const cells: Array<{ r: number; c: number }> = [];
  for (let r = 0; r < gridSize; r++) {
    for (let c = 0; c < gridSize; c++) {
      cells.push({ r, c });
    }
  }

  const onTap = (r: number, c: number) => {
    if (phase !== 'recall') return;
    const id = `${r},${c}`;
    const next = [...picks, id];
    setPicks(next);
    if (next.length === trial.answer.length) {
      onAnswer(next);
    }
  };

  return (
    <View style={styles.wrap}>
      <Text style={styles.prompt}>{trial.prompt ?? 'Tap the cells in order'}</Text>
      <View style={[styles.grid, { width: gridSize * 80 + (gridSize - 1) * 8 }]}>
        {cells.map(({ r, c }) => {
          const key = `${r},${c}`;
          const isActive = active && r === targetR && c === targetC;
          const isPicked = picks.includes(key);
          return (
            <Pressable
              key={key}
              onPress={() => onTap(r, c)}
              style={({ pressed }) => [
                styles.cell,
                isActive ? styles.cellActive : null,
                isPicked ? styles.cellPicked : null,
                pressed && { opacity: 0.7 },
              ]}
            />
          );
        })}
      </View>
      <View style={styles.slots}>
        {trial.answer.map((_, k) => (
          <View key={k} style={[styles.slot, picks[k] ? styles.slotFilled : null]}>
            <Text style={styles.slotText}>{picks[k] ? '✓' : '·'}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(4) },
  prompt: { ...type.body, color: colors.text, textAlign: 'center' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  cell: { width: 72, height: 72, borderRadius: radii.md, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider },
  cellActive: { backgroundColor: colors.teal, borderColor: colors.teal },
  cellPicked: { backgroundColor: 'rgba(20,184,166,0.18)', borderColor: colors.teal },
  slots: { flexDirection: 'row', gap: spacing(2), marginTop: spacing(2) },
  slot: { width: 28, height: 28, borderRadius: radii.xs, borderWidth: 1, borderColor: colors.divider, alignItems: 'center', justifyContent: 'center' },
  slotFilled: { borderColor: colors.teal, backgroundColor: 'rgba(20,184,166,0.18)' },
  slotText: { color: colors.teal, fontWeight: '600' },
});
