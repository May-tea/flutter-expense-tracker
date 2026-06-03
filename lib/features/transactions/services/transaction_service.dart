import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firebase_collections.dart';
import '../../../core/constants/transaction_constants.dart';
import '../models/transaction_model.dart';

class TransactionService {
  TransactionService._();

  static final TransactionService instance = ._();

  final FirebaseFirestore _firestore = .instance;
  final FirebaseAuth _firebase = .instance;

  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: TransactionConstants.userNotFound);
    }

    return _firestore
        .collection(FirebaseCollections.users)
        .doc(user.uid)
        .collection(FirebaseCollections.transactions);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final transactionDoc = _transactionsCollection.doc();

    final transactionWithId = transaction.copyWith(id: transactionDoc.id);

    await transactionDoc.set(transactionWithId.toJson());
  }

  Stream<List<TransactionModel>> getTransactions() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsCollection.doc(transactionId).delete();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toJson());
  }

  Future<void> restoreTransaction(TransactionModel transaction) async {
    await _transactionsCollection.doc(transaction.id).set(transaction.toJson());
  }
}
