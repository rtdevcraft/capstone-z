/// Base class for all authentication-related failures.
abstract class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown during sign-up if an error occurs.
class SignUpFailure extends AuthFailure {
  const SignUpFailure([super.message = 'An unknown error occurred during sign up.']);
}

/// Thrown during sign-in if an error occurs.
class SignInFailure extends AuthFailure {
  const SignInFailure([super.message = 'An unknown error occurred during sign in.']);
}