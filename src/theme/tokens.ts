/**
 * Upmind design tokens.
 * Single source of truth for color, type, spacing, motion.
 * PRD §Design: Deep navy background (#0A0F1C), teal accents (#14B8A6), calm animations.
 */
export const colors = {
  // Surfaces
  bg: '#0A0F1C',
  bgElevated: '#0F172A',
  surface: '#111827',
  surfaceMuted: '#1E293B',
  divider: 'rgba(255,255,255,0.06)',

  // Brand
  teal: '#14B8A6',
  tealSoft: '#5EEAD4',
  tealDeep: '#0F766E',

  // Text
  text: '#F8FAFC',
  textMuted: '#94A3B8',
  textDim: '#64748B',

  // Semantic
  success: '#22C55E',
  warn: '#F59E0B',
  danger: '#EF4444',
  gold: '#F5C76A',

  // Overlays
  glass: 'rgba(255,255,255,0.04)',
  glassBorder: 'rgba(255,255,255,0.08)',
  scrim: 'rgba(0,0,0,0.55)',
} as const;

export const radii = {
  xs: 8,
  sm: 12,
  md: 18,
  lg: 24,
  xl: 32,
  pill: 999,
} as const;

export const spacing = (n: number) => n * 4;

export const type = {
  display: { fontSize: 36, lineHeight: 42, fontWeight: '700' as const, letterSpacing: -0.6 },
  h1: { fontSize: 28, lineHeight: 34, fontWeight: '700' as const, letterSpacing: -0.4 },
  h2: { fontSize: 22, lineHeight: 28, fontWeight: '600' as const, letterSpacing: -0.2 },
  body: { fontSize: 16, lineHeight: 24, fontWeight: '400' as const },
  bodyStrong: { fontSize: 16, lineHeight: 24, fontWeight: '600' as const },
  small: { fontSize: 13, lineHeight: 18, fontWeight: '500' as const },
  micro: { fontSize: 11, lineHeight: 14, fontWeight: '600' as const, letterSpacing: 0.4 },
} as const;

export const motion = {
  // Calm, Headspace-style easing
  ease: [0.22, 1, 0.36, 1] as const,
  fast: 180,
  base: 280,
  slow: 520,
} as const;

export const layout = {
  screenPadding: 24,
  maxContent: 480,
} as const;
