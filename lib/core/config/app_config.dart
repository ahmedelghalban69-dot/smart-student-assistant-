class AppConfig {
  static const appName = 'مساعد الطالب الذكي';
  static const version = '2251.0.0';
  static const aiEndpoint = String.fromEnvironment('AI_ENDPOINT', defaultValue: '');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
}
