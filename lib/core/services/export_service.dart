import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

import '../../features/transactions/models/transaction_model.dart';

class ExportService {
  String generateCsv(List<TransactionModel> transactions) {
    final rows = <List<dynamic>>[
      ['Title', 'Amount', 'Type', 'Category', 'Date'],
    ];

    for (final transaction in transactions) {
      rows.add([
        transaction.title,
        transaction.amount,
        transaction.type.name,
        transaction.category.name,
        transaction.date.toIso8601String(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  Future<bool> saveToDevice(List<TransactionModel> transactions) async {
    try {
      final csv = generateCsv(transactions);
      final bytes = Uint8List.fromList(csv.codeUnits);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final path = await FileSaver.instance.saveAs(
        name: 'transactions_$timestamp',
        bytes: bytes,
        ext: 'csv',
        mimeType: .csv,
      );

      return path != null && path.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
