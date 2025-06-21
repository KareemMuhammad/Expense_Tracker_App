import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_source/expenses_local_data_source.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/filter_type_enum.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpensesLocalDataSource _expensesDataSource;

  ExpenseBloc({required ExpensesLocalDataSource expensesDataSource})
    : _expensesDataSource = expensesDataSource,
      super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
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
      emit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < 10,
          currentFilter: event.filter,
        ),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  void _onFilterExpenses(
    FilterExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _expensesDataSource.getExpenses(
        page: 0,
        pageSize: 10,
        filter: event.filter,
      );
      emit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < 10,
          currentFilter: event.filter,
        ),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  void _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final moreExpenses = await _expensesDataSource.getExpenses(
          page: (currentState.expenses.length / 10).floor(),
          pageSize: 10,
          filter: currentState.currentFilter,
        );

        emit(
          ExpenseLoaded(
            expenses: [...currentState.expenses, ...moreExpenses],
            hasReachedMax: moreExpenses.length < 10,
            currentFilter: currentState.currentFilter,
          ),
        );
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    }
  }
}
