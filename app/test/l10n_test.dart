import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers.dart';

void main() {
  testWidgets('saved language is used on start (Russian)', (tester) async {
    await pumpApp(tester, auth: FakeAuthService(), prefs: {'app_locale': 'ru'});
    await tester.pumpAndSettle();
    expect(find.text('Главная'), findsWidgets);
    expect(find.text('Компании'), findsWidgets);
    expect(find.text('Проверенные HR-контакты'), findsOneWidget);
  });

  testWidgets('switching language in settings updates the UI and the account', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) => req.url.path == '/health/ready'
          ? json({
              'status': 'ready',
              'environment': 'test',
              'integrations': {'supabase_auth': true},
            })
          : json(emptyDashboard),
    );
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Українська'));
    await tester.pumpAndSettle();

    expect(find.text('Налаштування'), findsOneWidget);
    expect(find.text('Мова'), findsWidgets);
    final patch = log.lastWhere((r) => r.method == 'PATCH');
    expect(patch.url.path, '/api/v1/me');
    expect(jsonDecode(patch.body), {'locale': 'uk'});
  });

  testWidgets('language can be chosen on the login screen', (tester) async {
    await pumpApp(tester, auth: FakeAuthService(signedIn: false));
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Забыли пароль?'), findsOneWidget);
  });

  testWidgets('plural forms follow Russian and Ukrainian rules', (tester) async {
    final company = {
      'id': 'c1',
      'name': 'Test AS',
      'country_code': null,
      'headquarters': null,
      'hiring_status': 'unknown',
      'verification_status': 'user_provided',
      'source_url': null,
      'last_verified_at': null,
      'confidence': null,
      'industries': [],
      'contacts_count': 3,
      'open_vacancies_count': 5,
      'created_at': '2026-11-10T10:00:00Z',
      'updated_at': '2026-11-10T10:00:00Z',
    };
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      prefs: {'app_locale': 'uk'},
      handler: (req) => switch (req.url.path) {
        '/api/v1/companies' => json([company]),
        '/api/v1/companies/duplicates' => json([]),
        _ => json(emptyDashboard),
      },
    );
    await tapNav(tester, 'Компанії');
    expect(find.text('3 контакти · 5 відкритих вакансій'), findsOneWidget);
    expect(find.text('СТАТУС НАЙМУ НЕВІДОМИЙ'), findsOneWidget);
  });
}
