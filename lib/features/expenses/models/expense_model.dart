import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/expense_constants.dart';
import 'expense_category.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ExpenseConstants.title: title,
      ExpenseConstants.amount: amount,
      ExpenseConstants.category: category.name,
      ExpenseConstants.date: Timestamp.fromDate(date),
      ExpenseConstants.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ExpenseModel(
      id: documentId,
      title: json[ExpenseConstants.title] as String,
      amount: (json[ExpenseConstants.amount] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (category) => category.name == json['category'],
      ),
      date: (json[ExpenseConstants.date] as Timestamp).toDate(),
      createdAt: (json[ExpenseConstants.createdAt] as Timestamp).toDate(),
    );
  }
}
