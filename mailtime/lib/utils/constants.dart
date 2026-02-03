class AppConstants {
  static const appName = 'MailTime';
  static const tagline = 'Write to Your Future Self';

  static const capsuleTitleMaxLength = 100;
  static const capsuleBodyMaxLength = 2000;

  static const photoMaxBytes = 5 * 1024 * 1024;
  static const videoMaxBytes = 50 * 1024 * 1024;
  static const audioMaxBytes = 10 * 1024 * 1024;

  static const videoMaxSeconds = 30;
  static const audioMaxSeconds = 60;

  static const signedUrlExpirySeconds = 60 * 60;
}

class RoutePaths {
  static const root = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const createCapsule = '/create-capsule';
  static const capsuleCreated = '/capsule-created';
  static const capsuleBase = '/capsule';
  static const profile = '/profile';
}
