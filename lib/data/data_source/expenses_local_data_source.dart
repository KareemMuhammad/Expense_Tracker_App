import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/filter_type_enum.dart';

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

  Future<List<Expense>> getExpenses({
    int page = 0,
    int pageSize = 10,
    FilterTypeEnum? filter,
  }) async {
    final allExpenses = _expenseBox.values.toList();
    
    // Sort by date (newest first)
    allExpenses.sort((a, b) => b.date.compareTo(a.date));
    
    // Apply filter
    List<Expense> filteredExpenses = allExpenses;
    if (filter != null) {
      final now = DateTime.now();
      switch (filter) {
        case FilterTypeEnum.thisMonth:
          filteredExpenses = allExpenses.where((expense) {
            return expense.date.year == now.year && 
                   expense.date.month == now.month;
          }).toList();
          break;
        case FilterTypeEnum.lastWeek:
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(sevenDaysAgo);
          }).toList();
          break;
        case FilterTypeEnum.all:
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

  Future<void> clearAll() async {
    await _expenseBox.clear();
  }
}

