/// Build-time configuration passed with `--dart-define` (see README).
///
/// Only public values belong here (API URL, Supabase URL and publishable key).
/// Server secrets such as the Claude API key never reach the app.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000'),
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabasePublishableKey;

  bool get isAuthConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
