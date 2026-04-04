/// Validation helpers for authentication forms
class AuthValidators {
  AuthValidators._();

  /// Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Username regex: 3-20 chars, alphanumeric and underscore only
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  /// Full name regex: min 2 chars, letters, spaces, and hyphens only
  static final RegExp _fullNameRegex = RegExp(r"^[a-zA-Z\s\-']{2,50}$");

  /// Validate email address
  ///
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 number
  /// - At least 1 special character (@$!%*?&)
  ///
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 128) {
      return 'Password is too long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'\d'))) {
      return 'Password must contain at least one number';
    }

    if (!password.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Password must contain at least one special character (@\$!%*?&)';
    }

    return null;
  }

  /// Validate password strength (simpler version for login)
  ///
  /// Returns null if valid, error message if invalid
  static String? validatePasswordSimple(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate username
  ///
  /// Requirements:
  /// - 3-20 characters
  /// - Only alphanumeric characters and underscores
  /// - No spaces
  /// - Cannot start with underscore
  ///
  /// Returns null if valid, error message if invalid
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmedUsername = username.trim().toLowerCase();

    if (trimmedUsername.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmedUsername.length > 20) {
      return 'Username must be at most 20 characters';
    }

    if (trimmedUsername.startsWith('_')) {
      return 'Username cannot start with underscore';
    }

    if (!_usernameRegex.hasMatch(trimmedUsername)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Check for reserved usernames
    final reservedUsernames = [
      'admin',
      'administrator',
      'mod',
      'moderator',
      'system',
      'support',
      'help',
      'api',
      'test',
      'null',
      'undefined',
      'root',
      'user',
      'guest',
      'anonymous',
      'colony',
    ];

    if (reservedUsernames.contains(trimmedUsername)) {
      return 'This username is reserved';
    }

    return null;
  }

  /// Validate full name
  ///
  /// Requirements:
  /// - Minimum 2 characters
  /// - Maximum 50 characters
  /// - Only letters, spaces, hyphens, and apostrophes
  /// - No special characters
  ///
  /// Returns null if valid, error message if invalid
  static String? validateFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'Full name is required';
    }

    final trimmedName = fullName.trim();

    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmedName.length > 50) {
      return 'Name must be at most 50 characters';
    }

    if (!_fullNameRegex.hasMatch(trimmedName)) {
      return 'Name can only contain letters, spaces, and hyphens';
    }

    // Check for consecutive spaces
    if (trimmedName.contains(RegExp(r'\s{2,}'))) {
      return 'Name cannot have consecutive spaces';
    }

    return null;
  }

  /// Validate confirm password
  ///
  /// Returns null if passwords match, error message if they don't
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Check if email is valid (returns bool)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is valid (returns bool)
  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if username is valid (returns bool)
  static bool isValidUsername(String username) {
    return validateUsername(username) == null;
  }

  /// Check if full name is valid (returns bool)
  static bool isValidFullName(String fullName) {
    return validateFullName(fullName) == null;
  }

  /// Get password strength score (0-4)
  ///
  /// 0: Very weak
  /// 1: Weak
  /// 2: Fair
  /// 3: Good
  /// 4: Strong
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'\d'))) strength++;
    if (password.contains(RegExp(r'[@$!%*?&]'))) strength++;

    return strength;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(String password) {
    final strength = getPasswordStrength(password);

    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }
}
