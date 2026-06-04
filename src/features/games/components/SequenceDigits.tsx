import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, radii, spacing, type } from '@/theme';
import type { SequenceTrial } from '../engine/types';

type Props = { trial: SequenceTrial; onAnswer: (r: unknown) => void };

/**
 * SequenceDigits — used for Digit Span (forward / backward / skip).
 * Shows digits one at a time, then accepts a keypad recall.
 */
export function SequenceDigits({ trial, onAnswer }: Props) {
  const [phase, setPhase] = useState<'show' | 'recall'>('show');
  const [showIndex, setShowIndex] = useState(0);
  const [picks, setPicks] = useState<string[]>([]);
  const choices = trial.choices ?? ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

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

  const current = trial.sequence[showIndex];
  const active = phase === 'show' && showIndex < trial.sequence.length;

  const onPick = (v: string) => {
    const next = [...picks, v];
    setPicks(next);
    if (next.length === trial.answer.length) {
      onAnswer(next);
    }
  };

  return (
    <View style={styles.wrap}>
      <Text style={styles.prompt}>{trial.prompt ?? 'Repeat the sequence'}</Text>
      <View style={styles.display}>
        <Text style={styles.bigNum}>{active ? String(current) : '·'}</Text>
      </View>
      <View style={styles.slots}>
        {trial.answer.map((_, k) => (
          <View key={k} style={[styles.slot, picks[k] ? styles.slotFilled : null]}>
            <Text style={styles.slotText}>{picks[k] ?? '·'}</Text>
          </View>
        ))}
      </View>
      {phase === 'recall' && (
        <View style={styles.keypad}>
          {choices.map((v) => (
            <Pressable key={v} onPress={() => onPick(v)} style={({ pressed }) => [styles.key, pressed && { opacity: 0.7 }]}>
              <Text style={styles.keyText}>{v}</Text>
            </Pressable>
          ))}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(4) },
  prompt: { ...type.body, color: colors.text, textAlign: 'center' },
  display: { width: 120, height: 120, borderRadius: radii.lg, backgroundColor: colors.surface, alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: colors.divider },
  bigNum: { fontSize: 64, fontWeight: '700', color: colors.teal, fontFamily: 'monospace' },
  slots: { flexDirection: 'row', gap: spacing(2), marginTop: spacing(2) },
  slot: { width: 28, height: 28, borderRadius: radii.xs, borderWidth: 1, borderColor: colors.divider, alignItems: 'center', justifyContent: 'center' },
  slotFilled: { borderColor: colors.teal, backgroundColor: 'rgba(20,184,166,0.18)' },
  slotText: { color: colors.teal, fontFamily: 'monospace', fontWeight: '600' },
  keypad: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', gap: spacing(2), marginTop: spacing(4) },
  key: { width: 60, height: 50, borderRadius: radii.sm, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, alignItems: 'center', justifyContent: 'center' },
  keyText: { fontSize: 18, fontWeight: '600', color: colors.text },
});
