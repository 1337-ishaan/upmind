import { StyleSheet, View, ViewStyle } from 'react-native';
import { colors, motion, radii } from '@/theme';
import Animated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

type Props = {
  total: number;
  active: number; // 0-indexed
  style?: ViewStyle;
};

export function ProgressDots({ total, active, style }: Props) {
  return (
    <View style={[styles.row, style]}>
      {Array.from({ length: total }).map((_, i) => (
        <Dot key={i} active={i === active} past={i < active} />
      ))}
    </View>
  );
}

function Dot({ active, past }: { active: boolean; past: boolean }) {
  const aStyle = useAnimatedStyle(() => ({
    width: withTiming(active ? 24 : 8, { duration: motion.base }),
    backgroundColor: withTiming(active || past ? colors.teal : colors.glassBorder, {
      duration: motion.base,
    }),
  }));
  return <Animated.View style={[styles.dot, aStyle]} />;
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  dot: { height: 8, borderRadius: radii.pill },
});
