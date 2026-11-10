/// Build-time configuration passed with `--dart-define` (see README).
///
/// Only public values belong here (API URL, Supabase URL and publishable key).
/// Server secrets such as the Claude API key never reach the app.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.demoMode = false,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000'),
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    demoMode: bool.fromEnvironment('DEMO_MODE'),
  );

  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabasePublishableKey;

  /// Preview build with an in-memory API (see lib/demo). Never enabled by default.
  final bool demoMode;

  bool get isAuthConfigured => supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
