import { useState } from 'react';
import { Alert, KeyboardAvoidingView, Platform, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Link, useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import * as Haptics from 'expo-haptics';
import { useAuthStore } from '@/features/auth/store';
import { colors, layout, radii, spacing, type } from '@/theme';

export default function RegisterScreen() {
  const router = useRouter();
  const signUp = useAuthStore((s) => s.signUp);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [busy, setBusy] = useState(false);

  const onSubmit = async () => {
    if (!email || !password || !name) {
      Alert.alert('Missing fields', 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      Alert.alert('Weak password', 'Use at least 6 characters.');
      return;
    }
    setBusy(true);
    const { error } = await signUp(email.trim(), password, name.trim());
    setBusy(false);
    if (error) {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
      Alert.alert('Sign-up failed', error);
      return;
    }
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    router.replace('/(tabs)/today');
  };

  return (
    <SafeAreaView style={styles.root} edges={['top', 'bottom']}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <View style={styles.content}>
          <Text style={styles.brand}>UPMIND</Text>
          <Text style={styles.title}>Create your account.</Text>
          <Text style={styles.sub}>It takes 30 seconds. No credit card.</Text>

          <View style={styles.field}>
            <Text style={styles.label}>Display name</Text>
            <TextInput
              style={styles.input}
              value={name}
              onChangeText={setName}
              autoCapitalize="words"
              placeholder="Your name"
              placeholderTextColor={colors.textDim}
              testID="register.name"
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              textContentType="emailAddress"
              placeholder="you@domain.com"
              placeholderTextColor={colors.textDim}
              testID="register.email"
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>Password</Text>
            <TextInput
              style={styles.input}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
              textContentType="newPassword"
              placeholder="At least 6 characters"
              placeholderTextColor={colors.textDim}
              testID="register.password"
            />
          </View>

          <Pressable
            onPress={onSubmit}
            disabled={busy}
            style={({ pressed }) => [styles.cta, pressed && { opacity: 0.85 }]}
            testID="register.submit"
          >
            <Text style={styles.ctaText}>{busy ? 'Creating…' : 'Create account'}</Text>
          </Pressable>

          <Link href="/(auth)/login" style={styles.link}>
            Already have an account? Sign in →
          </Link>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  content: { flex: 1, paddingHorizontal: layout.screenPadding, paddingTop: spacing(10), justifyContent: 'center' },
  brand: { ...type.micro, color: colors.teal, marginBottom: spacing(2) },
  title: { ...type.display, color: colors.text, marginBottom: spacing(1) },
  sub: { ...type.body, color: colors.textMuted, marginBottom: spacing(8) },
  field: { marginBottom: spacing(4) },
  label: { ...type.small, color: colors.textMuted, marginBottom: spacing(1) },
  input: {
    backgroundColor: colors.surface,
    borderColor: colors.divider,
    borderWidth: 1,
    borderRadius: radii.md,
    paddingHorizontal: spacing(4),
    paddingVertical: spacing(3),
    color: colors.text,
    fontSize: 16,
  },
  cta: { backgroundColor: colors.teal, borderRadius: radii.md, paddingVertical: spacing(4), alignItems: 'center', marginTop: spacing(2) },
  ctaText: { color: colors.bg, fontSize: 16, fontWeight: '600' },
  link: { color: colors.tealSoft, textAlign: 'center', marginTop: spacing(4), fontSize: 14 },
});
