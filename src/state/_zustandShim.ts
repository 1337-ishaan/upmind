/**
 * Tiny store helper to avoid adding zustand as a dep just for onboarding state.
 * Subscribe/unsubscribe pattern, ~40 LOC.
 */
type Listener<T> = (state: T) => void;
type SetState<T> = (partial: Partial<T> | ((s: T) => Partial<T>)) => void;
type GetState<T> = () => T;
type StoreCreator<T> = (set: SetState<T>, get: GetState<T>) => T;

export function create<T>(creator: StoreCreator<T>) {
  let state: T;
  const listeners = new Set<Listener<T>>();

  const setState: SetState<T> = (partial) => {
    const next =
      typeof partial === 'function' ? (partial as (s: T) => Partial<T>)(state) : partial;
    state = { ...state, ...next };
    listeners.forEach((l) => l(state));
  };

  const getState: GetState<T> = () => state;
  state = creator(setState, getState);

  function useStore(): T;
  function useStore<U>(selector: (s: T) => U): U;
  function useStore<U>(selector?: (s: T) => U) {
    // We rely on React 18 useSyncExternalStore via a per-call subscription.
    // Re-importing from 'react' here to avoid React at the top of the file.
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { useSyncExternalStore, useDebugValue } = require('react') as typeof import('react');
    const subscribe = (cb: () => void) => {
      const wrapped: Listener<T> = () => cb();
      listeners.add(wrapped);
      return () => listeners.delete(wrapped);
    };
    const snap = () => (selector ? selector(state) : (state as unknown as U));
    const val = useSyncExternalStore(subscribe, snap, snap);
    useDebugValue(val);
    return val;
  }

  (useStore as unknown as { getState: GetState<T> }).getState = getState;
  return useStore as typeof useStore & { getState: GetState<T> };
}
