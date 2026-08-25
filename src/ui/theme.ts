import { useColorScheme } from 'react-native';

export const lightTheme = {
  mode: 'light' as const,
  colors: {
    canvas: '#F3F0E8', paper: '#FFFDF7', paperMuted: '#E8E8DE', ink: '#1C2821', inkMuted: '#667168', line: '#D3D5C9', primary: '#246B58', primaryDark: '#174C3E', onPrimary: '#FFFDF7', accent: '#D9664B', accentSoft: '#F5D9D1', gold: '#D5A940', goldSoft: '#F5EBCB', success: '#2F7D57', error: '#B8483A', nav: '#1C2821', navMuted: '#A9B9AE', white: '#FFFFFF', black: '#000000',
  },
  radii: { small: 10, medium: 16, large: 24, pill: 99 },
};

export const darkTheme = {
  mode: 'dark' as const,
  colors: {
    canvas: '#111914', paper: '#1A241E', paperMuted: '#253229', ink: '#F1F4EC', inkMuted: '#A9B7AD', line: '#3B4A40', primary: '#80CDB3', primaryDark: '#9ADFC6', onPrimary: '#10231C', accent: '#F08E72', accentSoft: '#4A2D28', gold: '#E8C875', goldSoft: '#443B24', success: '#8CCFA5', error: '#FF9D8C', nav: '#0C120F', navMuted: '#8B9A90', white: '#FFFFFF', black: '#000000',
  },
  radii: { small: 10, medium: 16, large: 24, pill: 99 },
};

export type AppTheme = typeof lightTheme | typeof darkTheme;
export function useAppTheme(): AppTheme { return useColorScheme() === 'dark' ? darkTheme : lightTheme; }

export const typography = {
  display: { fontSize: 32, fontWeight: '800' as const, letterSpacing: -0.8 },
  headline: { fontSize: 24, fontWeight: '800' as const, letterSpacing: -0.4 },
  title: { fontSize: 18, fontWeight: '800' as const },
  body: { fontSize: 15, lineHeight: 22 },
  label: { fontSize: 11, fontWeight: '800' as const, letterSpacing: 1.2, textTransform: 'uppercase' as const },
  amount: { fontSize: 26, fontWeight: '800' as const, letterSpacing: -0.5 },
};
