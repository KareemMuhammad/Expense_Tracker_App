import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di.dart';
import '../../core/utils/helpers/screen_helpers.dart';
import '../../data/data_source/currency_remote_data_source.dart';
import '../../data/data_source/expenses_local_data_source.dart';
import '../../data/models/filter_type_enum.dart';
import '../blocs/add_expense/add_expense_bloc.dart';
import '../blocs/expenses_list/expense_bloc.dart';
import '../../core/utils/app_colors.dart';
import '../widgets/categories_grid_widget.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/text_field_widget.dart';

class AddExpenseScreen extends StatefulWidget {
  final FilterTypeEnum? currentFilter;

  const AddExpenseScreen({super.key, required this.currentFilter});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddExpenseBloc(
        currencyDataSource: getIt.get<CurrencyRemoteDataSource>(),
        expensesDataSource: getIt.get<ExpensesLocalDataSource>(),
        expenseBloc: context.read<ExpenseBloc>(),
        currentFilter: widget.currentFilter,
      ),
      child: BlocListener<AddExpenseBloc, AddExpenseState>(
        listener: (context, state) {
          if (state is AddExpenseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF4A90E2),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AddExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(context),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryDropdown(),
                  const SizedBox(height: 24),
                  _buildAmountSection(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildReceiptSection(),
                  const SizedBox(height: 32),
                  CategoriesGridWidget(categories: ScreenHelpers.categories),
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[50],
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: const Text(
        'Add Expense',
        style: TextStyle(
          color: Colors.black,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCategoryDropdown() {
    final List<String> categoryNames = ScreenHelpers.categories
        .map((category) => category['name'] as String)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AddExpenseBloc, AddExpenseState>(
          buildWhen: (previous, current) =>
              previous is AddExpenseFormState &&
              current is AddExpenseFormState &&
              previous.selectedCategory != current.selectedCategory,
          builder: (context, state) {
            String selectedCategory = 'Entertainment'; // Default value
            if (state is AddExpenseFormState) {
              selectedCategory = state.selectedCategory;
            }
            return DropdownWidget<String>(
              selectedValue: selectedCategory,
              items: categoryNames,
              onChanged: (String? value) {
                if (value != null) {
                  context.read<AddExpenseBloc>().add(ChangeCategory(value));
                }
              },
              itemLabel: (String value) => value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: BlocBuilder<AddExpenseBloc, AddExpenseState>(
                buildWhen: (previous, current) =>
                    previous is AddExpenseFormState &&
                    current is AddExpenseFormState &&
                    previous.selectedCurrency != current.selectedCurrency,
                builder: (context, state) {
                  String selectedCurrency = 'USD'; // Default
                  if (state is AddExpenseFormState) {
                    selectedCurrency = state.selectedCurrency;
                  }
                  return DropdownWidget<String>(
                    selectedValue: selectedCurrency,
                    items: context
                        .read<AddExpenseBloc>()
                        .getSupportedCurrencies(), // Call helper from Bloc
                    onChanged: (String? value) {
                      if (value != null) {
                        context.read<AddExpenseBloc>().add(
                          ChangeCurrency(value),
                        );
                      }
                    },
                    itemLabel: (String value) => value,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFieldWidget(
                amountController: _amountController,
                hint: '\$50,000',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AddExpenseBloc, AddExpenseState>(
          buildWhen: (previous, current) =>
              previous is AddExpenseFormState &&
              current is AddExpenseFormState &&
              previous.selectedDate != current.selectedDate,
          builder: (context, state) {
            DateTime selectedDate = DateTime.now(); // Default
            if (state is AddExpenseFormState) {
              selectedDate = state.selectedDate;
            }
            return GestureDetector(
              onTap: () async {
                final DateTime? picked = await _showDatePicker(
                  context,
                  selectedDate,
                );
                if (picked != null && picked != selectedDate) {
                  if (!context.mounted) return;
                  context.read<AddExpenseBloc>().add(SelectDateEvent(picked));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Receipt',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<AddExpenseBloc, AddExpenseState>(
          buildWhen: (previous, current) =>
              previous is AddExpenseFormState &&
              current is AddExpenseFormState &&
              previous.selectedReceiptPath != current.selectedReceiptPath,
          builder: (context, state) {
            String? selectedReceiptPath;
            if (state is AddExpenseFormState) {
              selectedReceiptPath = state.selectedReceiptPath;
            }
            return GestureDetector(
              onTap: () => context.read<AddExpenseBloc>().pickMedia(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedReceiptPath != null
                          ? 'Image attached'
                          : 'Upload image',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.document_scanner,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<AddExpenseBloc, AddExpenseState>(
        buildWhen: (previous, current) =>
            current is AddExpenseLoading || current is AddExpenseFormState,
        builder: (context, state) {
          final isLoading = state is AddExpenseLoading;
          final formState = state is AddExpenseFormState ? state : null;

          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate() &&
                        formState != null) {
                      final amount = double.parse(_amountController.text);
                      final finalAmount =
                          -amount; // Always negative for expenses

                      context.read<AddExpenseBloc>().add(
                        SubmitExpense(
                          category: formState.selectedCategory,
                          amount: finalAmount,
                          currency: formState.selectedCurrency,
                          date: formState.selectedDate,
                          receiptPath: formState.selectedReceiptPath,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
  }
}
