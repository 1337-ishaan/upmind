import * as Sentry from 'sentry-expo';
import { useEffect } from 'react';
import { useAuthStore } from '@/features/auth/store';

const SENTRY_DSN = process.env.EXPO_PUBLIC_SENTRY_DSN;

export function initSentry() {
  if (!SENTRY_DSN) {
    if (__DEV__) console.warn('Sentry DSN not set — crash reporting disabled');
    return;
  }
  Sentry.init({
    dsn: SENTRY_DSN,
    enableInExpoDevelopment: true,
    debug: __DEV__,
    tracesSampleRate: 0.2,
  });
}

export function captureError(error: Error, context?: Record<string, unknown>) {
  if (!SENTRY_DSN) return;
  Sentry.Native.captureException(error, { extra: context });
}

export function setUserContext(userId: string | null) {
  if (!SENTRY_DSN) return;
  if (userId) Sentry.Native.setUser({ id: userId });
  else Sentry.Native.setUser(null);
}

/** Hook — wires auth state into Sentry context. */
export function useSentryUser() {
  const user = useAuthStore((s) => s.user);
  useEffect(() => {
    setUserContext(user?.id ?? null);
  }, [user?.id]);
}
