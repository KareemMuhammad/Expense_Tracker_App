import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/expense.dart';

class ExportService {
  Future<void> exportToCsv(List<Expense> expenses) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expenses_export.csv');

      final csvContent = StringBuffer();
      csvContent.writeln('Date,Category,Amount,Currency,Amount in USD,Receipt');

      for (final expense in expenses) {
        csvContent.writeln(
          '${expense.date.toIso8601String()},'
          '${expense.category},'
          '${expense.amount},'
          '${expense.currency},'
          '${expense.amountInUSD},'
          '${expense.receiptPath ?? ''}',
        );
      }

      await file.writeAsString(csvContent.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Expense Tracker CSV Export',
          subject: 'My Expenses Data (CSV)',
        ),
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}
