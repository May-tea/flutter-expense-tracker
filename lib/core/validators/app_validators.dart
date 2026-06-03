abstract final class AppValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required.';
    }

    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Please enter at least 4 characters.';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null;
  }

  static String? amount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');

    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }

    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a title';
    }

    return null;
  }
}
