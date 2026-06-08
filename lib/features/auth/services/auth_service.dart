import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/firebase_collections.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = ._();

  final FirebaseAuth _firebase = .instance;
  final FirebaseFirestore _firestore = .instance;
  final UserService _userService = .instance;

  CollectionReference<Map<String, dynamic>> get _userCollection =>
      _firestore.collection(FirebaseCollections.users);

  Stream<User?> authStateChanges() {
    return _firebase.userChanges();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _firebase.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final userCredentials = await _firebase.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredentials.user!;

    await user.updateDisplayName(username);

    await user.sendEmailVerification();

    final userProfile = UserModel(
      username: username,
      email: email,
      isVerified: false,
      createdAt: .now(),
      lastVerificationEmailSentAt: .now(),
    );

    await _userService.createUserProfile(uid: user.uid, user: userProfile);
  }

  Future<void> signOut() async {
    await _firebase.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _firebase.sendPasswordResetEmail(email: email);
  }

  Future<void> resendVerificationEmail() async {
    final user = _firebase.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    await user.sendEmailVerification();

    await _userCollection.doc(user.uid).update({
      AuthConstants.verificationEmailField: Timestamp.now(),
    });
  }

  Future<bool> isEmailVerified() async {
    await _firebase.currentUser?.reload();

    final user = _firebase.currentUser;

    return user?.emailVerified ?? false;
  }

  Future<void> updateDisplayName(String name) async {
    await _firebase.currentUser?.updateDisplayName(name);
  }
}
