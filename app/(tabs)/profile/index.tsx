import { useRouter } from 'expo-router';
import { Alert, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuthStore } from '@/features/auth/store';
import { useGameStore } from '@/features/games/store';
import { colors, layout, radii, spacing, type } from '@/theme';

export default function ProfileScreen() {
  const router = useRouter();
  const { user, premium, signOut } = useAuthStore();
  const { sessions, streakDays } = useGameStore();

  const total = sessions.length;
  const avg = total ? Math.round(sessions.reduce((a, s) => a + s.score, 0) / total) : 0;

  return (
    <SafeAreaView style={styles.root} edges={['top']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Profile</Text>

        <View style={styles.card}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{(user?.email?.[0] ?? 'U').toUpperCase()}</Text>
          </View>
          <Text style={styles.email}>{user?.email ?? 'guest@upmind.app'}</Text>
          {premium && <View style={styles.proBadge}><Text style={styles.proText}>PRO</Text></View>}
        </View>

        <View style={styles.kpiGrid}>
          <View style={styles.kpiBox}><Text style={styles.kpiNum}>{total}</Text><Text style={styles.kpiLabel}>sessions</Text></View>
          <View style={styles.kpiBox}><Text style={styles.kpiNum}>{avg}</Text><Text style={styles.kpiLabel}>avg score</Text></View>
          <View style={styles.kpiBox}><Text style={styles.kpiNum}>{streakDays}</Text><Text style={styles.kpiLabel}>day streak</Text></View>
        </View>

        <View style={styles.section}>
          <Pressable onPress={() => router.push('/(tabs)/leaderboard')} style={({ pressed }) => [styles.row, pressed && { opacity: 0.7 }]}>
            <Text style={styles.rowText}>Leaderboard</Text>
            <Text style={styles.rowChevron}>›</Text>
          </Pressable>
          {!premium && (
            <Pressable onPress={() => router.push('/paywall')} style={({ pressed }) => [styles.row, pressed && { opacity: 0.7 }]}>
              <Text style={styles.rowText}>Upgrade to Premium</Text>
              <Text style={styles.rowChevron}>›</Text>
            </Pressable>
          )}
          <Pressable
            onPress={() => {
              Alert.alert('Sign out', 'Are you sure?', [
                { text: 'Cancel', style: 'cancel' },
                { text: 'Sign out', style: 'destructive', onPress: () => signOut().then(() => router.replace('/(auth)/login')) },
              ]);
            }}
            style={({ pressed }) => [styles.row, pressed && { opacity: 0.7 }]}
          >
            <Text style={[styles.rowText, { color: colors.danger }]}>Sign out</Text>
            <Text style={styles.rowChevron}>›</Text>
          </Pressable>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { padding: layout.screenPadding, paddingBottom: spacing(20) },
  title: { ...type.display, color: colors.text, marginBottom: spacing(6) },
  card: { backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(4), alignItems: 'center', marginBottom: spacing(4), borderWidth: 1, borderColor: colors.divider },
  avatar: { width: 64, height: 64, borderRadius: 32, backgroundColor: colors.teal, alignItems: 'center', justifyContent: 'center', marginBottom: spacing(3) },
  avatarText: { fontSize: 28, fontWeight: '700', color: colors.bg },
  email: { ...type.body, color: colors.text, marginBottom: spacing(2) },
  proBadge: { backgroundColor: colors.gold, paddingHorizontal: spacing(2), paddingVertical: 2, borderRadius: radii.xs },
  proText: { fontSize: 9, fontWeight: '700', color: colors.bg },
  kpiGrid: { flexDirection: 'row', gap: spacing(2), marginBottom: spacing(6) },
  kpiBox: { flex: 1, backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(3), alignItems: 'center', borderWidth: 1, borderColor: colors.divider },
  kpiNum: { fontSize: 22, fontWeight: '700', color: colors.text },
  kpiLabel: { ...type.micro, color: colors.textMuted, marginTop: 2 },
  section: { backgroundColor: colors.surface, borderRadius: radii.md, borderWidth: 1, borderColor: colors.divider, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: spacing(4), borderBottomWidth: 1, borderBottomColor: colors.divider },
  rowText: { ...type.bodyStrong, color: colors.text },
  rowChevron: { color: colors.textMuted, fontSize: 22 },
});
