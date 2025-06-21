import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker_app/data/models/expense.dart';
import 'package:expense_tracker_app/data/models/filter_type_enum.dart';
import 'package:expense_tracker_app/presentation/blocs/expenses_list/expense_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'expenses_mocks.dart';

void main() {
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
    mockExpensesLocalDataSource = MockExpensesLocalDataSource();
    expenseBloc = ExpenseBloc(
      expensesDataSource: mockExpensesLocalDataSource,
    );
  });

  tearDown(() {
    expenseBloc.close();
  });

  group('ExpenseBloc', () {

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
          hasReachedMax: true,
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

    // --- Filter Expenses ---
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] with filtered expenses when FilterExpenses is added',
      build: () {
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: FilterTypeEnum.thisMonth,
          ),
        ).thenAnswer((_) async => [tExpense1]);
        return expenseBloc;
      },
      act: (bloc) => bloc.add(FilterExpenses(FilterTypeEnum.thisMonth)),
      expect: () => [
        ExpenseLoading(),
        ExpenseLoaded(
          expenses: [tExpense1],
          hasReachedMax: true,
          // assuming more than 10 expenses exist but only 1 returned for this test
          currentFilter: FilterTypeEnum.thisMonth,
        ),
      ],
      verify: (_) {
        verify(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 0,
            pageSize: 10,
            filter: FilterTypeEnum.thisMonth,
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
        // Mock for LoadMoreExpenses call (page: 1, as the seed already has 10 items)
        when(
          () => mockExpensesLocalDataSource.getExpenses(
            page: 1, // Expecting page 1 for load more
            pageSize: 10,
            filter: any(named: 'filter'),
          ),
        ).thenAnswer(
          (_) async => List.generate(10, (index) => tExpense2),
        ); // Simulate 10 more expenses
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
              20, // 10 initial + 10 more
            )
            .having(
              (state) => state.hasReachedMax,
              'hasReachedMax',
              false, // Now will be false because moreExpenses.length (10) is not < 10
            ),
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
