import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { colors, radii, spacing, type } from '@/theme';
import type { Trial, ChoiceTrial, ReactionTrial, SequenceTrial, GridTrial, NumberLineTrial, TypeTrial, SortTrial } from '../engine/types';
import { SequenceCorsi } from './SequenceCorsi';
import { SequenceDigits } from './SequenceDigits';
import { GridGame } from './GridGame';
import { NumberLine } from './NumberLine';

type Props = {
  trial: Trial;
  onAnswer: (response: unknown) => void;
  feedback: 'correct' | 'incorrect' | null;
};

export function TemplateRenderer({ trial, onAnswer, feedback }: Props) {
  switch (trial.template) {
    case 'CHOICE':
    case 'RECALL':
      return <ChoiceView trial={trial} onAnswer={onAnswer} feedback={feedback} />;
    case 'REACTION':
      return <ReactionView trial={trial} onAnswer={onAnswer} />;
    case 'SEQUENCE': {
      // Heuristic: digits if all items are short strings of digits, else Corsi grid
      const isDigits = trial.sequence.every((s) => typeof s === 'string' && s.length === 1 && /\d/.test(s));
      if (isDigits) return <SequenceDigits trial={trial} onAnswer={onAnswer} />;
      return <SequenceCorsi trial={trial} onAnswer={onAnswer} />;
    }
    case 'GRID':
      return <GridGame trial={trial} onAnswer={onAnswer} />;
    case 'NUMBERLINE':
      return <NumberLine trial={trial} onAnswer={onAnswer} />;
    case 'TYPE':
      return <TypeView trial={trial} onAnswer={onAnswer} />;
    case 'SORT':
      return <SortView trial={trial} onAnswer={onAnswer} />;
  }
}

function ChoiceView({ trial, onAnswer, feedback }: { trial: ChoiceTrial; onAnswer: (r: unknown) => void; feedback: 'correct' | 'incorrect' | null }) {
  return (
    <View style={styles.choiceWrap}>
      <Text style={styles.prompt}>{stripHtml(trial.prompt)}</Text>
      <View style={styles.choices}>
        {trial.choices.map((c) => (
          <Pressable
            key={c.id}
            onPress={() => onAnswer(c.id)}
            style={({ pressed }) => [
              styles.choiceBtn,
              feedback === 'correct' && c.correct && styles.choiceCorrect,
              feedback === 'incorrect' && c.correct && styles.choiceCorrect,
              feedback === 'incorrect' && !c.correct && styles.choiceDim,
              pressed && { opacity: 0.7 },
            ]}
          >
            <Text style={styles.choiceLabel}>{c.label}</Text>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

function ReactionView({ trial, onAnswer }: { trial: ReactionTrial; onAnswer: (r: unknown) => void }) {
  const [phase, setPhase] = useState<'wait' | 'signal'>('wait');
  const [pressed, setPressed] = useState(false);

  useEffect(() => {
    setPhase('wait');
    setPressed(false);
    const delay = trial.minDelay + Math.random() * (trial.maxDelay - trial.minDelay);
    const t = setTimeout(() => setPhase('signal'), delay);
    return () => clearTimeout(t);
  }, [trial]);

  const onPress = () => {
    if (pressed) return;
    setPressed(true);
    onAnswer(phase === 'signal' ? 1 : 0);
  };

  if (trial.shouldPress && phase === 'wait') {
    return (
      <View style={styles.reactionWrap}>
        <Text style={styles.prompt}>{trial.prompt}</Text>
        <View style={styles.waitBubble}>
          <Text style={styles.waitText}>Wait for the signal…</Text>
        </View>
      </View>
    );
  }
  if (trial.shouldPress && phase === 'signal') {
    return (
      <Pressable onPress={onPress} style={({ pressed }) => [styles.signal, pressed && { opacity: 0.7 }]}>
        <Text style={styles.signalText}>{trial.signal || 'TAP!'}</Text>
      </Pressable>
    );
  }
  // Withhold trial: just present the prompt, user must NOT press
  return (
    <Pressable onPress={onPress} style={({ pressed }) => [styles.signal, pressed && { opacity: 0.7 }]}>
      <Text style={styles.prompt}>{trial.prompt}</Text>
      <View style={styles.withholdBubble}>
        <Text style={styles.waitText}>{trial.signal || 'No signal'}</Text>
        <Text style={styles.withholdHint}>Do NOT press</Text>
      </View>
    </Pressable>
  );
}

function TypeView({ trial, onAnswer }: { trial: TypeTrial; onAnswer: (r: unknown) => void }) {
  const [value, setValue] = useState('');
  return (
    <View style={styles.typeWrap}>
      <Text style={styles.prompt}>{stripHtml(trial.prompt)}</Text>
      <TextInput
        style={styles.input}
        value={value}
        onChangeText={setValue}
        placeholder={trial.placeholder ?? 'Type your answer…'}
        placeholderTextColor={colors.textDim}
        autoFocus
        onSubmitEditing={() => onAnswer(value)}
        returnKeyType="done"
      />
      <Pressable onPress={() => onAnswer(value)} style={({ pressed }) => [styles.submit, pressed && { opacity: 0.7 }]}>
        <Text style={styles.submitText}>Submit</Text>
      </Pressable>
    </View>
  );
}

function SortView({ trial, onAnswer }: { trial: SortTrial; onAnswer: (r: unknown) => void }) {
  return (
    <View style={styles.choiceWrap}>
      <Text style={styles.prompt}>{stripHtml(trial.item)}</Text>
      <View style={styles.choices}>
        {trial.categories.map((cat, k) => (
          <Pressable
            key={`${cat}-${k}`}
            onPress={() => onAnswer(k)}
            style={({ pressed }) => [styles.choiceBtn, pressed && { opacity: 0.7 }]}
          >
            <Text style={styles.choiceLabel}>{cat}</Text>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

function stripHtml(s: string): string {
  return s.replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').trim();
}

const styles = StyleSheet.create({
  choiceWrap: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(6) },
  prompt: { ...type.h1, color: colors.text, textAlign: 'center', marginBottom: spacing(2) },
  choices: { width: '100%', gap: spacing(3) },
  choiceBtn: { backgroundColor: colors.surface, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center', borderWidth: 1, borderColor: colors.divider },
  choiceLabel: { ...type.bodyStrong, color: colors.text },
  choiceCorrect: { borderColor: colors.teal, backgroundColor: 'rgba(20,184,166,0.12)' },
  choiceDim: { opacity: 0.35 },
  reactionWrap: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  waitBubble: { backgroundColor: colors.surface, borderRadius: radii.lg, padding: spacing(8), borderWidth: 1, borderColor: colors.divider, minWidth: 200, alignItems: 'center' },
  waitText: { ...type.bodyStrong, color: colors.textMuted },
  withholdBubble: { backgroundColor: colors.surface, borderRadius: radii.lg, padding: spacing(8), borderWidth: 1, borderColor: colors.divider, minWidth: 200, alignItems: 'center', gap: spacing(2) },
  withholdHint: { ...type.small, color: colors.warn },
  signal: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.teal, borderRadius: radii.lg, margin: spacing(2) },
  signalText: { fontSize: 36, fontWeight: '700', color: colors.bg },
  typeWrap: { flex: 1, justifyContent: 'center', gap: spacing(4) },
  input: { backgroundColor: colors.surface, borderColor: colors.divider, borderWidth: 1, borderRadius: radii.md, paddingHorizontal: spacing(4), paddingVertical: spacing(4), color: colors.text, fontSize: 18, textAlign: 'center' },
  submit: { backgroundColor: colors.teal, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center' },
  submitText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
});
