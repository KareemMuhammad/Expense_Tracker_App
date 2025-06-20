import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class ExpensesLocalDataSource {
  static const String _expenseBoxName = 'expenses';
  late Box<Expense> _expenseBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    _expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expenseBox.delete(expenseId);
  }

  Future<List<Expense>> getExpenses({
    int page = 0,
    int pageSize = 10,
    String? filter,
  }) async {
    final allExpenses = _expenseBox.values.toList();
    
    // Sort by date (newest first)
    allExpenses.sort((a, b) => b.date.compareTo(a.date));
    
    // Apply filter
    List<Expense> filteredExpenses = allExpenses;
    if (filter != null) {
      final now = DateTime.now();
      switch (filter) {
        case 'This Month':
          filteredExpenses = allExpenses.where((expense) {
            return expense.date.year == now.year && 
                   expense.date.month == now.month;
          }).toList();
          break;
        case 'Last 7 Days':
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(sevenDaysAgo);
          }).toList();
          break;
      }
    }
    
    // Apply pagination
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, filteredExpenses.length);
    
    if (startIndex >= filteredExpenses.length) {
      return [];
    }
    
    return filteredExpenses.sublist(startIndex, endIndex);
  }

  Future<double> getTotalBalance({String? filter}) async {
    final expenses = await getExpenses(filter: filter, pageSize: 1000);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amountInUSD;
    }
    return total;
  }

  Future<void> clearAll() async {
    await _expenseBox.clear();
  }
}

