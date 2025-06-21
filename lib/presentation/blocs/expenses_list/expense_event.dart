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

class FilterExpenses extends ExpenseEvent {
  final FilterTypeEnum filter;

  const FilterExpenses(this.filter);

  @override
  List<Object> get props => [filter];
}

class LoadMoreExpenses extends ExpenseEvent {
  const LoadMoreExpenses();
}

