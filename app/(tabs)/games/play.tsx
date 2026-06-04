import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { createEngine } from '@/features/games/engine/engine';
import { getGame } from '@/features/games/catalog';
import { useGameStore } from '@/features/games/store';
import { colors, layout, radii, spacing, type } from '@/theme';
import type { Trial } from '@/features/games/engine/types';
import { TemplateRenderer } from '@/features/games/components/TemplateRenderer';

export default function GamePlayerScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const gameDef = id ? getGame(id) : undefined;
  const [trial, setTrial] = useState<Trial | null>(null);
  const [index, setIndex] = useState(0);
  const [feedback, setFeedback] = useState<null | 'correct' | 'incorrect'>(null);
  const engineRef = useRef<ReturnType<typeof createEngine> | null>(null);
  const recordSession = useGameStore((s) => s.recordSession);

  useEffect(() => {
    if (!gameDef) return;
    const engine = createEngine(gameDef.id, {
      onTrial: (t) => {
        setTrial(t);
        setIndex(engine.state.currentIndex);
        setFeedback(null);
      },
      onAnswer: () => {
        // feedback is set inside onAnswer below via the response; we just count
      },
      onFinish: async (result) => {
        await recordSession({
          gameId: result.gameId,
          construct: result.construct as any,
          startedAt: result.startedAt,
          finishedAt: result.finishedAt,
          score: result.score,
          rtMedianMs: result.rtMedianMs,
          rtStddevMs: result.rtStddevMs,
          accuracy: result.accuracy,
          drifts: result.drifts,
          raw: result.answers,
        });
        router.replace({ pathname: '/(tabs)/games/result', params: { gameId: result.gameId, score: String(result.score) } });
      },
    });
    engineRef.current = engine;
    engine.start();
    return () => {
      engine.abort();
    };
  }, [gameDef, recordSession, router]);

  if (!gameDef) {
    return (
      <SafeAreaView style={styles.root}>
        <Text style={styles.errorText}>Game not found.</Text>
      </SafeAreaView>
    );
  }

  if (!trial) {
    return (
      <SafeAreaView style={[styles.root, styles.center]}>
        <ActivityIndicator color={colors.teal} />
      </SafeAreaView>
    );
  }

  const handleAnswer = (response: unknown) => {
    const engine = engineRef.current;
    if (!engine) return;
    const result = engine.answer(response);
    if (result.correct) {
      Haptics.selectionAsync();
    } else {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
    }
    setFeedback(result.correct ? 'correct' : 'incorrect');
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <View style={styles.header}>
        <Pressable onPress={() => { engineRef.current?.abort(); router.back(); }} hitSlop={10}>
          <Text style={styles.close}>✕</Text>
        </Pressable>
        <Text style={styles.title}>{gameDef.name.toUpperCase()}</Text>
        <View style={styles.scoreBox}>
          <Text style={styles.scoreNum}>{index + 1}</Text>
          <Text style={styles.scoreTotal}>/{gameDef.trials}</Text>
        </View>
      </View>

      <View style={styles.progress}>
        <View style={[styles.progressFill, { width: `${((index + 1) / gameDef.trials) * 100}%` }]} />
      </View>

      <View style={styles.content}>
        <TemplateRenderer trial={trial} onAnswer={handleAnswer} feedback={feedback} />
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerLabel}>{CONSTRUCT_SHORT[trial.template]}</Text>
        {trial.variant && <Text style={styles.variantLabel}>{trial.variant}</Text>}
      </View>
    </SafeAreaView>
  );
}

const CONSTRUCT_SHORT: Record<string, string> = {
  CHOICE: 'CHOICE',
  REACTION: 'REACTION',
  SEQUENCE: 'SEQUENCE',
  GRID: 'GRID',
  RECALL: 'RECALL',
  NUMBERLINE: 'NUMBERLINE',
  TYPE: 'TYPE',
  SORT: 'SORT',
};

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  center: { alignItems: 'center', justifyContent: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: layout.screenPadding, paddingVertical: spacing(3) },
  close: { color: colors.textMuted, fontSize: 22, padding: spacing(2) },
  title: { ...type.micro, color: colors.text },
  scoreBox: { flexDirection: 'row', alignItems: 'baseline' },
  scoreNum: { ...type.bodyStrong, color: colors.teal, fontFamily: 'monospace' },
  scoreTotal: { ...type.small, color: colors.textMuted, fontFamily: 'monospace' },
  progress: { height: 3, backgroundColor: colors.surfaceMuted },
  progressFill: { height: '100%', backgroundColor: colors.teal },
  content: { flex: 1, padding: layout.screenPadding },
  footer: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: layout.screenPadding, paddingVertical: spacing(3), borderTopWidth: 1, borderTopColor: colors.divider },
  footerLabel: { ...type.micro, color: colors.textDim },
  variantLabel: { ...type.micro, color: colors.teal },
  errorText: { color: colors.danger, textAlign: 'center', marginTop: spacing(10) },
});
