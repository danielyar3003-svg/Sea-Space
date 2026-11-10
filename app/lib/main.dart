import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/providers.dart';
import 'demo/demo_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();

  AuthService? auth;
  final overrides = [appConfigProvider.overrideWithValue(config)];

  if (config.demoMode) {
    // Preview build: in-memory API, no Supabase, clearly labelled in the UI.
    final demoAuth = DemoAuthService();
    auth = demoAuth;
    overrides.add(
      apiClientProvider.overrideWithValue(
        ApiClient(
          baseUrl: 'http://demo',
          tokenProvider: demoAuth.accessToken,
          httpClient: DemoBackend().client(),
        ),
      ),
    );
  } else if (config.isAuthConfigured) {
    await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);
    auth = SupabaseAuthService(Supabase.instance.client);
  }
  overrides.add(authServiceProvider.overrideWithValue(auth));

  runApp(ProviderScope(overrides: overrides, child: const SeaSpaceApp()));
}
