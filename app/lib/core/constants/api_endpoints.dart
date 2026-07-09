/// REST endpoint paths, relative to the API base URL.
class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String me = '/auth/me';

  // Phase 2+
  static const String chat = '/chat';
  static const String upload = '/documents/upload';
  static const String summary = '/documents/summary';
  static const String notes = '/notes';
  static const String tasks = '/tasks';
}
