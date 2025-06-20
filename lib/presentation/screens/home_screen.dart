import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_tracker_app/data/models/filter_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/animated_navigation.dart';
import '../blocs/expense_bloc.dart';
import '../../core/utils/app_colors.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/expenses_item_widget.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String userImage =
      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D';
  FilterTypeEnum selectedFilter = FilterTypeEnum.all;
  late ScrollController _scrollController;

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF357ABD)],
          ),
        ),
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.4,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: CachedNetworkImageProvider(userImage),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kareem Muhammad',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 115,
                  child: DropdownWidget<FilterTypeEnum>(
                    selectedValue: selectedFilter,
                    items: FilterTypeEnum.values.toList(),
                    onChanged: (FilterTypeEnum? value) {
                      if (value != null) {
                        setState(() => selectedFilter = value);
                        context.read<ExpenseBloc>().add(FilterExpenses(value));
                      }
                    },
                    itemLabel: (FilterTypeEnum type) => type.title,
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ExpenseState state) {
    double totalBalance = 2548.00;
    double totalIncome = 10840.00;
    double totalExpenses = 1884.00;

    if (state is ExpenseLoaded) {
      totalBalance = state.totalBalance;
      totalIncome = state.totalIncome;
      totalExpenses = state.totalExpenses.abs();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, Color(0xFF357ABD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.white.withOpacity(0.7),
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$ ${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigo.withValues(alpha: 0.3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$ ${totalIncome.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigo.withValues(alpha: 0.3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$ ${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
            _formatTime(expense.date),
            _getCategoryIcon(expense.category),
            _getCategoryColor(expense.category),
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
            color: Colors.black.withOpacity(0.1),
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
        Navigator.of(
          context,
        ).push(SlideRightRoute(page: const AddExpenseScreen()));
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      case 'rent':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return const Color(0xFF4A90E2);
      case 'entertainment':
        return const Color(0xFFFF9500);
      case 'transportation':
        return const Color(0xFF9B59B6);
      case 'rent':
        return const Color(0xFFE67E22);
      case 'food':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return 'Today ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
