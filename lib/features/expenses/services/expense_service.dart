import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/expense_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../models/expense_model.dart';

class ExpenseService {
  ExpenseService._();

  static final ExpenseService instance = ._();

  final FirebaseFirestore _firestore = .instance;
  final FirebaseAuth _firebase = .instance;

  CollectionReference<Map<String, dynamic>> get _expensesCollection {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: ExpenseConstants.userNotFound);
    }

    return _firestore
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .collection(FirebaseCollections.expenses);
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final expenseDoc = _expensesCollection.doc();

    final expenseWithId = expense.copyWith(id: expenseDoc.id);

    await expenseDoc.set(expenseWithId.toJson());
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ExpenseModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesCollection.doc(expenseId).delete();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toJson());
  }
}
