import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, radii, spacing, type } from '@/theme';
import type { NumberLineTrial } from '../engine/types';

type Props = { trial: NumberLineTrial; onAnswer: (r: unknown) => void };

/**
 * NumberLine — drag a thumb along a track to indicate a value.
 * For RN, we approximate with discrete increments (tap left/right arrows)
 * since drag-and-release is more complex; the discrete approximation
 * gives comparable accuracy for the construct being measured.
 */
export function NumberLine({ trial, onAnswer }: Props) {
  const [value, setValue] = useState(Math.round((trial.min + trial.max) / 2));
  const step = Math.max(1, Math.round((trial.max - trial.min) / 20));

  return (
    <View style={styles.wrap}>
      <Text style={styles.prompt}>{stripHtml(trial.prompt)}</Text>
      <View style={styles.valueBox}>
        <Text style={styles.valueText}>{value}</Text>
      </View>
      <View style={styles.row}>
        <Pressable onPress={() => setValue((v) => Math.max(trial.min, v - step))} style={({ pressed }) => [styles.arrow, pressed && { opacity: 0.7 }]}>
          <Text style={styles.arrowText}>‹</Text>
        </Pressable>
        <View style={styles.track}>
          <View style={styles.trackBg}>
            <View style={[styles.thumb, { left: `${((value - trial.min) / (trial.max - trial.min)) * 100}%` }]} />
          </View>
        </View>
        <Pressable onPress={() => setValue((v) => Math.min(trial.max, v + step))} style={({ pressed }) => [styles.arrow, pressed && { opacity: 0.7 }]}>
          <Text style={styles.arrowText}>›</Text>
        </Pressable>
      </View>
      <View style={styles.labels}>
        <Text style={styles.labelText}>{trial.min}</Text>
        <Text style={styles.labelText}>{Math.round((trial.min + trial.max) / 2)}</Text>
        <Text style={styles.labelText}>{trial.max}</Text>
      </View>
      <Pressable onPress={() => onAnswer(value)} style={({ pressed }) => [styles.submit, pressed && { opacity: 0.7 }]}>
        <Text style={styles.submitText}>Confirm</Text>
      </Pressable>
    </View>
  );
}

function stripHtml(s: string) {
  return s.replace(/<[^>]+>/g, '').trim();
}

const styles = StyleSheet.create({
  wrap: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(4) },
  prompt: { ...type.body, color: colors.text, textAlign: 'center' },
  valueBox: { paddingHorizontal: spacing(8), paddingVertical: spacing(4), borderRadius: radii.lg, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, marginVertical: spacing(4) },
  valueText: { fontSize: 40, fontWeight: '700', color: colors.teal, fontFamily: 'monospace' },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing(3), width: '100%' },
  arrow: { width: 44, height: 44, borderRadius: 22, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, alignItems: 'center', justifyContent: 'center' },
  arrowText: { color: colors.text, fontSize: 22 },
  track: { flex: 1 },
  trackBg: { height: 6, backgroundColor: colors.surfaceMuted, borderRadius: 3, position: 'relative' },
  thumb: { position: 'absolute', top: -7, width: 20, height: 20, borderRadius: 10, backgroundColor: colors.teal, marginLeft: -10 },
  labels: { flexDirection: 'row', justifyContent: 'space-between', width: '100%' },
  labelText: { color: colors.textMuted, fontSize: 11, fontFamily: 'monospace' },
  submit: { backgroundColor: colors.teal, borderRadius: radii.md, paddingHorizontal: spacing(8), paddingVertical: spacing(3), marginTop: spacing(4) },
  submitText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
});
