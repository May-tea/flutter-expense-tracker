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

  User get _currentUser {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: TransactionConstants.userNotFound);
    }

    return user;
  }

  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(_currentUser.uid)
        .collection(FirebaseCollections.transactions);
  }

  Future<void> addTransaction(TransactionModel transaction) {
    final transactionDoc = _transactionsCollection.doc();

    final transactionWithId = transaction.copyWith(id: transactionDoc.id);

    return transactionDoc.set(transactionWithId.toJson());
  }

  Stream<List<TransactionModel>> getTransactions() {
    return _transactionsCollection
        .orderBy(TransactionConstants.date, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteTransaction(String transactionId) {
    return _transactionsCollection.doc(transactionId).delete();
  }

  Future<void> updateTransaction(TransactionModel transaction) {
    return _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toJson());
  }

  Future<void> restoreTransaction(TransactionModel transaction) {
    return _transactionsCollection
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<void> deleteAllTransactions() async {
    final snapshot = await _transactionsCollection.get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
