import 'package:expense_tracker_app/data/models/filter_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/animated_navigation.dart';
import '../../core/utils/helpers/screen_helpers.dart';
import '../blocs/expenses_list/expense_bloc.dart';
import '../../core/utils/app_colors.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/expenses_item_widget.dart';
import '../widgets/home_screen_header.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  FilterTypeEnum selectedFilter = FilterTypeEnum.all;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses(filter: selectedFilter));

    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter <= 0) {
      context.read<ExpenseBloc>().add(LoadMoreExpenses());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey[50]!,
      child: Stack(
        children: [
          _buildHeader(),
          Positioned.fill(
            top: MediaQuery.sizeOf(context).height * 0.12,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _buildBalanceCard(state),
                        Expanded(child: _buildRecentExpensesSection(state)),
                      ],
                    );
                  },
                ),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return HomeScreenHeader(
      userImage: ScreenHelpers.userImage,
      selectedFilter: selectedFilter,
      onFilterChanged: (FilterTypeEnum? value) {
        if (value != null) {
          setState(() => selectedFilter = value);
          context.read<ExpenseBloc>().add(FilterExpenses(value));
        }
      },
    );
  }

  Widget _buildBalanceCard(ExpenseState state) {
    double totalBalance = 0.00;
    double totalIncome = 0.00;
    double totalExpenses = 0.00;
    if (state is ExpenseLoaded) {
      totalBalance = state.totalBalance;
      totalIncome = state.totalIncome;
      totalExpenses = state.totalExpenses.abs();
    }

    return BalanceCardWidget(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
    );
  }

  Widget _buildRecentExpensesSection(ExpenseState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'see all',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildRecentExpenses(state)),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseState state) {
    if (state is ExpenseLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ExpenseError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error: ${state.message}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (state is ExpenseLoaded && state.expenses.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          final expense = state.expenses[index];
          return _buildExpenseItem(
            expense.category,
            expense.amount.abs(),
            expense.currency,
            ScreenHelpers.formatTime(expense.date),
            ScreenHelpers.getCategoryIcon(expense.category),
            ScreenHelpers.getCategoryColor(expense.category),
          );
        },
      );
    }

    return Center(
      child: Text(
        'No expenses found',
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildExpenseItem(
    String category,
    double amount,
    String currency,
    String time,
    IconData icon,
    Color color,
  ) {
    return ExpensesItemWidget(
      category: category,
      amount: amount,
      currency: currency,
      time: time,
      icon: icon,
      color: color,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, true),
          _buildNavItem(Icons.bar_chart, 1, false),
          _buildAddButton(),
          _buildNavItem(Icons.calendar_today, 3, false),
          _buildNavItem(Icons.person, 4, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (index == 4) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlideRightRoute(
            page: AddExpenseScreen(currentFilter: selectedFilter),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
