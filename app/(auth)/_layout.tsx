import { Stack } from 'expo-router';
import { useAuthStore } from '@/features/auth/store';
import { Redirect } from 'expo-router';

export default function AuthLayout() {
  const { session, hydrated } = useAuthStore();
  if (hydrated && session) return <Redirect href="/(tabs)/today" />;
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#0A0F1C' },
        animation: 'fade',
      }}
    />
  );
}
