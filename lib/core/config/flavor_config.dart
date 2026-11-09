/// Application Flavor enumeration
enum AppFlavor {
  dev,
  staging,
  prod,
}

/// Global Flavor Configuration for RxEdge
class FlavorConfig {
  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  /// Initialize the active flavor configuration (called in `main_<flavor>.dart`)
  static void initialize({
    required AppFlavor flavor,
    required String appName,
    required String apiBaseUrl,
    bool enableLogging = true,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      enableLogging: enableLogging,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
  }

  static FlavorConfig get instance {
    if (_instance == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Call FlavorConfig.initialize() before running the app.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;
  static bool get isDev => instance.flavor == AppFlavor.dev;
  static bool get isStaging => instance.flavor == AppFlavor.staging;
  static bool get isProd => instance.flavor == AppFlavor.prod;
}
