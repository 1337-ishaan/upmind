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
import { colors, motion, radii, spacing, type } from '@/theme';

type Slide = {
  key: string;
  eyebrow: string;
  title: string;
  body: string;
  visual: 'focus' | 'memory' | 'tribe';
  proof?: string;
};

const SLIDES: Slide[] = [
  {
    key: 'focus',
    eyebrow: 'CLARITY',
    title: 'Cut through noise. Decide faster.',
    body: '8-minute sessions that train the part of your brain responsible for attention and impulse control. No fluff.',
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
  },
];

export default function ValueSlides() {
  const [index, setIndex] = useState(0);
  const scrollX = useSharedValue(0);
  const { width } = Dimensions.get('window');
  const listRef = useRef<FlatList<Slide>>(null);

  const onMomentumScrollEnd = (e: NativeSyntheticEvent<NativeScrollEvent>) => {
    const x = e.nativeEvent.contentOffset.x;
    scrollX.value = x;
    setIndex(Math.round(x / width));
  };

  const next = () => {
    if (index < SLIDES.length - 1) {
      listRef.current?.scrollToIndex({ index: index + 1, animated: true });
    } else {
      router.push('/(auth)/register');
    }
  };

  return (
    <Screen>
      <Aurora />
      <View style={styles.header}>
        <Text style={styles.eyebrow}>WHY UPMIND</Text>
        <ProgressDots total={SLIDES.length} active={index} style={styles.dots} />
      </View>
      <FlatList
        ref={listRef}
        data={SLIDES}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={onMomentumScrollEnd}
        onScroll={(e) => (scrollX.value = e.nativeEvent.contentOffset.x)}
        scrollEventThrottle={16}
        keyExtractor={(s) => s.key}
        renderItem={({ item, index: i }) => (
          <View style={{ width, padding: 24, justifyContent: 'center' }}>
            <SlideView slide={item} index={i} scrollX={scrollX} />
          </View>
        )}
      />
      <View style={styles.footer}>
        <Button
          testID="value.continue"
          label={index === SLIDES.length - 1 ? 'Get started' : 'Continue'}
          onPress={next}
        />
        <Text onPress={() => router.push('/(auth)/login')} style={styles.legalLink}>
          Already have an account? Sign in
        </Text>
      </View>
    </Screen>
  );
}

function SlideView({ slide, index, scrollX }: { slide: Slide; index: number; scrollX: Animated.SharedValue<number> }) {
  const aStyle = useAnimatedStyle(() => {
    const { width } = Dimensions.get('window');
    const input = scrollX.value / width - index;
    return {
      opacity: 1 - Math.abs(input) * 0.6,
      transform: [{ translateY: Math.abs(input) * 30 }],
    };
  });
  return (
    <Animated.View style={[{ flex: 1, justifyContent: 'center' }, aStyle]}>
      <View style={styles.visualBox}>
        <Text style={styles.visualText}>{visualLabel(slide.visual)}</Text>
      </View>
      <Text style={styles.slideEyebrow}>{slide.eyebrow}</Text>
      <Text style={styles.slideTitle}>{slide.title}</Text>
      <Text style={styles.slideBody}>{slide.body}</Text>
    </Animated.View>
  );
}

function visualLabel(v: 'focus' | 'memory' | 'tribe') {
  if (v === 'focus') return '◆';
  if (v === 'memory') return '◇';
  return '★';
}

const styles = StyleSheet.create({
  header: { paddingTop: spacing(2) },
  eyebrow: { ...type.micro, color: colors.teal, marginBottom: spacing(3) },
  dots: { marginTop: spacing(1) },
  visualBox: {
    width: 120, height: 120, borderRadius: 24, backgroundColor: colors.surface,
    borderWidth: 1, borderColor: colors.glassBorder, alignItems: 'center', justifyContent: 'center',
    marginBottom: spacing(6), alignSelf: 'center',
  },
  visualText: { fontSize: 48, color: colors.teal },
  slideEyebrow: { ...type.micro, color: colors.teal, marginBottom: spacing(2) },
  slideTitle: { ...type.h1, color: colors.text, marginBottom: spacing(3) },
  slideBody: { ...type.body, color: colors.textMuted },
  footer: { paddingBottom: spacing(2), gap: spacing(3) },
  legalLink: { ...type.small, color: colors.textDim, textAlign: 'center' },
});
