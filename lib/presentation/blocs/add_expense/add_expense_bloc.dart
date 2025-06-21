import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:expense_tracker_app/data/models/filter_type_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/data_source/currency_remote_data_source.dart';
import '../../../data/data_source/expenses_local_data_source.dart';
import '../../../data/models/expense.dart';
import '../expenses_list/expense_bloc.dart';

part 'add_expense_event.dart';

part 'add_expense_state.dart';

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  final CurrencyRemoteDataSource _currencyDataSource;
  final ExpensesLocalDataSource _expensesDataSource;
  final ExpenseBloc _expenseBloc;
  final ImagePicker _imagePicker;
  final FilterTypeEnum? currentFilter;

  AddExpenseBloc({
    required CurrencyRemoteDataSource currencyDataSource,
    required ExpensesLocalDataSource expensesDataSource,
    required ExpenseBloc expenseBloc,
    this.currentFilter,
  }) : _currencyDataSource = currencyDataSource,
       _expensesDataSource = expensesDataSource,
       _expenseBloc = expenseBloc,
       _imagePicker = ImagePicker(),
       super(
         AddExpenseFormState(
           selectedCategory: 'Entertainment',
           selectedCurrency: 'USD',
           selectedDate: DateTime.now(),
         ),
       ) {
    on<ChangeCategory>(_onChangeCategory);
    on<ChangeCurrency>(_onChangeCurrency);
    on<SelectDateEvent>(_onSelectDate);
    on<AttachReceiptEvent>(_onAttachReceipt);
    on<SubmitExpense>(_onSubmitExpense);
    on<AddExpenseErrorEvent>(_onAddExpenseError);
  }

  void _onChangeCategory(ChangeCategory event, Emitter<AddExpenseState> emit) {
    if (state is AddExpenseFormState) {
      final currentState = state as AddExpenseFormState;
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  void _onChangeCurrency(ChangeCurrency event, Emitter<AddExpenseState> emit) {
    if (state is AddExpenseFormState) {
      final currentState = state as AddExpenseFormState;
      emit(currentState.copyWith(selectedCurrency: event.currency));
    }
  }

  void _onSelectDate(SelectDateEvent event, Emitter<AddExpenseState> emit) {
    if (state is AddExpenseFormState) {
      final currentState = state as AddExpenseFormState;
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  void _onAttachReceipt(
    AttachReceiptEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    if (state is AddExpenseFormState) {
      final currentState = state as AddExpenseFormState;
      emit(currentState.copyWith(selectedReceiptPath: event.receiptPath));
    }
  }

  void _onAddExpenseError(
    AddExpenseErrorEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(AddExpenseError(event.message));
  }

  void _onSubmitExpense(
    SubmitExpense event,
    Emitter<AddExpenseState> emit,
  ) async {
    emit(AddExpenseLoading());

    try {
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

      _expenseBloc.add(LoadExpenses(filter: currentFilter));

      emit(const AddExpenseSuccess('Expense added successfully!'));

      if (state is AddExpenseFormState) {
        final currentFormState = state as AddExpenseFormState;
        emit(
          currentFormState.copyWith(
            successMessage: 'Expense added successfully!',
            errorMessage: null,
            isLoading: false,
          ),
        );
      } else {
        emit(
          AddExpenseFormState(
            selectedCategory: 'Entertainment',
            selectedCurrency: 'USD',
            selectedDate: DateTime.now(),
            selectedReceiptPath: null,
            successMessage: 'Expense added successfully!',
          ),
        );
      }
    } catch (e) {
      final errorMessage = 'Failed to add expense: ${e.toString()}';
      emit(AddExpenseError(errorMessage));
      if (state is AddExpenseFormState) {
        final currentFormState = state as AddExpenseFormState;
        emit(
          currentFormState.copyWith(
            errorMessage: errorMessage,
            successMessage: null,
            isLoading: false,
          ),
        );
      } else {
        emit(
          AddExpenseFormState(
            selectedCategory: 'Entertainment',
            selectedCurrency: 'USD',
            selectedDate: DateTime.now(),
            selectedReceiptPath: null,
            errorMessage: errorMessage,
          ),
        );
      }
    }
  }

  Future<void> pickMedia() async {
    try {
      final XFile? image = await _imagePicker.pickMedia(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        add(AttachReceiptEvent(image.path));
      } else {
        add(const AttachReceiptEvent(null));
      }
    } catch (e) {
      add(
        AddExpenseErrorEvent('Error picking image: $e'),
      ); // Changed from direct emit
    }
  }

  List<String> getSupportedCurrencies() {
    return _currencyDataSource.getSupportedCurrencies();
  }
}
