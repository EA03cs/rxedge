/// Domain and Data Model for Centralized App Settings (`GET /app-settings`).
class AppSettings {
  final bool translationsEnabled;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final DateTime? updatedAt;

  const AppSettings({
    this.translationsEnabled = false,
    this.defaultLanguage = 'en',
    this.supportedLanguages = const ['en'],
    this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final list = json['supportedLanguages'] as List<dynamic>?;
    return AppSettings(
      translationsEnabled: json['translationsEnabled'] as bool? ?? false,
      defaultLanguage: json['defaultLanguage']?.toString() ?? 'en',
      supportedLanguages: list != null
          ? list.map((e) => e.toString()).toList()
          : const ['en'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'translationsEnabled': translationsEnabled,
        'defaultLanguage': defaultLanguage,
        'supportedLanguages': supportedLanguages,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
