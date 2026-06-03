import { StyleSheet, View } from 'react-native';
import { colors } from '@/theme';

/**
 * Decorative ambient gradient blobs behind screens.
 * Pure View + opacity to avoid pulling in a gradient lib at this layer.
 */
export function Aurora() {
  return (
    <View pointerEvents="none" style={StyleSheet.absoluteFill}>
      <View style={[styles.blob, { backgroundColor: colors.tealDeep, top: -80, left: -60, opacity: 0.35 }]} />
      <View style={[styles.blob, { backgroundColor: colors.teal, top: 120, right: -80, opacity: 0.18 }]} />
      <View style={[styles.blob, { backgroundColor: '#1E3A8A', bottom: -120, left: 40, opacity: 0.22 }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  blob: {
    position: 'absolute',
    width: 320,
    height: 320,
    borderRadius: 200,
    transform: [{ scale: 1.2 }],
  },
});
