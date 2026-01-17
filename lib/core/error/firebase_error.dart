class AuthErrorMessages {
  static String getMessage(String code) {
    String msg;

    switch (code) {
      case 'invalid-email':
        msg = 'Invalid email address';
        break;
      case 'user-not-found':
        msg = 'No account found for this email';
        break;
      case 'wrong-password':
      case 'invalid-login-credentials':
        msg = 'Incorrect email or password';
        break;
      case 'email-already-in-use':
        msg = 'Email already in use';
        break;
      case 'weak-password':
        msg = 'Password is too weak';
        break;
      case 'user-disabled':
        msg = 'This account has been disabled';
        break;
      case 'too-many-requests':
        msg = 'Too many attempts. Try again later';
        break;
      case 'network-request-failed':
        msg = 'Check your internet connection';
        break;
      default:
        msg = 'Authentication failed';
    }

    return msg;
  }
}
