abstract final class AuthConstants {
  static const String resetPasswordKey = 'last_password_reset_sent_at';

  static const String signIn = 'Sign in';

  static const int verificationCooldownSeconds = 60;
  static const int passwordResetCooldownSeconds = 60;

  static const String verificationEmailField = 'lastVerificationEmailSentAt';
  static const String passwordResetField = 'lastPasswordResetEmailSentAt';
  static const String isVerifiedField = 'isVerified';

  static const String userNotFound = 'user-not-found';
}
