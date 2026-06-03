import { View, Text, StyleSheet } from 'react-native';
import { Button } from '@/components/Button';
import { Screen } from '@/components/Screen';
import { colors, spacing, type } from '@/theme';

/**
 * Stub used for the rest of the onboarding + auth routes so the app
 * is navigable end-to-end. Each gets replaced by a real screen in
 * subsequent iterations.
 */
export default function PlaceholderScreen({ title, next }: { title: string; next: string }) {
  return (
    <Screen>
      <View style={styles.center}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.sub}>{next}</Text>
        <Text style={styles.note}>(real screen coming next iteration)</Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: spacing(2) },
  title: { ...type.h1, color: colors.text, textAlign: 'center' },
  sub: { ...type.body, color: colors.textMuted, textAlign: 'center' },
  note: { ...type.small, color: colors.textDim, marginTop: spacing(4) },
});
