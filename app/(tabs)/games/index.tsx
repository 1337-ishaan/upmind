import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuthStore } from '@/features/auth/store';
import { GAMES, CONSTRUCT_LABELS, CONSTRUCT_ORDER } from '@/features/games/catalog';
import { colors, layout, radii, spacing, type } from '@/theme';

export default function GamesLibrary() {
  const router = useRouter();
  const { premium } = useAuthStore();
  const [filter, setFilter] = useState<string>('all');

  const visible = filter === 'all' ? CONSTRUCT_ORDER : [filter as typeof CONSTRUCT_ORDER[number]];
  const games = GAMES.filter((g) => visible.includes(g.construct) && (!g.premium || premium));

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.title}>Games</Text>
        <Text style={styles.subtitle}>{games.length} available</Text>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.tabs}>
        <FilterChip label="All" active={filter === 'all'} onPress={() => setFilter('all')} />
        {CONSTRUCT_ORDER.map((c) => (
          <FilterChip
            key={c}
            label={CONSTRUCT_LABELS[c]}
            active={filter === c}
            onPress={() => setFilter(c)}
            premium={c === 'executive' && !premium}
          />
        ))}
      </ScrollView>

      <ScrollView contentContainerStyle={styles.list}>
        {games.map((g) => (
          <Pressable
            key={g.id}
            onPress={() => {
              if (g.premium && !premium) {
                router.push('/paywall');
              } else {
                router.push({ pathname: '/(tabs)/games/play', params: { id: g.id } });
              }
            }}
            style={({ pressed }) => [styles.card, pressed && { opacity: 0.7 }]}
            testID={`game.${g.id}`}
          >
            <View style={styles.cardMain}>
              <View style={styles.cardHeader}>
                <Text style={styles.cardName}>{g.name}</Text>
                {g.premium && <View style={styles.premiumBadge}><Text style={styles.premiumBadgeText}>PRO</Text></View>}
              </View>
              <Text style={styles.cardDesc}>{g.description}</Text>
              <View style={styles.cardMeta}>
                <Text style={styles.constructChip}>{CONSTRUCT_LABELS[g.construct]}</Text>
                <Text style={styles.trialChip}>{g.trials} trials</Text>
                <Text style={styles.templateChip}>{g.template}</Text>
              </View>
            </View>
          </Pressable>
        ))}
        {games.length === 0 && (
          <Text style={styles.empty}>No games in this category yet.</Text>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function FilterChip({ label, active, onPress, premium }: { label: string; active: boolean; onPress: () => void; premium?: boolean }) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.chip,
        active && styles.chipActive,
        premium && styles.chipPremium,
        pressed && { opacity: 0.7 },
      ]}
    >
      <Text style={[styles.chipText, active && styles.chipTextActive]}>{label}{premium ? ' 🔒' : ''}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  header: { paddingHorizontal: layout.screenPadding, paddingTop: spacing(4) },
  title: { ...type.display, color: colors.text },
  subtitle: { ...type.small, color: colors.textMuted, marginTop: spacing(1) },
  tabs: { paddingHorizontal: layout.screenPadding, paddingVertical: spacing(4), gap: spacing(2) },
  chip: { paddingHorizontal: spacing(3), paddingVertical: spacing(2), borderRadius: radii.pill, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, marginRight: spacing(2) },
  chipActive: { backgroundColor: colors.teal, borderColor: colors.teal },
  chipPremium: { borderColor: colors.gold, borderStyle: 'dashed' },
  chipText: { ...type.small, color: colors.textMuted },
  chipTextActive: { color: colors.bg, fontWeight: '600' },
  list: { padding: layout.screenPadding, paddingTop: 0, paddingBottom: spacing(20) },
  card: { backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(4), marginBottom: spacing(3), borderWidth: 1, borderColor: colors.divider },
  cardMain: { flex: 1 },
  cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: spacing(1) },
  cardName: { ...type.bodyStrong, color: colors.text, flex: 1 },
  cardDesc: { ...type.small, color: colors.textMuted, marginBottom: spacing(3) },
  cardMeta: { flexDirection: 'row', gap: spacing(2) },
  constructChip: { ...type.micro, color: colors.teal, backgroundColor: 'rgba(20,184,166,0.1)', paddingHorizontal: spacing(2), paddingVertical: 2, borderRadius: radii.xs },
  trialChip: { ...type.micro, color: colors.textMuted, backgroundColor: colors.surfaceMuted, paddingHorizontal: spacing(2), paddingVertical: 2, borderRadius: radii.xs },
  templateChip: { ...type.micro, color: colors.textMuted, backgroundColor: colors.surfaceMuted, paddingHorizontal: spacing(2), paddingVertical: 2, borderRadius: radii.xs },
  premiumBadge: { backgroundColor: colors.gold, paddingHorizontal: spacing(2), paddingVertical: 2, borderRadius: radii.xs },
  premiumBadgeText: { fontSize: 9, fontWeight: '700', color: colors.bg },
  empty: { ...type.body, color: colors.textDim, textAlign: 'center', paddingVertical: spacing(10) },
});
