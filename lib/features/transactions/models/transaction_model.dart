import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/transaction_constants.dart';
import 'expense_category.dart';
import 'transaction_type.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final TransactionType type;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TransactionConstants.title: title,
      TransactionConstants.amount: amount,
      TransactionConstants.category: category.name,
      TransactionConstants.type: type.name,
      TransactionConstants.date: Timestamp.fromDate(date),
      TransactionConstants.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TransactionModel(
      id: documentId,
      title: json[TransactionConstants.title] as String,
      amount: (json[TransactionConstants.amount] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (category) => category.name == json['category'],
      ),
      type: TransactionType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      date: (json[TransactionConstants.date] as Timestamp).toDate(),
      createdAt: (json[TransactionConstants.createdAt] as Timestamp).toDate(),
    );
  }
}
