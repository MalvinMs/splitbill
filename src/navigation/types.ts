export type RootStackParamList = { Auth: undefined; Main: undefined; PasswordRecovery: undefined };
export type MainTabParamList = { Home: undefined; Groups: undefined; Activity: undefined; Profile: undefined };
export type GroupStackParamList = {
  GroupList: undefined;
  CreateGroup: undefined;
  JoinGroup: undefined;
  GroupDetail: { groupId: string };
  EditGroup: { groupId: string };
  Members: { groupId: string };
  AddExpense: { groupId: string };
  EditExpense: { groupId: string; expenseId: string };
  ExpenseDetail: { groupId: string; expenseId: string };
};
