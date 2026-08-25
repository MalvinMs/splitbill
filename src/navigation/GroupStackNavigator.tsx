import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { GroupStackParamList } from './types';
import { GroupsScreen } from '../screens/GroupsScreen';
import { CreateGroupScreen } from '../screens/CreateGroupScreen';
import { JoinGroupScreen } from '../screens/JoinGroupScreen';
import { GroupDetailScreen } from '../screens/GroupDetailScreen';
import { EditGroupScreen } from '../screens/EditGroupScreen';
import { MembersScreen } from '../screens/MembersScreen';
import { ExpenseFormScreen } from '../screens/ExpenseFormScreen';
import { ExpenseDetailScreen } from '../screens/ExpenseDetailScreen';
import { useAppTheme } from '../ui/theme';

const Stack = createNativeStackNavigator<GroupStackParamList>();

export function GroupStackNavigator() {
  const theme = useAppTheme();
  return <Stack.Navigator screenOptions={{ headerShown: false, contentStyle: { backgroundColor: theme.colors.canvas } }}><Stack.Screen name="GroupList" component={GroupsScreen} /><Stack.Screen name="CreateGroup" component={CreateGroupScreen} /><Stack.Screen name="JoinGroup" component={JoinGroupScreen} /><Stack.Screen name="GroupDetail" component={GroupDetailScreen} /><Stack.Screen name="EditGroup" component={EditGroupScreen} /><Stack.Screen name="Members" component={MembersScreen} /><Stack.Screen name="AddExpense" component={ExpenseFormScreen} /><Stack.Screen name="EditExpense" component={ExpenseFormScreen} /><Stack.Screen name="ExpenseDetail" component={ExpenseDetailScreen} /></Stack.Navigator>;
}
