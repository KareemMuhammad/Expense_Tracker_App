import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_source/expenses_local_data_source.dart';
import '../../data/data_source/currency_remote_data_source.dart';
import '../../data/models/expense.dart';
import '../../data/models/filter_type_enum.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final CurrencyRemoteDataSource _currencyDataSource;
  final ExpensesLocalDataSource _expensesDataSource;

  ExpenseBloc({
    required CurrencyRemoteDataSource currencyDataSource,
    required ExpensesLocalDataSource expensesDataSource,
  })  : _currencyDataSource = currencyDataSource,
        _expensesDataSource = expensesDataSource,
        super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<FilterExpenses>(_onFilterExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _expensesDataSource.getExpenses(
        page: 0,
        pageSize: 10,
        filter: event.filter,
      );
      emit(ExpenseLoaded(
        expenses: expenses,
        hasReachedMax: expenses.length < 10,
        currentFilter: event.filter,
      ));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  void _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      // Convert amount to USD
      final amountInUSD = await _currencyDataSource.convertCurrency(
        event.amount,
        event.currency,
        'USD',
      );

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: event.category,
        amount: event.amount,
        currency: event.currency,
        amountInUSD: amountInUSD,
        date: event.date,
        receiptPath: event.receiptPath,
        categoryIcon: event.categoryIcon,
      );

      await _expensesDataSource.addExpense(expense);

      // Safely get current filter for reload
      FilterTypeEnum? currentFilter;
      if (state is ExpenseLoaded) {
        currentFilter = (state as ExpenseLoaded).currentFilter;
      }
      // If not ExpenseLoaded, it will default to null, which means loading all expenses.
      add(LoadExpenses(filter: currentFilter));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  void _onFilterExpenses(FilterExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _expensesDataSource.getExpenses(
        page: 0,
        pageSize: 10,
        filter: event.filter,
      );
      emit(ExpenseLoaded(
        expenses: expenses,
        hasReachedMax: expenses.length < 10,
        currentFilter: event.filter,
      ));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  void _onLoadMoreExpenses(LoadMoreExpenses event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final moreExpenses = await _expensesDataSource.getExpenses(
          page: (currentState.expenses.length / 10).floor(),
          pageSize: 10,
          filter: currentState.currentFilter,
        );

        emit(ExpenseLoaded(
          expenses: [...currentState.expenses, ...moreExpenses],
          hasReachedMax: moreExpenses.length < 10,
          currentFilter: currentState.currentFilter,
        ));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    }
  }
}

