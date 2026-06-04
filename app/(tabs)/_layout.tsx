import { Tabs } from 'expo-router';
import { StyleSheet, Text, View } from 'react-native';
import { colors } from '@/theme';

type IconProps = { color: string; size: number };

const TodayIcon = ({ color, size }: IconProps) => (
  <View style={[styles.icon, { borderColor: color }]}>
    <Text style={[styles.iconDot, { color, fontSize: size * 0.7 }]}>●</Text>
  </View>
);
const GamesIcon = ({ color, size }: IconProps) => (
  <View style={[styles.icon, { borderColor: color, width: size, height: size, borderRadius: 4 }]}>
    <Text style={{ color, fontSize: size * 0.4, fontWeight: '600' }}>42</Text>
  </View>
);
const ProfileIcon = ({ color, size }: IconProps) => (
  <View style={[styles.icon, { borderColor: color, borderRadius: size / 2 }]}>
    <Text style={{ color, fontSize: size * 0.5, fontWeight: '600' }}>U</Text>
  </View>
);

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: colors.bgElevated,
          borderTopColor: colors.divider,
        },
        tabBarActiveTintColor: colors.teal,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
      }}
    >
      <Tabs.Screen
        name="today"
        options={{
          title: 'Today',
          tabBarIcon: (p) => <TodayIcon {...p} size={22} />,
        }}
      />
      <Tabs.Screen
        name="games"
        options={{
          title: 'Games',
          tabBarIcon: (p) => <GamesIcon {...p} size={22} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: (p) => <ProfileIcon {...p} size={22} />,
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  icon: {
    width: 22,
    height: 22,
    borderWidth: 1.5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconDot: { fontWeight: '700' },
});
