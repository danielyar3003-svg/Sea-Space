import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_service.dart';
import 'config/app_config.dart';
import 'network/api_client.dart';

/// Overridden in `main()` with values read from `--dart-define`.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

/// `null` when Supabase is not configured — the app then shows a setup screen instead
/// of pretending to be connected. Overridden in `main()` and in tests.
final authServiceProvider = Provider<AuthService?>((ref) => null);

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final auth = ref.watch(authServiceProvider);
  return ApiClient(baseUrl: config.apiBaseUrl, tokenProvider: () async => auth?.accessToken());
});
