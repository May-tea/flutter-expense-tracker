import 'package:app/features/auth/models/user_model.dart';

import '../services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) => .instance);

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  return ref.read(userServiceProvider).currentUserProfileStream();
});
