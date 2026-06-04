import { Stack, useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { useAuthStore } from '@/features/auth/store';
import { colors, layout, radii, spacing, type } from '@/theme';

export default function PaywallScreen() {
  const router = useRouter();
  const { setPremium } = useAuthStore();
  const [plan, setPlan] = useState<'monthly' | 'annual'>('annual');
  const [purchased, setPurchased] = useState(false);
  const [busy, setBusy] = useState(false);

  const onBuy = async () => {
    setBusy(true);
    await new Promise((r) => setTimeout(r, 600));
    setPremium(true);
    setPurchased(true);
    setBusy(false);
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  };

  if (purchased) {
    return (
      <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
        <Stack.Screen options={{ headerShown: false }} />
        <View style={styles.content}>
          <Text style={styles.checkmark}>✓</Text>
          <Text style={styles.title}>You're Premium</Text>
          <Text style={styles.subtitle}>Executive Function tests and advanced features unlocked.</Text>
          <Pressable onPress={() => router.back()} style={({ pressed }) => [styles.cta, pressed && { opacity: 0.7 }]}>
            <Text style={styles.ctaText}>Back</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <Stack.Screen options={{ headerShown: false }} />
      <View style={styles.content}>
        <Pressable onPress={() => router.back()} hitSlop={10} style={{ alignSelf: 'flex-start' }}>
          <Text style={styles.close}>‹ Close</Text>
        </Pressable>
        <View style={{ flex: 1, justifyContent: 'center' }}>
          <Text style={styles.eyebrow}>UPMIND PREMIUM</Text>
          <Text style={styles.title}>Unlock the full brain.</Text>
          <Text style={styles.subtitle}>Executive Function tests, advanced analytics, and priority support.</Text>

          <View style={styles.plans}>
            <Pressable
              onPress={() => setPlan('monthly')}
              style={[styles.plan, plan === 'monthly' && styles.planActive]}
            >
              <Text style={styles.planLabel}>Monthly</Text>
              <Text style={styles.planPrice}>$9</Text>
              <Text style={styles.planSub}>/month</Text>
            </Pressable>
            <Pressable
              onPress={() => setPlan('annual')}
              style={[styles.plan, plan === 'annual' && styles.planActive]}
            >
              <Text style={styles.planLabel}>Annual</Text>
              <Text style={styles.planPrice}>$69</Text>
              <Text style={styles.planSub}>/year · save 36%</Text>
            </Pressable>
          </View>

          <View style={styles.demoNote}>
            <Text style={styles.demoText}>Demo mode — no real charge.</Text>
          </View>
        </View>

        <Pressable onPress={onBuy} disabled={busy} style={({ pressed }) => [styles.cta, (pressed || busy) && { opacity: 0.7 }]}>
          <Text style={styles.ctaText}>{busy ? 'Processing…' : `Subscribe to ${plan === 'monthly' ? 'Monthly' : 'Annual'}`}</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { flex: 1, padding: layout.screenPadding },
  close: { color: colors.teal, fontSize: 14, marginBottom: spacing(2) },
  eyebrow: { ...type.micro, color: colors.teal, marginBottom: spacing(2) },
  title: { ...type.display, color: colors.text, marginBottom: spacing(2) },
  subtitle: { ...type.body, color: colors.textMuted, marginBottom: spacing(6) },
  plans: { flexDirection: 'row', gap: spacing(3), marginBottom: spacing(4) },
  plan: { flex: 1, backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(4), borderWidth: 2, borderColor: colors.divider, alignItems: 'center' },
  planActive: { borderColor: colors.teal, backgroundColor: 'rgba(20,184,166,0.06)' },
  planLabel: { ...type.small, color: colors.textMuted, marginBottom: spacing(1) },
  planPrice: { fontSize: 28, fontWeight: '700', color: colors.text },
  planSub: { ...type.micro, color: colors.textMuted, marginTop: 2 },
  demoNote: { backgroundColor: colors.surface, borderRadius: radii.md, padding: spacing(3), borderWidth: 1, borderColor: colors.divider },
  demoText: { ...type.small, color: colors.textMuted, textAlign: 'center' },
  cta: { backgroundColor: colors.teal, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center', marginTop: spacing(4) },
  ctaText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
  checkmark: { fontSize: 64, color: colors.teal, textAlign: 'center', marginBottom: spacing(4) },
});
