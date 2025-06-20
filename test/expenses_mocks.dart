import 'package:expense_tracker_app/data/data_source/currency_remote_data_source.dart';
import 'package:expense_tracker_app/data/data_source/expenses_local_data_source.dart';
import 'package:expense_tracker_app/data/models/expense.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRemoteDataSource extends Mock
    implements CurrencyRemoteDataSource {}

class MockExpensesLocalDataSource extends Mock
    implements ExpensesLocalDataSource {}

final tExpense1 = Expense(
  id: '1',
  category: 'Groceries',
  amount: 50.0,
  currency: 'USD',
  amountInUSD: 50.0,
  date: DateTime(2023, 1, 1),
  receiptPath: null,
  categoryIcon: null,
);
final tExpense2 = Expense(
  id: '2',
  category: 'Transport',
  amount: 25.0,
  currency: 'EUR',
  amountInUSD: 27.5,
  // Assuming 1 EUR = 1.1 USD
  date: DateTime(2023, 1, 2),
  receiptPath: null,
  categoryIcon: null,
);
final tExpense3 = Expense(
  id: '3',
  category: 'Shopping',
  amount: 100.0,
  currency: 'GBP',
  amountInUSD: 130.0,
  // Assuming 1 GBP = 1.3 USD
  date: DateTime(2023, 1, 3),
  receiptPath: null,
  categoryIcon: null,
);
