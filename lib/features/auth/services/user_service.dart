import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../models/user_model.dart';

class UserService {
  UserService._();

  static final UserService instance = ._();

  final FirebaseFirestore _firestore = .instance;
  final FirebaseAuth _firebase = .instance;

  String? get currentUserId => _firebase.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection(FirebaseCollections.users);

  Future<void> markUserAsVerified() async {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: AuthConstants.userNotFound);
    }

    await _userCollection.doc(user.uid).update({
      AuthConstants.isVerifiedField: true,
    });
  }

  Future<int> getVerificationEmailCooldown() async {
    final user = _firebase.currentUser;

    if (user == null) return 0;

    final doc = await _userCollection.doc(user.uid).get();

    final timestamp =
        doc.data()?[AuthConstants.verificationEmailField] as Timestamp?;

    if (timestamp == null) return 0;

    final elapsed = DateTime.now().difference(timestamp.toDate()).inSeconds;

    final remaining = AuthConstants.verificationCooldownSeconds - elapsed;

    return remaining.clamp(0, AuthConstants.verificationCooldownSeconds);
  }

  Future<void> createUserProfile({
    required String uid,
    required UserModel user,
  }) async {
    await _userCollection.doc(uid).set(user.toJson());
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _firebase.currentUser;

    if (user == null) return null;

    final doc = await _userCollection.doc(user.uid).get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  Future<void> updateUserProfile({required String username}) async {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: AuthConstants.userNotFound);
    }

    await _userCollection.doc(user.uid).update({'username': username});

    await user.updateDisplayName(username);
  }

  Future<UserModel?> getUserProfileById(String uid) async {
    final doc = await _userCollection.doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }
}
