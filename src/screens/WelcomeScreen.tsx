import { useEffect } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withSequence,
  withTiming,
} from 'react-native-reanimated';
import { router } from 'expo-router';
import { Aurora } from '@/components/Aurora';
import { Button } from '@/components/Button';
import { Screen } from '@/components/Screen';
import { colors, motion, spacing, type } from '@/theme';
import { useOnboarding } from '@/state';

export default function WelcomeScreen() {
  const setStep = useOnboarding((s) => s.setStep);

  const logo = useSharedValue(0);
  const headline = useSharedValue(0);
  const sub = useSharedValue(0);
  const cta = useSharedValue(0);
  const legal = useSharedValue(0);

  useEffect(() => {
    logo.value = withTiming(1, { duration: motion.slow, easing: Easing.bezier(...motion.ease) });
    headline.value = withDelay(120, withTiming(1, { duration: motion.slow }));
    sub.value = withDelay(220, withTiming(1, { duration: motion.slow }));
    cta.value = withDelay(420, withTiming(1, { duration: motion.slow }));
    legal.value = withDelay(560, withTiming(1, { duration: motion.slow }));
  }, []);

  const logoStyle = useAnimatedStyle(() => ({
    opacity: logo.value,
    transform: [{ scale: 0.92 + logo.value * 0.08 }, { translateY: (1 - logo.value) * 8 }],
  }));
  const headlineStyle = useAnimatedStyle(() => ({
    opacity: headline.value,
    transform: [{ translateY: (1 - headline.value) * 14 }],
  }));
  const subStyle = useAnimatedStyle(() => ({
    opacity: sub.value,
    transform: [{ translateY: (1 - sub.value) * 10 }],
  }));
  const ctaStyle = useAnimatedStyle(() => ({
    opacity: cta.value,
    transform: [{ translateY: (1 - cta.value) * 16 }],
  }));
  const legalStyle = useAnimatedStyle(() => ({ opacity: legal.value }));

  return (
    <Screen>
      <Aurora />
      <View style={styles.headerArea}>
        <Animated.View style={[styles.logoMark, logoStyle]}>
          <View style={styles.logoInner} />
        </Animated.View>
        <Animated.Text style={[styles.eyebrow, headlineStyle]}>UPMIND</Animated.Text>
      </View>

      <View style={styles.middle}>
        <Animated.Text style={[styles.headline, headlineStyle]}>
          Congratulations.{'\n'}You've taken the first step{'\n'}
          <Text style={styles.headlineAccent}>toward a sharper mind.</Text>
        </Animated.Text>

        <Animated.Text style={[styles.sub, subStyle]}>
          A 10-minute daily practice that rewires how you focus, remember, and decide — built
          for high-performing professionals.
        </Animated.Text>
      </View>

      <View style={styles.footer}>
        <Animated.View style={ctaStyle}>
          <Button
            testID="welcome.continue"
            label="Begin"
            onPress={() => {
              setStep(1);
              router.push('/onboarding/value');
            }}
          />
        </Animated.View>
        <Animated.Text style={[styles.legal, legalStyle]}>
          Already have an account?{' '}
          <Text
            onPress={() => router.push('/auth/sign-in')}
            style={styles.legalLink}
            accessibilityRole="link"
          >
            Sign in
          </Text>
        </Animated.Text>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  headerArea: { marginTop: spacing(6), alignItems: 'center' },
  logoMark: {
    width: 72,
    height: 72,
    borderRadius: 22,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing(4),
  },
  logoInner: {
    width: 28,
    height: 28,
    borderRadius: 8,
    backgroundColor: colors.teal,
    shadowColor: colors.teal,
    shadowOpacity: 0.6,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 0 },
  },
  eyebrow: {
    ...type.micro,
    color: colors.teal,
    letterSpacing: 3,
  },
  middle: { flex: 1, justifyContent: 'center' },
  headline: {
    ...type.display,
    color: colors.text,
  },
  headlineAccent: { color: colors.tealSoft },
  sub: {
    ...type.body,
    color: colors.textMuted,
    marginTop: spacing(4),
  },
  footer: { paddingBottom: spacing(2), gap: spacing(3) },
  legal: { ...type.small, color: colors.textDim, textAlign: 'center' },
  legalLink: { color: colors.teal, fontWeight: '600' },
});
