part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final bool hasReachedMax;
  final FilterTypeEnum? currentFilter;

  const ExpenseLoaded({
    required this.expenses,
    required this.hasReachedMax,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [expenses, hasReachedMax, currentFilter];

  double get totalBalance {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amountInUSD);
  }

  double get totalIncome {
    return expenses
        .where((expense) => expense.amount > 0)
        .fold(0.0, (sum, expense) => sum + expense.amountInUSD);
  }

  double get totalExpenses {
    return expenses
        .where((expense) => expense.amount < 0)
        .fold(0.0, (sum, expense) => sum + expense.amountInUSD.abs());
  }
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

