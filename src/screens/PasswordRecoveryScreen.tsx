import { useState } from 'react';
import { ActivityIndicator, KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { useAuth } from '../auth/AuthProvider';
import { useAppTheme, typography } from '../ui/theme';
import { Rule, SectionLabel } from '../ui/Primitives';

export function PasswordRecoveryScreen() {
  const theme = useAppTheme();
  const { updatePassword } = useAuth();
  const [password, setPassword] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [errorMessage, setErrorMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function submit() {
    setErrorMessage('');
    if (password.length < 6) return setErrorMessage('Password must be at least 6 characters.');
    if (password !== confirmation) return setErrorMessage('Passwords do not match.');
    setIsSubmitting(true);
    const result = await updatePassword(password);
    setIsSubmitting(false);
    if (result.error) setErrorMessage(result.error.message);
  }

  return <KeyboardAvoidingView style={[styles.flex, { backgroundColor: theme.colors.canvas }]} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
    <ScrollView contentContainerStyle={styles.container} keyboardShouldPersistTaps="handled">
      <View style={styles.masthead}>
        <View style={[styles.mark, { backgroundColor: theme.colors.primary }]}><Text style={[styles.markText, { color: theme.colors.onPrimary }]}>SB</Text></View>
        <View><Text style={[styles.wordmark, { color: theme.colors.ink }]}>SPLITBILL</Text><Text style={[typography.label, { color: theme.colors.inkMuted, fontSize: 10 }]}>THE SHARED LEDGER</Text></View>
      </View>
      <View style={[styles.heroRule, { backgroundColor: theme.colors.primary }]} />
      <Text style={[typography.display, { color: theme.colors.ink }]}>Choose a new password.</Text>
      <Text style={[typography.body, { color: theme.colors.inkMuted, marginTop: 9 }]}>Your recovery link is valid. Set a new password to reopen your ledger.</Text>
      <View style={[styles.sheet, { backgroundColor: theme.colors.paper, borderColor: theme.colors.line }]}>
        <SectionLabel>ACCOUNT RECOVERY</SectionLabel>
        <Text style={[typography.headline, { color: theme.colors.ink, marginBottom: 18 }]}>New credentials.</Text>
        <Field label="New password" value={password} onChangeText={setPassword} placeholder="At least 6 characters" theme={theme} />
        <Field label="Confirm password" value={confirmation} onChangeText={setConfirmation} placeholder="Repeat your password" theme={theme} />
        <Rule />
        {!!errorMessage && <Text style={[typography.body, { color: theme.colors.error, marginTop: 14 }]}>{errorMessage}</Text>}
        <Pressable disabled={isSubmitting} onPress={submit} style={({ pressed }) => [styles.submit, { backgroundColor: theme.colors.primary }, (pressed || isSubmitting) && { opacity: 0.68 }]}>
          {isSubmitting ? <ActivityIndicator color={theme.colors.onPrimary} /> : <Text style={[styles.submitText, { color: theme.colors.onPrimary }]}>Save new password</Text>}
        </Pressable>
      </View>
    </ScrollView>
  </KeyboardAvoidingView>;
}

function Field({ label, theme, ...props }: { label: string; theme: ReturnType<typeof useAppTheme> } & React.ComponentProps<typeof TextInput>) {
  return <View style={styles.field}><Text style={[typography.label, { color: theme.colors.inkMuted, marginBottom: 7 }]}>{label}</Text><TextInput {...props} secureTextEntry placeholderTextColor={theme.colors.inkMuted} style={[styles.input, { backgroundColor: theme.colors.paperMuted, borderColor: theme.colors.line, color: theme.colors.ink }]} /></View>;
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  container: { flexGrow: 1, justifyContent: 'center', padding: 22 },
  masthead: { alignItems: 'center', flexDirection: 'row', gap: 12, marginBottom: 28 },
  mark: { alignItems: 'center', borderRadius: 12, height: 48, justifyContent: 'center', width: 48 },
  markText: { fontSize: 18, fontWeight: '900', letterSpacing: -1 },
  wordmark: { fontSize: 17, fontWeight: '900', letterSpacing: 2 },
  heroRule: { height: 4, marginBottom: 18, width: 48 },
  sheet: { borderRadius: 18, borderWidth: 1, marginTop: 28, padding: 20 },
  field: { marginBottom: 15 },
  input: { borderRadius: 10, borderWidth: 1, fontSize: 16, minHeight: 50, paddingHorizontal: 14, paddingVertical: 12 },
  submit: { alignItems: 'center', borderRadius: 11, justifyContent: 'center', marginTop: 18, minHeight: 52, padding: 14 },
  submitText: { fontSize: 15, fontWeight: '800' },
});
