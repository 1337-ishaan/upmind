import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, radii, spacing, type } from '@/theme';
import type { GridTrial } from '../engine/types';

type Props = { trial: GridTrial; onAnswer: (r: unknown) => void };

/**
 * GridGame — visual search, cancellation, planning, trail-making, etc.
 * For single-target: tap the cell. For cancellation: tap all matching cells
 * and submit.
 */
export function GridGame({ trial, onAnswer }: Props) {
  const [tapped, setTapped] = useState<Set<string>>(new Set());

  const isCancel = trial.variant?.startsWith('cancel-');
  const isTrail = trial.template === 'GRID' && !trial.variant && !isCancel;
  const expectedTarget = trial.target;

  const onCell = (r: number, c: number) => {
    const key = `${r},${c}`;
    if (isCancel || isTrail) {
      const next = new Set(tapped);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      setTapped(next);
    } else {
      // Single-target: answer immediately
      onAnswer({ r, c });
    }
  };

  return (
    <View style={styles.wrap}>
      <Text style={styles.prompt}>{stripHtml(trial.prompt)}</Text>
      <View style={[styles.grid, { width: trial.cols * 56 + (trial.cols - 1) * 4 }]}>
        {trial.cells.flatMap((row, r) =>
          row.map((cell, c) => {
            const key = `${r},${c}`;
            const isTarget = cell === expectedTarget;
            const isTapped = tapped.has(key);
            const filled = cell !== '' && !isTarget;
            return (
              <Pressable
                key={key}
                onPress={() => onCell(r, c)}
                style={({ pressed }) => [
                  styles.cell,
                  isTarget && styles.cellTarget,
                  filled && styles.cellFilled,
                  isTapped && styles.cellTapped,
                  pressed && { opacity: 0.7 },
                ]}
              >
                {cell && <Text style={[styles.cellText, isTarget && { color: colors.bg }]}>{cell}</Text>}
              </Pressable>
            );
          })
        )}
      </View>
      {(isCancel || isTrail) && (
        <Pressable onPress={() => {
          // Submit: count correct targets
          if (isCancel) {
            const correctCells = trial.cells.flatMap((row, r) => row.map((c, k) => (c === expectedTarget ? { r, c: k } : null)).filter(Boolean) as Array<{ r: number; c: number }>);
            const correct = correctCells.filter((p) => tapped.has(`${p.r},${p.c}`)).length;
            const extras = Array.from(tapped).filter((k) => !correctCells.some((cc) => `${cc.r},${cc.c}` === k)).length;
            onAnswer({ correct, extras, total: correctCells.length });
          } else {
            onAnswer({ tapped: Array.from(tapped) });
          }
        }} style={({ pressed }) => [styles.submit, pressed && { opacity: 0.7 }]}>
          <Text style={styles.submitText}>Submit</Text>
        </Pressable>
      )}
    </View>
  );
}

function stripHtml(s: string) {
  return s.replace(/<[^>]+>/g, '').trim();
}

const styles = StyleSheet.create({
  wrap: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(4) },
  prompt: { ...type.body, color: colors.text, textAlign: 'center' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 4 },
  cell: { width: 52, height: 52, borderRadius: radii.xs, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, alignItems: 'center', justifyContent: 'center' },
  cellTarget: { backgroundColor: 'rgba(20,184,166,0.18)', borderColor: colors.teal },
  cellFilled: { backgroundColor: colors.surfaceMuted },
  cellTapped: { backgroundColor: colors.teal, borderColor: colors.teal },
  cellText: { color: colors.text, fontSize: 16, fontWeight: '600' },
  submit: { backgroundColor: colors.teal, borderRadius: radii.md, paddingHorizontal: spacing(6), paddingVertical: spacing(3), marginTop: spacing(2) },
  submitText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
});
