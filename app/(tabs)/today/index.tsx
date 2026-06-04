import { useRouter } from 'expo-router';
import { useMemo } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuthStore } from '@/features/auth/store';
import { useGameStore } from '@/features/games/store';
import { GAMES, CONSTRUCT_LABELS, CONSTRUCT_ORDER } from '@/features/games/catalog';
import { colors, layout, radii, spacing, type } from '@/theme';

export default function TodayScreen() {
  const router = useRouter();
  const { user, premium } = useAuthStore();
  const { sessions, skillScores, streakDays, hydrate } = useGameStore();

  useMemo(() => {
    hydrate();
  }, [hydrate]);

  const todays = sessions.filter((s) => new Date(s.startedAt).toDateString() === new Date().toDateString());
  const avg = todays.length ? Math.round(todays.reduce((a, s) => a + s.score, 0) / todays.length) : 0;

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.greet}>Good {greeting()}.</Text>
        <Text style={styles.name}>{user?.user_metadata?.display_name ?? 'Trainer'}.</Text>

        <View style={styles.kpiRow}>
          <View style={styles.kpi}>
            <Text style={styles.kpiNum}>{streakDays}</Text>
            <Text style={styles.kpiLabel}>day streak</Text>
          </View>
          <View style={styles.kpi}>
            <Text style={styles.kpiNum}>{todays.length}</Text>
            <Text style={styles.kpiLabel}>sessions today</Text>
          </View>
          <View style={styles.kpi}>
            <Text style={styles.kpiNum}>{avg}</Text>
            <Text style={styles.kpiLabel}>avg score</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Your 6-skill profile</Text>
          {CONSTRUCT_ORDER.filter((c) => c !== 'executive' || premium).map((c) => (
            <View key={c} style={styles.skillRow}>
              <Text style={styles.skillLabel}>{CONSTRUCT_LABELS[c]}</Text>
              <View style={styles.barTrack}>
                <View style={[styles.barFill, { width: `${skillScores[c]}%` }]} />
              </View>
              <Text style={styles.skillNum}>{skillScores[c]}</Text>
            </View>
          ))}
        </View>

        <Pressable
          onPress={() => router.push('/(tabs)/games')}
          style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85 }]}
          testID="today.start"
        >
          <Text style={styles.ctaText}>Start a drill →</Text>
        </Pressable>

        {!premium && (
          <Pressable
            onPress={() => router.push('/paywall')}
            style={({ pressed }) => [styles.premiumCta, pressed && { opacity: 0.85 }]}
          >
            <Text style={styles.premiumText}>Unlock Executive Function tests →</Text>
          </Pressable>
        )}

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent</Text>
          {sessions.slice(0, 5).map((s) => {
            const game = GAMES.find((g) => g.id === s.gameId);
            return (
              <View key={`${s.gameId}-${s.startedAt}`} style={styles.recentRow}>
                <Text style={styles.recentName}>{game?.name ?? s.gameId}</Text>
                <Text style={styles.recentScore}>{s.score}</Text>
              </View>
            );
          })}
          {sessions.length === 0 && (
            <Text style={styles.empty}>No sessions yet. Tap "Start a drill" above.</Text>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function greeting() {
  const h = new Date().getHours();
  if (h < 5) return 'evening';
  if (h < 12) return 'morning';
  if (h < 18) return 'afternoon';
  return 'evening';
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { padding: layout.screenPadding, paddingBottom: spacing(20) },
  greet: { ...type.micro, color: colors.teal, marginTop: spacing(2) },
  name: { ...type.display, color: colors.text, marginBottom: spacing(6) },
  kpiRow: { flexDirection: 'row', gap: spacing(3), marginBottom: spacing(6) },
  kpi: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radii.md,
    padding: spacing(4),
    borderWidth: 1,
    borderColor: colors.divider,
  },
  kpiNum: { fontSize: 24, fontWeight: '700', color: colors.text },
  kpiLabel: { ...type.small, color: colors.textMuted, marginTop: 2 },
  section: { marginBottom: spacing(6) },
  sectionTitle: { ...type.h2, color: colors.text, marginBottom: spacing(3) },
  skillRow: { flexDirection: 'row', alignItems: 'center', marginBottom: spacing(2) },
  skillLabel: { ...type.small, color: colors.textMuted, width: 110 },
  barTrack: { flex: 1, height: 6, backgroundColor: colors.surfaceMuted, borderRadius: 3, overflow: 'hidden' },
  barFill: { height: '100%', backgroundColor: colors.teal, borderRadius: 3 },
  skillNum: { ...type.small, color: colors.text, fontFamily: 'monospace', width: 32, textAlign: 'right' },
  cta: { backgroundColor: colors.teal, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center', marginBottom: spacing(3) },
  ctaText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
  premiumCta: { backgroundColor: colors.surface, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center', borderWidth: 1, borderColor: colors.teal, marginBottom: spacing(6) },
  premiumText: { color: colors.tealSoft, fontSize: 15, fontWeight: '600' },
  recentRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: spacing(2) },
  recentName: { ...type.body, color: colors.text },
  recentScore: { ...type.body, color: colors.teal, fontFamily: 'monospace' },
  empty: { ...type.body, color: colors.textDim, paddingVertical: spacing(2) },
});
