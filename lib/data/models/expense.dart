import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  double amountInUSD;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? receiptPath;

  @HiveField(7)
  String? categoryIcon;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountInUSD,
    required this.date,
    this.receiptPath,
    this.categoryIcon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'currency': currency,
      'amountInUSD': amountInUSD,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath,
      'categoryIcon': categoryIcon,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      amountInUSD: json['amountInUSD'].toDouble(),
      date: DateTime.parse(json['date']),
      receiptPath: json['receiptPath'],
      categoryIcon: json['categoryIcon'],
    );
  }

  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    double? amountInUSD,
    DateTime? date,
    String? receiptPath,
    String? categoryIcon,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountInUSD: amountInUSD ?? this.amountInUSD,
      date: date ?? this.date,
      receiptPath: receiptPath ?? this.receiptPath,
      categoryIcon: categoryIcon ?? this.categoryIcon,
    );
  }
}

