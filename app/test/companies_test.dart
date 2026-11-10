import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers.dart';

Map<String, dynamic> _company(String id, String name, {String status = 'unknown'}) => {
  'id': id,
  'name': name,
  'country_code': 'NO',
  'headquarters': null,
  'hiring_status': status,
  'verification_status': 'user_provided',
  'source_url': null,
  'last_verified_at': null,
  'confidence': null,
  'industries': ['krill'],
  'contacts_count': 1,
  'open_vacancies_count': 0,
  'speculative_policy': null,
  'careers_url': null,
  'recruitment_email': null,
  'fleet_summary': null,
  'description': null,
  'latitude': null,
  'longitude': null,
  'websites': [
    {'id': 'w1', 'url': 'https://nordhav.example/', 'kind': 'main'},
  ],
  'sources': [],
  'notes': [],
  'vessels': [],
  'created_at': '2026-11-10T10:00:00Z',
  'updated_at': '2026-11-10T10:00:00Z',
};

void main() {
  testWidgets('duplicate warning offers to open the saved company or create anyway', (tester) async {
    final log = <http.Request>[];
    var attempts = 0;
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) {
        final p = req.url.path;
        if (p == '/api/v1/companies' && req.method == 'POST') {
          attempts++;
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          if (body['allow_duplicate'] != true) {
            return json({
              'detail': {
                'message': 'A similar company already exists',
                'can_override': true,
                'candidates': [
                  {
                    'id': 'c1',
                    'name': 'Nergård AS',
                    'country_code': 'NO',
                    'reason': 'Very similar name',
                    'score': 0.9,
                  },
                ],
              },
            }, 409);
          }
          return json(_company('c2', body['name'] as String), 201);
        }
        if (p == '/api/v1/companies/c2') return json(_company('c2', 'Nergaard'));
        if (p.startsWith('/api/v1/contacts')) return json([]);
        if (p == '/api/v1/companies') return json([]);
        if (p == '/api/v1/companies/duplicates') return json([]);
        return json(emptyDashboard);
      },
    );
    await tapNav(tester, 'Companies');
    expect(find.text('No companies yet'), findsOneWidget);

    await tester.tap(find.text('Add company'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Company name *'), 'Nergaard');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('This company may already exist'), findsOneWidget);
    expect(find.text('Nergård AS (NO)'), findsOneWidget);
    await tester.tap(find.text('Create anyway'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    final second = jsonDecode(log.where((r) => r.method == 'POST').last.body) as Map<String, dynamic>;
    expect(second['allow_duplicate'], isTrue);
    expect(find.text('Nergaard'), findsWidgets); // detail page opened
  });

  testWidgets('company list shows hiring status, counts and filters by status', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) {
        final p = req.url.path;
        if (p == '/api/v1/companies') {
          final status = req.url.queryParameters['hiring_status'];
          final all = [_company('a', 'Aker Test', status: 'actively_hiring'), _company('b', 'Hav Test')];
          return json(status == null ? all : all.where((c) => c['hiring_status'] == status).toList());
        }
        if (p == '/api/v1/companies/duplicates') return json([]);
        return json(emptyDashboard);
      },
    );
    await tapNav(tester, 'Companies');
    expect(find.text('Aker Test'), findsOneWidget);
    expect(find.text('Hav Test'), findsOneWidget);
    expect(find.text('ACTIVELY HIRING'), findsOneWidget);
    expect(find.text('1 contact · 0 open vacancies'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Actively hiring'));
    await tester.pumpAndSettle();
    expect(find.text('Hav Test'), findsNothing);
    expect(log.last.url.queryParameters['hiring_status'], 'actively_hiring');
  });

  testWidgets('website research findings are imported one by one with their source', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) {
        final p = req.url.path;
        if (p == '/api/v1/companies/c1') return json(_company('c1', 'Nordhav'));
        if (p == '/api/v1/discovery/website') {
          return json({
            'start_url': 'https://nordhav.example/',
            'pages_checked': ['https://nordhav.example/', 'https://nordhav.example/careers'],
            'pages_skipped': [],
            'checked_at': '2026-11-10T10:00:00Z',
            'limitations': ['Only 2 page(s) of this website were read.'],
            'findings': [
              {
                'kind': 'email',
                'value': 'crewing@nordhav.example',
                'source_url': 'https://nordhav.example/careers',
                'excerpt': 'Applications: crewing@nordhav.example',
                'hints': {'recruitment_inbox': true, 'generic_inbox': true, 'domain_matches_site': true},
              },
              {
                'kind': 'position_mention',
                'value': 'deckhand',
                'source_url': 'https://nordhav.example/careers',
                'excerpt': 'deckhand',
                'hints': {},
              },
            ],
          });
        }
        if (p == '/api/v1/discovery/import') return json({'kind': 'email'}, 201);
        if (p.startsWith('/api/v1/contacts')) return json([]);
        if (p == '/api/v1/companies') return json([_company('c1', 'Nordhav')]);
        if (p == '/api/v1/companies/duplicates') return json([]);
        return json(emptyDashboard);
      },
    );
    await tapNav(tester, 'Companies');
    await tester.tap(find.text('Nordhav'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Research company website'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'https://nordhav.example/'), findsOneWidget);
    await tester.tap(find.text('Research'));
    await tester.pumpAndSettle();

    expect(find.text('crewing@nordhav.example'), findsOneWidget);
    expect(find.textContaining('Recruitment inbox'), findsOneWidget);
    expect(find.textContaining('NOT VACANCIES'), findsOneWidget);
    // Keyword mentions are not importable; only the e-mail has an Import button.
    expect(find.text('Import'), findsOneWidget);
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    final imported = log.firstWhere((r) => r.url.path == '/api/v1/discovery/import');
    final body = jsonDecode(imported.body) as Map<String, dynamic>;
    expect(body['value'], 'crewing@nordhav.example');
    expect(body['source_url'], 'https://nordhav.example/careers');
    expect(body['company_id'], 'c1');
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
