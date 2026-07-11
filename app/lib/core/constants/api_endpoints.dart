/// REST endpoint paths, relative to the API base URL.
class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
  static const String documents = '/documents';
  static const String upload = '/documents/upload';
  static const String notes = '/notes';
  static const String tasks = '/tasks';

  static String task(int id) => '/tasks/$id';
  static String taskToggle(int id) => '/tasks/$id/toggle';
  static String note(int id) => '/notes/$id';
  static String document(int id) => '/documents/$id';
}
