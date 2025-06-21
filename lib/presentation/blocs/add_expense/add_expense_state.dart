part of 'add_expense_bloc.dart';

// Abstract base class for all AddExpense states
abstract class AddExpenseState extends Equatable {
  const AddExpenseState();

  @override
  List<Object?> get props => [];
}

// Initial state of the AddExpenseBloc
class AddExpenseInitial extends AddExpenseState {}

// State representing that an operation is in progress (e.g., submitting expense)
class AddExpenseLoading extends AddExpenseState {}

// State representing successful completion of an operation (e.g., expense added)
class AddExpenseSuccess extends AddExpenseState {
  final String message;

  const AddExpenseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// State representing an error during an operation
class AddExpenseError extends AddExpenseState {
  final String message;

  const AddExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

// State holding the current form values
class AddExpenseFormState extends AddExpenseState {
  final String selectedCategory;
  final String selectedCurrency;
  final DateTime selectedDate;
  final String? selectedReceiptPath;
  final bool isLoading; // To indicate if a specific part of the form is loading (e.g., currency conversion)
  final String? errorMessage;
  final String? successMessage;

  const AddExpenseFormState({
    required this.selectedCategory,
    required this.selectedCurrency,
    required this.selectedDate,
    this.selectedReceiptPath,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  // copyWith method to easily update specific properties of the state
  AddExpenseFormState copyWith({
    String? selectedCategory,
    String? selectedCurrency,
    DateTime? selectedDate,
    String? selectedReceiptPath,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddExpenseFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedReceiptPath: selectedReceiptPath ?? this.selectedReceiptPath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // We explicitly set to null if not provided, for clearing
      successMessage: successMessage, // We explicitly set to null if not provided, for clearing
    );
  }

  @override
  List<Object?> get props => [
    selectedCategory,
    selectedCurrency,
    selectedDate,
    selectedReceiptPath,
    isLoading,
    errorMessage,
    successMessage,
  ];
}

