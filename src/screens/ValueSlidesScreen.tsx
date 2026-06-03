import { useRef, useState } from 'react';
import {
  Dimensions,
  FlatList,
  ListRenderItemInfo,
  NativeScrollEvent,
  NativeSyntheticEvent,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import Animated, {
  Extrapolation,
  interpolate,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';
import { router } from 'expo-router';
import { Aurora } from '@/components/Aurora';
import { Button } from '@/components/Button';
import { ProgressDots } from '@/components/ProgressDots';
import { Screen } from '@/components/Screen';
import { colors, layout, motion, radii, spacing, type } from '@/theme';
import { useOnboarding } from '@/state';

type Slide = {
  key: string;
  eyebrow: string;
  title: string;
  body: string;
  visual: 'focus' | 'memory' | 'tribe';
  proof?: { quote: string; who: string };
};

const SLIDES: Slide[] = [
  {
    key: 'focus',
    eyebrow: 'CLARITY',
    title: 'Cut through noise. Decide faster.',
    body: '10-minute sessions that train the part of your brain responsible for attention and impulse control. No fluff.',
    visual: 'focus',
  },
  {
    key: 'memory',
    eyebrow: 'MEMORY',
    title: 'Remember what actually matters.',
    body: 'Adaptive exercises built on the same science used by elite operators. We start easy, then we push.',
    visual: 'memory',
  },
  {
    key: 'tribe',
    eyebrow: 'JOIN 18,400+',
    title: 'Used by founders, surgeons, and pilots.',
    body: '“I’m sharper before standup than I used to be after coffee. It’s the first app I open.” — Rohan M., Founder, Bangalore',
    visual: 'tribe',
    proof: { quote: '', who: '' },
  },
];

const { width } = Dimensions.get('window');
const PAGE_W = width;

export default function ValueSlidesScreen() {
  const setStep = useOnboarding((s) => s.setStep);
  const [index, setIndex] = useState(0);
  const scrollX = useSharedValue(0);
  const listRef = useRef<FlatList<Slide>>(null);

  const onMomentumEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const i = Math.round(e.nativeEvent.contentOffset.x / PAGE_W);
    if (i !== index) setIndex(i);
  };

  const goNext = () => {
    if (index < SLIDES.length - 1) {
      listRef.current?.scrollToIndex({ index: index + 1, animated: true });
    } else {
      setStep(2);
      router.push('/onboarding/survey');
    }
  };

  const renderItem = ({ item }: ListRenderItemInfo<Slide>) => (
    <View style={styles.page}>
      <Visual kind={item.visual} />
      <Text style={styles.eyebrow}>{item.eyebrow}</Text>
      <Text style={styles.title}>{item.title}</Text>
      <Text style={styles.body}>{item.body}</Text>
      {item.key === 'tribe' && <ProofRow />}
    </View>
  );

  return (
    <Screen>
      <Aurora />
      <View style={styles.topRow}>
        <Text style={styles.brand}>Upmind</Text>
        <ProgressDots total={3} active={index} />
      </View>

      <Animated.FlatList
        ref={listRef as unknown as React.RefObject<FlatList<Slide>>}
        data={SLIDES}
        keyExtractor={(s) => s.key}
        renderItem={renderItem}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onScroll={(e) => {
          scrollX.value = e.nativeEvent.contentOffset.x;
        }}
        onMomentumScrollEnd={onMomentumEnd}
        scrollEventThrottle={16}
        style={styles.list}
      />

      <View style={styles.footer}>
        <Button
          testID="value.continue"
          label={index === SLIDES.length - 1 ? 'Take the survey' : 'Continue'}
          onPress={goNext}
        />
        <Text style={styles.legal}>
          Step {index + 1} of {SLIDES.length}
        </Text>
      </View>
    </Screen>
  );
}

function Visual({ kind }: { kind: Slide['visual'] }) {
  const style = useAnimatedStyle(() => ({ opacity: withTiming(1, { duration: motion.base }) }));
  return (
    <Animated.View style={[styles.visual, kindStyle(kind), style]}>
      {kind === 'focus' && <FocusGlyph />}
      {kind === 'memory' && <MemoryGlyph />}
      {kind === 'tribe' && <TribeGlyph />}
    </Animated.View>
  );
}

function FocusGlyph() {
  return (
    <View style={glyphStyles.wrap}>
      <View style={[glyphStyles.ring, { width: 180, height: 180, borderColor: colors.teal }]} />
      <View style={[glyphStyles.ring, { width: 120, height: 120, borderColor: colors.tealSoft, opacity: 0.7 }]} />
      <View style={[glyphStyles.dot, { backgroundColor: colors.teal, shadowColor: colors.teal }]} />
    </View>
  );
}
function MemoryGlyph() {
  return (
    <View style={glyphStyles.wrap}>
      {[0, 1, 2, 3, 4].map((i) => (
        <View
          key={i}
          style={[
            glyphStyles.node,
            { left: 30 + (i % 3) * 50, top: 30 + Math.floor(i / 3) * 80, backgroundColor: i % 2 ? colors.tealSoft : colors.teal },
          ]}
        />
      ))}
      <View style={[glyphStyles.line, { width: 60, top: 60, left: 60, transform: [{ rotate: '30deg' }] }]} />
      <View style={[glyphStyles.line, { width: 60, top: 100, left: 90, transform: [{ rotate: '-25deg' }] }]} />
    </View>
  );
}
function TribeGlyph() {
  return (
    <View style={glyphStyles.wrap}>
      {[-1, 0, 1].map((dx) => (
        <View
          key={dx}
          style={[
            glyphStyles.avatar,
            { left: 60 + dx * 36, backgroundColor: dx === 0 ? colors.teal : colors.surfaceMuted },
          ]}
        />
      ))}
    </View>
  );
}

function ProofRow() {
  return (
    <View style={styles.proofRow}>
      <Text style={styles.proofStar}>★★★★★</Text>
      <Text style={styles.proofCount}>4.9 · 18,400+ members</Text>
    </View>
  );
}

const kindStyle = (k: Slide['visual']) => {
  switch (k) {
    case 'focus':
      return { backgroundColor: 'rgba(20,184,166,0.08)' };
    case 'memory':
      return { backgroundColor: 'rgba(94,234,212,0.06)' };
    case 'tribe':
      return { backgroundColor: 'rgba(245,199,106,0.06)' };
  }
};

const styles = StyleSheet.create({
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: spacing(2),
  },
  brand: { ...type.bodyStrong, color: colors.text, letterSpacing: 0.3 },
  list: { flex: 1, marginTop: spacing(4) },
  page: {
    width: PAGE_W - layout.screenPadding * 2,
    marginRight: layout.screenPadding * 2,
    paddingTop: spacing(2),
  },
  visual: {
    height: 220,
    borderRadius: radii.xl,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing(6),
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  eyebrow: { ...type.micro, color: colors.teal, marginBottom: spacing(2) },
  title: { ...type.h1, color: colors.text, marginBottom: spacing(3) },
  body: { ...type.body, color: colors.textMuted },
  proofRow: {
    marginTop: spacing(5),
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing(2),
  },
  proofStar: { color: colors.gold, fontSize: 16, letterSpacing: 2 },
  proofCount: { ...type.small, color: colors.textMuted },
  footer: { paddingBottom: spacing(2), gap: spacing(2), alignItems: 'center' },
  legal: { ...type.small, color: colors.textDim },
});

const glyphStyles = StyleSheet.create({
  wrap: { width: 220, height: 200, alignItems: 'center', justifyContent: 'center' },
  ring: { position: 'absolute', borderRadius: 999, borderWidth: 1.5 },
  dot: {
    width: 18,
    height: 18,
    borderRadius: 9,
    shadowOpacity: 0.9,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 0 },
  },
  node: { position: 'absolute', width: 14, height: 14, borderRadius: 7 },
  line: { position: 'absolute', height: 1.5, backgroundColor: colors.glassBorder },
  avatar: {
    position: 'absolute',
    width: 56,
    height: 56,
    borderRadius: 28,
    borderWidth: 2,
    borderColor: colors.bg,
  },
});
