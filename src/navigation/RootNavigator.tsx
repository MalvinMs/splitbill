import { ActivityIndicator, StyleSheet, View } from 'react-native';
import Ionicons from '@expo/vector-icons/Ionicons';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import type { MainTabParamList, RootStackParamList } from './types';
import { useAuth } from '../auth/AuthProvider';
import { AuthScreen } from '../screens/AuthScreen';
import { PasswordRecoveryScreen } from '../screens/PasswordRecoveryScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { GroupsScreen } from '../screens/GroupsScreen';
import { ActivityScreen } from '../screens/ActivityScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { GroupStackNavigator } from './GroupStackNavigator';
import { useAppTheme } from '../ui/theme';

const Root = createNativeStackNavigator<RootStackParamList>();
const Tabs = createBottomTabNavigator<MainTabParamList>();

function MainTabs() {
  const theme = useAppTheme();
  return <Tabs.Navigator screenOptions={{ headerShown: false, tabBarActiveTintColor: theme.colors.primary, tabBarInactiveTintColor: theme.colors.navMuted, tabBarLabelStyle: { fontSize: 10, fontWeight: '800', letterSpacing: 0.5, marginTop: 1, paddingBottom: 2 }, tabBarStyle: { backgroundColor: theme.colors.nav, borderTopWidth: 0, height: 76, paddingTop: 5 }, tabBarItemStyle: { minHeight: 60 }, tabBarIconStyle: { marginTop: 1 } }}>
    <Tabs.Screen name="Home" component={HomeScreen} options={{ tabBarLabel: 'HOME', tabBarIcon: ({ color, size, focused }) => <Ionicons name={focused ? 'home' : 'home-outline'} color={color} size={size ?? 23} /> }} />
    <Tabs.Screen name="Groups" component={GroupStackNavigator} options={{ headerShown: false, tabBarLabel: 'GROUPS', tabBarIcon: ({ color, size, focused }) => <Ionicons name={focused ? 'people' : 'people-outline'} color={color} size={size ?? 23} /> }} />
    <Tabs.Screen name="Activity" component={ActivityScreen} options={{ tabBarLabel: 'ACTIVITY', tabBarIcon: ({ color, size, focused }) => <Ionicons name={focused ? 'time' : 'time-outline'} color={color} size={size ?? 23} /> }} />
    <Tabs.Screen name="Profile" component={ProfileScreen} options={{ tabBarLabel: 'PROFILE', tabBarIcon: ({ color, size, focused }) => <Ionicons name={focused ? 'person' : 'person-outline'} color={color} size={size ?? 23} /> }} />
  </Tabs.Navigator>;
}

export function RootNavigator() {
  const theme = useAppTheme();
  const { session, isLoading, isPasswordRecovery } = useAuth();
  if (isLoading) return <View style={[styles.loading, { backgroundColor: theme.colors.canvas }]}><ActivityIndicator size="large" color={theme.colors.primary} /></View>;
  return <Root.Navigator screenOptions={{ headerShown: false }}>{session ? (isPasswordRecovery ? <Root.Screen name="PasswordRecovery" component={PasswordRecoveryScreen} /> : <Root.Screen name="Main" component={MainTabs} />) : <Root.Screen name="Auth" component={AuthScreen} />}</Root.Navigator>;
}

const styles = StyleSheet.create({ loading: { alignItems: 'center', backgroundColor: '#f8fafc', flex: 1, justifyContent: 'center' } });
