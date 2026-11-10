import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();

  AuthService? auth;
  if (config.isAuthConfigured) {
    await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);
    auth = SupabaseAuthService(Supabase.instance.client);
  }

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config), authServiceProvider.overrideWithValue(auth)],
      child: const SeaSpaceApp(),
    ),
  );
}
