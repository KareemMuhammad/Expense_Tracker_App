import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker_app/data/models/expense.dart';
import 'package:expense_tracker_app/data/models/filter_type_enum.dart';
import 'package:expense_tracker_app/presentation/blocs/expense_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'expenses_mocks.dart';

void main() {
  late MockCurrencyRemoteDataSource mockCurrencyRemoteDataSource;
  late MockExpensesLocalDataSource mockExpensesLocalDataSource;
  late ExpenseBloc expenseBloc;

  setUpAll(() {
    registerFallbackValue(
      Expense(
        id: 'fallback_id',
        category: 'Fallback',
        amount: 0.0,
        currency: 'USD',
        amountInUSD: 0.0,
        date: DateTime.now(),
      ),
    );
    registerFallbackValue(FilterTypeEnum.all);
  });

  setUp(() {
    mockCurrencyRemoteDataSource = MockCurrencyRemoteDataSource();
    mockExpensesLocalDataSource = MockExpensesLocalDataSource();
    expenseBloc = ExpenseBloc(
      currencyDataSource: mockCurrencyRemoteDataSource,
      expensesDataSource: mockExpensesLocalDataSource,
    );
  });

  tearDown(() {
    expenseBloc.close();
  });

  group('ExpenseBloc', () {
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

    // --- Initial State and Loading ---
    test('initial state is ExpenseInitial', () {
      expect(expenseBloc.state, equals(ExpenseInitial()));
    });

    // --- Expense Loading (Pagination) ---
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] when LoadExpenses is added and succeeds',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'), // mocktail syntax for named arguments
          ),
        ).thenAnswer((_) async => [tExpense1, tExpense2]);
        return expenseBloc;
      },
      act: (bloc) => bloc.add(LoadExpenses()),
      expect: () => [
        ExpenseLoading(),
        ExpenseLoaded(
          expenses: [tExpense1, tExpense2],
          hasReachedMax: false,
          currentFilter: null,
        ),
      ],
      verify: (_) {
        verify(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: null,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] with hasReachedMax true if fewer than pageSize expenses are returned',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer(
          (_) async => [tExpense1],
        ); // Only one expense, less than 10
        return expenseBloc;
      },
      act: (bloc) => bloc.add(LoadExpenses()),
      expect: () => [
        ExpenseLoading(),
        ExpenseLoaded(
          expenses: [tExpense1],
          hasReachedMax: true,
          currentFilter: null,
        ),
      ],
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseError] when LoadExpenses fails',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow('Error loading expenses');
        return expenseBloc;
      },
      act: (bloc) => bloc.add(LoadExpenses()),
      expect: () => [ExpenseLoading(), ExpenseError('Error loading expenses')],
    );

    // --- Add Expense (Validation & Currency Calculation) ---
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoaded] with new expense after AddExpense succeeds and reloads',
      build: () {
        // Mock initial load state
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => []); // Initial empty state

        // Mock currency conversion
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(50.0, 'EUR', 'USD'),
        ).thenAnswer((_) async => 55.0); // Converted amount

        // Mock adding expense
        when(
          () =>
              mockExpensesLocalDataSource.addExpense(any(that: isA<Expense>())),
        ).thenAnswer((_) async => Future.value());

        // Mock reload after adding, including the new expense
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((invocation) async {
          // This ensures that when getExpenses is called after addExpense,
          // it returns the 'newly' added expense, simulating reload.
          // Note: Mocktail's `any(named:)` doesn't directly expose the named arg value like mockito.
          // For simplicity in this test, we'll assume a null filter for the reload.
          if (invocation.namedArguments[#filter] == null) {
            // Access named arguments via Symbol
            return [
              Expense(
                id: 'some_id',
                // Mocked ID as dynamic ID is hard to match here
                category: 'Groceries',
                amount: 50.0,
                currency: 'EUR',
                amountInUSD: 55.0,
                date: DateTime(2024, 6, 20),
                receiptPath: null,
                categoryIcon: null,
              ),
            ];
          }
          return [];
        });

        return expenseBloc;
      },
      act: (bloc) => bloc.add(
        AddExpense(
          category: 'Groceries',
          amount: 50.0,
          currency: 'EUR',
          date: DateTime(2024, 6, 20),
        ),
      ),
      expect: () => [
        // The bloc first loads (empty), then when AddExpense finishes, it triggers LoadExpenses again.
        // We'll test the resulting state after the AddExpense and subsequent LoadExpenses
        ExpenseLoading(),
        // From the implicit LoadExpenses triggered by AddExpense
        isA<ExpenseLoaded>(),
        // Check type, then check content
      ],
      verify: (_) {
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(50.0, 'EUR', 'USD'),
        ).called(1);
        verify(
          () =>
              mockExpensesLocalDataSource.addExpense(any(that: isA<Expense>())),
        ).called(1);
        verify(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).called(2); // One for initial load, one for reload after add
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseError] when AddExpense fails during currency conversion',
      build: () {
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).thenThrow('Conversion error');
        return expenseBloc;
      },
      act: (bloc) => bloc.add(
        AddExpense(
          category: 'Books',
          amount: 30.0,
          currency: 'JPY',
          date: DateTime(2024, 6, 20),
        ),
      ),
      expect: () => [ExpenseError('Conversion error')],
      verify: (_) {
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(30.0, 'JPY', 'USD'),
        ).called(1);
        verifyNever(
          () =>
              mockExpensesLocalDataSource.addExpense(any(that: isA<Expense>())),
        ); // Should not be called
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseError] when AddExpense fails during saving to local data source',
      build: () {
        when(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(any(), any(), any()),
        ).thenAnswer((_) async => 100.0); // Successful conversion

        when(
          () =>
              mockExpensesLocalDataSource.addExpense(any(that: isA<Expense>())),
        ).thenThrow('DB save error');
        return expenseBloc;
      },
      act: (bloc) => bloc.add(
        AddExpense(
          category: 'Games',
          amount: 80.0,
          currency: 'CAD',
          date: DateTime(2024, 6, 20),
        ),
      ),
      expect: () => [ExpenseError('DB save error')],
      verify: (_) {
        verify(
          () =>
              mockCurrencyRemoteDataSource.convertCurrency(80.0, 'CAD', 'USD'),
        ).called(1);
        verify(
          () =>
              mockExpensesLocalDataSource.addExpense(any(that: isA<Expense>())),
        ).called(1);
      },
    );

    // --- Filter Expenses ---
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] with filtered expenses when FilterExpenses is added',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: 'This Month',
          ),
        ).thenAnswer((_) async => [tExpense1]);
        return expenseBloc;
      },
      act: (bloc) => bloc.add(FilterExpenses(FilterTypeEnum.thisMonth)),
      expect: () => [
        ExpenseLoading(),
        ExpenseLoaded(
          expenses: [tExpense1],
          hasReachedMax: false,
          // assuming more than 10 expenses exist but only 1 returned for this test
          currentFilter: FilterTypeEnum.thisMonth,
        ),
      ],
      verify: (_) {
        verify(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: 'This Month',
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseError] when FilterExpenses fails',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow('Error filtering expenses');
        return expenseBloc;
      },
      act: (bloc) => bloc.add(FilterExpenses(FilterTypeEnum.all)),
      expect: () => [
        ExpenseLoading(),
        ExpenseError('Error filtering expenses'),
      ],
    );

    // --- Load More Expenses (Pagination) ---
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoaded] with appended expenses when LoadMoreExpenses is added and succeeds',
      build: () {
        // Initial load for seed state setup
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => [tExpense1, tExpense2, tExpense3]);

        // Mock for LoadMoreExpenses call (page: 1, as 3 expenses means (3/10).floor() = 0 page was initial)
        // If initial load returned 10 items, the next page would be 1.
        // For current `seed` with 3 items, the next page fetched by `LoadMoreExpenses`
        // would still be page 0 based on `(currentState.expenses.length / 10).floor()`.
        // To accurately test loading page 1, the `seed` state's expense count should be 10 or more.
        // Let's adjust the mock to expect page 1 if the seed implicitly sets up such a scenario.
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 1, // Expecting page 1 for load more
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer(
          (_) async => [tExpense1, tExpense2],
        ); // Simulate 2 more expenses
        return expenseBloc;
      },
      seed: () => ExpenseLoaded(
        expenses: List.generate(10, (index) => tExpense1),
        hasReachedMax: false,
      ),
      // Seed with 10 expenses to make next page = 1
      act: (bloc) => bloc.add(const LoadMoreExpenses()),
      expect: () => [
        isA<ExpenseLoaded>()
            .having(
              (state) => state.expenses.length,
              'expenses length',
              12, // 10 initial + 2 more
            )
            .having((state) => state.hasReachedMax, 'hasReachedMax', false),
      ],
      verify: (_) {
        verify(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 1, // Now correctly verifying page 1
            pageSize: 10,
            filter: null,
          ),
        ).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'does nothing when LoadMoreExpenses is added and hasReachedMax is true',
      build: () {
        return expenseBloc;
      },
      seed: () => ExpenseLoaded(expenses: [tExpense1], hasReachedMax: true),
      act: (bloc) => bloc.add(const LoadMoreExpenses()),
      expect: () => [],
      // No state changes
      verify: (_) {
        verifyZeroInteractions(
          mockExpensesLocalDataSource,
        ); // No new calls to data source
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseError] when LoadMoreExpenses fails',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow('Error loading more expenses');
        return expenseBloc;
      },
      seed: () => ExpenseLoaded(
        expenses: [tExpense1, tExpense2, tExpense3],
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreExpenses()),
      expect: () => [ExpenseError('Error loading more expenses')],
    );

    test('totalBalance getter returns correct sum of amountInUSD', () {
      final loadedState = ExpenseLoaded(
        expenses: [
          tExpense1.copyWith(amountInUSD: 100),
          tExpense2.copyWith(amountInUSD: 50),
          tExpense3.copyWith(amountInUSD: 25),
        ],
        hasReachedMax: false,
      );
      expect(loadedState.totalBalance, 175.0);
    });

    test('totalIncome getter returns correct sum of positive amountInUSD', () {
      final incomeExpense = tExpense1.copyWith(
        amount: 100.0,
        amountInUSD: 100.0,
      );
      final expenseExpense = tExpense2.copyWith(
        amount: -50.0,
        amountInUSD: -50.0,
      );
      final loadedState = ExpenseLoaded(
        expenses: [incomeExpense, expenseExpense],
        hasReachedMax: false,
      );
      expect(loadedState.totalIncome, 100.0);
    });

    test(
      'totalExpenses getter returns correct sum of absolute negative amountInUSD',
      () {
        final incomeExpense = tExpense1.copyWith(
          amount: 100.0,
          amountInUSD: 100.0,
        );
        final expenseExpense1 = tExpense2.copyWith(
          amount: -50.0,
          amountInUSD: -50.0,
        );
        final expenseExpense2 = tExpense3.copyWith(
          amount: -25.0,
          amountInUSD: -25.0,
        );
        final loadedState = ExpenseLoaded(
          expenses: [incomeExpense, expenseExpense1, expenseExpense2],
          hasReachedMax: false,
        );
        expect(loadedState.totalExpenses, 75.0);
      },
    );
  });
}
