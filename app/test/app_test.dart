import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'helpers.dart';

void main() {
  testWidgets('without Supabase config the setup screen is shown', (tester) async {
    await pumpApp(tester, auth: null);
    expect(find.text('Authentication is not configured'), findsOneWidget);
  });

  testWidgets('signed-out users land on the login screen and can sign in', (tester) async {
    final auth = FakeAuthService(signedIn: false);
    await pumpApp(tester, auth: auth);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'sailor@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('dashboard shows numbers returned by the API with the bearer token', (tester) async {
    final log = <http.Request>[];
    final data = jsonDecode(jsonEncode(emptyDashboard)) as Map<String, dynamic>;
    (data['counts'] as Map)['companies'] = 12;
    (data['counts'] as Map)['interviews'] = 3;
    await pumpApp(tester, auth: FakeAuthService(), log: log, handler: (_) => json(data));

    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(log.first.url.path, '/api/v1/dashboard/summary');
    expect(log.first.headers['Authorization'], 'Bearer test-token');
  });

  testWidgets('network failure shows an error state with retry', (tester) async {
    var fail = true;
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      handler: (_) {
        if (fail) throw http.ClientException('offline');
        return json(emptyDashboard);
      },
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('No connection'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Companies'), findsWidgets);
    expect(find.text('Something went wrong'), findsNothing);
  });

  testWidgets('wide screens use a navigation rail', (tester) async {
    await pumpApp(tester, auth: FakeAuthService(), size: const Size(1400, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('unbuilt modules say which phase they ship in', (tester) async {
    await pumpApp(tester, auth: FakeAuthService());
    await tester.tap(find.text('Mail'));
    await tester.pumpAndSettle();
    expect(find.text('Coming in Phase 5'), findsOneWidget);
  });

  testWidgets('suggested profile is only saved after review, without invented data', (tester) async {
    final log = <http.Request>[];
    await pumpApp(
      tester,
      auth: FakeAuthService(),
      log: log,
      handler: (req) {
        final path = req.url.path;
        if (path == '/api/v1/profiles/primary') return json({'detail': 'No profile yet'}, 404);
        if (path == '/api/v1/profiles' && req.method == 'POST') {
          return json({
            ...jsonDecode(req.body) as Map<String, dynamic>,
            'id': 'p1',
            'is_primary': true,
            'experience': [],
          }, 201);
        }
        if (path == '/api/v1/profiles/p1/experience') return json({'id': 'e1'}, 201);
        return json(emptyDashboard);
      },
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Create your maritime profile'), findsOneWidget);

    await tester.tap(find.text('Review suggested profile'));
    await tester.pumpAndSettle();
    expect(log.where((r) => r.method == 'POST'), isEmpty); // nothing saved yet
    expect(find.text('Ukrainian'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final created = log.firstWhere((r) => r.method == 'POST' && r.url.path == '/api/v1/profiles');
    final body = jsonDecode(created.body) as Map<String, dynamic>;
    expect(body['nationality'], 'Ukrainian');
    expect(body['english_level'], 'intermediate');
    expect(body['target_positions'], contains('Trawl Deckhand'));
    expect(body.containsKey('certificates'), isFalse);

    final vessel = log.firstWhere((r) => r.url.path == '/api/v1/profiles/p1/experience');
    final exp = jsonDecode(vessel.body) as Map<String, dynamic>;
    expect(exp['vessel_name'], 'M/V More Sodruzhestva');
    expect(exp['start_date'], isNull);
    expect(exp['end_date'], isNull);
  });
}
