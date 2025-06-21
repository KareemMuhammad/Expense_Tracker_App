import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker_app/presentation/blocs/add_expense/add_expense_bloc.dart';
import 'package:expense_tracker_app/presentation/blocs/expenses_list/expense_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker_app/data/models/expense.dart';

import 'expenses_mocks.dart';

void main() {
  late MockCurrencyRemoteDataSource mockCurrencyRemoteDataSource;
  late MockExpensesLocalDataSource mockExpensesLocalDataSource;
  late MockExpenseBloc mockExpenseBloc;
  late AddExpenseBloc addExpenseBloc;

  setUpAll(() {
    registerFallbackValue(
      Expense(
        id: 'fallback',
        category: 'fallback',
        amount: 0.0,
        currency: 'USD',
        amountInUSD: 0.0,
        date: DateTime.now(),
        receiptPath: null,
        categoryIcon: null,
      ),
    );
    registerFallbackValue(
      LoadExpenses(),
    );
    registerFallbackValue(
      ExpenseLoaded(
        expenses: const [],
        currentFilter: null,
        hasReachedMax: true,
      ),
    );
  });

  setUp(() {
    mockCurrencyRemoteDataSource = MockCurrencyRemoteDataSource();
    mockExpensesLocalDataSource = MockExpensesLocalDataSource();
    mockExpenseBloc = MockExpenseBloc();
    addExpenseBloc = AddExpenseBloc(
      currencyDataSource: mockCurrencyRemoteDataSource,
      expensesDataSource: mockExpensesLocalDataSource,
      expenseBloc: mockExpenseBloc, // Pass the mock ExpenseBloc
    );

    // Stub the default behavior of mockExpenseBloc.state if accessed in the bloc
    when(() => mockExpenseBloc.state).thenReturn(
      ExpenseLoaded(
        expenses: const [],
        currentFilter: null,
        hasReachedMax: true,
      ),
    );
    // Stub the default behavior of mockExpenseBloc.add to avoid unexpected errors
    when(() => mockExpenseBloc.add(any())).thenReturn(null);
  });

  tearDown(() {
    addExpenseBloc.close();
  });

  group('AddExpenseBloc', () {
    // --- Test cases for SubmitExpense (Validation & Currency Calculation) ---

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits [AddExpenseLoading, AddExpenseSuccess, AddExpenseFormState] and calls data sources on successful SubmitExpense',
      build: () {
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).thenAnswer((_) async => 90.0); // Converted USD amount
        when(
          () => mockExpensesLocalDataSource.addExpense(any()),
        ).thenAnswer((_) async => {});
        return addExpenseBloc;
      },
      act: (bloc) => bloc.add(
        SubmitExpense(
          category: 'Groceries',
          amount: 100.0,
          // Original amount
          currency: 'EUR',
          date: DateTime(2023, 1, 1),
          receiptPath: null,
          categoryIcon: 'shopping_cart',
        ),
      ),
      expect: () => [
        AddExpenseLoading(),
        isA<AddExpenseSuccess>(), // Initial success state
        isA<AddExpenseFormState>().having(
          (state) => state.successMessage,
          'successMessage',
          'Expense added successfully!',
        ), // Form state with success message
      ],
      verify: (_) {
        // Verify currency conversion
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(100.0, 'EUR', 'USD'),
        ).called(1);

        // Verify addExpense is called with the correct Expense object
        final capturedExpense =
            verify(
                  () => mockExpensesLocalDataSource.addExpense(captureAny()),
                ).captured.first
                as Expense;

        expect(capturedExpense.category, 'Groceries');
        expect(capturedExpense.amount, 100.0); // original amount
        expect(capturedExpense.currency, 'EUR');
        expect(capturedExpense.amountInUSD, 90.0); // converted amount
        expect(capturedExpense.date, DateTime(2023, 1, 1));
        // You can add more specific assertions for the captured Expense properties

        // Verify that LoadExpenses event is dispatched to the main ExpenseBloc
        verify(
          () => mockExpenseBloc.add(any(that: isA<LoadExpenses>())),
        ).called(1);
      },
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits [AddExpenseLoading, AddExpenseError] when currency conversion fails',
      build: () {
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).thenThrow(
          Exception('Currency conversion failed'),
        ); // Simulate failure
        return addExpenseBloc;
      },
      act: (bloc) => bloc.add(
        SubmitExpense(
          category: 'Groceries',
          amount: 100.0,
          currency: 'EUR',
          date: DateTime(2023, 1, 1),
        ),
      ),
      expect: () => [
        AddExpenseLoading(),
        isA<AddExpenseError>(),
        // Expect error state
        isA<AddExpenseFormState>().having(
          (state) => state.errorMessage,
          'errorMessage',
          contains('Currency conversion failed'),
        ),
        // Form state with error message
      ],
      verify: (_) {
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).called(1);
        verifyNever(
          () => mockExpensesLocalDataSource.addExpense(any()),
        ); // Should not attempt to save
        verifyNever(
          () => mockExpenseBloc.add(any()),
        ); // Should not dispatch LoadExpenses
      },
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits [AddExpenseLoading, AddExpenseError] when adding expense to local data source fails',
      build: () {
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).thenAnswer((_) async => 90.0);
        when(() => mockExpensesLocalDataSource.addExpense(any())).thenThrow(
          Exception('Failed to save expense locally'),
        ); // Simulate failure
        return addExpenseBloc;
      },
      act: (bloc) => bloc.add(
        SubmitExpense(
          category: 'Groceries',
          amount: 100.0,
          currency: 'EUR',
          date: DateTime(2023, 1, 1),
        ),
      ),
      expect: () => [
        AddExpenseLoading(),
        isA<AddExpenseError>(),
        isA<AddExpenseFormState>().having(
          (state) => state.errorMessage,
          'errorMessage',
          contains('Failed to save expense locally'),
        ),
      ],
      verify: (_) {
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).called(1);
        verify(
          () => mockExpensesLocalDataSource.addExpense(any()),
        ).called(1); // Should attempt to save
        verifyNever(
          () => mockExpenseBloc.add(any()),
        ); // Should not dispatch LoadExpenses
      },
    );

    // --- Test cases for other events updating form state ---

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits AddExpenseFormState with updated category when ChangeCategory is added',
      build: () => addExpenseBloc,
      act: (bloc) => bloc.add(const ChangeCategory('Entertainment')),
      expect: () => [
        isA<AddExpenseFormState>().having(
          (state) => state.selectedCategory,
          'selectedCategory',
          'Entertainment',
        ),
      ],
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits AddExpenseFormState with updated currency when ChangeCurrency is added',
      build: () => addExpenseBloc,
      act: (bloc) => bloc.add(const ChangeCurrency('GBP')),
      expect: () => [
        isA<AddExpenseFormState>().having(
          (state) => state.selectedCurrency,
          'selectedCurrency',
          'GBP',
        ),
      ],
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits AddExpenseFormState with updated date when SelectDateEvent is added',
      build: () => addExpenseBloc,
      act: (bloc) => bloc.add(SelectDateEvent(DateTime(2024, 5, 15))),
      expect: () => [
        isA<AddExpenseFormState>().having(
          (state) => state.selectedDate,
          'selectedDate',
          DateTime(2024, 5, 15),
        ),
      ],
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'emits AddExpenseFormState with updated receipt path when AttachReceiptEvent is added',
      build: () => addExpenseBloc,
      act: (bloc) => bloc.add(const AttachReceiptEvent('/path/to/receipt.jpg')),
      expect: () => [
        isA<AddExpenseFormState>().having(
          (state) => state.selectedReceiptPath,
          'selectedReceiptPath',
          '/path/to/receipt.jpg',
        ),
      ],
    );

    // --- Test cases for pickMedia() method (calls events internally) ---

    blocTest<AddExpenseBloc, AddExpenseState>(
      'dispatches AttachReceiptEvent with path on successful pickMedia',
      build: () {
        // Here, we simulate the internal behavior of pickMedia by calling the event directly.
        // If pickMedia internally uses ImagePicker, you'd mock ImagePicker and its methods.
        return addExpenseBloc;
      },
      act: (bloc) async {
        // Simulate a successful pickMedia operation which then dispatches the event
        bloc.add(const AttachReceiptEvent('mock_image_path.jpg'));
      },
      expect: () => [
        isA<AddExpenseFormState>().having(
          (state) => state.selectedReceiptPath,
          'selectedReceiptPath',
          'mock_image_path.jpg',
        ),
      ],
    );

    blocTest<AddExpenseBloc, AddExpenseState>(
      'dispatches AddExpenseError on pickMedia failure',
      build: () {
        // Simulate a pickMedia failure which then dispatches the error event
        return addExpenseBloc;
      },
      act: (bloc) async {
        bloc.add(
          const AddExpenseErrorEvent('Error picking image: Test Exception'),
        );
      },
      expect: () => [
        isA<AddExpenseError>().having(
          (error) => error.message,
          'message',
          contains('Error picking image: Test Exception'),
        ),
      ],
    );
  });
}
