/// All REST API endpoint paths aligned strictly with `D:\Backend\rxedge\src\index.routes.js`.
/// All module paths are relative to `EnvConfig.baseUrl` (`/api/v1`).
abstract final class ApiEndpoints {
  // System / Health
  static const String health = '/health';
  static const String appInfo = '/health';

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String mePreferences = '/auth/me/preferences';
  static const String forgotPassword = '/auth/forgot-password';

  // Dashboard
  static const String homeDashboard = '/dashboard/home';

  // Products & Learn & Competitors
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String productPositioning(String id) => '/products/$id/positioning';

  static const String learnLessons = '/learn/lessons';
  static String learnLessonById(String id) => '/learn/lessons/$id';
  static String completeLesson(String id) => '/learn/lessons/$id/complete';
  static String bookmarkLesson(String id) => '/learn/lessons/$id/bookmark';
  static const String learnProgress = '/learn/progress';

  static const String competitors = '/competitors';
  static String competitorById(String id) => '/competitors/$id';
  static const String objectionOfMonth = '/competitors/objections/month';

  // Media / Library
  static const String mediaUpload = '/media/upload';
  static const String materials = '/media/materials';
  static String materialById(String id) => '/media/materials/$id';

  // Gamification & Challenges
  static const String monthlyChallenge = '/gamification/challenges/monthly';
  static const String leaderboard = '/gamification/challenges/leaderboard';
  static const String quizzes = '/gamification/quizzes';
  static String quizById(String id) => '/gamification/quizzes/$id';
  static String submitQuiz(String id) => '/gamification/quizzes/$id/submit';
  static const String pointsHistory = '/gamification/points/history';

  // Feedback
  static const String feedback = '/feedback';
  static const String myFeedbackSubmissions = '/feedback/my-submissions';
  static String feedbackById(String id) => '/feedback/$id';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationDevices = '/notifications/devices';

  // Sync & Search
  static const String syncManifest = '/sync/manifest';
  static const String search = '/search';
}
