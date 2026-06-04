import { useLocalSearchParams, useRouter } from 'expo-router';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { useEffect } from 'react';
import { colors, layout, radii, spacing, type } from '@/theme';
import { getGame } from '@/features/games/catalog';

export default function ResultScreen() {
  const router = useRouter();
  const { gameId, score } = useLocalSearchParams<{ gameId: string; score: string }>();
  const game = gameId ? getGame(gameId) : undefined;
  const s = Number(score ?? 0);

  useEffect(() => {
    Haptics.notificationAsync(s >= 70 ? Haptics.NotificationFeedbackType.Success : Haptics.NotificationFeedbackType.Warning);
  }, [s]);

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <View style={styles.content}>
        <Text style={styles.eyebrow}>SESSION COMPLETE</Text>
        <Text style={styles.gameName}>{game?.name ?? gameId}</Text>
        <View style={styles.scoreRing}>
          <Text style={styles.scoreNum}>{s}</Text>
          <Text style={styles.scoreOut}>/100</Text>
        </View>
        <Text style={styles.feedback}>
          {s >= 90 ? 'Excellent.' : s >= 70 ? 'Solid.' : s >= 50 ? 'Keep going.' : 'Tough one. Try again.'}
        </Text>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>What you trained</Text>
          <Text style={styles.cardText}>{game?.description}</Text>
          <Text style={styles.cardText}>This score updates your {game?.construct ?? 'construct'} skill rating in the Today tab.</Text>
        </View>

        <Pressable
          onPress={() => router.replace('/(tabs)/today')}
          style={({ pressed }) => [styles.cta, pressed && { opacity: 0.7 }]}
        >
          <Text style={styles.ctaText}>Back to Today</Text>
        </Pressable>
        <Pressable
          onPress={() => router.replace('/(tabs)/games')}
          style={({ pressed }) => [styles.linkBtn, pressed && { opacity: 0.7 }]}
        >
          <Text style={styles.linkText}>Pick another game</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { flex: 1, padding: layout.screenPadding, alignItems: 'center', justifyContent: 'center' },
  eyebrow: { ...type.micro, color: colors.teal, marginBottom: spacing(2) },
  gameName: { ...type.h1, color: colors.text, marginBottom: spacing(6) },
  scoreRing: { width: 160, height: 160, borderRadius: 80, backgroundColor: colors.surface, borderWidth: 4, borderColor: colors.teal, alignItems: 'center', justifyContent: 'center', marginBottom: spacing(4) },
  scoreNum: { fontSize: 56, fontWeight: '700', color: colors.text, fontFamily: 'monospace' },
  scoreOut: { ...type.micro, color: colors.textMuted, marginTop: -4 },
  feedback: { ...type.h2, color: colors.tealSoft, marginBottom: spacing(8) },
  card: { backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(4), borderWidth: 1, borderColor: colors.divider, width: '100%', marginBottom: spacing(6) },
  cardTitle: { ...type.small, color: colors.textMuted, marginBottom: spacing(2) },
  cardText: { ...type.body, color: colors.text, marginBottom: spacing(2) },
  cta: { backgroundColor: colors.teal, borderRadius: radii.md, paddingVertical: spacing(4), paddingHorizontal: spacing(8), alignItems: 'center', width: '100%', marginBottom: spacing(2) },
  ctaText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
  linkBtn: { paddingVertical: spacing(3), alignItems: 'center', width: '100%' },
  linkText: { color: colors.tealSoft, fontSize: 15 },
});
