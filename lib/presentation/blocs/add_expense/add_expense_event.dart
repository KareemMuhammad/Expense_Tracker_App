part of 'add_expense_bloc.dart';

// Abstract base class for all AddExpense events
abstract class AddExpenseEvent extends Equatable {
  const AddExpenseEvent();

  @override
  List<Object?> get props => [];
}

// Event to change the selected category
class ChangeCategory extends AddExpenseEvent {
  final String category;

  const ChangeCategory(this.category);

  @override
  List<Object> get props => [category];
}

// Event to change the selected currency
class ChangeCurrency extends AddExpenseEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}

// Event to update the selected date
class SelectDateEvent extends AddExpenseEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object> get props => [date];
}

// Event to attach a receipt image
class AttachReceiptEvent extends AddExpenseEvent {
  final String? receiptPath; // Path to the selected image

  const AttachReceiptEvent(this.receiptPath);

  @override
  List<Object?> get props => [receiptPath];
}

class AddExpenseErrorEvent extends AddExpenseEvent {
  final String message;

  const AddExpenseErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}

// Event to submit the expense data
class SubmitExpense extends AddExpenseEvent {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? receiptPath;
  final String? categoryIcon; // Pass this along if needed by ExpenseBloc

  const SubmitExpense({
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

