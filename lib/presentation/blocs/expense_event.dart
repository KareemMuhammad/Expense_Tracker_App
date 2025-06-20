part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final FilterTypeEnum? filter;

  const LoadExpenses({this.filter});

  @override
  List<Object?> get props => [filter];
}

class AddExpense extends ExpenseEvent {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? receiptPath;
  final String? categoryIcon;

  const AddExpense({
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.receiptPath,
    this.categoryIcon,
  });

  @override
  List<Object?> get props => [
        category,
        amount,
        currency,
        date,
        receiptPath,
        categoryIcon,
      ];
}

class FilterExpenses extends ExpenseEvent {
  final FilterTypeEnum filter;

  const FilterExpenses(this.filter);

  @override
  List<Object> get props => [filter];
}

class LoadMoreExpenses extends ExpenseEvent {
  const LoadMoreExpenses();
}

