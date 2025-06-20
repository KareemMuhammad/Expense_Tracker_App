import 'package:expense_tracker_app/data/data_source/currency_remote_data_source.dart';
import 'package:expense_tracker_app/data/data_source/expenses_local_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRemoteDataSource extends Mock
    implements CurrencyRemoteDataSource {}

class MockExpensesLocalDataSource extends Mock
    implements ExpensesLocalDataSource {}
