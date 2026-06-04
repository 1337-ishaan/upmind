import { Stack, useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { supabase } from '@/lib/supabase';
import { useAuthStore } from '@/features/auth/store';
import { CONSTRUCT_LABELS, CONSTRUCT_ORDER } from '@/features/games/catalog';
import { colors, layout, radii, spacing, type } from '@/theme';

type LbRow = { id: string; display_name: string | null; elo: number };

export default function LeaderboardScreen() {
  const router = useRouter();
  const { user } = useAuthStore();
  const [domain, setDomain] = useState<string>('attention');
  const [rows, setRows] = useState<LbRow[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let cancelled = false;
    async function load() {
      setLoading(true);
      const { data } = await supabase
        .from('leaderboard')
        .select('id, display_name, elo')
        .eq('domain', domain)
        .order('elo', { ascending: false })
        .limit(25);
      if (!cancelled) {
        setRows((data ?? []) as LbRow[]);
        setLoading(false);
      }
    }
    load();
    return () => { cancelled = true; };
  }, [domain]);

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <Stack.Screen options={{ headerShown: false }} />
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={10}><Text style={styles.close}>‹ Back</Text></Pressable>
        <Text style={styles.title}>Leaderboard</Text>
        <View style={{ width: 60 }} />
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.tabs}>
        {CONSTRUCT_ORDER.map((c) => (
          <Pressable
            key={c}
            onPress={() => setDomain(c)}
            style={({ pressed }) => [styles.chip, domain === c && styles.chipActive, pressed && { opacity: 0.7 }]}
          >
            <Text style={[styles.chipText, domain === c && styles.chipTextActive]}>{CONSTRUCT_LABELS[c]}</Text>
          </Pressable>
        ))}
      </ScrollView>

      <ScrollView contentContainerStyle={styles.list}>
        {loading ? (
          <ActivityIndicator color={colors.teal} style={{ marginTop: spacing(10) }} />
        ) : rows.length === 0 ? (
          <Text style={styles.empty}>No data yet for {CONSTRUCT_LABELS[domain as keyof typeof CONSTRUCT_LABELS] ?? domain}.</Text>
        ) : (
          rows.map((r, i) => {
            const isMe = r.id === user?.id;
            const medal = i < 3 ? ['🥇', '🥈', '🥉'][i] : '';
            return (
              <View key={r.id} style={[styles.row, isMe && styles.rowMe]}>
                <Text style={styles.rank}>{medal || `#${i + 1}`}</Text>
                <Text style={[styles.name, isMe && { color: colors.teal, fontWeight: '700' }]}>
                  {r.display_name || 'Anonymous'}
                </Text>
                <Text style={styles.elo}>{r.elo}</Text>
              </View>
            );
          })
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: layout.screenPadding, paddingVertical: spacing(3) },
  close: { color: colors.teal, fontSize: 14 },
  title: { ...type.h2, color: colors.text },
  tabs: { paddingHorizontal: layout.screenPadding, paddingVertical: spacing(3), gap: spacing(2) },
  chip: { paddingHorizontal: spacing(3), paddingVertical: spacing(2), borderRadius: radii.pill, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.divider, marginRight: spacing(2) },
  chipActive: { backgroundColor: colors.teal, borderColor: colors.teal },
  chipText: { ...type.small, color: colors.textMuted },
  chipTextActive: { color: colors.bg, fontWeight: '600' },
  list: { padding: layout.screenPadding, paddingBottom: spacing(20) },
  row: { flexDirection: 'row', alignItems: 'center', paddingVertical: spacing(3), borderBottomWidth: 1, borderBottomColor: colors.divider },
  rowMe: { backgroundColor: 'rgba(20,184,166,0.06)' },
  rank: { width: 40, fontSize: 16, color: colors.textMuted, fontFamily: 'monospace' },
  name: { ...type.body, color: colors.text, flex: 1 },
  elo: { ...type.bodyStrong, color: colors.text, fontFamily: 'monospace' },
  empty: { ...type.body, color: colors.textDim, textAlign: 'center', marginTop: spacing(10) },
});
