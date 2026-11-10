import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'network/api_client.dart';
import 'providers.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Languages offered in the app, with their own (not translated) names.
const supportedLanguages = <String, String>{'en': 'English', 'uk': 'Українська', 'ru': 'Русский'};

const _prefsKey = 'app_locale';

/// Selected UI language. `null` means "follow the device language".
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final code = (await SharedPreferences.getInstance()).getString(_prefsKey);
      if (code != null && supportedLanguages.containsKey(code)) state = Locale(code);
    } catch (_) {
      // Storage unavailable (private window, tests): keep the device language.
    }
  }

  Future<void> set(String? code) async {
    state = code == null ? null : Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      code == null ? await prefs.remove(_prefsKey) : await prefs.setString(_prefsKey, code);
    } catch (_) {}
    // Keep the account's language in sync (used later for AI drafts and e-mails).
    if (code != null && ref.read(authServiceProvider)?.isSignedIn == true) {
      try {
        await ref.read(apiClientProvider).patch('/api/v1/me', {'locale': code});
      } on ApiException {
        // Best effort: the choice is still saved on this device.
      }
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// User-facing text for an error, translated where the app knows the cause.
String errorText(BuildContext context, Object error) {
  final l = context.l10n;
  if (error is ApiException) {
    return switch (error.kind) {
      ApiErrorKind.network => l.errorNetwork,
      ApiErrorKind.timeout => l.errorTimeout,
      ApiErrorKind.rateLimited => l.errorRateLimited,
      ApiErrorKind.unauthorized => l.errorSessionExpired,
      ApiErrorKind.server => l.errorServer,
      _ => error.message, // validation / conflict details come from the server (English)
    };
  }
  return error.toString();
}
