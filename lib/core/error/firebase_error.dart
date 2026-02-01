/// Centralized Firebase Auth error mapping. Used by login, signup, forgot password.
String getFirebaseAuthMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Invalid email address';
    case 'user-not-found':
      return 'No account found for this email';
    case 'wrong-password':
    case 'invalid-login-credentials':
    case 'invalid-credential':
      return 'Incorrect email or password';
    case 'email-already-in-use':
      return 'Email already in use';
    case 'weak-password':
      return 'Password is too weak';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'too-many-requests':
      return 'Too many attempts. Try again later';
    case 'network-request-failed':
      return 'Check your internet connection';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled';
    case 'requires-recent-login':
      return 'Please sign in again and retry';
    case 'invalid-verification-code':
      return 'Invalid verification code';
    case 'invalid-verification-id':
      return 'Verification session expired';
    default:
      return 'Authentication failed';
  }
}

@Deprecated('Use getFirebaseAuthMessage(code) instead')
class AuthErrorMessages {
  static String getMessage(String code) => getFirebaseAuthMessage(code);
}
