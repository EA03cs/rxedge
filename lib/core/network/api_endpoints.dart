/// API Endpoints for RxEdge Backend Services
abstract final class ApiEndpoints {
  // System / App
  static const String appInfo = '/app/info';
  static const String health = '/health';

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Medical Rep Detailing & Products
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
  static String productMonograph(String id) => '/products/$id/monograph';

  // Learning Modules & Quizzes
  static const String modules = '/learning/modules';
  static String moduleDetail(String id) => '/learning/modules/$id';
  static String submitQuiz(String id) => '/learning/modules/$id/quiz';

  // Schedule & Visits
  static const String visits = '/visits';
  static String visitDetail(String id) => '/visits/$id';
  static String submitVisitFeedback(String id) => '/visits/$id/feedback';

  // Challenges & Gamification (Streaks/Badges)
  static const String challenges = '/challenges';
  static const String leaderboard = '/challenges/leaderboard';

  // Notifications
  static const String notifications = '/notifications';
}
